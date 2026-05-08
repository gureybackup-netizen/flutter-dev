import '../services/appwrite_service.dart';

class UserService {
  final AppwriteService _appwrite = AppwriteService();

  Future<Map<String, dynamic>?> getUserById(String uid) async {
    return await _appwrite.getUserByUniqueId(uid);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    return await _appwrite.searchUsers(query);
  }
}