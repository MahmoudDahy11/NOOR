import 'package:bloc/bloc.dart';

import '../../../domain/repo/otp_repo.dart';
import 'otp_state.dart';

class OtpCubit extends Cubit<OtpState> {
  final OtpRepository otpRepository;

  OtpCubit(this.otpRepository) : super(OtpInitial());

  Future<void> sendOtp({required String uid, required String email}) async {
    if (isClosed) return;
    emit(OtpLoading());
    if (isClosed) return;
    try {
      await otpRepository.sendOtp(uid: uid, email: email);
      emit(OtpSent());
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }

  Future<void> verifyOtp({
    required String uid,
    required String enteredOtp,
  }) async {
    if (isClosed) return;
    emit(OtpLoading());
    if (isClosed) return;
    try {
      final valid = await otpRepository.verifyOtp(
        uid: uid,
        enteredOtp: enteredOtp,
      );
      if (valid) {
        emit(OtpVerified());
      } else {
        emit(const OtpError("رمز التحقق غير صحيح أو منتهي الصلاحية"));
      }
    } catch (e) {
      emit(OtpError(e.toString()));
    }
  }

  Future<bool> canResendOtp({required String uid}) async {
    return await otpRepository.canResendOtp(uid: uid);
  }
}
