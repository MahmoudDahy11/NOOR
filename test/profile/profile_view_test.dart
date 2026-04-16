import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tally_islamic/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:tally_islamic/features/profile/presentation/widgets/profile_view.dart';

import 'profile_support.dart';

void main() {
  testWidgets(
    'profile view renders loaded content and shows recoverable errors without blanking',
    (tester) async {
      final cubit = TestProfileCubit(
        profileRepo: StubProfileRepo(),
        createRoomRepo: StubCreateRoomRepo(),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProfileCubit>.value(
            value: cubit,
            child: const ProfileView(),
          ),
        ),
      );
      cubit.push(
        const ProfileState().copyWith(
          profile: sampleProfile(),
          loadStatus: ProfileLoadStatus.loaded,
        ),
      );
      await tester.pump();
      expect(find.text('Morning Circle'), findsOneWidget);
      expect(find.text('Maha'), findsOneWidget);
      cubit.push(
        const ProfileState().copyWith(
          profile: sampleProfile(),
          loadStatus: ProfileLoadStatus.loaded,
          outcome: ProfileOutcome.error,
          message: 'boom',
          reactionId: 1,
        ),
      );
      await tester.pump();
      expect(find.text('Morning Circle'), findsOneWidget);
      expect(find.text('boom'), findsOneWidget);
    },
  );
}
