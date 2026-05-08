import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';

class OutgoingCallScreen extends ConsumerWidget {
  final String callId;
  const OutgoingCallScreen({super.key, required this.callId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            const Text(
              'Calling...',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.call_end, color: Colors.red, size: 40),
                  onPressed: () => context.go(RouteConstants.conversations),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}