/// OAuth 2.1 Token Response returned after code exchange or token refresh.
class FricaTokenResponse {
  /// The Bearer access token used to authenticate API requests.
  final String accessToken;

  /// The token type, usually `Bearer`.
  final String tokenType;

  /// Lifetime of the access token in seconds (e.g. 3600).
  final int expiresIn;

  /// Long-lived refresh token used to obtain new access tokens.
  final String? refreshToken;

  /// OpenID Connect JSON Web Token containing signed user identity claims.
  final String? idToken;

  /// The scopes granted for this access token.
  final String? scope;

  /// The calculated expiration timestamp.
  final DateTime expiresAt;

  FricaTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.refreshToken,
    this.idToken,
    this.scope,
    DateTime? expiresAt,
  }) : expiresAt = expiresAt ??
            DateTime.now().add(Duration(seconds: expiresIn));

  /// Checks if the access token has expired (with a 60-second safety margin).
  bool get isExpired =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)));

  factory FricaTokenResponse.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] as int? ?? 3600;
    DateTime? expAt;
    if (json['expires_at'] != null) {
      expAt = DateTime.tryParse(json['expires_at'].toString());
    }

    return FricaTokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: expiresIn,
      refreshToken: json['refresh_token'] as String?,
      idToken: json['id_token'] as String?,
      scope: json['scope'] as String?,
      expiresAt: expAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'refresh_token': refreshToken,
        'id_token': idToken,
        'scope': scope,
        'expires_at': expiresAt.toIso8601String(),
      };
}
