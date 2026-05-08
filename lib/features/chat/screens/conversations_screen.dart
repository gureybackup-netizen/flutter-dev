import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants.dart';
import '../../../services/providers.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUserIdAsync = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(RouteConstants.search),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(RouteConstants.settings),
          ),
        ],
      ),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No conversations yet'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go(RouteConstants.search),
                    child: const Text('Start a conversation'),
                  ),
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

              return ListView.separated(
                itemCount: conversations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final participantIds = conversation['participant_ids'] as List<dynamic>?;
                  final displayNames = conversation['participant_display_names'] as Map<String, dynamic>?;
                  
                  final otherId = participantIds?.firstWhere(
                    (id) => id.toString() != currentUserId,
                    orElse: () => '',
                  );
                  
                  final otherName = displayNames?[otherId?.toString()] as String? ?? 'Unknown';
                  final lastMessageAt = conversation['last_message_at'] as String?;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Text(
                        otherName.isNotEmpty ? otherName[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(otherName),
                    subtitle: const Text(
                      'Tap to open',
                      style: TextStyle(color: Colors.grey),
                    ),
                    trailing: lastMessageAt != null
                        ? Text(
                            timeago.format(DateTime.tryParse(lastMessageAt) ?? DateTime.now()),
                            style: Theme.of(context).textTheme.labelSmall,
                          )
                        : null,
                    onTap: () => context.go('/chat/${conversation['id']}'),
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