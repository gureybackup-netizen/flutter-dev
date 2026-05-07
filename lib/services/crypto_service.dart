import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
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

      final privateKey = base64Decode(privateKeyBase64);
      final recipientKey = base64Decode(recipientPublicKeyBase64);
      
      final sharedSecret = _xorKeys(privateKey, recipientKey);
      
      final nonce = List<int>.generate(12, (_) => random.nextInt(256));
      
      final key = _deriveKey(sharedSecret);
      final ciphertext = _xorEncrypt(plaintext, key);
      
      final ephemeralPublicKey = base64Encode(List<int>.generate(32, (_) => random.nextInt(256)));
      final nonceBase64 = base64Encode(nonce);
      final ciphertextBase64 = base64Encode(ciphertext);
      
      return '$ephemeralPublicKey::$nonceBase64::$ciphertextBase64';
    } catch (e) {
      rethrow;
    }
  }

  List<int> _xorKeys(List<int> key1, List<int> key2) {
    final result = <int>[];
    for (var i = 0; i < 32; i++) {
      result.add(key1[i] ^ key2[i % key2.length]);
    }
    return result;
  }

  List<int> _deriveKey(List<int> secret) {
    final key = <int>[];
    var state = 0;
    for (var i = 0; i < 32; i++) {
      state = (state * 33 + secret[i % secret.length]) % 256;
      key.add(state);
    }
    return key;
  }

  List<int> _xorEncrypt(String plaintext, List<int> key) {
    final plaintextBytes = utf8.encode(plaintext);
    final result = <int>[];
    for (var i = 0; i < plaintextBytes.length; i++) {
      result.add(plaintextBytes[i] ^ key[i % key.length]);
    }
    return result;
  }

  Future<String> decryptMessage({
    required String encryptedContent,
  }) async {
    try {
      final parts = encryptedContent.split('::');
      if (parts.length != 3) {
        throw Exception('Invalid encrypted content format');
      }

      final _ = parts[0];
      final nonceBase64 = parts[1];
      final ciphertextBase64 = parts[2];

      final privateKeyBase64 = await getPrivateKey();
      if (privateKeyBase64 == null) {
        throw Exception('Private key not found');
      }

      final privateKey = base64Decode(privateKeyBase64);
      final recipientKey = base64Decode(privateKeyBase64);
      
      final sharedSecret = _xorKeys(privateKey, recipientKey);
      final key = _deriveKey(sharedSecret);
      
      final ciphertext = base64Decode(ciphertextBase64);
      final plaintextBytes = _xorDecrypt(ciphertext, key);
      
      return utf8.decode(plaintextBytes);
    } catch (e) {
      return 'Unable to decrypt';
    }
  }

  List<int> _xorDecrypt(List<int> ciphertext, List<int> key) {
    final result = <int>[];
    for (var i = 0; i < ciphertext.length; i++) {
      result.add(ciphertext[i] ^ key[i % key.length]);
    }
    return result;
  }

  Future<bool> hasPrivateKey() async {
    final key = await getPrivateKey();
    return key != null;
  }
}

final random = Random.secure();