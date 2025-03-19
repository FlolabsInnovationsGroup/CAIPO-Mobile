import '../../presentation/screens/dynamic/activity_screen.dart';
import '../../presentation/screens/dynamic/music_screen.dart';
import '../../presentation/screens/dynamic/calendar_screen.dart';
import '../../presentation/screens/dynamic/transcription_screen.dart';
import '../../presentation/screens/dynamic/base_dynamic_screen.dart';

class DynamicScreenManager {
  static BaseDynamicScreen? getScreenForCommand(String command,
      {dynamic commandData}) {
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
