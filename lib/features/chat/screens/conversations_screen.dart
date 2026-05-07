import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/providers.dart';
import '../../core/constants.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.go(RouteConstants.search),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go(RouteConstants.callHistory),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'settings') {
                context.go(RouteConstants.settings);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
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
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go(RouteConstants.search),
                    child: const Text('Start a new chat'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              final otherUsername = conversation.getOtherParticipantUsername(currentUserId ?? '');
              final otherDisplayName = conversation.getOtherParticipantDisplayName(currentUserId ?? '');
              final displayName = otherDisplayName.isNotEmpty ? otherDisplayName : otherUsername;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(displayName),
                subtitle: Text(
                  'Encrypted message',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: conversation.lastMessageAt != null
                    ? Text(
                        timeago.format(conversation.lastMessageAt!),
                        style: Theme.of(context).textTheme.labelSmall,
                      )
                    : null,
                onTap: () => context.go('/chat/${conversation.id}'),
              );
            },
          );
        },
      ),
    );
  }
}