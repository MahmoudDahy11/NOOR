# 🔴 Critical Fixes Required — Phase 2 Integration

## 1. OtpPage — Missing Firebase UID

**File:** `lib/features/auth/presentation/pages/otp_page.dart` (Line 45)

**Current Code (BROKEN):**

```dart
void _handleVerifyOtp() {
  final otp = _getOtpCode();
  if (otp.length != 4) {
    showSnakBar(context, "Please enter all 4 digits", isError: true);
    return;
  }
  // TODO: Get uid from somewhere (Firebase auth or shared preferences)
  context.read<OtpCubit>().verifyOtp(uid: '', enteredOtp: otp);  // ❌ Empty UID!
}
```

**Required Fix:**

```dart
import 'package:firebase_auth/firebase_auth.dart';

void _handleVerifyOtp() {
  final otp = _getOtpCode();
  if (otp.length != 4) {
    showSnakBar(context, "Please enter all 4 digits", isError: true);
    return;
  }

  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    showSnakBar(context, "User authentication required", isError: true);
    return;
  }

  context.read<OtpCubit>().verifyOtp(uid: userId, enteredOtp: otp);
}
```

**Why Important:** Without the UID, OTP verification will always fail. This breaks the entire auth flow.

---

## 2. OtpPage — Resend OTP Not Implemented

**File:** `lib/features/auth/presentation/pages/otp_page.dart` (Line 51-58)

**Current Code (MOCKED):**

```dart
Widget _buildResendSection() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Didn't receive code? "),
      TextButton(
        onPressed: () {
          // TODO: Call resendOtp method
          showSnakBar(context, "Code resent to your email");  // ❌ Fake!
        },
        child: const Text(
          "Resend",
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    ],
  );
}
```

**Required Fix:**

```dart
Widget _buildResendSection() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Didn't receive code? "),
      TextButton(
        onPressed: () => _handleResendOtp(),
        child: const Text(
          "Resend",
          style: TextStyle(color: AppColors.primary),
        ),
      ),
    ],
  );
}

void _handleResendOtp() {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    showSnakBar(context, "User authentication required", isError: true);
    return;
  }

  final userEmail = FirebaseAuth.instance.currentUser?.email;
  if (userEmail == null) {
    showSnakBar(context, "User email not found", isError: true);
    return;
  }

  context.read<OtpCubit>().sendOtp(uid: userId, email: userEmail);
}
```

**Why Important:** Users need ability to request new OTP if they didn't receive the first one.

---

## 3. ResetPasswordPage — Architecture Mismatch

**File:** `lib/features/auth/presentation/pages/reset_password_page.dart` (Line 38-42)

**Current Code (BROKEN):**

```dart
void _handleSendLink() {
  // TODO: Implement send password reset email/OTP logic
  // For now, navigate to OTP page after showing message
  showSnakBar(context, "Password reset link sent to your email");
  context.pushNamed(AppRouter.otpRoute);
}
```

**Problem:** The current `forgetPassword()` cubit method requires an authenticated user (uses `FirebaseAuth.instance.currentUser`), but the ResetPasswordPage flow is for **unauthenticated users who forgot their password**.

### Option A: Add New Cubit Method (RECOMMENDED)

**Step 1: Update `FirebaseAuthRepo` (abstract class)**
File: `lib/features/auth/domain/repo/auth_repo.dart`

```dart
abstract class FirebaseAuthRepo {
  // ... existing methods ...

  Future<Either<CustomFailure, Unit>> sendPasswordResetEmail({
    required String email,
  });
}
```

**Step 2: Implement in `FirebaseAuthRepoImplement`**
File: `lib/features/auth/data/repo/auth_repo_implement.dart`

```dart
@override
Future<Either<CustomFailure, Unit>> sendPasswordResetEmail({
  required String email,
}) async {
  try {
    final otp = _otpService.generateOtp();
    // Store OTP with email (create new method in OtpService or Firestore)
    await _otpService.saveOtpForEmail(email, otp);
    await _otpService.sendOtpToEmail(email, otp);

    return right(unit);
  } on CustomException catch (ex) {
    return left(CustomFailure(errMessage: ex.errMessage));
  } catch (e) {
    return left(CustomFailure(errMessage: e.toString()));
  }
}
```

