import 'package:flutter/material.dart';
import 'activity_screen.dart';
import 'music_screen.dart';
import 'calendar_screen.dart';
import 'transcription_screen.dart';
import 'base_dynamic_screen.dart';

enum CommandType {
  activity,
  transcription,
  music,
  calendar,
  chat,
}

class ScreenManager {
  static BaseDynamicScreen getScreenForCommand(String command) {
    // Parse command to determine screen type
    CommandType type = _parseCommand(command);
    
    // Return appropriate screen based on command type
    switch (type) {
      case CommandType.activity:
        return ActivityScreen(
          command: command,
          commandData: null,
        );
      case CommandType.transcription:
        return TranscriptionScreen(
          command: command,
          commandData: null,
        );
      case CommandType.music:
        return MusicScreen(
          command: command,
          commandData: null,
        );
      case CommandType.calendar:
        return CalendarScreen(
          command: command,
          commandData: null,
        );
      case CommandType.chat:
        // Return chat screen (to be implemented)
        throw UnimplementedError('Chat screen not yet implemented');
    }
  }

  static CommandType _parseCommand(String command) {
    command = command.toLowerCase();
    
    // Activity commands
    if (command.contains('exercise') ||
        command.contains('steps') ||
        command.contains('calories') ||
        command.contains('heart rate')) {
      return CommandType.activity;
    }
    
    // Transcription commands
    if (command.contains('transcribe') ||
        command.contains('record') ||
        command.contains('write this down')) {
      return CommandType.transcription;
    }
    
    // Music commands
    if (command.contains('play') ||
        command.contains('music') ||
        command.contains('song') ||
        command.contains('playlist')) {
      return CommandType.music;
    }
    
    // Calendar commands
    if (command.contains('schedule') ||
        command.contains('calendar') ||
        command.contains('reminder') ||
        command.contains('event')) {
      return CommandType.calendar;
    }
    
    // Default to chat
    return CommandType.chat;
  }
}

class DynamicScreenContainer extends StatefulWidget {
  final String initialCommand;

  const DynamicScreenContainer({
    super.key,
    required this.initialCommand,
  });

  @override
  DynamicScreenContainerState createState() => DynamicScreenContainerState();
}

class DynamicScreenContainerState extends State<DynamicScreenContainer> {
  late BaseDynamicScreen _currentScreen;

  @override
  void initState() {
    super.initState();
    _currentScreen = ScreenManager.getScreenForCommand(widget.initialCommand);
  }

  void handleNewCommand(String command) {
    setState(() {
      _currentScreen = ScreenManager.getScreenForCommand(command);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _currentScreen,
    );
  }
}

class DynamicScreenManager {
  static BaseDynamicScreen? getScreenForCommand(String command, {dynamic commandData}) {
    final lowercaseCommand = command.toLowerCase();
    
    if (lowercaseCommand.contains('activity') || 
        lowercaseCommand.contains('steps') || 
        lowercaseCommand.contains('fitness')) {
      return ActivityScreen(command: command, commandData: commandData);
    }
    
    if (lowercaseCommand.contains('music') || 
        lowercaseCommand.contains('play') || 
        lowercaseCommand.contains('song')) {
      return MusicScreen(command: command, commandData: commandData);
    }
    
    if (lowercaseCommand.contains('calendar') || 
        lowercaseCommand.contains('schedule') || 
        lowercaseCommand.contains('events')) {
      return CalendarScreen(command: command, commandData: commandData);
    }
    
    if (lowercaseCommand.contains('transcribe') || 
        lowercaseCommand.contains('transcription')) {
      return TranscriptionScreen(command: command, commandData: commandData);
    }
    
    return null;
  }
} 