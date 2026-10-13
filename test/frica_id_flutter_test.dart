import 'package:flutter_test/flutter_test.dart';
import 'package:frica_id_flutter/frica_id_flutter.dart';

void main() {
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
}
