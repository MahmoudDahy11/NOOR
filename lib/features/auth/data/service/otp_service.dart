import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

import '../../../../core/constants/app_keys.dart';
import '../../../../core/env/app_env.dart';

/*
 * OtpService class
 * manages OTP generation, storage, verification, and email sending
 * generates a random 4-digit OTP
 * saves OTP with expiration and resend cooldown in Firestore
 * verifies entered OTP against stored value and checks expiration
 * checks if user can resend OTP based on cooldown
 * sends OTP to user's email using Gmail SMTP server
 */
class OtpService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Duration otpValidity = const Duration(minutes: 15);

  final Duration resendCooldown = const Duration(seconds: 60);

  String generateOtp() {
    final rand = Random.secure();
    return (1000 + rand.nextInt(9000)).toString();
  }

  Future<void> saveOtp(String uid, String otp) async {
    await _firestore.collection(AppKeys.otpsCollection).doc(uid).set({
      AppKeys.otpValue: otp,
      AppKeys.otpCreatedAt: FieldValue.serverTimestamp(),
      AppKeys.otpExpiresAt: DateTime.now().add(otpValidity),
      AppKeys.otpCanResendAt: DateTime.now().add(resendCooldown),
      AppKeys.otpVerified: false,
    });
  }

  Future<bool> verifyOtp(String uid, String enteredOtp) async {
    final snap = await _firestore
        .collection(AppKeys.otpsCollection)
        .doc(uid)
        .get();
    if (!snap.exists) return false;

    final data = snap.data()!;
    final otpValue = data[AppKeys.otpValue];
    final expiresAt = (data[AppKeys.otpExpiresAt] as Timestamp).toDate();

    if (DateTime.now().isAfter(expiresAt)) {
      return false;
    }

    final isValid = otpValue == enteredOtp;

    if (isValid) {
      await _firestore.collection(AppKeys.otpsCollection).doc(uid).update({
        AppKeys.otpVerified: true,
        AppKeys.otpVerifiedAt: FieldValue.serverTimestamp(),
      });
    }

    return isValid;
  }

  Future<bool> canResendOtp(String uid) async {
    final snap = await _firestore
        .collection(AppKeys.otpsCollection)
        .doc(uid)
        .get();
    if (!snap.exists) return true;

    final data = snap.data()!;
    final canResendAt = (data[AppKeys.otpCanResendAt] as Timestamp).toDate();

    return DateTime.now().isAfter(canResendAt);
  }

  Future<bool> isOtpVerified(String uid) async {
    final snap = await _firestore
        .collection(AppKeys.otpsCollection)
        .doc(uid)
        .get();
    if (!snap.exists) return false;

    final data = snap.data()!;
    return data[AppKeys.otpVerified] == true;
  }

  Future<void> sendOtpToEmail(String email, String otp) async {
    final smtpServer = gmail('dahym2028@gmail.com', AppEnv.otpPasswordAccount);

    final message = Message()
      ..from = const Address('dahym2028@gmail.com', 'Suits')
      ..recipients.add(email)
      ..subject = 'Your OTP Code'
      ..text = 'رمز التحقق الخاص بك هو: $otp (صالح لمدة 15 دقائق)';

    try {
      await send(message, smtpServer);
      if (kDebugMode) {
        print('📩 OTP sent to $email');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to send OTP: $e');
      }
      rethrow;
    }
  }
}
