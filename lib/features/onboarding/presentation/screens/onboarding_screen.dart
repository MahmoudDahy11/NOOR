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
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier<int>(0);

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
  void dispose() {
    _pageController.dispose();
    _currentIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (i) => _currentIndexNotifier.value = i,
        itemBuilder: (_, i) => Stack(
          children: [
            OnboardingImageWidget(imagePath: _pages[i].imagePath),
            Align(
              alignment: Alignment.bottomCenter,
              child: ValueListenableBuilder<int>(
                valueListenable: _currentIndexNotifier,
                builder: (context, currentIndex, _) {
                  return OnboardingContentCard(
                    page: _pages[currentIndex == i ? i : i], // We need to pass the page corresponding to i
                    // However, we want the card to stay linked to the page i
                    // But use the currentIndex for button text and dots
                    currentIndex: currentIndex,
                    totalPages: _pages.length,
                    onNext: () {
                      if (currentIndex < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      } else {
                        context.read<OnboardingCubit>().finish();
                        context.goNamed(AppRouter.signinRoute);
                      }
                    },
                    onSkip: () => context.goNamed(AppRouter.signinRoute),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
