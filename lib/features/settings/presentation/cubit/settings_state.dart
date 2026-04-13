part of 'settings_cubit.dart';

@immutable
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class DeleteAccountSuccess extends SettingsState {}

class SettingsError extends SettingsState {
  final String message;
  SettingsError({required this.message});
}
