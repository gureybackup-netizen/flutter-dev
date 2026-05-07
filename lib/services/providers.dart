import 'dart:async';
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
  final supabase = ref.watch(supabaseClientProvider);
  return supabase.auth.onAuthStateChange();
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
  
  final controller = StreamController<List<VardConversation>>();
  
  Future<void> fetchConversations() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final conversations = await chatService.getConversations(userId);
      if (controller.isClosed) return;
      controller.add(conversations);
    } catch (e) {
      // Ignore
    }
  }
  
  fetchConversations();
  
  Timer.periodic(const Duration(seconds: 5), (timer) {
    if (controller.isClosed) {
      timer.cancel();
      return;
    }
    fetchConversations();
  });
  
  ref.onDispose(() {
    controller.close();
  });
  
  return controller.stream;
});

final messagesProvider = StreamProvider.family<List<VardMessage>, String>((ref, conversationId) {
  final controller = StreamController<List<VardMessage>>();
  
  Future<void> fetchMessages() async {
    try {
      final chatService = ref.read(chatServiceProvider);
      final messages = await chatService.getMessages(conversationId);
      if (controller.isClosed) return;
      controller.add(messages);
    } catch (e) {
      // Ignore
    }
  }
  
  fetchMessages();
  
  Timer.periodic(const Duration(seconds: 3), (timer) {
    if (controller.isClosed) {
      timer.cancel();
      return;
    }
    fetchMessages();
  });
  
  ref.onDispose(() {
    controller.close();
  });
  
  return controller.stream;
});

final callsProvider = StreamProvider<List<VardCall>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  
  final controller = StreamController<List<VardCall>>();
  
  Future<void> fetchCalls() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final response = await supabase
          .from('calls')
          .select()
          .or('caller_id.eq.$userId,callee_uid.eq.$userId')
          .order('created_at', ascending: false);
      
      final calls = response.map((e) => VardCall.fromMap(e, e['id'])).toList();
      if (controller.isClosed) return;
      controller.add(calls);
    } catch (e) {
      // Ignore
    }
  }
  
  fetchCalls();
  
  Timer.periodic(const Duration(seconds: 5), (timer) {
    if (controller.isClosed) {
      timer.cancel();
      return;
    }
    fetchCalls();
  });
  
  ref.onDispose(() {
    controller.close();
  });
  
  return controller.stream;
});

final themeProvider = StateProvider<String>((ref) => 'dark');