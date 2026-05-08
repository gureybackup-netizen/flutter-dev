import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../core/constants.dart';
import '../../services/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          _ChatsTab(),
          _CallsTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_outlined),
            activeIcon: Icon(Icons.call),
            label: 'Calls',
          ),
        ],
      ),
    );
  }
}

class _ChatsTab extends ConsumerWidget {
  const _ChatsTab();

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

              return ListView.builder(
                itemCount: conversations.length,
                itemBuilder: (context, index) {
                  final conversation = conversations[index];
                  final participantIds = conversation['participant_ids'] as List<dynamic>? ?? [];
                  final displayNames = conversation['participant_display_names'] as Map<String, dynamic>? ?? {};
                  
                  final otherId = participantIds.firstWhere(
                    (id) => id.toString() != currentUserId,
                    orElse: () => '',
                  );
                  final displayName = displayNames[otherId.toString()]?.toString() ?? 'Unknown';
                  final lastMessageAt = conversation['last_message_at'] as String?;
                  final unreadCount = conversation['unread_count'] as int? ?? 0;

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(displayName[0].toUpperCase()),
                    ),
                    title: Text(displayName),
                    subtitle: Text(
                      lastMessageAt != null 
                          ? timeago.format(DateTime.tryParse(lastMessageAt) ?? DateTime.now())
                          : 'No messages',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: unreadCount > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
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

class _CallsTab extends ConsumerWidget {
  const _CallsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go(RouteConstants.callHistory),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go(RouteConstants.settings),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No calls yet'),
            const SizedBox(height: 16),
            const Text(
              'Start a chat and tap the call button',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}