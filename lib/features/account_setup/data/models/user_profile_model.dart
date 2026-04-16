import '../../../../core/constants/app_keys.dart';
import '../../domain/entities/user_profile_entity.dart';

class UserProfileModel extends UserProfileEntity {
  const UserProfileModel({
    required super.uid,
    required super.displayName,
    required super.avatarAsset,
    required super.bio,
    required super.interests,
  });

  factory UserProfileModel.fromEntity(UserProfileEntity e) => UserProfileModel(
    uid: e.uid,
    displayName: e.displayName,
    avatarAsset: e.avatarAsset,
    bio: e.bio,
    interests: e.interests,
  );

  Map<String, dynamic> toFirestore() => {
    AppKeys.uId: uid,
    AppKeys.displayName: displayName,
    AppKeys.avatarAsset: avatarAsset,
    AppKeys.bio: bio,
    AppKeys.interests: interests,
  };

  factory UserProfileModel.fromFirestore(Map<String, dynamic> json) =>
      UserProfileModel(
        uid: json[AppKeys.uId] ?? '',
        displayName: json[AppKeys.displayName] ?? '',
        avatarAsset: json[AppKeys.avatarAsset] ?? 'assets/avatars/avatar_1.svg',
        bio: json[AppKeys.bio] ?? '',
        interests: List<String>.from(json[AppKeys.interests] ?? []),
      );
}
