import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/features/auth/presentation/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/screens/login_screen.dart';
import 'package:expense_tracker/features/auth/presentation/screens/register_screen.dart';
import 'package:expense_tracker/features/accounts/presentation/account_detail_cubit.dart';
import 'package:expense_tracker/features/accounts/presentation/screens/account_detail_screen.dart';
import 'package:expense_tracker/features/accounts/presentation/screens/accounts_screen.dart';
import 'package:expense_tracker/features/boot/presentation/screens/boot_screen.dart';
import 'package:expense_tracker/features/categories/presentation/category_detail_cubit.dart';
import 'package:expense_tracker/features/categories/presentation/screens/categories_screen.dart';
import 'package:expense_tracker/features/categories/presentation/screens/category_detail_screen.dart';
import 'package:expense_tracker/features/dashboard/presentation/screens/home_screen.dart';
import 'package:expense_tracker/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/screens/entries_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/screens/transaction_detail_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/screens/transaction_form_screen.dart';
import 'package:expense_tracker/features/transactions/presentation/transaction_detail_cubit.dart';
import 'package:expense_tracker/features/transactions/presentation/transaction_form_bloc.dart';
import 'package:expense_tracker/features/users/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  void trigger() => notifyListeners();
}

GoRouter buildAppRouter() {
  final refresh = _RouterRefreshNotifier();
  authBloc.stream.listen((_) => refresh.trigger());
  bootCubit.stream.listen((_) => refresh.trigger());
  return GoRouter(
    initialLocation: '/bootstrap',
    refreshListenable: refresh,
    redirect: (context, state) {
      final bootReady = bootCubit.state.isReady;
      final location = state.matchedLocation;

      if (!bootReady) {
        if (location == '/bootstrap') return null;
        return '/bootstrap';
      }

      final authStatus = authBloc.state.status;
      final startedOnboarding = localStorage.isOnboardingComplete;
      final isBootScreen =
          location == '/bootstrap' ||
          location == '/onboarding' ||
          location == '/login' ||
          location == '/register';

      if (authStatus == AuthStatus.checking) {
        if (isBootScreen) return null;
        return '/bootstrap';
      }

      if (!startedOnboarding) {
        if (location == '/onboarding') return null;
        return '/onboarding';
      }

      if (authStatus == AuthStatus.unauthenticated) {
        if (location == '/login' || location == '/register') return null;
        return '/login';
      }

      if (isBootScreen) {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/bootstrap',
        builder: (_, _) => const BootScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _fadeSlidePage(context, state, const OnboardingScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeSlidePage(
          context,
          state,
          const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _fadeSlidePage(
          context,
          state,
          const RegisterScreen(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                pageBuilder: (context, state) =>
                    _fadeSlidePage(context, state, const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/entries',
                pageBuilder: (context, state) =>
                    _fadeSlidePage(context, state, const EntriesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/accounts',
                pageBuilder: (context, state) =>
                    _fadeSlidePage(context, state, const AccountsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) =>
                    _fadeSlidePage(context, state, const ProfileScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'expense';
          final editId = state.uri.queryParameters['editId'];
          return _fadeSlidePage(
            context,
            state,
            BlocProvider(
              create: (context) =>
                  TransactionFormBloc(transactionRepository),
              child: TransactionFormScreen(
                type: type,
                editId: editId == null ? null : int.tryParse(editId),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: '/transaction/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return _fadeSlidePage(
            context,
            state,
            BlocProvider(
              create: (context) => TransactionDetailCubit(transactionRepository),
              child: TransactionDetailScreen(transactionId: id),
            ),
          );
        },
      ),
      GoRoute(
        path: '/account/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return _fadeSlidePage(
            context,
            state,
            BlocProvider(
              create: (context) => AccountDetailCubit(accountRepository),
              child: AccountDetailScreen(accountId: id),
            ),
          );
        },
      ),
      GoRoute(
        path: '/categories',
        pageBuilder: (context, state) =>
            _fadeSlidePage(context, state, const CategoriesScreen()),
      ),
      GoRoute(
        path: '/category/:id',
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final title = state.uri.queryParameters['title'] ?? 'Category';
          return _fadeSlidePage(
            context,
            state,
            BlocProvider(
              create: (context) => CategoryDetailCubit(categoryRepository),
              child: CategoryDetailScreen(categoryId: id, title: title),
            ),
          );
        },
      ),
    ],
  );
}

CustomTransitionPage<Object> _fadeSlidePage(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<Object>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      (Icons.home_outlined, Icons.home_rounded, 'Home'),
      (Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Entries'),
      (Icons.account_balance_wallet_outlined, Icons.account_balance_wallet_rounded, 'Accounts'),
      (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
    ];

    return Scaffold(
      body: navigationShell,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.buttonGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-transaction?type=expense'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: AppColors.surface,
        elevation: 0,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(4, (index) {
                final isSelected = index == navigationShell.currentIndex;
                final data = destinations[index];
                return Expanded(
                  child: InkWell(
                    onTap: () => _onTap(context, index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            isSelected ? data.$2 : data.$1,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.hint,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          data.$3,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.hint,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}