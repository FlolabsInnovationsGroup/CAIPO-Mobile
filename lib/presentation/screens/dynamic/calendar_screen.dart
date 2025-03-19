import 'package:flutter/material.dart';
import 'base_dynamic_screen.dart';

class CalendarScreen extends BaseDynamicScreen {
  const CalendarScreen({
    super.key,
    required super.command,
    super.commandData,
  });

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends BaseDynamicScreenState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  // Mock data
  final List<Map<String, dynamic>> _events = [
    {
      'title': 'Team Meeting',
      'time': '10:00 AM',
      'duration': '1h',
      'location': 'Conference Room A',
      'isCompleted': false,
    },
    {
      'title': 'Lunch with Client',
      'time': '12:30 PM',
      'duration': '1h 30m',
      'location': 'Restaurant',
      'isCompleted': false,
    },
    {
      'title': 'Project Review',
      'time': '3:00 PM',
      'duration': '2h',
      'location': 'Virtual Meeting',
      'isCompleted': false,
    },
  ];

  final List<Map<String, dynamic>> _reminders = [
    {
      'title': 'Take medication',
      'time': '9:00 AM',
      'isCompleted': false,
    },
    {
      'title': 'Call mom',
      'time': '5:00 PM',
      'isCompleted': false,
    },
  ];

  @override
  void setupBackgroundAnimation() {
    backgroundStartAnimation = ColorTween(
      begin: const Color(0xFF00BCD4), // Cyan for calendar
      end: const Color(0xFF4DD0E1),
    ).animate(backgroundController);

    backgroundEndAnimation = ColorTween(
      begin: const Color(0xFF4DD0E1),
      end: const Color(0xFF00BCD4),
    ).animate(backgroundController);
  }

  Widget _buildCalendar() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.subtract(const Duration(days: 1));
                    });
                  },
                ),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _selectedDate =
                          _selectedDate.add(const Duration(days: 1));
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._events.map((event) => _buildEventTile(event)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminders() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reminders',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ..._reminders.map((reminder) => _buildReminderTile(reminder)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    return ListTile(
      leading: Container(
        width: 4,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      title: Text(
        event['title'],
        style: TextStyle(
          decoration: event['isCompleted'] ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(
          '${event['time']} • ${event['duration']} • ${event['location']}'),
      trailing: Checkbox(
        value: event['isCompleted'],
        onChanged: (value) {
          setState(() {
            event['isCompleted'] = value;
          });
        },
      ),
    );
  }

  Widget _buildReminderTile(Map<String, dynamic> reminder) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: Text(
        reminder['title'],
        style: TextStyle(
          decoration:
              reminder['isCompleted'] ? TextDecoration.lineThrough : null,
        ),
      ),
      subtitle: Text(reminder['time']),
      trailing: Checkbox(
        value: reminder['isCompleted'],
        onChanged: (value) {
          setState(() {
            reminder['isCompleted'] = value;
          });
        },
      ),
    );
  }

  @override
  Widget buildScreenContent(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Calendar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () {
                    // Implement add new event/reminder
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCalendar(),
                    const SizedBox(height: 24),
                    _buildReminders(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
