import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.settings),
        ),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms & Conditions',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Last updated: May 2026',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 24),
            Text(
              'Acceptance of Terms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'By using VardChat, you agree to these terms and conditions. If you do not agree to these terms, please do not use the app.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Use of Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'VardChat is provided for private, personal communication. You agree to use the app only for lawful purposes.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'User Responsibilities',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• You are responsible for keeping your unique ID secure\n'
              '• You must not attempt to hack, reverse engineer, or disrupt the service\n'
              '• You must not use the app for any illegal activities\n'
              '• You must not harass, threaten, or impersonate others',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Service Limitations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'VardChat is provided "as is" without any warranties. We do not guarantee that the service will be always available or error-free.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Changes to Terms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We may update these terms from time to time. Continued use of the app after changes constitutes acceptance of the new terms.',
              style: TextStyle(height: 1.5),
            ),
            SizedBox(height: 16),
            Text(
              'Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'For questions about these terms, please contact us through the app.',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}