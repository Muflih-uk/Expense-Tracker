import 'package:expense_tracker/app/app.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const ExpenseTrackerApp());
}