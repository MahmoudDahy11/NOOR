import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../cubit/profile_cubit.dart';

Future<void> showProfileSignOutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text(AppStrings.signOut),
      content: const Text(AppStrings.signOutConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            context.read<ProfileCubit>().signOut();
          },
          child: const Text(
            AppStrings.signOut,
            style: TextStyle(color: AppColors.error),
          ),
        ),
      ],
    ),
  );
}
