import 'package:flutter/material.dart';

class AdvancedSettingsPage extends StatefulWidget {
  const AdvancedSettingsPage({super.key});

  @override
  _AdvancedSettingsPageState createState() => _AdvancedSettingsPageState();
}

class _AdvancedSettingsPageState extends State<AdvancedSettingsPage> {
  bool developerMode = false;
  bool betaFeatures = false;
  bool enableLogs = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Settings',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Developer Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Enable Developer Mode',
              description: 'Access debugging tools and experimental features.',
              value: developerMode,
              onChanged: (val) => setState(() => developerMode = val),
            ),
            _buildSwitchTile(
              title: 'Enable Beta Features',
              description: 'Try out upcoming features before they are released.',
              value: betaFeatures,
              onChanged: (val) => setState(() => betaFeatures = val),
            ),
            _buildSwitchTile(
              title: 'Enable Debug Logs',
              description: 'Log errors and diagnostic information for troubleshooting.',
              value: enableLogs,
              onChanged: (val) => setState(() => enableLogs = val),
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

  Widget _buildSwitchTile({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        subtitle: Text(description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
        ),
      ),
    );
  }
}
