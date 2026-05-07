import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/providers.dart';
import '../../../core/constants.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.settings),
        ),
        title: const Text('Notifications'),
      ),
      body: currentUserAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not logged in'));
          }

          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Message Notifications'),
                subtitle: const Text('Receive notifications for new messages'),
                value: user.notificationsEnabled,
                onChanged: (value) async {
                  final userService = ref.read(userServiceProvider);
                  await userService.updateNotificationsEnabled(user.id, value);
                  ref.invalidate(currentUserProvider);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}