import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../account_setup/data/models/user_profile_model.dart';
import '../../../account_setup/domain/entities/user_profile_entity.dart';
import '../../../auth/data/service/firebase_auth.dart';
import '../../../auth/data/service/local_storage.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repos/profile_repo.dart';

class ProfileRepoImpl implements ProfileRepo {
  final FirebaseService _firebaseService;

  ProfileRepoImpl({required FirebaseService firebaseService})
      : _firebaseService = firebaseService;

  @override
  Future<Either<CustomFailure, ProfileEntity>> getProfile(String uid) async {
    try {
      final doc = await _firebaseService.firestoreInstance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return Left(CustomFailure(errMessage: 'User profile not found'));
      }

      final userModel = UserProfileModel.fromFirestore(doc.data()!);

      // Currently stats are placeholders, ready to be connected to Firestore
      final profile = ProfileEntity(
        user: userModel,
        roomsJoined: 0,
        totalCounts: 0,
        roomsCreated: 0,
      );

      return Right(profile);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> updateProfile(UserProfileEntity profile) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _firebaseService.firestoreInstance
          .collection('users')
          .doc(profile.uid)
          .update(model.toFirestore());
      return const Right(null);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, void>> signOut() async {
    try {
      await _firebaseService.signOut();
      await LocalStorageService.clearUserData();
      return const Right(null);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }
}
