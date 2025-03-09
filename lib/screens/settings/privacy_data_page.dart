import 'package:flutter/material.dart';
import '../../widgets/gradient_scaffold.dart';

class PrivacyDataPage extends StatefulWidget {
  const PrivacyDataPage({super.key});

  @override
  _PrivacyDataPageState createState() => _PrivacyDataPageState();
}

class _PrivacyDataPageState extends State<PrivacyDataPage> {
  bool dataSharing = false;
  bool personalizedAds = true;
  bool locationAccess = false;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Privacy & Data',
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
              'Manage Your Data Preferences',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Allow Data Sharing',
              description: 'Share anonymous data to improve services.',
              value: dataSharing,
              onChanged: (val) => setState(() => dataSharing = val),
            ),
            _buildSwitchTile(
              title: 'Personalized Ads',
              description: 'Receive ads based on your preferences.',
              value: personalizedAds,
              onChanged: (val) => setState(() => personalizedAds = val),
            ),
            _buildSwitchTile(
              title: 'Location Access',
              description: 'Allow access to your location for better recommendations.',
              value: locationAccess,
              onChanged: (val) => setState(() => locationAccess = val),
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