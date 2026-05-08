import 'dart:async';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _privateKeyStorageKey = 'e2e_private_key';

  Future<bool> generateAndStoreKeyPair() async {
    try {
      // Simplified - store a simple key for now
      final random = await _secureStorage.read(key: _privateKeyStorageKey);
      if (random != null) return true; // Already has key
      
      // Generate a simple key (in production, use proper X25519)
      final key = base64Encode(List<int>.generate(32, (i) => DateTime.now().millisecond % 256));
      await _secureStorage.write(key: _privateKeyStorageKey, value: key);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getPublicKeyBase64() async {
    // In a real implementation, derive public key from private key
    return await getPrivateKey();
  }

  Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: _privateKeyStorageKey);
  }

  Future<String> encryptMessage({
    required String recipientPublicKeyBase64,
    required String plaintext,
  }) async {
    // Simplified encryption - just base64 encode for now
    // In production, use proper X25519 + AES-256-GCM
    try {
      return base64Encode(utf8.encode(plaintext));
    } catch (e) {
      return plaintext;
    }
  }

  Future<String> decryptMessage({
    required String encryptedContent,
  }) async {
    // Simplified decryption - just base64 decode for now
    try {
      return utf8.decode(base64Decode(encryptedContent));
    } catch (e) {
      return 'Unable to decrypt';
    }
  }

  Future<bool> hasPrivateKey() async {
    final key = await getPrivateKey();
    return key != null;
  }
}
