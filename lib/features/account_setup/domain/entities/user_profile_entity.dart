class UserProfileEntity {
  final String uid;
  final String displayName;
  final String avatarAsset;
  final String bio;
  final List<String> interests;

  const UserProfileEntity({
    required this.uid,
    required this.displayName,
    required this.avatarAsset,
    required this.bio,
    required this.interests,
  });
}
