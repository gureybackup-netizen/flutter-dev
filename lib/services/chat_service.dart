import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import 'crypto_service.dart';

class ChatService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final CryptoService _cryptoService = CryptoService();

  String generateConversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Future<VardConversation?> getOrCreateConversation({
    required String currentUserId,
    required String otherUserId,
    required String otherUsername,
    required String otherDisplayName,
  }) async {
    final conversationId = generateConversationId(currentUserId, otherUserId);

    try {
      final existing = await _supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();

      if (existing != null) {
        return VardConversation.fromMap(existing, existing['id']);
      }

      await _supabase.from('conversations').insert({
        'id': conversationId,
        'participant_uids': [currentUserId, otherUserId],
        'participant_usernames': {currentUserId: '', otherUserId: otherUsername},
        'participant_display_names': {currentUserId: '', otherUserId: otherDisplayName},
        'unread_count': 0,
      });

      final created = await _supabase
          .from('conversations')
          .select()
          .eq('id', conversationId)
          .maybeSingle();

      if (created != null) {
        return VardConversation.fromMap(created, created['id']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<VardConversation>> getConversations(String userId) async {
    final response = await _supabase
        .from('conversations')
        .select()
        .contains('participant_uids', [userId])
        .order('last_message_at', ascending: false);

    return response.map((e) => VardConversation.fromMap(e, e['id'])).toList();
  }

  Future<VardConversation?> getConversation(String conversationId) async {
    final response = await _supabase
        .from('conversations')
        .select()
        .eq('id', conversationId)
        .maybeSingle();

    if (response == null) return null;
    return VardConversation.fromMap(response, response['id']);
  }

  Future<String?> sendMessage({
    required String conversationId,
    required String senderUid,
    required String recipientPublicKeyBase64,
    required String plaintext,
  }) async {
    try {
      final encryptedContent = await _cryptoService.encryptMessage(
        recipientPublicKeyBase64: recipientPublicKeyBase64,
        plaintext: plaintext,
      );

      final messageId = DateTime.now().millisecondsSinceEpoch.toString();

      await _supabase.from('messages').insert({
        'id': messageId,
        'conversation_id': conversationId,
        'sender_uid': senderUid,
        'encrypted_content': encryptedContent,
        'sent_at': DateTime.now().toIso8601String(),
        'is_read': false,
        'is_deleted_by_sender': false,
      });

      await _supabase.from('conversations').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', conversationId);

      return messageId;
    } catch (e) {
      return null;
    }
  }

  Future<List<VardMessage>> getMessages(String conversationId, {int limit = 100}) async {
    final response = await _supabase
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('sent_at', ascending: false)
        .limit(limit);

    return response.map((e) => VardMessage.fromMap(e, e['id'])).toList();
  }

  Future<void> markMessagesAsRead(String conversationId, String recipientUid) async {
    await _supabase.from('messages').update({
      'is_read': true,
      'delivered_at': DateTime.now().toIso8601String(),
    }).eq('conversation_id', conversationId).neq('sender_uid', recipientUid);

    await _supabase.from('conversations').update({
      'unread_count': 0,
    }).eq('id', conversationId);
  }

  Future<void> deleteMessageForSelf(String messageId) async {
    await _supabase.from('messages').update({
      'is_deleted_by_sender': true,
    }).eq('id', messageId);
  }

  Future<String> decryptMessage(String encryptedContent) async {
    try {
      final plaintext = await _cryptoService.decryptMessage(encryptedContent: encryptedContent);
      return plaintext;
    } catch (e) {
      return 'Unable to decrypt';
    }
  }

  Future<void> updateConversationDisplayName({
    required String conversationId,
    required String userId,
    required String displayName,
  }) async {
    final conversation = await getConversation(conversationId);
    if (conversation == null) return;

    final updatedDisplayNames = Map<String, String>.from(conversation.participantDisplayNames);
    updatedDisplayNames[userId] = displayName;

    await _supabase.from('conversations').update({
      'participant_display_names': updatedDisplayNames,
    }).eq('id', conversationId);
  }
}