import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/providers.dart';
import '../../../core/constants.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.conversations),
        ),
        title: const Text('Settings'),
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
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                subtitle: Text(user.displayName),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(RouteConstants.profileSettings),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: user.notificationsEnabled,
                  onChanged: (value) async {
                    final userService = ref.read(userServiceProvider);
                    await userService.updateNotificationsEnabled(user.id, value);
                    ref.invalidate(currentUserProvider);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('Light Mode'),
                trailing: Switch(
                  value: user.themePreference == 'light',
                  onChanged: (value) async {
                    final userService = ref.read(userServiceProvider);
                    await userService.updateThemePreference(
                      user.id,
                      value ? 'light' : 'dark',
                    );
                    ref.read(themeProvider.notifier).state = value ? 'light' : 'dark';
                    ref.invalidate(currentUserProvider);
                  },
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Security'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(RouteConstants.securitySettings),
              ),
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
                title: Text(
                  'Log Out',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Log Out'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final authService = ref.read(authServiceProvider);
                    await authService.logout();
                    if (context.mounted) {
                      context.go(RouteConstants.welcome);
                    }
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}