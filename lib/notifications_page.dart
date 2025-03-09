import 'package:flutter/material.dart';
import '../../widgets/gradient_scaffold.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool pushNotifications = true;
  bool emailNotifications = false;
  bool reminders = true;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Notifications & Reminders',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Notifications',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Push Notifications',
              value: pushNotifications,
              onChanged: (val) => setState(() => pushNotifications = val),
            ),
            _buildSwitchTile(
              title: 'Email Notifications',
              value: emailNotifications,
              onChanged: (val) => setState(() => emailNotifications = val),
            ),
            _buildSwitchTile(
              title: 'Reminders',
              value: reminders,
              onChanged: (val) => setState(() => reminders = val),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Save Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blueAccent,
      ),
    );
  }
}