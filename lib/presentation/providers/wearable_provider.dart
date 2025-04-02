import 'package:flutter/foundation.dart';
import '../../core/wearable/wearable_service.dart';
import '../../di/injection.dart';

class WearableProvider with ChangeNotifier {
  final WearableService _wearableService;
  
  WearableStatus _status = WearableStatus.disconnected;
  Map<String, dynamic> _lastData = {};
  List<Map<String, dynamic>> _dataHistory = [];
  static const int maxHistoryLength = 100;  // Keep last 100 data points for charting

  bool _isConnected = false;
  int _batteryLevel = 100;
  String? _lastStatus;

  WearableProvider() : _wearableService = getIt<WearableService>() {
    _initializeListeners();
    _wearableService.initialize();
  }

  // Public getters
  WearableStatus get status => _status;
  Map<String, dynamic> get lastData => _lastData;
  List<Map<String, dynamic>> get dataHistory => _dataHistory;
  Stream<WearableStatus> get statusStream => _wearableService.statusStream;
  Stream<Map<String, dynamic>> get dataStream => _wearableService.dataStream;
  bool get isConnected => _isConnected;
  String? get deviceIP => _wearableService.deviceIP;
  int get batteryLevel => _batteryLevel;
  String? get lastStatus => _lastStatus;

  void _initializeListeners() {
    _wearableService.statusStream.listen((status) {
      _status = status;
      notifyListeners();
    });

    _wearableService.dataStream.listen((data) {
      _lastData = data;
      _dataHistory.add(data);
      if (_dataHistory.length > maxHistoryLength) {
        _dataHistory.removeAt(0);
      }
      notifyListeners();
    });
  }

  // Public methods that mirror WearableService
  Future<bool> connectToDevice(String ip) async {
    return await _wearableService.connectToDevice(ip);
  }

  Future<Map<String, dynamic>> getDeviceStatus() async {
    return await _wearableService.getDeviceStatus();
  }

  Future<bool> startRecording({bool isVideo = false}) async {
    return await _wearableService.startRecording(isVideo: isVideo);
  }

  Future<Map<String, dynamic>> stopRecording({bool isVideo = false}) async {
    return await _wearableService.stopRecording(isVideo: isVideo);
  }

  Future<Map<String, dynamic>> captureImage() async {
    return await _wearableService.sendCommand(WearableCommand.captureImage);
  }

  Future<Map<String, dynamic>> getBatteryLevel() async {
    return await _wearableService.sendCommand(WearableCommand.getBatteryLevel);
  }

  // Update connection status
  void updateConnectionStatus(bool connected) {
    _isConnected = connected;
    notifyListeners();
  }

  // Update battery level
  void updateBatteryLevel(int level) {
    _batteryLevel = level;
    notifyListeners();
  }

  // Update device status
  void updateStatus(String status) {
    _lastStatus = status;
    notifyListeners();
  }

  // Clean up
  @override
  void dispose() {
    // No need to call disconnect as the service manages its own connection
    super.dispose();
  }
} 