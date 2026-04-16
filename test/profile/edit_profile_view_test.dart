import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_islamic/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tally_islamic/features/profile/presentation/widgets/edit_profile_view.dart';

import 'profile_support.dart';

void main() {
  testWidgets(
    'edit profile is prefilled, shows saving, and pops true on success',
    (tester) async {
      final cubit = TestProfileCubit(
        profileRepo: StubProfileRepo(),
        createRoomRepo: StubCreateRoomRepo(),
      );
      cubit.push(
        const ProfileState().copyWith(
          profile: sampleProfile(),
          loadStatus: ProfileLoadStatus.loaded,
        ),
      );
      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider<ProfileCubit>.value(
                      value: cubit,
                      child: const EditProfileView(),
                    ),
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final nameField = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(nameField.controller.text, 'Maha');
      cubit.push(
        const ProfileState().copyWith(
          profile: sampleProfile(),
          loadStatus: ProfileLoadStatus.loaded,
          actionStatus: ProfileActionStatus.saving,
        ),
      );
      await tester.pump();
      expect(cubit.state.isSaving, isTrue);
      cubit.push(
        const ProfileState().copyWith(
          profile: sampleProfile(),
          loadStatus: ProfileLoadStatus.loaded,
          outcome: ProfileOutcome.updated,
          reactionId: 1,
        ),
      );
      await tester.pumpAndSettle();
      expect(result, isTrue);
    },
  );
}
