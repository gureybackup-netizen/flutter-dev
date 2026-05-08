import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/constants.dart';
import '../../../services/providers.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const MessageScreen({super.key, required this.conversationId});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _otherDisplayName;

  @override
  void initState() {
    super.initState();
    _loadConversationData();
  }

  Future<void> _loadConversationData() async {
    final appwrite = ref.read(appwriteServiceProvider);
    final currentUserId = await appwrite.getCurrentUserId();
    
    if (currentUserId != null) {
      final conversations = await appwrite.getConversations(currentUserId);
      final conversation = conversations.firstWhere(
        (c) => c['id'] == widget.conversationId,
        orElse: () => {},
      );
      
      final displayNames = conversation['participant_display_names'] as Map<String, dynamic>?;
      final participantIds = conversation['participant_ids'] as List<dynamic>?;
      
      if (displayNames != null && participantIds != null) {
        final otherId = participantIds.firstWhere(
          (id) => id.toString() != currentUserId,
          orElse: () => '',
        );
        
        setState(() {
          _otherDisplayName = displayNames[otherId.toString()] as String? ?? 'Unknown';
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final appwrite = ref.read(appwriteServiceProvider);
    final currentUserId = await appwrite.getCurrentUserId();
    
    if (currentUserId == null) return;

    await appwrite.sendMessage(
      conversationId: widget.conversationId,
      senderId: currentUserId,
      content: text,
    );

    if (mounted) {
      _messageController.clear();
      ref.invalidate(messagesProvider(widget.conversationId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final currentUserIdAsync = ref.watch(currentUserIdProvider);
    final displayName = _otherDisplayName ?? 'Chat';

    return Scaffold(
      appBar: AppBar(
        title: Text(displayName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteConstants.conversations),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              context.go('/call/outgoing/${widget.conversationId}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              context.go('/call/outgoing/${widget.conversationId}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
              data: (messages) {
                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return currentUserIdAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('Error: $e')),
                  data: (currentUserId) {
                    if (currentUserId == null) {
                      return const Center(child: Text('Please log in'));
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isSent = message['sender_id'] == currentUserId;
                        final content = message['content'] as String? ?? '';
                        final sentAt = message['sent_at'] as String?;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSent 
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(content),
                                    if (sentAt != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            timeago.format(DateTime.tryParse(sentAt) ?? DateTime.now()),
                                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: isSent ? Colors.white70 : Colors.grey,
                                            ),
                                          ),
                                          if (isSent) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.done_all,
                                              size: 14,
                                              color: Colors.white70,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Message',
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}