/// Result of creating a hosted KYC verification session.
class FricaKycSession {
  final String sessionId;
  final String clientSecret;
  final String hostedUrl;
  final String? expiresAt;
  final String? targetUserId;
  final String? requestedTier;

  const FricaKycSession({
    required this.sessionId,
    required this.clientSecret,
    required this.hostedUrl,
    this.expiresAt,
    this.targetUserId,
    this.requestedTier,
  });

  factory FricaKycSession.fromJson(Map<String, dynamic> json) {
    return FricaKycSession(
      sessionId: (json['sessionId'] ?? json['session_id'] ?? '').toString(),
      clientSecret: (json['clientSecret'] ?? json['client_secret'] ?? '').toString(),
      hostedUrl: (json['hostedUrl'] ?? json['hosted_url'] ?? '').toString(),
      expiresAt: json['expiresAt']?.toString() ?? json['expires_at']?.toString(),
      targetUserId: json['targetUserId']?.toString() ?? json['target_user_id']?.toString(),
      requestedTier: json['requestedTier']?.toString() ?? json['requested_tier']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'clientSecret': clientSecret,
        'hostedUrl': hostedUrl,
        'expiresAt': expiresAt,
        'targetUserId': targetUserId,
        'requestedTier': requestedTier,
      };
}

/// Detailed KYC verification session status and reviewed claims.
class FricaKycVerification {
  final String verificationId;
  final String userId;
  final String status;
  final String tier;
  final String? submittedAt;
  final String? reviewedAt;
  final String? rejectionReason;
  final Map<String, dynamic>? claims;

  const FricaKycVerification({
    required this.verificationId,
    required this.userId,
    required this.status,
    required this.tier,
    this.submittedAt,
    this.reviewedAt,
    this.rejectionReason,
    this.claims,
  });

  factory FricaKycVerification.fromJson(Map<String, dynamic> json) {
    return FricaKycVerification(
      verificationId: (json['verificationId'] ?? json['verification_id'] ?? json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      tier: (json['tier'] ?? '').toString(),
      submittedAt: json['submittedAt']?.toString() ?? json['submitted_at']?.toString(),
      reviewedAt: json['reviewedAt']?.toString() ?? json['reviewed_at']?.toString(),
      rejectionReason: json['rejectionReason']?.toString() ?? json['rejection_reason']?.toString(),
      claims: json['claims'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['claims'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'verificationId': verificationId,
        'userId': userId,
        'status': status,
        'tier': tier,
        'submittedAt': submittedAt,
        'reviewedAt': reviewedAt,
        'rejectionReason': rejectionReason,
        'claims': claims,
      };
}

/// Instant KYC identity verification result.
class FricaInstantCheckResult {
  final bool verified;
  final double? confidenceScore;
  final Map<String, dynamic>? matchDetails;
  final String? providerReference;

  const FricaInstantCheckResult({
    required this.verified,
    this.confidenceScore,
    this.matchDetails,
    this.providerReference,
  });

  factory FricaInstantCheckResult.fromJson(Map<String, dynamic> json) {
    return FricaInstantCheckResult(
      verified: json['verified'] == true,
      confidenceScore: json['confidenceScore'] is num
          ? (json['confidenceScore'] as num).toDouble()
          : (json['confidence_score'] is num ? (json['confidence_score'] as num).toDouble() : null),
      matchDetails: json['matchDetails'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['matchDetails'] as Map)
          : (json['match_details'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['match_details'] as Map) : null),
      providerReference: json['providerReference']?.toString() ?? json['provider_reference']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'verified': verified,
        'confidenceScore': confidenceScore,
        'matchDetails': matchDetails,
        'providerReference': providerReference,
      };
}
