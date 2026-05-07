import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../services/providers.dart';
import '../../../services/chat_service.dart';

class MessageScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const MessageScreen({super.key, required this.conversationId});

  @override
  ConsumerState<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends ConsumerState<MessageScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _otherUserId;
  String? _otherUsername;
  String? _otherDisplayName;
  String? _otherPublicKey;

  @override
  void initState() {
    super.initState();
    _loadConversationData();
  }

  Future<void> _loadConversationData() async {
    final chatService = ref.read(chatServiceProvider);
    final conversation = await chatService.getConversation(widget.conversationId);
    if (conversation != null) {
      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId != null) {
        final otherUid = conversation.getOtherParticipantUid(currentUserId);
        final userService = ref.read(userServiceProvider);
        final otherUser = await userService.getUserById(otherUid);
        
        if (otherUser != null && mounted) {
          setState(() {
            _otherUserId = otherUid;
            _otherUsername = otherUser.username;
            _otherDisplayName = otherUser.displayName;
            _otherPublicKey = otherUser.publicKey;
          });
        }
      }
    }

    final chatService2 = ref.read(chatServiceProvider);
    await chatService2.markMessagesAsRead(widget.conversationId, ref.read(currentUserIdProvider) ?? '');
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _otherPublicKey == null || _otherPublicKey!.isEmpty) return;

    final currentUserId = ref.read(currentUserIdProvider);
    if (currentUserId == null) return;

    final chatService = ref.read(chatServiceProvider);
    final messageId = await chatService.sendMessage(
      conversationId: widget.conversationId,
      senderUid: currentUserId,
      recipientPublicKey: _otherPublicKey!,
      plaintext: text,
    );

    if (messageId != null && mounted) {
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(messagesProvider(widget.conversationId));
    final currentUserId = ref.watch(currentUserIdProvider);
    final displayName = _otherDisplayName ?? _otherUsername ?? 'Chat';

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
              // TODO: Start voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: () {
              // TODO: Start video call
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
                final filteredMessages = messages.where((m) => 
                  m.senderUid == currentUserId || !m.isDeletedBySender
                ).toList();

                if (filteredMessages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet'),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final message = filteredMessages[index];
                    final isSent = message.senderUid == currentUserId;

                    String content;
                    if (isSent) {
                      content = message.encryptedContent;
                    } else {
                      final chatService = ref.read(chatServiceProvider);
                      content = chatService.decryptMessage(message.encryptedContent);
                    }

                    final isDecryptError = content == 'Unable to decrypt';

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSent
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isDecryptError ? 'Unable to decrypt' : content,
                                  style: TextStyle(
                                    fontStyle: isDecryptError ? FontStyle.italic : FontStyle.normal,
                                    color: isDecryptError 
                                        ? Theme.of(context).colorScheme.error 
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      timeago.format(message.sentAt),
                                      style: Theme.of(context).textTheme.labelSmall,
                                    ),
                                    if (isSent) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        message.deliveredAt != null
                                            ? Icons.done_all
                                            : Icons.done,
                                        size: 14,
                                        color: message.deliveredAt != null
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).textTheme.labelSmall?.color,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
                  onPressed: _otherPublicKey == null || _otherPublicKey!.isEmpty
                      ? null
                      : _sendMessage,
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