import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WearableCommand {
  startAudioRecording,
  stopAudioRecording,
  startVideoRecording,
  stopVideoRecording,
  captureImage,
  getStatus,
  getBatteryLevel,
}

enum WearableStatus {
  connected,
  disconnected,
  recording,
  error,
}

class WearableService {
  static const String _lastDeviceKey = 'last_wearable_ip';
  static const Duration _connectionTimeout = Duration(seconds: 5);
  static const Duration _reconnectInterval = Duration(seconds: 30);
  
  String? _deviceIP;
  WebSocketChannel? _wsChannel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  final StreamController<WearableStatus> _statusController = StreamController<WearableStatus>.broadcast();
  final StreamController<Map<String, dynamic>> _dataController = StreamController<Map<String, dynamic>>.broadcast();

  // Singleton pattern
  static final WearableService _instance = WearableService._internal();
  factory WearableService() => _instance;
  WearableService._internal();

  // Public streams and getters
  Stream<WearableStatus> get statusStream => _statusController.stream;
  Stream<Map<String, dynamic>> get dataStream => _dataController.stream;
  bool get isConnected => _wsChannel != null;
  String? get deviceIP => _deviceIP;

  // Initialize the service
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final lastIP = prefs.getString(_lastDeviceKey);
    
    if (lastIP != null) {
      await connectToDevice(lastIP);
    }
  }

  // Connect to device by IP
  Future<bool> connectToDevice(String ip) async {
    try {
      // Test HTTP connection first
      final response = await http.get(Uri.parse('http://$ip/status'))
          .timeout(_connectionTimeout);
      
      if (response.statusCode != 200) {
        throw Exception('Device not responding');
      }

      // If HTTP successful, establish WebSocket
      final wsUrl = 'ws://$ip/ws';
      _wsChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Start listening for messages
      _wsChannel!.stream.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) => _handleConnectionError(error),
        onDone: () => _handleDisconnect(),
      );

      // Save device IP
      _deviceIP = ip;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastDeviceKey, ip);

      // Start heartbeat
      _startHeartbeat();
      
      _statusController.add(WearableStatus.connected);
      return true;
    } catch (e) {
      print('Connection error: $e');
      _handleConnectionError(e);
      return false;
    }
  }

  // Send command to device
  Future<Map<String, dynamic>> sendCommand(WearableCommand command, [Map<String, dynamic>? params]) async {
    if (!isConnected) {
      throw Exception('Device not connected');
    }

    final commandMap = {
      'command': command.toString().split('.').last,
      'params': params ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      // Send command via WebSocket
      _wsChannel!.sink.add(jsonEncode(commandMap));
      
      // For commands that need immediate HTTP response
      if (command == WearableCommand.captureImage) {
        final response = await http.get(
          Uri.parse('http://$_deviceIP/capture'),
        ).timeout(_connectionTimeout);
        
        if (response.statusCode == 200) {
          return {'success': true, 'data': response.body};
        }
      }
      
      return {'success': true};
    } catch (e) {
      print('Command error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Start recording
  Future<bool> startRecording({bool isVideo = false}) async {
    try {
      final command = isVideo 
          ? WearableCommand.startVideoRecording 
          : WearableCommand.startAudioRecording;
          
      final result = await sendCommand(command);
      return result['success'] ?? false;
    } catch (e) {
      print('Recording error: $e');
      return false;
    }
  }

  // Stop recording
  Future<Map<String, dynamic>> stopRecording({bool isVideo = false}) async {
    try {
      final command = isVideo 
          ? WearableCommand.stopVideoRecording 
          : WearableCommand.stopAudioRecording;
          
      return await sendCommand(command);
    } catch (e) {
      print('Stop recording error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get device status
  Future<Map<String, dynamic>> getDeviceStatus() async {
    try {
      final response = await http.get(
        Uri.parse('http://$_deviceIP/status'),
      ).timeout(_connectionTimeout);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to get status');
    } catch (e) {
      print('Status error: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  // Private methods
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => sendCommand(WearableCommand.getStatus),
    );
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message);
      _dataController.add(data);
    } catch (e) {
      print('Message parsing error: $e');
    }
  }

  void _handleConnectionError(dynamic error) {
    print('Connection error: $error');
    _statusController.add(WearableStatus.error);
    _initiateReconnection();
  }

  void _handleDisconnect() {
    _wsChannel?.sink.close();
    _wsChannel = null;
    _statusController.add(WearableStatus.disconnected);
    _initiateReconnection();
  }

  void _initiateReconnection() {
    if (_deviceIP != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer.periodic(
        _reconnectInterval,
        (_) async {
          if (!isConnected) {
            await connectToDevice(_deviceIP!);
          }
        },
      );
    }
  }

  // Cleanup
  void dispose() {
    _wsChannel?.sink.close();
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _statusController.close();
    _dataController.close();
  }
} 