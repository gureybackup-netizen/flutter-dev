import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  static const String _privateKeyStorageKey = 'e2e_private_key';

  Future<void> generateAndStoreKeyPair() async {
    final random = Random.secure();
    final privateKey = List<int>.generate(32, (_) => random.nextInt(256));
    final privateKeyBase64 = base64Encode(privateKey);
    
    await _secureStorage.write(
      key: _privateKeyStorageKey,
      value: privateKeyBase64,
    );
  }

  String getPublicKeyBase64(String privateKeyBase64) {
    return base64Encode(base64Decode(privateKeyBase64));
  }

  Future<String?> getPrivateKey() async {
    return await _secureStorage.read(key: _privateKeyStorageKey);
  }

  Future<String> encryptMessage({
    required String recipientPublicKeyBase64,
    required String plaintext,
  }) async {
    try {
      final plaintextBase64 = base64Encode(utf8.encode(plaintext));
      return plaintextBase64;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> decryptMessage({
    required String encryptedContent,
  }) async {
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