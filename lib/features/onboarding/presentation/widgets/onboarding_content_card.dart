import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/models/onboarding_page_model.dart';
import 'smooth_dots_indicator.dart';

class OnboardingContentCard extends StatelessWidget {
  final OnboardingPageModel page;
  final int currentIndex;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const OnboardingContentCard({
    super.key,
    required this.page,
    required this.currentIndex,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTitle(),
          const SizedBox(height: 8),
          if (page.subtitle != null) _buildSubtitle(page.subtitle!),
          const SizedBox(height: 24),
          _buildBody(),
          const SizedBox(height: 32),
          SmoothDotsIndicator(
            totalDots: totalPages,
            currentIndex: currentIndex,
          ),
          const SizedBox(height: 40),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 32,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        children: [
          TextSpan(text: '${page.titleRegular}\n'),
          TextSpan(
            text: page.titleItalic,
            style: const TextStyle(
              color: AppColors.primary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 3, height: 40, color: AppColors.gold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            page.body,
            style: const TextStyle(color: Colors.black54, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton(
          onPressed: onSkip,
          child: const Text('SKIP', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: onNext,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: Text(
            currentIndex == totalPages - 1 ? 'START' : 'NEXT',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
