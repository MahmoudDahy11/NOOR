import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:tally_islamic/core/error/failure.dart';

import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/account_setup_repo.dart';
import '../models/user_profile_model.dart';

class AccountSetupRepoImpl implements AccountSetupRepo {
  final FirebaseFirestore _firestore;

  AccountSetupRepoImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Either<CustomFailure, void>> saveProfile(
    UserProfileEntity profile,
  ) async {
    try {
      final model = UserProfileModel.fromEntity(profile);
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(model.toFirestore());
      return right(null);
    } catch (e) {
      return left(CustomFailure(errMessage: e.toString()));
    }
  }

  @override
  Future<Either<CustomFailure, bool>> hasUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return Right(doc.exists);
    } catch (e) {
      return Left(CustomFailure(errMessage: e.toString()));
    }
  }
}
