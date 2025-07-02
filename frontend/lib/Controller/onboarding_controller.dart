import 'package:shared_preferences/shared_preferences.dart';

class OnboardingController {

  // Get Onboarding Status in Local Storage
  Future<bool> getOnboardingStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }

  // Set the Onboarding Status in Local Storage
  Future<void> setOnboardingStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
  }
}