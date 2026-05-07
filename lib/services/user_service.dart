import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

class UserService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<VardUser?> getUserById(String uid) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', uid)
          .maybeSingle();

      if (response == null) return null;
      return VardUser.fromMap(response, response['id']);
    } catch (e) {
      return null;
    }
  }

  Future<VardUser?> getUserByUsername(String username) async {
    try {
      final usernameResponse = await _supabase
          .from('usernames')
          .select('uid')
          .eq('username', username)
          .maybeSingle();

      if (usernameResponse == null) return null;

      final uid = usernameResponse['uid'];
      return await getUserById(uid);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isUsernameAvailable(String username) async {
    final user = await getUserByUsername(username);
    return user == null;
  }

  Future<void> updateUserDisplayName(String uid, String displayName) async {
    await _supabase
        .from('users')
        .update({'display_name': displayName})
        .eq('id', uid);
  }

  Future<void> updateUserPublicKey(String uid, String publicKey) async {
    await _supabase
        .from('users')
        .update({'public_key': publicKey})
        .eq('id', uid);
  }

  Future<void> updateUserFcmToken(String uid, String? fcmToken) async {
    await _supabase
        .from('users')
        .update({'fcm_token': fcmToken})
        .eq('id', uid);
  }

  Future<void> updateThemePreference(String uid, String theme) async {
    await _supabase
        .from('users')
        .update({'theme_preference': theme})
        .eq('id', uid);
  }

  Future<void> updateNotificationsEnabled(String uid, bool enabled) async {
    await _supabase
        .from('users')
        .update({'notifications_enabled': enabled})
        .eq('id', uid);
  }

  Future<List<VardUser>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _supabase
          .from('users')
          .select()
          .ilike('username', '%$query%')
          .limit(20);

      return response.map((e) => VardUser.fromMap(e, e['id'])).toList();
    } catch (e) {
      return [];
    }
  }

  Stream<VardUser?> watchUser(String uid) {
    return _supabase
        .channel('users:$uid')
        .onPostgresChanges(
          event: '*',
          schema: 'public',
          table: 'users',
          filter: PostgrestFilter.equals('id', uid),
          callback: (data) async {
            return await getUserById(uid);
          },
        )
        .map((_) => null);
  }
}