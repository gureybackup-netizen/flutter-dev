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
      if (e.message.contains('already registered') || e.message.contains('already exists')) {
        return 'Username already taken';
      }
      if (e.message.contains('rate limit') || e.message.contains('429')) {
        return 'Server busy. Please try again in a few minutes.';
      }
      return 'Connection error: ${e.message}';
    } catch (e) {
      return 'Connection error. Please try again.';
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
        return 'Invalid username or password';
      }

      return null;
    } on AuthException catch (e) {
      if (e.message.contains('invalid') || e.message.contains('Invalid')) {
        return 'Invalid username or password';
      }
      if (e.message.contains('rate limit') || e.message.contains('429')) {
        return 'Server busy. Please try again in a few minutes.';
      }
      return 'Connection error: ${e.message}';
    } catch (e) {
      return 'Connection error. Please try again.';
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  dynamic get currentUser => _supabase.auth.currentUser;

  String? get currentUserId => _supabase.auth.currentUser?.id;
}