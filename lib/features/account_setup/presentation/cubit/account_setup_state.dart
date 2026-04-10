part of 'account_setup_cubit.dart';

@immutable
sealed class AccountSetupState {
  const AccountSetupState();
}

final class AccountSetupInitial extends AccountSetupState {}

final class AccountSetupLoading extends AccountSetupState {}

final class AccountSetupSuccess extends AccountSetupState {}

final class AccountSetupFailure extends AccountSetupState {
  final String message;
  const AccountSetupFailure(this.message);
}
