part of 'profile_cubit.dart';

enum ProfileLoadStatus { initial, loading, loaded, failure }

enum ProfileActionStatus { idle, saving, startingRoom, signingOut }

enum ProfileOutcome { none, updated, roomStarted, signedOut, error }

@immutable
class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.loadStatus = ProfileLoadStatus.initial,
    this.actionStatus = ProfileActionStatus.idle,
    this.outcome = ProfileOutcome.none,
    this.message,
    this.startedRoomId,
    this.reactionId = 0,
  });

  final ProfileEntity? profile;
  final ProfileLoadStatus loadStatus;
  final ProfileActionStatus actionStatus;
  final ProfileOutcome outcome;
  final String? message;
  final String? startedRoomId;
  final int reactionId;

  bool get isInitialLoading =>
      profile == null && loadStatus == ProfileLoadStatus.loading;
  bool get isSaving => actionStatus == ProfileActionStatus.saving;
  bool get isStartingRoom => actionStatus == ProfileActionStatus.startingRoom;

  ProfileState copyWith({
    ProfileEntity? profile,
    ProfileLoadStatus? loadStatus,
    ProfileActionStatus? actionStatus,
    ProfileOutcome? outcome,
    String? message,
    String? startedRoomId,
    int? reactionId,
  }) => ProfileState(
    profile: profile ?? this.profile,
    loadStatus: loadStatus ?? this.loadStatus,
    actionStatus: actionStatus ?? this.actionStatus,
    outcome: outcome ?? this.outcome,
    message: message,
    startedRoomId: startedRoomId ?? this.startedRoomId,
    reactionId: reactionId ?? this.reactionId,
  );

  @override
  List<Object?> get props => [
    profile,
    loadStatus,
    actionStatus,
    outcome,
    message,
    startedRoomId,
    reactionId,
  ];
}
