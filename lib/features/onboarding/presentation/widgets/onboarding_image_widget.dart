import 'package:flutter/material.dart';

class OnboardingImageWidget extends StatelessWidget {
  final String imagePath;

  const OnboardingImageWidget({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) =>
          const Center(child: Text('Image not found')),
    );
  }
}
