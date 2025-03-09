import 'package:flutter/material.dart';
import '../../widgets/gradient_scaffold.dart';

class AIPreferencesPage extends StatefulWidget {
  const AIPreferencesPage({super.key});

  @override
  _AIPreferencesPageState createState() => _AIPreferencesPageState();
}

class _AIPreferencesPageState extends State<AIPreferencesPage> {
  bool adaptiveResponses = true;
  bool voiceFeedback = false;
  double responseSpeed = 0.5;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('AI Preferences',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
              'Customize AI Interaction',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white, // Added for better visibility on gradient
              ),
            ),
            const SizedBox(height: 12),
            _buildSwitchTile(
              title: 'Adaptive Responses',
              value: adaptiveResponses,
              onChanged: (val) => setState(() => adaptiveResponses = val),
            ),
            _buildSwitchTile(
              title: 'Voice Feedback',
              value: voiceFeedback,
              onChanged: (val) => setState(() => voiceFeedback = val),
            ),
            const SizedBox(height: 16),
            const Text(
              'Response Speed',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w500,
                color: Colors.white, // Added for better visibility on gradient
              ),
            ),
            Slider(
              value: responseSpeed,
              min: 0.1,
              max: 1.0,
              divisions: 9,
              label: "${(responseSpeed * 100).toInt()}%",
              onChanged: (value) {
                setState(() => responseSpeed = value);
              },
              activeColor: Colors.blueAccent,
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