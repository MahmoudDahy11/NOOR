import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';
import 'avatar_constants.dart';

class AvatarPickerWidget extends StatelessWidget {
  final String selectedAvatar;
  final ValueChanged<String> onSelected;

  const AvatarPickerWidget({
    super.key,
    required this.selectedAvatar,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: AvatarConstants.all.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemBuilder: (_, i) {
        final path = AvatarConstants.all[i];
        final isSelected = path == selectedAvatar;
        return GestureDetector(
          onTap: () => onSelected(path),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.gold : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: ClipOval(child: SvgPicture.asset(path, fit: BoxFit.cover)),
          ),
        );
      },
    );
  }
}
