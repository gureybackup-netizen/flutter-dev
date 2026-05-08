import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';

class ActiveCallScreen extends ConsumerWidget {
  final String callId;
  const ActiveCallScreen({super.key, required this.callId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'In Call',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const Text(
              '00:00',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.mic_off, color: Colors.white, size: 32),
                  onPressed: () {},
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red, size: 48),
                  onPressed: () => context.go(RouteConstants.conversations),
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}