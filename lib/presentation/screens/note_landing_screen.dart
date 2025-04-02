import 'package:flutter/material.dart';
import '../widgets/wearable_status_chart.dart';

class NoteLandingScreen extends StatefulWidget {
  const NoteLandingScreen({Key? key}) : super(key: key);

  @override
  State<NoteLandingScreen> createState() => _NoteLandingScreenState();
}

class _NoteLandingScreenState extends State<NoteLandingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: WearableStatusChart(),
          ),
          Expanded(
            child: ListView(
              children: const [],  // Your existing note list items will go here
            ),
          ),
        ],
      ),
    );
  }
} 