import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/call_record.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/chat_service.dart';
import '../services/crypto_service.dart';
import '../services/call_service.dart';

final authServiceProvider = Provider((ref) => AuthService());
final userServiceProvider = Provider((ref) => UserService());
final chatServiceProvider = Provider((ref) => ChatService());
final cryptoServiceProvider = Provider((ref) => CryptoService());
final callServiceProvider = Provider((ref) => CallService());

final supabaseClientProvider = Provider((ref) => Supabase.instance.client);

final authStateProvider = StreamProvider<AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges.asyncMap((event) async {
    return event;
  });
});

final currentUserIdProvider = Provider<String?>((ref) {
  final authAsync = ref.watch(authStateProvider);
  return authAsync.whenOrNull(
    data: (state) => state.session?.user.id,
  );
});

final currentUserProvider = FutureProvider<VardUser?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  
  final userService = ref.watch(userServiceProvider);
  return await userService.getUserById(userId);
});

final conversationsProvider = StreamProvider<List<VardConversation>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  final chatService = ref.watch(chatServiceProvider);
  return chatService.watchConversations(userId);
});

final messagesProvider = StreamProvider.family<List<VardMessage>, String>((ref, conversationId) {
  final chatService = ref.watch(chatServiceProvider);
  return chatService.watchMessages(conversationId);
});

final callsProvider = StreamProvider<List<VardCall>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  final supabase = ref.watch(supabaseClientProvider);
  return supabase
      .from('calls')
      .select()
      .or('caller_id.eq.$userId,callee_uid.eq.$userId')
      .order('created_at', ascending: false)
      .stream()
      .map((events) => events.map((e) => VardCall.fromMap(e, e['id'])).toList());
});

final themeProvider = StateProvider<String>((ref) => 'dark');