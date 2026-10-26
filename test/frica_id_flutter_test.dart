import 'package:flutter_test/flutter_test.dart';
import 'package:frica_id_flutter/frica_id_flutter.dart';

void main() {
  test('Public Frica ID is optional, round-trips and remains separate from subject', () {
    const subject = 'usr_opaque_account_reference';
    for (final claims in <Map<String, dynamic>>[
      {'public_id': 'FID-7K9MX4QP2N8C'},
      {'publicId': 'FID-7K9MX4QP2N8C'},
      {'public_id': 'FID-7K9MX4QP2N8C', 'publicId': 'stale-alias'},
      {},
      {'public_id': 42, 'publicId': false},
    ]) {
      final expected = claims['public_id'] is String || claims['publicId'] is String
          ? 'FID-7K9MX4QP2N8C' : null;
      final user = FricaUserInfo.fromJson({
        'sub': subject,
        'name': 'Frica member',
        'picture': 'https://api.frica.id/users/FID-7K9MX4QP2N8C/avatar',
        ...claims,
      });
      expect(user.publicId, expected);
      expect(user.sub, subject);
      expect(user.avatarUrl, startsWith('https://api.frica.id/users/'));
      expect(user.toJson()['public_id'], expected);
      expect(FricaUserInfo.fromJson(user.toJson()).publicId, expected);
      expect(user.rawClaims['sub'], subject);
    }
  });

  group('PKCE Tests', () {
    test('generateCodeVerifier creates valid RFC 7636 verifier', () {
      final verifier = FricaPkce.generateCodeVerifier(64);
      expect(verifier.length, equals(64));
      expect(RegExp(r'^[A-Za-z0-9\-._~]+$').hasMatch(verifier), isTrue);
    });

    test('generateCodeChallenge generates valid S256 challenge', () {
      final verifier = FricaPkce.generateCodeVerifier(64);
      final challenge = FricaPkce.generateCodeChallenge(verifier);
      expect(challenge.length, greaterThanOrEqualTo(43));
      expect(challenge.contains('='), isFalse); // No base64 padding
    });
  });

  group('FricaUserInfo KYC Claims Tests', () {
    test('parses KYC claims and helper properties correctly', () {
      final json = {
        'sub': 'frica_usr_998877',
        'name': 'Kwame Mensah',
        'email': 'kwame@example.com',
        'email_verified': true,
        'country': 'GH',
        'kyc_status': 'APPROVED',
        'kyc_tier': 'TIER_2',
        'kyc_verified_at': '2026-10-13T10:30:00Z',
        'kyc_legal_first_name': 'Kwame',
        'kyc_legal_last_name': 'Mensah',
        'kyc_date_of_birth': '1992-08-20',
        'kyc_nationality': 'GH',
        'kyc_country_of_residence': 'GH',
      };

      final user = FricaUserInfo.fromJson(json);

      expect(user.sub, equals('frica_usr_998877'));
      expect(user.name, equals('Kwame Mensah'));
      expect(user.email, equals('kwame@example.com'));
      expect(user.emailVerified, isTrue);
      expect(user.kycStatus, equals('APPROVED'));
      expect(user.kycTier, equals('TIER_2'));
      expect(user.kycVerifiedAt, equals('2026-10-13T10:30:00Z'));
      expect(user.kycLegalFirstName, equals('Kwame'));
      expect(user.kycLegalLastName, equals('Mensah'));
      expect(user.kycNationality, equals('GH'));

      expect(user.isKycApproved, isTrue);
      expect(user.isKycUnderReview, isFalse);
      expect(user.isKycPending, isFalse);
      expect(user.isKycRejected, isFalse);

      final exported = user.toJson();
      expect(exported['kyc_status'], equals('APPROVED'));
      expect(exported['kyc_tier'], equals('TIER_2'));
    });

    test('correctly identifies UNDER_REVIEW status', () {
      final json = {
        'sub': 'frica_usr_112233',
        'name': 'Zainab Ahmed',
        'email': 'zainab@example.com',
        'kyc_status': 'UNDER_REVIEW',
        'kyc_tier': 'TIER_1',
      };

      final user = FricaUserInfo.fromJson(json);

      expect(user.isKycApproved, isFalse);
      expect(user.isKycUnderReview, isTrue);
      expect(user.isKycPending, isFalse);
      expect(user.isKycRejected, isFalse);
    });
  });

  group('Developer KYC Models Tests', () {
    test('FricaKycSession serialization', () {
      final sessionJson = {
        'sessionId': 'kyc_sess_12345',
        'clientSecret': 'sec_abc',
        'hostedUrl': 'https://frica.id/verify?session=kyc_sess_12345',
        'expiresAt': '2026-10-14T00:00:00Z',
        'requestedTier': 'TIER_2',
      };

      final session = FricaKycSession.fromJson(sessionJson);
      expect(session.sessionId, equals('kyc_sess_12345'));
      expect(session.hostedUrl, equals('https://frica.id/verify?session=kyc_sess_12345'));
      expect(session.requestedTier, equals('TIER_2'));
    });

    test('FricaKycVerification serialization', () {
      final verificationJson = {
        'verificationId': 'ver_987',
        'userId': 'usr_456',
        'status': 'APPROVED',
        'tier': 'TIER_2',
        'reviewedAt': '2026-10-13T18:00:00Z',
        'claims': {
          'legalFirstName': 'Amina',
          'legalLastName': 'Bello',
        },
      };

      final verification = FricaKycVerification.fromJson(verificationJson);
      expect(verification.verificationId, equals('ver_987'));
      expect(verification.status, equals('APPROVED'));
      expect(verification.claims?['legalFirstName'], equals('Amina'));
    });

    test('FricaInstantCheckResult serialization', () {
      final checkJson = {
        'verified': true,
        'confidenceScore': 0.98,
        'matchDetails': {'nameMatched': true, 'dobMatched': true},
        'providerReference': 'ref_nid_5544',
      };

      final result = FricaInstantCheckResult.fromJson(checkJson);
      expect(result.verified, isTrue);
      expect(result.confidenceScore, equals(0.98));
      expect(result.providerReference, equals('ref_nid_5544'));
    });
  });

  group('Wallet & Token Models Tests', () {
    test('FricaWallet deserialization and remaining checks getter', () {
      final json = {
        'id': 'wal_dev_123',
        'ownerId': 'app_456',
        'ownerType': 'DEVELOPER_ORG',
        'currency': 'FRICA',
        'availableBalance': 45.0,
        'lockedBalance': 0.0,
        'totalToppedUp': 50.0,
      };

      final wallet = FricaWallet.fromJson(json);
      expect(wallet.id, equals('wal_dev_123'));
      expect(wallet.availableBalance, equals(45.0));
      expect(wallet.currency, equals('FRICA'));
      // 45.0 / 0.45 = 100 verification checks
      expect(wallet.remainingKycChecks, equals(100));

      final serialized = wallet.toJson();
      expect(serialized['availableBalance'], equals(45.0));
      expect(serialized['remainingKycChecks'], equals(100));
    });

    test('FricaWalletTransaction deserialization', () {
      final txJson = {
        'id': 'tx_9988',
        'walletId': 'wal_dev_123',
        'amount': 0.45,
        'balanceBefore': 45.0,
        'balanceAfter': 44.55,
        'type': 'KYC_DEDUCTION',
        'status': 'COMPLETED',
        'reference': 'ref_tx_9988',
        'createdAt': '2026-10-14T12:00:00Z',
      };

      final tx = FricaWalletTransaction.fromJson(txJson);
      expect(tx.id, equals('tx_9988'));
      expect(tx.amount, equals(0.45));
      expect(tx.balanceAfter, equals(44.55));
      expect(tx.type, equals('KYC_DEDUCTION'));
    });

    test('FricaPassportVerificationResult deserialization', () {
      final passportJson = {
        'verified': true,
        'identifier': 'FRICA-PASSPORT-KWAME-001',
        'fullName': 'Kwame Mensah',
        'country': 'GH',
        'status': 'APPROVED',
      };

      final passport = FricaPassportVerificationResult.fromJson(passportJson);
      expect(passport.verified, isTrue);
      expect(passport.identifier, equals('FRICA-PASSPORT-KWAME-001'));
      expect(passport.fullName, equals('Kwame Mensah'));
    });
  });
}

