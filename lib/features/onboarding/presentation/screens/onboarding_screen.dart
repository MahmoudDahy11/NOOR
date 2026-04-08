import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../data/models/onboarding_page_model.dart';
import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_content_card.dart';
import '../widgets/onboarding_image_widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: const _OnboardingView(),
    );
  }
}

class _OnboardingView extends StatefulWidget {
  const _OnboardingView();
  @override
  State<_OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<_OnboardingView> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingPageModel> _pages = [
    const OnboardingPageModel(
      imagePath: AppAssets.onboarding1,
      titleRegular: 'Spiritual',
      titleItalic: 'Synergy',
      subtitle: 'PREMIUM. SAFE FOR WORK.',
      body: AppStrings.onboarding1Body,
    ),
    const OnboardingPageModel(
      imagePath: AppAssets.onboarding2,
      titleRegular: 'The Golden',
      titleItalic: 'Ticket',
      subtitle: 'PREMIUM. SAFE FOR WORK.',
      body: AppStrings.onboarding2Body,
    ),
    const OnboardingPageModel(
      imagePath: AppAssets.onboarding3,
      titleRegular: 'Count Your',
      titleItalic: 'Way',
      subtitle: 'KNOW WHERE YOUR MONEY GOES.',
      body: AppStrings.onboarding3Body,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _currentIndex = i),
              itemBuilder: (_, i) =>
                  OnboardingImageWidget(imagePath: _pages[i].imagePath),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: OnboardingContentCard(
              page: _pages[_currentIndex],
              currentIndex: _currentIndex,
              totalPages: _pages.length,
              onNext: () {
                if (_currentIndex < _pages.length - 1) {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                } else {
                  context.read<OnboardingCubit>().finish();
                  context.go(AppRouter.auth);
                }
              },
              onSkip: () => context.go(AppRouter.auth),
            ),
          ),
        ],
      ),
    );
  }
}