**Step 3: Add method to `ForgetPasswordCubit`**
File: `lib/features/auth/presentation/cubits/forget_password_cubit/forget_password_cubit.dart`

```dart
Future<void> sendPasswordResetEmail(String email) async {
  emit(ForgetPasswordLoading());
  final result = await _firebaseAuthrepo.sendPasswordResetEmail(email: email);
  result.fold(
    (failure) => emit(ForgetPasswordFailure(errMessage: failure.errMessage)),
    (_) => emit(const ForgetPasswordSuccess(message: 'تم إرسال رمز التحقق إلى بريدك الإلكتروني')),
  );
}
```

**Step 4: Update ResetPasswordPage**

```dart
void _handleSendLink() {
  final email = _emailController.text.trim();
  if (email.isEmpty) {
    showSnakBar(context, "Please enter your email", isError: true);
    return;
  }

  context.read<ForgetPasswordCubit>().sendPasswordResetEmail(email);
}
```

### Option B: Extend OTP Cubit (ALTERNATIVE)

Create a separate flow that stores `email` → `uid` mapping during OTP verification for reset password.

---

## 4. Import Statement for Firebase Auth

**File:** `lib/features/auth/presentation/pages/otp_page.dart`

Add at top:

```dart
import 'package:firebase_auth/firebase_auth.dart';
```

---

## 5. Complete Fixed OtpPage Code

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helper/show_snak_bar.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_gradient_button.dart';
import '../cubits/otp_cubit/otp_cubit.dart';
import '../cubits/otp_cubit/otp_state.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getOtpCode() => _controllers.map((c) => c.text).join();

  void _handleVerifyOtp() {
    final otp = _getOtpCode();
    if (otp.length != 4) {
      showSnakBar(context, "Please enter all 4 digits", isError: true);
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showSnakBar(context, "User authentication required", isError: true);
      return;
    }

    context.read<OtpCubit>().verifyOtp(uid: userId, enteredOtp: otp);
  }

  void _handleResendOtp() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showSnakBar(context, "User authentication required", isError: true);
      return;
    }

    final userEmail = FirebaseAuth.instance.currentUser?.email;
    if (userEmail == null) {
      showSnakBar(context, "User email not found", isError: true);
      return;
    }

    context.read<OtpCubit>().sendOtp(uid: userId, email: userEmail);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocListener<OtpCubit, OtpState>(
          listener: (context, state) {
            if (state is OtpVerified) {
              context.go('/');
            } else if (state is OtpError) {
              showSnakBar(context, state.errmessage, isError: true);
            } else if (state is OtpSent) {
              showSnakBar(context, "OTP sent to your email");
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Text(
                  "OTP Verification",
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Enter the 4-digit code sent to your email",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _buildOtpFields(),
                const SizedBox(height: 48),
                BlocBuilder<OtpCubit, OtpState>(
                  builder: (context, state) => CustomGradientButton(
                    text: "Verify",
                    isLoading: state is OtpLoading,
                    onPressed: _handleVerifyOtp,
                  ),
                ),
                const SizedBox(height: 24),
                _buildResendSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) => _otpBox(index)),
    );
  }

  Widget _otpBox(int index) {
    return SizedBox(
      width: 60,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.textHint),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildResendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Didn't receive code? "),
        TextButton(
          onPressed: _handleResendOtp,
          child: const Text(
            "Resend",
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
```

---

## Priority Order

1. **MUST FIX:** Fix OtpPage UID issue (breaks entire auth flow)
2. **MUST FIX:** Implement Resend OTP
3. **MUST FIX:** Resolve ResetPasswordPage architecture
4. **SHOULD FIX:** Add input validation to all forms
5. **NICE-TO-HAVE:** Implement Apple Sign-In

---

## Testing Command

After fixes, test with:

```bash
cd /home/mahmoud-dahy/Flutter\ Projects/tally_islamic
flutter clean
flutter pub get
flutter run
```

---

**Status:** 🔴 Not Production Ready - Awaiting Critical Fixes
