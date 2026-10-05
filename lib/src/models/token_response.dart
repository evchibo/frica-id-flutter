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
    final payload = (json.containsKey('data') && json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    final expiresIn = payload['expires_in'] is num
        ? (payload['expires_in'] as num).toInt()
        : int.tryParse(payload['expires_in']?.toString() ?? '') ?? 3600;
    DateTime? expAt;
    if (payload['expires_at'] != null) {
      expAt = DateTime.tryParse(payload['expires_at'].toString());
    }

    return FricaTokenResponse(
      accessToken: (payload['access_token'] ?? payload['accessToken'] ?? '')?.toString() ?? '',
      tokenType: (payload['token_type'] ?? payload['tokenType'] ?? 'Bearer')?.toString() ?? 'Bearer',
      expiresIn: expiresIn,
      refreshToken: (payload['refresh_token'] ?? payload['refreshToken'])?.toString(),
      idToken: (payload['id_token'] ?? payload['idToken'])?.toString(),
      scope: payload['scope']?.toString(),
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
