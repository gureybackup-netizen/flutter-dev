import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/providers.dart';
import '../../../core/constants.dart';

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsAsync = ref.watch(callsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.conversations),
        ),
        title: const Text('Call History'),
      ),
      body: callsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (calls) {
          if (calls.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No call history'),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: calls.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final call = calls[index];
              final isCaller = call.callerId == currentUserId;
              final otherUsername = isCaller 
                  ? call.calleeUid 
                  : call.callerUsername;
              final statusIcon = switch (call.status) {
                'active' => Icons.check_circle,
                'missed' => Icons.missed_video_call,
                'declined' => Icons.cancel,
                _ => Icons.call_missed,
              };
              final statusColor = call.status == 'active' ? Colors.green : Colors.red;

              return ListTile(
                leading: Icon(
                  call.type == 'video' ? Icons.videocam : Icons.call,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(otherUsername),
                subtitle: Text(
                  '${call.type} • ${timeago.format(call.createdAt)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (call.durationSeconds != null && call.durationSeconds! > 0)
                      Text(call.formattedDuration),
                    const SizedBox(width: 8),
                    Icon(statusIcon, color: statusColor, size: 20),
                  ],
                ),
                onTap: () {},
              );
            },
          );
        },
      ),
    );
  }
}