import '../services/appwrite_service.dart';

class AuthService {
  final AppwriteService _appwrite = AppwriteService();

  Future<String?> register({required String displayName}) async {
    try {
      final uniqueId = _appwrite.generateUniqueId();
      final error = await _appwrite.createUser(
        uniqueId: uniqueId,
        displayName: displayName,
      );
      
      if (error != null) {
        return error;
      }
      
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login({required String uniqueId}) async {
    try {
      final error = await _appwrite.loginWithUniqueId(uniqueId);
      
      if (error != null) {
        return error;
      }
      
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logout() async {
    await _appwrite.logout();
  }

  Future<String?> getCurrentUserId() async {
    return await _appwrite.getCurrentUserId();
  }
}