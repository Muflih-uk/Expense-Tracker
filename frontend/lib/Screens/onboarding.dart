import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import '../Provider/onboarding_provider.dart';
import '../Constants/app_color.dart';
import 'Widgets/onboarding_widgets.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _onDone(BuildContext context) {
    Provider.of<OnboardingProvider>(context, listen: false).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalFooter: OnboardingWidgets.bottomButton(context,_onDone),
      globalBackgroundColor: AppColor.appPrimary,
      pages: [
        // page 1
        OnboardingWidgets.pages(
          image: 'assets/images/illustration.png', 
          heading1: "Note Down Expenses", 
          heading2: "Daily note your expenses to", 
          subHeading2: "help manage money"
        ),

        // page 2
        OnboardingWidgets.pages(
          image: 'assets/images/taximan.png', 
          heading1: 'Simple Money Management', 
          heading2: 'Get your notifications or alert', 
          subHeading2: 'when you do the over expenses'
        ),

        // page 3
        OnboardingWidgets.pages(
          image: 'assets/images/illu.png', 
          heading1: 'Easy to Track and Analize', 
          heading2: 'Tracking your expense help make sure', 
          subHeading2: "you don't overspand"
        )
      ],
      next: Container(),
      dotsDecorator: DotsDecorator(
        activeColor: AppColor.appSecondary,
      ),
      overrideDone: Container(),
    );
  }
}
