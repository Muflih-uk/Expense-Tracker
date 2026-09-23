import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/core/widgets/shimmer.dart';
import 'package:expense_tracker/core/widgets/status_views.dart';
import 'package:expense_tracker/features/accounts/domain/entities/account.dart';
import 'package:expense_tracker/features/accounts/presentation/accounts_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AccountsBloc>().add(const AccountsLoaded());
  }

  Future<void> _addAccount() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController(text: '0');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          title: const Text(
            'New Account',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Account name',
                  hintText: 'e.g. Wallet',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Initial balance',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            GradientButton(
              label: 'Create',
              expanded: false,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    final title = titleController.text.trim();
    final initial = double.tryParse(amountController.text) ?? 0;
    if (confirmed == true && title.isNotEmpty) {
      if (!mounted) return;
      context
          .read<AccountsBloc>()
          .add(AccountCreated(title: title, initial: initial));
    }
  }

  Future<void> _delete(Account account) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete account',
      message: 'Delete "${account.title}"?',
    );
    if (!confirmed) return;
    if (!mounted) return;
    context.read<AccountsBloc>().add(AccountDeleted(account.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addAccount,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Account',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<AccountsBloc, AccountsState>(
        listenWhen: (previous, current) =>
            current.failure != null && current.failure != previous.failure,
        listener: (context, state) {
          if (state.failure != null) {
            showAppSnack(context, state.failure!.message, isError: true);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<AccountsBloc>().add(const AccountsRefreshed()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, state)),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: _buildBody(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AccountsState state) {
    final summary = state.summary;
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Accounts',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.buttonGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xD9FFFFFF),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatAmount(summary?.totalCurrentBalance ?? 0),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                if (summary != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${summary.totalAccounts} accounts · '
                    'Net change ${summary.totalChange >= 0 ? '+' : ''}'
                    '${formatAmount(summary.totalChange)}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xD9FFFFFF),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AccountsState state) {
    switch (state.status) {
      case AccountsStatus.initial:
      case AccountsStatus.loading:
        if (state.accounts.isEmpty) return _buildSkeleton();
        return _buildList(state);
      case AccountsStatus.failure:
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 360,
            child: ErrorView(
              message: state.failure?.message ?? 'Unable to load accounts',
              onRetry: () =>
                  context.read<AccountsBloc>().add(const AccountsRefreshed()),
            ),
          ),
        );
      case AccountsStatus.loaded:
        if (state.accounts.isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 360,
              child: EmptyView(
                icon: Icons.account_balance_wallet_rounded,
                title: 'No accounts yet',
                subtitle: 'Add an account to track balances',
              ),
            ),
          );
        }
        return _buildList(state);
    }
  }

  Widget _buildSkeleton() {
    return SliverToBoxAdapter(
      child: SizedBox(height: 520, child: ListSkeleton(count: 5)),
    );
  }

  Widget _buildList(AccountsState state) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          for (final (index, account) in state.accounts.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 320 + index * 50),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: child,
                  ),
                ),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => context.push('/account/${account.id}'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Initial ${formatAmount(account.initial)}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _delete(account),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.hint,
                              size: 22,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatAmount(account.currentBalance),
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '${account.change >= 0 ? '+' : ''}'
                                '${formatAmount(account.change)}',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: account.change < 0
                                      ? AppColors.expense
                                      : AppColors.income,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}