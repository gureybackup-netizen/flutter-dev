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
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text('In Call'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.mic_off, color: Colors.white),
                    iconSize: 32,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.videocam_off, color: Colors.white),
                    iconSize: 32,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_android, color: Colors.white),
                    iconSize: 32,
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_end, color: Colors.red),
                    iconSize: 48,
                    onPressed: () => context.go(RouteConstants.conversations),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}