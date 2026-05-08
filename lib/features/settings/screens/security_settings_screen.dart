import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';

class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.settings),
        ),
        title: const Text('Security'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.security, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'End-to-End Encrypted',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Text(
              'VardChat uses end-to-end encryption to protect your messages. This means only you and the recipient can read your messages - not even we can access them.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            _SecurityItem(
              icon: Icons.lock,
              title: 'Your Messages are Private',
              description: 'All messages are encrypted on your device before being sent.',
            ),
            _SecurityItem(
              icon: Icons.key,
              title: 'Secure Key Storage',
              description: 'Your encryption keys are stored securely on your device.',
            ),
            _SecurityItem(
              icon: Icons.cloud_off,
              title: 'No Message Storage',
              description: 'We do not store or access your message content on our servers.',
            ),
            _SecurityItem(
              icon: Icons.warning_amber,
              title: 'Important',
              description: 'If you reinstall the app, your previous messages cannot be recovered because your unique encryption key is stored only on this device.',
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SecurityItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}