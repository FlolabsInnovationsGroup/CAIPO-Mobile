import 'package:flutter/material.dart';
import 'base_dynamic_screen.dart';
import '../../../data/services/bluetooth_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as blue;

class ActivityScreen extends BaseDynamicScreen {
  const ActivityScreen({
    super.key,
    required super.command,
    super.commandData,
  });

  @override
  ActivityScreenState createState() => ActivityScreenState();
}

class ActivityScreenState extends BaseDynamicScreenState<ActivityScreen> {
  final BluetoothService _bluetoothService = BluetoothService();
  
  // Activity metrics
  int _steps = 0;
  int _caloriesBurned = 0;
  int _heartRate = 0;
  double _distance = 0.0;

  bool _isConnecting = false;
  String _connectionStatus = 'Not Connected';

  @override
  void initState() {
    super.initState();
    _initializeBluetoothService();
    _setupActivityDataListener();
  }

  Future<void> _initializeBluetoothService() async {
    await _bluetoothService.initialize();
    _bluetoothService.deviceStateStream.listen((state) {
      setState(() {
        switch (state) {
          case blue.BluetoothConnectionState.connected:
            _connectionStatus = 'Connected';
            break;
          case blue.BluetoothConnectionState.disconnected:
            _connectionStatus = 'Disconnected';
            break;
          case blue.BluetoothConnectionState.connecting:
            _connectionStatus = 'Connecting...';
            break;
          default:
            _connectionStatus = 'Not Connected';
        }
      });
    });
  }

  void _setupActivityDataListener() {
    _bluetoothService.activityDataStream.listen((data) {
      setState(() {
        if (data.containsKey('heartRate')) {
          _heartRate = data['heartRate'];
        }
        if (data.containsKey('steps')) {
          _steps = data['steps'];
        }
        if (data.containsKey('calories')) {
          _caloriesBurned = data['calories'];
        }
        if (data.containsKey('distance')) {
          _distance = data['distance'];
        }
      });
    });
  }

  Future<void> _scanAndConnect() async {
    if (_isConnecting) return;

    setState(() {
      _isConnecting = true;
      _connectionStatus = 'Scanning...';
    });

    await _bluetoothService.startScan();

    if (_bluetoothService.discoveredDevices.isNotEmpty) {
      // Connect to the first available device
      // In a production app, you'd want to let the user choose
      final device = _bluetoothService.discoveredDevices.first;
      await _bluetoothService.connect(device);
    }

    setState(() {
      _isConnecting = false;
    });
  }

  @override
  void setupBackgroundAnimation() {
    backgroundStartAnimation = ColorTween(
      begin: const Color(0xFF4CAF50),
      end: const Color(0xFF81C784),
    ).animate(backgroundController);

    backgroundEndAnimation = ColorTween(
      begin: const Color(0xFF81C784),
      end: const Color(0xFF4CAF50),
    ).animate(backgroundController);
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _bluetoothService.connectedDevice != null
                ? Icons.bluetooth_connected
                : Icons.bluetooth_disabled,
            color: _bluetoothService.connectedDevice != null
                ? Colors.green
                : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(_connectionStatus),
          const SizedBox(width: 16),
          if (_bluetoothService.connectedDevice == null)
            ElevatedButton.icon(
              onPressed: _isConnecting ? null : _scanAndConnect,
              icon: const Icon(Icons.search),
              label: Text(_isConnecting ? 'Scanning...' : 'Scan for Devices'),
            ),
        ],
      ),
    );
  }

  @override
  Widget buildScreenContent(BuildContext context) {
    return Column(
      children: [
        _buildConnectionStatus(),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _buildMetricCard(
                title: 'Steps',
                value: _steps.toString(),
                unit: 'steps',
                icon: Icons.directions_walk,
              ),
              _buildMetricCard(
                title: 'Calories',
                value: _caloriesBurned.toString(),
                unit: 'kcal',
                icon: Icons.local_fire_department,
              ),
              _buildMetricCard(
                title: 'Heart Rate',
                value: _heartRate.toString(),
                unit: 'bpm',
                icon: Icons.favorite,
              ),
              _buildMetricCard(
                title: 'Distance',
                value: _distance.toStringAsFixed(2),
                unit: 'km',
                icon: Icons.map,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _bluetoothService.disconnect();
    super.dispose();
  }
} 