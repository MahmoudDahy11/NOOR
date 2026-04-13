import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../../auth/domain/repo/auth_repo.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final FirebaseAuthRepo _authRepo;

  SettingsCubit(this._authRepo) : super(SettingsInitial());

  Future<void> deleteAccount(String password) async {
    emit(SettingsLoading());
    final result = await _authRepo.deleteUserAccount(password);
    result.fold(
      (failure) => emit(SettingsError(message: failure.errMessage)),
      (_) => emit(DeleteAccountSuccess()),
    );
  }
}
