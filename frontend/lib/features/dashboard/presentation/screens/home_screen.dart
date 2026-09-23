import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/core/widgets/period_selector.dart';
import 'package:expense_tracker/core/widgets/shimmer.dart';
import 'package:expense_tracker/core/widgets/status_views.dart';
import 'package:expense_tracker/core/widgets/transaction_tile.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/dashboard.dart';
import 'package:expense_tracker/features/dashboard/presentation/dashboard_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/chart_cards.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _periods = ['Today', 'Week', 'Month', 'Year'];

String _periodValue(String label) => label.toLowerCase();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const DashboardStarted('month'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<DashboardBloc, DashboardState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.period != current.period ||
            previous.isRefreshing != current.isRefreshing ||
            previous.failure != current.failure,
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<DashboardBloc>().add(const DashboardRefreshed()),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, state)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 10),
                    child: PeriodSelector(
                      periods: _periods,
                      selected: _displayLabel(state.period),
                      onChanged: (label) => context
                          .read<DashboardBloc>()
                          .add(DashboardPeriodChanged(_periodValue(label))),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 24),
                  sliver: _buildBody(state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DashboardState state) {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July',
      'August', 'September', 'October', 'November', 'December',
    ];
    final dateLabel = '${now.day} ${months[now.month - 1]} ${now.year}';

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateLabel,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Overview',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${state.isRefreshing ? 'Updating' : 'See your money summary'}…',
                    key: ValueKey(state.isRefreshing),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.hint,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/profile'),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.buttonGradient,
              ),
              child: const Icon(
                Icons.person_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(DashboardState state) {
    switch (state.status) {
      case DashboardStatus.initial:
      case DashboardStatus.loading:
        return _buildSkeleton();
      case DashboardStatus.failure:
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 480,
            child: ErrorView(
              message: state.failure?.message ?? 'Unable to load dashboard',
              onRetry: () => context
                  .read<DashboardBloc>()
                  .add(DashboardStarted(state.period)),
            ),
          ),
        );
      case DashboardStatus.loaded:
        if (state.data == null) {
          return _buildSkeleton();
        }
        return SliverToBoxAdapter(child: _buildLoaded(context, state));
    }
  }

  Widget _buildSkeleton() {
    return SliverToBoxAdapter(
      child: SizedBox(height: 560, child: ListSkeleton(count: 5)),
    );
  }

  Widget _buildLoaded(BuildContext context, DashboardState state) {
    final data = state.data!;
    final summary = data.summary;
    final trendItems = data.monthlyTrend
        .map(
          (t) => (month: t.month, income: t.income, expenses: t.expenses),
        )
        .toList();
    final categoryItems = data.topCategories.isEmpty
        ? data.categoryBreakdown
        : data.topCategories;
    final pieItems = categoryItems
        .map((c) => (title: c.title, total: c.total))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSummaryRow(context, summary),
        const SizedBox(height: 6),
        if (state.quickStats != null)
          _QuickStatsCard(stats: state.quickStats!),
        TrendChartCard(data: trendItems),
        CategoryBreakdownCard(items: pieItems),
        if (data.accountSummary.isNotEmpty) ...[
          _SectionHeader(
            title: 'Accounts',
            onSeeAll: () => context.push('/accounts'),
          ),
          for (final account in data.accountSummary) _AccountRow(account: account),
        ],
        if (data.recentTransactions.isNotEmpty) ...[
          _SectionHeader(
            title: 'Recent Transactions',
            onSeeAll: () => context.push('/entries'),
          ),
          for (final (index, tx) in data.recentTransactions.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TransactionTile(
                transaction: tx,
                appearIndex: index,
                onTap: () => context.push('/transaction/${tx.id}'),
              ),
            ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, DashboardSummary summary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SummaryCard(
            title: 'Income',
            amount: summary.totalIncome,
            icon: Icons.trending_up_rounded,
            color: AppColors.income,
            subtitle: '${summary.transactionCount} transactions',
            flex: 3,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'Expenses',
            amount: summary.totalExpenses,
            icon: Icons.trending_down_rounded,
            color: AppColors.expense,
            subtitle: 'Balance ${formatAmount(summary.totalAccountBalance)}',
            flex: 3,
          ),
          const SizedBox(width: 12),
          _SummaryCard(
            title: 'Net',
            amount: summary.netAmount,
            icon: Icons.account_balance_wallet_rounded,
            color: summary.netAmount < 0
                ? AppColors.expense
                : AppColors.primary,
            subtitle: 'This period',
            flex: 2,
          ),
        ],
      ),
    );
  }

  String _displayLabel(String value) {
    for (final label in _periods) {
      if (_periodValue(label) == value) return label;
    }
    return value;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.subtitle,
    required this.flex,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String subtitle;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667085).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                formatAmount(amount),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                color: AppColors.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard({required this.stats});

  final QuickStats stats;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Today', stats.today),
      ('This Week', stats.week),
      ('This Month', stats.month),
    ];
    return SectionCard(
      title: 'Quick Stats',
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: _QuickHeader(label: 'Period'),
              ),
              const Expanded(
                child: _QuickHeader(label: 'Income'),
              ),
              const Expanded(
                child: _QuickHeader(label: 'Expenses'),
              ),
              const Expanded(
                child: _QuickHeader(label: 'Net'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final entry in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.$1,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      formatAmount(entry.$2.income),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.income,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      formatAmount(entry.$2.expenses),
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.expense,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      formatAmount(entry.$2.net),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: entry.$2.net < 0
                            ? AppColors.expense
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickHeader extends StatelessWidget {
  const _QuickHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.hint,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll});

  final String title;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({required this.account});

  final AccountSummaryItem account;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => context.push('/account/${account.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
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
                      '${account.change >= 0 ? '+' : ''}${formatAmount(account.change)}',
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
    );
  }
}