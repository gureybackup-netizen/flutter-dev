import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/constants.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String _generateInternalEmail(String username) {
    return '$username@${AppConstants.internalEmailDomain}';
  }

  Future<String?> register({
    required String username,
    required String password,
  }) async {
    try {
      final email = _generateInternalEmail(username);

      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return 'Registration failed';
      }

      final uid = authResponse.user!.id;

      await _supabase.from('usernames').insert({
        'username': username,
        'uid': uid,
      });

      await _supabase.from('users').insert({
        'id': uid,
        'username': username,
        'display_name': username,
        'public_key': '',
        'created_at': DateTime.now().toIso8601String(),
      });

      return null;
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        return ErrorMessages.usernameTaken;
      }
      return ErrorMessages.connectionError;
    } catch (e) {
      return ErrorMessages.connectionError;
    }
  }

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    try {
      final email = _generateInternalEmail(username);

      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        return ErrorMessages.invalidCredentials;
      }

      return null;
    } on AuthException catch (e) {
      if (e.message.contains('invalid') || e.message.contains('Invalid')) {
        return ErrorMessages.invalidCredentials;
      }
      return ErrorMessages.connectionError;
    } catch (e) {
      return ErrorMessages.connectionError;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange();
  }

  dynamic get currentUser {
    return _supabase.auth.currentUser;
  }

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }
}