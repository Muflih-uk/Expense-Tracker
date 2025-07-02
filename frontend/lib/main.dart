// Packages
import 'package:expense_tracker/Constants/app_color.dart';
import 'package:expense_tracker/Constants/app_route.dart';
import 'package:expense_tracker/Provider/account_provider.dart';
import 'package:expense_tracker/Provider/category_provider.dart';

// import 'package:expense_tracker/Controller/auth_cotroller.dart';
// import 'package:expense_tracker/Screens/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import 'Provider/onboarding_provider.dart';
import 'Provider/dashboard_provider.dart';


// Screens
import 'Screens/login.dart';
import 'Screens/onboarding.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider())
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // Controller
  //final AuthController _controller = AuthController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: AppColor.bgColor,
        fontFamily: 'Inter'
      ),
      debugShowCheckedModeBanner: false,
      routes: AppRoute.routes,
      home: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          // Wait until the onboarding status is loaded
          if (!provider.isOnboardingComplete) {
            return const OnboardingScreen();
          }
          return Login(); 
        }
      )
    );
  }
}

