import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants.dart';
import '../../../services/providers.dart';

final callHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return [];
  final appwrite = ref.watch(appwriteServiceProvider);
  return await appwrite.getCallHistory(userId);
});

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callHistoryAsync = ref.watch(callHistoryProvider);
    final currentUserIdAsync = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.home),
        ),
        title: const Text('Call History'),
      ),
      body: callHistoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (calls) {
          if (calls.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.call_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No calls yet'),
                ],
              ),
            );
          }

          return currentUserIdAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (currentUserId) {
              if (currentUserId == null) {
                return const Center(child: Text('Please log in'));
              }

return ListView.builder(
                        itemCount: calls.length,
                        itemBuilder: (context, index) {
                          final call = calls[index];
                          final isCaller = call['caller_id'] == currentUserId;
                          final otherName = isCaller 
                              ? (call['callee_name'] ?? call['callee_id'] ?? 'Unknown')
                              : (call['caller_name'] ?? call['caller_id'] ?? 'Unknown');
                  final callType = call['type'] as String? ?? 'voice';
                  final status = call['status'] as String? ?? 'missed';
                  final createdAt = call['created_at'] as String?;
                  final duration = call['duration_seconds'] as int? ?? 0;

                  IconData statusIcon;
                  Color statusColor;

                  switch (status) {
                    case 'answered':
                      statusIcon = Icons.call;
                      statusColor = Colors.green;
                      break;
                    case 'missed':
                      statusIcon = Icons.call_missed;
                      statusColor = Colors.red;
                      break;
                    case 'declined':
                      statusIcon = Icons.call_missed_outgoing;
                      statusColor = Colors.orange;
                      break;
                    default:
                      statusIcon = Icons.call;
                      statusColor = Colors.grey;
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        callType == 'video' ? Icons.videocam : Icons.call,
                      ),
                    ),
                    title: Text(otherName),
                    subtitle: Text(
                      createdAt != null 
                          ? timeago.format(DateTime.tryParse(createdAt) ?? DateTime.now())
                          : 'Unknown time',
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        if (status == 'answered' && duration > 0)
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                    onTap: () {
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }
}