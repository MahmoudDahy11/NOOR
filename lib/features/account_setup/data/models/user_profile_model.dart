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
        'uid': uid,
        'displayName': displayName,
        'avatarAsset': avatarAsset,
        'bio': bio,
        'interests': interests,
        'createdAt': DateTime.now().toIso8601String(),
      };

  factory UserProfileModel.fromFirestore(Map<String, dynamic> json) =>
      UserProfileModel(
        uid: json['uid'] ?? '',
        displayName: json['displayName'] ?? '',
        avatarAsset: json['avatarAsset'] ?? 'assets/avatars/avatar_1.svg',
        bio: json['bio'] ?? '',
        interests: List<String>.from(json['interests'] ?? []),
      );
}
