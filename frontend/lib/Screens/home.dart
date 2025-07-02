import 'package:expense_tracker/Constants/app_color.dart';
import 'package:expense_tracker/Provider/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'Widgets/bottom_bar.dart';
import 'Widgets/app_widgets.dart';
import 'Widgets/home_widgets.dart';
import 'package:provider/provider.dart';
import 'package:expense_tracker/Provider/account_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final DashboardProvider dashboardProvider = DashboardProvider();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<AccountProvider>(context, listen: false).loadAccount()
    );
    Future.microtask(() =>
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboardData()
    );
  }

  void pressedPlusButton(BuildContext context) {
    Navigator.pushNamed(context, '/add_page');
  }

  void addAccount(BuildContext context) {
    Navigator.pushNamed(context, '/account');
  }

  

  @override
  Widget build(BuildContext context) {
    final dashboardData = context.watch<DashboardProvider>().data;
    final summary = dashboardData!['summary'];
    final income = summary?['total_income'] ?? "0";
    final expenses = summary?['total_expenses'] ?? "0";
    final account = context.watch<AccountProvider>().account;
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      body: Padding(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Bar
              HomeWidgets.topBar(
                context: context,
                addAccount: addAccount,
                account: account,
              ),

              const SizedBox(height: 25),

              // Total Expense and Total Salary
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HomeWidgets.totalDiv(
                    typeOfTrans: "Income",
                    cash: income,
                  ),
                  SizedBox(width: 20,),
                  HomeWidgets.totalDiv(
                    typeOfTrans: "Expense",
                    cash: expenses,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // Add the Expense and Salary
              HomeWidgets.addTrans(),
            ],
          ),
        ),
      ),
      floatingActionButton: AppWidgets.plusButton(
        context: context,
        onTapHandler: pressedPlusButton,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const BottomBar(key: Key('home bottom Bar')),
    );
  }
}
