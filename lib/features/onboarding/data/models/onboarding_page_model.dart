class OnboardingPageModel {
  final String imagePath;
  final String titleRegular;
  final String titleItalic;
  final String body;
  final String? subtitle; 

  const OnboardingPageModel({
    required this.imagePath,
    required this.titleRegular,
    required this.titleItalic,
    required this.body,
    this.subtitle,
  });
}