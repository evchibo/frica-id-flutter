import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'models/config.dart';
import 'models/token_response.dart';
import 'models/user_info.dart';
import 'pkce.dart';
import 'storage/token_storage.dart';

class FricaClient {
  final FricaConfig config;
  late final TokenStorage _storage;

  static const _keyAccessToken = 'frica_access_token';
  static const _keyRefreshToken = 'frica_refresh_token';
  static const _keyIdToken = 'frica_id_token';
  static const _keyExpiresAt = 'frica_token_expires_at';
  static const _keyUser = 'frica_user_profile';
  static const _keyVerifier = 'frica_pkce_verifier';
  static const _keyState = 'frica_oauth_state';

  FricaClient({required this.config}) {
    _storage = config.storage ?? InMemoryTokenStorage();
  }

  /// Resolves the effective redirect URI taking into account Flutter Web vs Mobile platforms.
  String get effectiveRedirectUri {
    if (kIsWeb) {
      if (config.webRedirectUri != null && config.webRedirectUri!.isNotEmpty) {
        return config.webRedirectUri!;
      }
      // If mobile custom scheme is configured, on Web fallback to current window origin if available
      if (!config.redirectUri.startsWith('http://') && !config.redirectUri.startsWith('https://')) {
        try {
          return Uri.base.origin;
        } catch (_) {}
      }
    }
    return config.redirectUri;
  }

