abstract class OtpRepository {
  /* 
   * Method to send OTP to the user's email
   * takes the user's uid and email as parameters
   * returns a Future that completes when the OTP is sent
   */
  Future<void> sendOtp({required String uid, required String email});
  /* 
   * Method to verify the entered OTP
   * returns a boolean indicating if the OTP is correct or not
   */
  Future<bool> verifyOtp({required String uid, required String enteredOtp});
  /* 
   * Method to check if the user can resend OTP
   * returns a boolean indicating if the user can resend OTP or not
   */
  Future<bool> canResendOtp({required String uid});
}
