import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/features/onboarding/presentation/onboarding_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onDone(BuildContext context) {
    context.read<OnboardingCubit>().complete();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalFooter: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: GradientFooterButton(
            label: "LET'S GO",
            onPressed: () => _onDone(context),
          ),
        ),
      ),
      globalBackgroundColor: AppColors.surface,
      pages: [
        _page(
          image: 'assets/images/illustration.png',
          heading1: 'Note Down Expenses',
          heading2: 'Daily note your expenses to',
          subHeading2: 'help manage money',
        ),
        _page(
          image: 'assets/images/taximan.png',
          heading1: 'Simple Money Management',
          heading2: 'Get your notifications or alert',
          subHeading2: 'when you do the over expenses',
        ),
        _page(
          image: 'assets/images/illu.png',
          heading1: 'Easy to Track and Analyze',
          heading2: 'Tracking your expense helps make sure',
          subHeading2: "you don't overspend",
        ),
      ],
      next: null,
      done: null,
      showSkipButton: false,
      showNextButton: false,
      showDoneButton: false,
      dotsDecorator: DotsDecorator(
        activeColor: AppColors.primary,
        color: const Color(0xFFD3D8E0),
        size: const Size(9, 9),
        activeSize: const Size(26, 9),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      animationDuration: 400,
    );
  }

  PageViewModel _page({
    required String image,
    required String heading1,
    required String heading2,
    required String subHeading2,
  }) {
    return PageViewModel(
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg', height: 26, width: 26),
            const SizedBox(width: 6),
            const Text(
              'monex',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
      bodyWidget: Column(
        children: [
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) =>
                Transform.translate(
                  offset: Offset(0, (1 - value) * 24),
                  child: Opacity(opacity: value, child: child),
                ),
            child: Image.asset(image, height: 220, fit: BoxFit.contain),
          ),
          const SizedBox(height: 30),
          Text(
            heading1,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            heading2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            subHeading2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientFooterButton extends StatelessWidget {
  const GradientFooterButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }
}