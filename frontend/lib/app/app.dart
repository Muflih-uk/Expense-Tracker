import 'package:expense_tracker/app/router/app_router.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/accounts/presentation/accounts_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/auth_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/categories_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/dashboard_bloc.dart';
import 'package:expense_tracker/features/onboarding/presentation/onboarding_cubit.dart';
import 'package:expense_tracker/features/transactions/presentation/transactions_bloc.dart';
import 'package:expense_tracker/features/users/presentation/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ExpenseTrackerApp extends StatefulWidget {
  const ExpenseTrackerApp({super.key});

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => authBloc),
        BlocProvider<OnboardingCubit>(
          create: (_) => OnboardingCubit(localStorage)..load(),
        ),
        BlocProvider<DashboardBloc>(
          create: (_) => DashboardBloc(dashboardRepository),
        ),
        BlocProvider<CategoriesBloc>(
          create: (_) => CategoriesBloc(categoryRepository),
        ),
        BlocProvider<AccountsBloc>(
          create: (_) => AccountsBloc(accountRepository),
        ),
        BlocProvider<TransactionsBloc>(
          create: (_) => TransactionsBloc(transactionRepository),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(userRepository),
        ),
      ],
      child: MaterialApp.router(
        title: 'monex',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}