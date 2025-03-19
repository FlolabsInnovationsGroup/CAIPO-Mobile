import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;
import 'package:permission_handler/permission_handler.dart';

class BluetoothService extends ChangeNotifier {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  bool _isScanning = false;
  bool get isScanning => _isScanning;

  blue.BluetoothDevice? _connectedDevice;
  blue.BluetoothDevice? get connectedDevice => _connectedDevice;

  final List<blue.BluetoothDevice> _discoveredDevices = [];
  List<blue.BluetoothDevice> get discoveredDevices =>
      List.unmodifiable(_discoveredDevices);

  // Stream controllers
  final _deviceStateController =
      StreamController<blue.BluetoothConnectionState>.broadcast();
  Stream<blue.BluetoothConnectionState> get deviceStateStream =>
      _deviceStateController.stream;

  final _activityDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get activityDataStream =>
      _activityDataController.stream;

  // Initialize Bluetooth service
  Future<void> initialize() async {
    await _checkPermissions();
    await _setupBluetoothState();
  }

  // Check and request necessary permissions
  Future<void> _checkPermissions() async {
    if (await Permission.bluetooth.isDenied) {
      await Permission.bluetooth.request();
    }
    if (await Permission.bluetoothScan.isDenied) {
      await Permission.bluetoothScan.request();
    }
    if (await Permission.bluetoothConnect.isDenied) {
      await Permission.bluetoothConnect.request();
    }
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }
  }

  // Setup Bluetooth state monitoring
  Future<void> _setupBluetoothState() async {
    blue.FlutterBluePlus.adapterState.listen((state) {
      if (state == blue.BluetoothAdapterState.off) {
        disconnect();
      }
    });
  }

  // Start scanning for devices
  Future<void> startScan() async {
    if (_isScanning) return;

    _discoveredDevices.clear();
    _isScanning = true;
    notifyListeners();

    try {
      blue.FlutterBluePlus.scanResults.listen((results) {
        for (blue.ScanResult result in results) {
          if (!_discoveredDevices.contains(result.device) &&
              result.device.name.isNotEmpty) {
            _discoveredDevices.add(result.device);
            notifyListeners();
          }
        }
      });

      await blue.FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 10),
        androidUsesFineLocation: true,
      );
    } catch (e) {
      debugPrint('Error scanning for devices: $e');
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  // Connect to a device
  Future<bool> connect(blue.BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;

      // Setup state monitoring
      device.connectionState.listen((state) {
        _deviceStateController.add(state);
        if (state == blue.BluetoothConnectionState.disconnected) {
          _connectedDevice = null;
        }
        notifyListeners();
      });

      // Discover services
      await _discoverServices(device);
      return true;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      return false;
    }
  }

  // Discover device services
  Future<void> _discoverServices(blue.BluetoothDevice device) async {
    try {
      List<blue.BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        // Look for specific service UUIDs for activity tracking
        if (service.uuid.toString().toUpperCase().startsWith('180D')) {
          // Heart Rate Service
          _setupHeartRateNotifications(service);
        }
        // Add more service checks as needed
      }
    } catch (e) {
      debugPrint('Error discovering services: $e');
    }
  }

  // Setup heart rate notifications
  void _setupHeartRateNotifications(blue.BluetoothService service) {
    var characteristic = service.characteristics.firstWhere(
      (c) => c.uuid.toString().toUpperCase().startsWith('2A37'),
      orElse: () => throw Exception('Heart rate characteristic not found'),
    );

    characteristic.setNotifyValue(true);
    characteristic.value.listen((value) {
      if (value.isNotEmpty) {
        int heartRate = value[1];
        _activityDataController.add({'heartRate': heartRate});
      }
    });
  }

  // Disconnect from current device
  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      try {
        await _connectedDevice!.disconnect();
      } catch (e) {
        debugPrint('Error disconnecting from device: $e');
      }
      _connectedDevice = null;
      notifyListeners();
    }
  }

  // Clean up resources
  @override
  void dispose() {
    disconnect();
    _deviceStateController.close();
    _activityDataController.close();
    super.dispose();
  }
}
