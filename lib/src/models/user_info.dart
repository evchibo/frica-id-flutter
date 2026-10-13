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

  /// KYC verification status (`NOT_STARTED`, `PENDING`, `UNDER_REVIEW`, `APPROVED`, `REJECTED`, `EXPIRED`).
  final String? kycStatus;

  /// KYC tier achieved (`TIER_0`, `TIER_1`, `TIER_2`, `TIER_3`).
  final String? kycTier;

  /// Timestamp when KYC verification was approved/completed.
  final String? kycVerifiedAt;

  /// Legal first name from verified identity document (requires `kyc.identity` scope).
  final String? kycLegalFirstName;

  /// Legal last name from verified identity document (requires `kyc.identity` scope).
  final String? kycLegalLastName;

  /// Date of birth from verified identity document (requires `kyc.identity` scope).
  final String? kycDateOfBirth;

  /// Verified nationality country code (requires `kyc.identity` scope).
  final String? kycNationality;

  /// Verified country of residence (requires `kyc.identity` scope).
  final String? kycCountryOfResidence;

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
    this.kycStatus,
    this.kycTier,
    this.kycVerifiedAt,
    this.kycLegalFirstName,
    this.kycLegalLastName,
    this.kycDateOfBirth,
    this.kycNationality,
    this.kycCountryOfResidence,
    this.rawClaims = const {},
  });

  /// Whether KYC verification has been officially approved.
  bool get isKycApproved => kycStatus?.toUpperCase() == 'APPROVED';

  /// Whether KYC verification is currently under compliance officer review.
  bool get isKycUnderReview => kycStatus?.toUpperCase() == 'UNDER_REVIEW';

  /// Whether KYC submission is pending.
  bool get isKycPending => kycStatus?.toUpperCase() == 'PENDING';

  /// Whether KYC submission was rejected.
  bool get isKycRejected => kycStatus?.toUpperCase() == 'REJECTED';

  factory FricaUserInfo.fromJson(Map<String, dynamic> json) {
    return FricaUserInfo(
      sub: (json['sub'] ?? json['id'] ?? '')?.toString() ?? '',
      name: (json['name'] ?? json['preferred_username'] ?? '')?.toString() ?? '',
      email: (json['email'] ?? json['email_address'] ?? '')?.toString() ?? '',
      emailVerified: json['email_verified'] == true ||
          json['emailVerified'] == true,
      phoneNumber: (json['phone_number'] ?? json['phoneNumber'] ?? json['phone'])?.toString(),
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl'] ?? json['picture'])?.toString(),
      country: json['country']?.toString(),
      role: json['role']?.toString(),
      status: json['status']?.toString(),
      kycStatus: (json['kyc_status'] ?? json['kycStatus'])?.toString(),
      kycTier: (json['kyc_tier'] ?? json['kycTier'])?.toString(),
      kycVerifiedAt: (json['kyc_verified_at'] ?? json['kycVerifiedAt'])?.toString(),
      kycLegalFirstName: (json['kyc_legal_first_name'] ?? json['kycLegalFirstName'])?.toString(),
      kycLegalLastName: (json['kyc_legal_last_name'] ?? json['kycLegalLastName'])?.toString(),
      kycDateOfBirth: (json['kyc_date_of_birth'] ?? json['kycDateOfBirth'])?.toString(),
      kycNationality: (json['kyc_nationality'] ?? json['kycNationality'])?.toString(),
      kycCountryOfResidence: (json['kyc_country_of_residence'] ?? json['kycCountryOfResidence'])?.toString(),
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
        'kyc_status': kycStatus,
        'kyc_tier': kycTier,
        'kyc_verified_at': kycVerifiedAt,
        'kyc_legal_first_name': kycLegalFirstName,
        'kyc_legal_last_name': kycLegalLastName,
        'kyc_date_of_birth': kycDateOfBirth,
        'kyc_nationality': kycNationality,
        'kyc_country_of_residence': kycCountryOfResidence,
        'raw_claims': rawClaims,
      };
}
