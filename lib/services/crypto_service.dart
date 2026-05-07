import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class CryptoService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final X25519 _x25519 = X25519();
  final AesGcm _aesGcm = AesGcm.with256bits();

  Future<void> generateAndStoreKeyPair() async {
    final keyPair = await _x25519.newKeyPairFromSeed(
      Uint8List.fromList(List.generate(32, (i) => DateTime.now().microsecondsSinceEpoch % 256)),
    );
    
    final privateKey = await keyPair.extractPrivateKeyBytes();
    final publicKey = await keyPair.extractPublicKeyBytes();

    final privateKeyBase64 = base64Encode(privateKey);
    final publicKeyBase64 = base64Encode(publicKey);

    await _secureStorage.write(
      key: AppConstants.privateKeyStorageKey,
      value: privateKeyBase64,
    );

    return;
  }

  String getPublicKeyBase64(String privateKeyBase64) {
    final privateKeyBytes = base64Decode(privateKeyBase64);
    final keyPair = _x25519.newKeyPairFromSeed(privateKeyBytes);
    return base64Encode(keyPair as dynamic);
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

      final privateKeyBytes = base64Decode(privateKeyBase64);
      final recipientPublicKeyBytes = base64Decode(recipientPublicKeyBase64);

      final localKeyPair = _x25519.newKeyPairFromSeed(privateKeyBytes);
      final recipientPublicKey = SimplePublicKey(recipientPublicKeyBytes, type: X25519());

      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: await localKeyPair,
        remotePublicKey: recipientPublicKey,
      );

      final hkdf = Hkdf(
        hmac: Hmac.sha256(),
        outputLength: 32,
      );

      final aesKey = await hkdf.deriveKey(
        secretKey: sharedSecret,
        info: utf8.encode('VardChat-E2EE'),
      );

      final nonce = _aesGcm.newNonce();

      final secretBox = await _aesGcm.encrypt(
        utf8.encode(plaintext),
        secretKey: aesKey,
        nonce: nonce,
      );

      final ephemeralKeyPair = await _x25519.newKeyPair();
      final ephemeralPublicKey = await ephemeralKeyPair.extractPublicKeyBytes();

      final nonceBase64 = base64Encode(secretBox.nonce);
      final ciphertextBase64 = base64Encode(secretBox.cipherText);
      final macBase64 = base64Encode(secretBox.mac.bytes);

      final ephemeralPublicKeyBase64 = base64Encode(ephemeralPublicKey);

      return '$ephemeralPublicKeyBase64::$nonceBase64::$macBase64::$ciphertextBase64';
    } catch (e) {
      rethrow;
    }
  }

  Future<String> decryptMessage({
    required String encryptedContent,
  }) async {
    try {
      final parts = encryptedContent.split('::');
      if (parts.length != 4) {
        throw Exception('Invalid encrypted content format');
      }

      final ephemeralPublicKeyBase64 = parts[0];
      final nonceBase64 = parts[1];
      final macBase64 = parts[2];
      final ciphertextBase64 = parts[3];

      final privateKeyBase64 = await getPrivateKey();
      if (privateKeyBase64 == null) {
        throw Exception('Private key not found');
      }

      final privateKeyBytes = base64Decode(privateKeyBase64);
      final ephemeralPublicKeyBytes = base64Decode(ephemeralPublicKeyBase64);

      final localKeyPair = _x25519.newKeyPairFromSeed(privateKeyBytes);
      final ephemeralPublicKey = SimplePublicKey(ephemeralPublicKeyBytes, type: X25519());

      final sharedSecret = await _x25519.sharedSecretKey(
        keyPair: await localKeyPair,
        remotePublicKey: ephemeralPublicKey,
      );

      final hkdf = Hkdf(
        hmac: Hmac.sha256(),
        outputLength: 32,
      );

      final aesKey = await hkdf.deriveKey(
        secretKey: sharedSecret,
        info: utf8.encode('VardChat-E2EE'),
      );

      final nonce = base64Decode(nonceBase64);
      final ciphertext = base64Decode(ciphertextBase64);
      final mac = Mac(base64Decode(macBase64));

      final secretBox = SecretBox(
        ciphertext,
        nonce: nonce,
        mac: mac,
      );

      final plaintextBytes = await _aesGcm.decrypt(
        secretBox,
        secretKey: aesKey,
      );

      return utf8.decode(plaintextBytes);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasPrivateKey() async {
    final key = await getPrivateKey();
    return key != null;
  }
}