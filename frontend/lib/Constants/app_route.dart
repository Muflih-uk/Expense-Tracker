import 'package:expense_tracker/Screens/account.dart';
import 'package:expense_tracker/Screens/entries.dart';
import 'package:expense_tracker/Screens/home.dart';
import 'package:flutter/widgets.dart';
import 'package:expense_tracker/Screens/add_page.dart';
import 'package:expense_tracker/Screens/register.dart';
import 'package:expense_tracker/Screens/add_income_exp.dart';

class AppRoute {
  static Map<String, Widget Function(BuildContext)> routes = {
    "/home": (context) => HomeScreen(),
    "/entries": (context) => Entries(),
    "/add_expense": (context) => AddIncomeExp(purpose: "Expense",key: Key("Expense"),),
    "/add_income": (context) => AddIncomeExp(purpose: "Income",key: Key("Income"),),
    "/add_page": (context) => AddPage(),
    "/account": (context) => Account(),
    "/register": (context) => Register()
  };
}