import 'package:flutter/material.dart';

class AboutSupportPage extends StatelessWidget {
  const AboutSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Support', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
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
              'About CAIPO AI Companion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'CAIPO is your AI-powered assistant designed to help streamline tasks, provide insights, and improve productivity.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildFAQItem(
              question: 'How does CAIPO work?',
              answer: 'CAIPO uses AI to process and understand your queries in real-time.',
            ),
            _buildFAQItem(
              question: 'Is my data secure?',
              answer: 'Yes, your interactions are private and encrypted.',
            ),
            _buildFAQItem(
              question: 'How do I contact support?',
              answer: 'You can contact support using the button below.',
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Placeholder for support action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Contact Support',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}