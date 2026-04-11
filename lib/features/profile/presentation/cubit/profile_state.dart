part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}
class ProfileLoading extends ProfileState {}
class ProfileSuccess extends ProfileState {
  final ProfileEntity profile;
  ProfileSuccess({required this.profile});
}
class ProfileUpdateSuccess extends ProfileState {}
class ProfileError extends ProfileState {
  final String message;
  ProfileError({required this.message});
}
class ProfileSignOutSuccess extends ProfileState {}
