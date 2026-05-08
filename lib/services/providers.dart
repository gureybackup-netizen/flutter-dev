import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/call_record.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/chat_service.dart';
import '../services/crypto_service.dart';
import '../services/call_service.dart';
import '../services/appwrite_service.dart';

final appwriteServiceProvider = Provider((ref) => AppwriteService());
final authServiceProvider = Provider((ref) => AuthService());
final userServiceProvider = Provider((ref) => UserService());
final chatServiceProvider = Provider((ref) => ChatService());
final cryptoServiceProvider = Provider((ref) => CryptoService());
final callServiceProvider = Provider((ref) => CallService());

class AuthNotifier extends StateNotifier<bool> {
  final AppwriteService _appwrite;
  Timer? _timer;
  
  AuthNotifier(this._appwrite) : super(false) {
    _checkAuth();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _checkAuth());
  }
  
  Future<void> _checkAuth() async {
    final userId = await _appwrite.getCurrentUserId();
    if (state != (userId != null)) {
      state = userId != null;
    }
  }
  
  Future<void> login(String uniqueId) async {
    final error = await _appwrite.loginWithUniqueId(uniqueId);
    if (error == null) {
      state = true;
    }
  }
  
  Future<void> logout() async {
    await _appwrite.logout();
    state = false;
  }
  
  Future<String?> getCurrentUserId() async {
    return await _appwrite.getCurrentUserId();
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final appwrite = ref.watch(appwriteServiceProvider);
  return AuthNotifier(appwrite);
});

final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final appwrite = ref.watch(appwriteServiceProvider);
  return await appwrite.getCurrentUserId();
});

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return null;
  
  final appwrite = ref.watch(appwriteServiceProvider);
  return await appwrite.getUserByUniqueId(userId);
});

final conversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  if (userId == null) return [];
  
  final appwrite = ref.watch(appwriteServiceProvider);
  return await appwrite.getConversations(userId);
});

final messagesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, conversationId) async {
  final appwrite = ref.watch(appwriteServiceProvider);
  return await appwrite.getMessages(conversationId);
});

final themeProvider = StateProvider<String>((ref) => 'dark');