  /// Builds the OAuth 2.1 PKCE authorization URL and persists state and verifier.
  Future<Uri> getAuthorizationUrl({
    String? scope,
    String? state,
    String? nonce,
  }) async {
    final verifier = FricaPkce.generateCodeVerifier(64);
    final challenge = FricaPkce.generateCodeChallenge(verifier);
    final authState = state ?? FricaPkce.generateRandomString(24);
    final authNonce = nonce ?? FricaPkce.generateRandomString(24);

    await _storage.write(_keyVerifier, verifier);
    await _storage.write(_keyState, authState);

    final base = config.issuerUrl.replaceAll(RegExp(r'/+$'), '');
    final uri = Uri.parse('$base/oauth/authorize').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': config.clientId,
        'redirect_uri': effectiveRedirectUri,
        'scope': scope ?? config.defaultScope,
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'state': authState,
        'nonce': authNonce,
      },
    );

    return uri;
  }

  /// Initiates interactive login by launching the Frica ID authorization URL in the system browser.
  Future<bool> signIn({String? scope}) async {
    final uri = await getAuthorizationUrl(scope: scope);
    return await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
  }

  /// Processes the incoming deep link or redirect URL containing the authorization code.
  Future<FricaTokenResponse> handleRedirectUri(Uri uri) async {
    final error = uri.queryParameters['error'];
    if (error != null) {
      final desc = uri.queryParameters['error_description'] ?? error;
      throw Exception('Frica ID Authentication failed: $desc');
    }

    final code = uri.queryParameters['code'];
    if (code == null) {
      throw Exception('Missing authorization code in redirect URI');
    }

    final returnedState = uri.queryParameters['state'];
    final storedState = await _storage.read(_keyState);
    if (storedState != null && returnedState != null && storedState != returnedState) {
      throw Exception('OAuth state mismatch. Security verification failed.');
    }

    final verifier = await _storage.read(_keyVerifier);
    if (verifier == null) {
      throw Exception('PKCE code verifier not found in session storage.');
    }

    // Clean up temporary authorization state
    await _storage.delete(_keyVerifier);
    await _storage.delete(_keyState);

    // Exchange code for tokens
    final tokens = await exchangeCode(code, verifier);

    // Fetch and cache user profile (best-effort so token flow is resilient)
    try {
      if (tokens.accessToken.trim().isNotEmpty) {
        await getUserInfo(tokens.accessToken);
      }
    } catch (_) {
      // Profile can be fetched on demand
    }

    return tokens;
  }

  /// For Flutter Web: Checks if current browser window URL contains OAuth callback query params (?code=...) and completes sign-in automatically.
  Future<FricaTokenResponse?> handleWebCallbackIfPresent() async {
    if (!kIsWeb) return null;
    try {
      final uri = Uri.base;
      if (uri.queryParameters.containsKey('code')) {
        return await handleRedirectUri(uri);
      }
    } catch (_) {}
    return null;
  }

  /// Exchanges the authorization code and PKCE verifier for OAuth 2.1 access and refresh tokens.
  Future<FricaTokenResponse> exchangeCode(String code, String codeVerifier) async {
    final base = config.issuerUrl.replaceAll(RegExp(r'/+$'), '');
    final response = await http.post(
      Uri.parse('$base/oauth/token'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'grant_type': 'authorization_code',
        'client_id': config.clientId,
        'code': code,
        'redirect_uri': effectiveRedirectUri,
        'code_verifier': codeVerifier,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final payload = (data.containsKey('data') && data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : data;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final err = payload['error_description'] ?? payload['error'] ?? payload['message'] ?? 'Token exchange failed';
      throw Exception('Frica Token Exchange error: $err');
    }

    final tokens = FricaTokenResponse.fromJson(payload);
    await _storeTokens(tokens);
    return tokens;
  }

  /// Refreshes the active access token using the stored refresh token.
  Future<FricaTokenResponse> refreshToken([String? explicitRefreshToken]) async {
    final token = explicitRefreshToken ?? await _storage.read(_keyRefreshToken);
    if (token == null) {
      throw Exception('No refresh token available');
    }

    final base = config.issuerUrl.replaceAll(RegExp(r'/+$'), '');
    final response = await http.post(
      Uri.parse('$base/oauth/token'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'grant_type': 'refresh_token',
        'client_id': config.clientId,
        'refresh_token': token,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final payload = (data.containsKey('data') && data['data'] is Map<String, dynamic>)
        ? data['data'] as Map<String, dynamic>
        : data;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      await signOut();
      final err = payload['error_description'] ?? payload['error'] ?? 'Token refresh failed';
      throw Exception('Frica Token Refresh error: $err');
    }

    final tokens = FricaTokenResponse.fromJson(payload);
    await _storeTokens(tokens);
    return tokens;
  }

  /// Fetches the authenticated user profile.
  Future<FricaUserInfo> getUserInfo([String? accessToken]) async {
    final token = accessToken ?? await getValidAccessToken();
    if (token == null || token.trim().isEmpty) {
      throw Exception('No valid access token available');
    }

    final trimmed = token.trim();
    final base = config.issuerUrl.replaceAll(RegExp(r'/+$'), '');
    final response = await http.get(
      Uri.parse('$base/oauth/userinfo'),
      headers: {
        'Authorization': 'Bearer $trimmed',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to fetch user profile (${response.statusCode}): ${response.body}');
    }

    final body = jsonDecode(response.body);
    final data = (body is Map<String, dynamic> && body.containsKey('data') && body['data'] is Map<String, dynamic>)
        ? body['data'] as Map<String, dynamic>
        : (body is Map<String, dynamic> ? body : <String, dynamic>{});

    final user = FricaUserInfo.fromJson(data);
    await _storage.write(_keyUser, jsonEncode(user.toJson()));
    return user;
  }

  /// Returns a valid access token, auto-refreshing via the refresh token if expired.
  Future<String?> getValidAccessToken() async {
    final token = await _storage.read(_keyAccessToken);
    final expiresAtRaw = await _storage.read(_keyExpiresAt);
    if (token == null) return null;

    if (expiresAtRaw != null) {
      final expiresAt = DateTime.tryParse(expiresAtRaw);
      if (expiresAt != null &&
          DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)))) {
        try {
          final refreshed = await refreshToken();
          return refreshed.accessToken;
        } catch (_) {
          return null;
        }
      }
    }

    return token;
  }

  /// Checks if the client holds a valid session.
  Future<bool> isAuthenticated() async {
    final token = await getValidAccessToken();
    return token != null;
  }

  /// Retrieves the cached user profile if present.
  Future<FricaUserInfo?> getStoredUser() async {
    final raw = await _storage.read(_keyUser);
    if (raw == null) return null;
    try {
      return FricaUserInfo.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Retrieves the stored token response.
  Future<FricaTokenResponse?> getStoredTokens() async {
    final access = await _storage.read(_keyAccessToken);
    if (access == null) return null;

    final refresh = await _storage.read(_keyRefreshToken);
    final idToken = await _storage.read(_keyIdToken);
    final expiresAtRaw = await _storage.read(_keyExpiresAt);

    return FricaTokenResponse(
      accessToken: access,
      tokenType: 'Bearer',
      expiresIn: 3600,
      refreshToken: refresh,
      idToken: idToken,
      expiresAt: expiresAtRaw != null ? DateTime.tryParse(expiresAtRaw) : null,
    );
  }

  /// Revokes active tokens and clears client session storage.
  Future<void> signOut() async {
    final token = (await _storage.read(_keyRefreshToken)) ?? (await _storage.read(_keyAccessToken));
    if (token != null) {
      final base = config.issuerUrl.replaceAll(RegExp(r'/+$'), '');
      await http.post(
        Uri.parse('$base/oauth/revoke'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'client_id': config.clientId,
        }),
      ).catchError((_) => http.Response('', 200));
    }

    await _storage.delete(_keyAccessToken);
    await _storage.delete(_keyRefreshToken);
    await _storage.delete(_keyIdToken);
    await _storage.delete(_keyExpiresAt);
    await _storage.delete(_keyUser);
    await _storage.delete(_keyVerifier);
    await _storage.delete(_keyState);
  }

  Future<void> _storeTokens(FricaTokenResponse tokens) async {
    await _storage.write(_keyAccessToken, tokens.accessToken);
    if (tokens.refreshToken != null) {
      await _storage.write(_keyRefreshToken, tokens.refreshToken!);
    }
    if (tokens.idToken != null) {
      await _storage.write(_keyIdToken, tokens.idToken!);
    }
    await _storage.write(_keyExpiresAt, tokens.expiresAt.toIso8601String());
  }
}
