import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants.dart';
import '../../services/providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserIdAsync = ref.watch(currentUserIdProvider);
    final conversationsAsync = ref.watch(conversationsProvider);
    final callHistoryAsync = ref.watch(callHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.home),
        ),
        title: const Text('Notifications'),
      ),
      body: currentUserIdAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (currentUserId) {
          if (currentUserId == null) {
            return const Center(child: Text('Please log in'));
          }

          return conversationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
            data: (conversations) {
              return callHistoryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Center(child: Text('Error: $e')),
                data: (calls) {
                  // Combine recent messages and calls
                  final items = <Map<String, dynamic>>[];
                  
                  // Add recent messages (from conversations)
                  for (final conv in conversations.take(10)) {
                    items.add({
                      'type': 'message',
                      'title': conv['participant_display_names']?[currentUserId] ?? 'Unknown',
                      'subtitle': 'Last message: ${conv['last_message_preview'] ?? 'No messages'}',
                      'time': conv['last_message_at'] ?? conv['created_at'],
                      'conversation_id': conv['id'],
                    });
                  }
                  
                  // Add recent calls
                  for (final call in calls.take(10)) {
                    items.add({
                      'type': 'call',
                      'title': call['caller_name'] ?? call['callee_name'] ?? 'Unknown',
                      'subtitle': 'Status: ${call['status']}',
                      'time': call['created_at'],
                      'call_id': call['id'],
                    });
                  }
                  
                  // Sort by time
                  items.sort((a, b) {
                    final aTime = a['time'] as String? ?? '';
                    final bTime = b['time'] as String? ?? '';
                    return bTime.compareTo(aTime);
                  });
                  
                  if (items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No notifications yet'),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isMessage = item['type'] == 'message';
                      final time = item['time'] as String?;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isMessage ? Colors.blue : Colors.green,
                          child: Icon(
                            isMessage ? Icons.message : Icons.call,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(
                          time != null
                              ? timeago.format(DateTime.tryParse(time) ?? DateTime.now())
                              : 'Unknown time',
                        ),
                        trailing: isMessage
                            ? const Icon(Icons.chat, size: 16)
                            : Icon(
                                item['subtitle'].toString().contains('answered')
                                    ? Icons.call
                                    : Icons.call_missed,
                                size: 16,
                              ),
                        onTap: () {
                          if (isMessage && item['conversation_id'] != null) {
                            context.go('/chat/${item['conversation_id']}');
                          }
                        },
                      );
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
}
