import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class CryptoService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<void> generateAndStoreKeyPair() async {
    final random = Random.secure();
    final privateKey = List<int>.generate(32, (_) => random.nextInt(256));
    final privateKeyBase64 = base64Encode(privateKey);
    
    await _secureStorage.write(
      key: AppConstants.privateKeyStorageKey,
      value: privateKeyBase64,
    );
  }

  String getPublicKeyBase64(String privateKeyBase64) {
    return base64Encode(base64Decode(privateKeyBase64));
  }

  Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: AppConstants.privateKeyStorageKey);
  }

  Future<String> encryptMessage({
    required String recipientPublicKeyBase64,
    required String plaintext,
  }) async {
    try {
      final privateKeyBase64 = await getPrivateKey();
      if (privateKeyBase64 == null) {
        throw Exception('Private key not found');
      }

      final random = Random.secure();
      final nonce = List<int>.generate(8, (_) => random.nextInt(256));
      final nonceBase64 = base64Encode(nonce);
      
      final plaintextBase64 = base64Encode(utf8.encode(plaintext));
      
      final combined = '$nonceBase64:$plaintextBase64:$recipientPublicKeyBase64';
      return base64Encode(utf8.encode(combined));
    } catch (e) {
      rethrow;
    }
  }

  Future<String> decryptMessage({
    required String encryptedContent,
  }) async {
    try {
      final decoded = utf8.decode(base64Decode(encryptedContent));
      final parts = decoded.split(':');
      
      if (parts.length < 2) {
        throw Exception('Invalid format');
      }

      final plaintextBase64 = parts[1];
      return utf8.decode(base64Decode(plaintextBase64));
    } catch (e) {
      return 'Unable to decrypt';
    }
  }

  Future<bool> hasPrivateKey() async {
    final key = await getPrivateKey();
    return key != null;
  }
}