/// Sovereign Frica Wallet holding FRICA tokens (1 FRICA = 1 USD).
class FricaWallet {
  final String id;
  final String ownerId;
  final String ownerType;
  final String currency;
  final double availableBalance;
  final double lockedBalance;
  final double totalToppedUp;
  final String? createdAt;
  final String? updatedAt;

  const FricaWallet({
    required this.id,
    required this.ownerId,
    required this.ownerType,
    required this.currency,
    required this.availableBalance,
    required this.lockedBalance,
    required this.totalToppedUp,
    this.createdAt,
    this.updatedAt,
  });

  /// Approximate number of commercial KYC verification checks available (0.45 FRICA per check).
  int get remainingKycChecks => (availableBalance / 0.45).floor();

  factory FricaWallet.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return FricaWallet(
      id: (json['id'] ?? json['walletId'] ?? '').toString(),
      ownerId: (json['ownerId'] ?? json['owner_id'] ?? '').toString(),
      ownerType: (json['ownerType'] ?? json['owner_type'] ?? 'USER').toString(),
      currency: (json['currency'] ?? 'FRICA').toString(),
      availableBalance: parseNum(json['availableBalance'] ?? json['balance'] ?? json['available_balance']),
      lockedBalance: parseNum(json['lockedBalance'] ?? json['locked_balance']),
      totalToppedUp: parseNum(json['totalToppedUp'] ?? json['total_topped_up']),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerId': ownerId,
        'ownerType': ownerType,
        'currency': currency,
        'availableBalance': availableBalance,
        'lockedBalance': lockedBalance,
        'totalToppedUp': totalToppedUp,
        'remainingKycChecks': remainingKycChecks,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

/// Ledger transaction record in Frica Wallet.
class FricaWalletTransaction {
  final String id;
  final String walletId;
  final double amount;
  final double balanceBefore;
  final double balanceAfter;
  final String type;
  final String status;
  final String reference;
  final String? paymentMethod;
  final String? description;
  final Map<String, dynamic>? metadata;
  final String createdAt;

  const FricaWalletTransaction({
    required this.id,
    required this.walletId,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.type,
    required this.status,
    required this.reference,
    this.paymentMethod,
    this.description,
    this.metadata,
    required this.createdAt,
  });

  factory FricaWalletTransaction.fromJson(Map<String, dynamic> json) {
    double parseNum(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return FricaWalletTransaction(
      id: (json['id'] ?? '').toString(),
      walletId: (json['walletId'] ?? json['wallet_id'] ?? '').toString(),
      amount: parseNum(json['amount']),
      balanceBefore: parseNum(json['balanceBefore'] ?? json['balance_before']),
      balanceAfter: parseNum(json['balanceAfter'] ?? json['balance_after']),
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reference: (json['reference'] ?? '').toString(),
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      description: json['description']?.toString(),
      metadata: json['metadata'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: (json['createdAt'] ?? json['created_at'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'walletId': walletId,
        'amount': amount,
        'balanceBefore': balanceBefore,
        'balanceAfter': balanceAfter,
        'type': type,
        'status': status,
        'reference': reference,
        'paymentMethod': paymentMethod,
        'description': description,
        'metadata': metadata,
        'createdAt': createdAt,
      };
}

/// Result of digital passport authenticity verification.
class FricaPassportVerificationResult {
  final bool verified;
  final String identifier;
  final String? fullName;
  final String? country;
  final String? status;
  final String? tier;
  final String? issuedAt;
  final String? expiresAt;
  final String? message;

  const FricaPassportVerificationResult({
    required this.verified,
    required this.identifier,
    this.fullName,
    this.country,
    this.status,
    this.tier,
    this.issuedAt,
    this.expiresAt,
    this.message,
  });

  factory FricaPassportVerificationResult.fromJson(Map<String, dynamic> json) {
    return FricaPassportVerificationResult(
      verified: json['verified'] == true,
      identifier: (json['identifier'] ?? '').toString(),
      fullName: json['fullName']?.toString() ?? json['name']?.toString(),
      country: json['country']?.toString(),
      status: json['status']?.toString(),
      tier: json['tier']?.toString(),
      issuedAt: json['issuedAt']?.toString() ?? json['issued_at']?.toString(),
      expiresAt: json['expiresAt']?.toString() ?? json['expires_at']?.toString(),
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'verified': verified,
        'identifier': identifier,
        'fullName': fullName,
        'country': country,
        'status': status,
        'tier': tier,
        'issuedAt': issuedAt,
        'expiresAt': expiresAt,
        'message': message,
      };
}
