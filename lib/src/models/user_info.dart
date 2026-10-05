/// Authenticated Frica User Profile Claims.
class FricaUserInfo {
  /// The unique subject ID prefixed with `frica_` (e.g. `frica_00c2...`).
  final String sub;

  /// User's full display name.
  final String name;

  /// User's primary email address.
  final String email;

  /// Whether the user has completed email verification.
  final bool emailVerified;

  /// Verified phone number in E.164 format.
  final String? phoneNumber;

  /// Public URL to the user's avatar image.
  final String? avatarUrl;

  /// User's country code or name.
  final String? country;

  /// System role (e.g. `USER`, `ADMIN`).
  final String? role;

  /// Account status (`ACTIVE`, `SUSPENDED`).
  final String? status;

  /// All raw OpenID Connect claims returned by the userinfo endpoint.
  final Map<String, dynamic> rawClaims;

  const FricaUserInfo({
    required this.sub,
    required this.name,
    required this.email,
    this.emailVerified = false,
    this.phoneNumber,
    this.avatarUrl,
    this.country,
    this.role,
    this.status,
    this.rawClaims = const {},
  });

  factory FricaUserInfo.fromJson(Map<String, dynamic> json) {
    return FricaUserInfo(
      sub: (json['sub'] ?? json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      emailVerified: json['email_verified'] == true ||
          json['emailVerified'] == true,
      phoneNumber: (json['phone_number'] ?? json['phoneNumber']) as String?,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl'] ?? json['picture']) as String?,
      country: json['country'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      rawClaims: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() => {
        'sub': sub,
        'name': name,
        'email': email,
        'email_verified': emailVerified,
        'phone_number': phoneNumber,
        'avatar_url': avatarUrl,
        'country': country,
        'role': role,
        'status': status,
        'raw_claims': rawClaims,
      };
}
