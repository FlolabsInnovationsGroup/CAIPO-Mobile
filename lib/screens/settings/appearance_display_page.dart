import 'package:flutter/material.dart';
import '../../widgets/gradient_scaffold.dart';

class AppearanceDisplayPage extends StatefulWidget {
  const AppearanceDisplayPage({super.key});

  @override
  _AppearanceDisplayPageState createState() => _AppearanceDisplayPageState();
}

class _AppearanceDisplayPageState extends State<AppearanceDisplayPage> {
  double textScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Appearance & Display',
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
              'Customize Your Appearance',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Colors.white
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Text Size',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            Slider(
              value: textScale,
              min: 0.8,
              max: 1.5,
              divisions: 7,
              label: "${(textScale * 100).toInt()}%",
              onChanged: (value) {
                setState(() => textScale = value);
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
}