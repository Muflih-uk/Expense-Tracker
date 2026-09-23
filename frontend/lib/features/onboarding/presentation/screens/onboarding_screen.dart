import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/motion.dart';
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
        child: PressScale(
          onTap: () => _onDone(context),
          child: SizedBox(
            width: double.infinity,
            child: GradientFooterButton(label: "LET'S GO"),
          ),
        ),
      ),
      globalBackgroundColor: AppColors.background,
      pages: [
        _page(
          image: 'assets/images/illustration.png',
          heading: 'Note Down Expenses',
          subtitle: 'Daily note your expenses to\nhelp manage money',
        ),
        _page(
          image: 'assets/images/taximan.png',
          heading: 'Simple Money Management',
          subtitle: 'Get your notifications or alert\nwhen you do the over expenses',
        ),
        _page(
          image: 'assets/images/illu.png',
          heading: 'Easy to Track and Analyze',
          subtitle: "Tracking your expense helps make sure\nyou don't overspend",
        ),
      ],
      next: null,
      done: null,
      showSkipButton: false,
      showNextButton: false,
      showDoneButton: false,
      dotsDecorator: DotsDecorator(
        activeColor: AppColors.primary,
        color: AppColors.dividerLight,
        size: const Size(9, 9),
        activeSize: const Size(28, 11),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      animationDuration: 400,
    );
  }

  PageViewModel _page({
    required String image,
    required String heading,
    required String subtitle,
  }) {
    return PageViewModel(
      titleWidget: Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.32),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpg',
                  height: 24,
                  width: 24,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Paisa Book',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
      bodyWidget: Column(
        children: [
          const SizedBox(height: 24),
          Container(
            height: 240,
            width: 240,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.accent.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) =>
                  Transform.translate(
                    offset: Offset(0, (1 - value) * 24),
                    child: Opacity(opacity: value, child: child),
                  ),
              child: Image.asset(image, height: 200, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 30),
          Text(
            heading,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class GradientFooterButton extends StatelessWidget {
  const GradientFooterButton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: AppColors.buttonGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}