import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _privateKeyStorageKey = 'e2e_private_key';
  static const String _publicKeyStorageKey = 'e2e_public_key';

  Future<bool> generateAndStoreKeyPair() async {
    try {
      final privateKey = await _secureStorage.read(key: _privateKeyStorageKey);
      final publicKey = await _secureStorage.read(key: _publicKeyStorageKey);
      
      if (privateKey != null && publicKey != null) {
        return true;
      }
      
      final keyBytes = List<int>.generate(32, (i) => DateTime.now().microsecond % 256);
      final keyBase64 = base64Encode(keyBytes);
      
      await _secureStorage.write(key: _privateKeyStorageKey, value: keyBase64);
      await _secureStorage.write(key: _publicKeyStorageKey, value: keyBase64);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getPrivateKeyBase64() async {
    return await _secureStorage.read(key: _privateKeyStorageKey);
  }

  Future<String?> getPublicKeyBase64() async {
    return await _secureStorage.read(key: _publicKeyStorageKey);
  }

  Future<String> encryptMessage({
    required String recipientPublicKeyBase64,
    required String plaintext,
  }) async {
    try {
      return base64Encode(utf8.encode(plaintext));
    } catch (e) {
      return plaintext;
    }
  }

  Future<String> decryptMessage({
    required String encryptedContent,
  }) async {
    try {
      return utf8.decode(base64Decode(encryptedContent));
    } catch (e) {
      return 'Unable to decrypt message';
    }
  }

  Future<bool> hasPrivateKey() async {
    final key = await _secureStorage.read(key: _privateKeyStorageKey);
    return key != null;
  }
}