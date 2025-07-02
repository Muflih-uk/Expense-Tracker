import 'package:flutter/material.dart';
import 'package:expense_tracker/Controller/onboarding_controller.dart';

class OnboardingProvider extends ChangeNotifier {

  final OnboardingController controller = OnboardingController();

  bool _isOnboardingComplete = false;

  bool get isOnboardingComplete => _isOnboardingComplete;

  OnboardingProvider() {
    _loadOnboardingStatus();
  }

  void _loadOnboardingStatus() async {
    _isOnboardingComplete = await controller.getOnboardingStatus();
    notifyListeners();
  }

  void completeOnboarding() async {
    await controller.setOnboardingStatus();
    _isOnboardingComplete = true;
    notifyListeners();
  }
}
