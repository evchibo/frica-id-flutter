import '../storage/token_storage.dart';

/// Configuration options for initializing the [FricaClient].
class FricaConfig {
  /// The OAuth 2.1 Client ID registered in the Frica Developer Console.
  final String clientId;

  /// The redirect URI registered for this application (e.g. `myapp://oauth-callback`).
  final String redirectUri;

  /// Optional web-specific redirect URI for Flutter Web (e.g. `http://localhost:3000/auth/callback` or `https://web.supfrica.com/auth/callback`).
  /// When running on Flutter Web, this URI takes precedence over custom mobile schemes.
  final String? webRedirectUri;

  /// Base URL of the authoritative Frica ID API backend. Defaults to `https://api.frica.id`.
  final String issuerUrl;

  /// Base URL of the user-facing Frica ID auth portal. Defaults to `https://frica.id`.
  final String portalUrl;

  /// Default scopes requested during authorization. Defaults to `openid profile email`.
  final String defaultScope;

  /// Optional custom token storage engine. Defaults to [InMemoryTokenStorage].
  final TokenStorage? storage;

  const FricaConfig({
    required this.clientId,
    required this.redirectUri,
    this.webRedirectUri,
    this.issuerUrl = 'https://api.frica.id',
    this.portalUrl = 'https://frica.id',
    this.defaultScope = 'openid profile email',
    this.storage,
  });
}
