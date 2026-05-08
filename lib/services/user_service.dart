import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers.dart';

final userServiceProvider = Provider((ref) => UserService(ref));

class UserService {
  final Ref _ref;

  UserService(this._ref);

  Future<Map<String, dynamic>?> getUserByUniqueId(String uniqueId) async {
    final appwrite = _ref.read(appwriteServiceProvider);
    return await appwrite.getUserByUniqueId(uniqueId);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final appwrite = _ref.read(appwriteServiceProvider);
    return await appwrite.searchUsers(query);
  }

  Future<String?> createConversation({
    required String userId,
    required String otherUserId,
    required String otherDisplayName,
  }) async {
    final appwrite = _ref.read(appwriteServiceProvider);
    return await appwrite.createConversation(
      userId: userId,
      otherUserId: otherUserId,
      otherDisplayName: otherDisplayName,
    );
  }
}
