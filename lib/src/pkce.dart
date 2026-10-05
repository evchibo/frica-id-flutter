import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// PKCE (Proof Key for Code Exchange - RFC 7636) helpers for Flutter.
class FricaPkce {
  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';

  /// Generates a cryptographically secure random PKCE code verifier (43-128 chars).
  static String generateCodeVerifier([int length = 64]) {
    final clampedLength = length.clamp(43, 128);
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < clampedLength; i++) {
      buffer.write(_charset[random.nextInt(_charset.length)]);
    }
    return buffer.toString();
  }

  /// Computes the SHA-256 base64url-encoded code challenge from the code verifier.
  static String generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(digest.bytes).replaceAll('=', '');
  }

  /// Generates an unguessable state or nonce token.
  static String generateRandomString([int length = 32]) {
    final random = Random.secure();
    final buffer = StringBuffer();
    for (var i = 0; i < length; i++) {
      buffer.write(_charset[random.nextInt(_charset.length)]);
    }
    return buffer.toString();
  }
}
