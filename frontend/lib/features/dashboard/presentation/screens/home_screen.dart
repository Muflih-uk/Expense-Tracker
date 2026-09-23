import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/animated_amount.dart';
import 'package:expense_tracker/core/widgets/motion.dart';
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
                    child: _PeriodSegmented(
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
    final hour = now.hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Row(
                        key: ValueKey(state.isRefreshing),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isRefreshing) ...[
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.6,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            state.isRefreshing
                                ? 'Updating your money…'
                                : 'Here is your money summary',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.buttonGradient,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x334F46E5),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
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
        ),
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
        _buildHero(context, summary),
        _buildSummaryRow(context, summary),
        TrendChartCard(data: trendItems),
        CategoryBreakdownCard(items: pieItems),
        if (state.quickStats != null)
          _QuickStatsSection(stats: state.quickStats!),
        if (data.accountSummary.isNotEmpty) ...[
          _SectionHeader(
            title: 'Accounts',
            onSeeAll: () => context.push('/accounts'),
          ),
          for (final (index, account) in data.accountSummary.indexed)
            Reveal(
              index: index,
              child: _AccountRow(account: account),
            ),
        ],
        if (data.recentTransactions.isNotEmpty) ...[
          _SectionHeader(
            title: 'Recent Transactions',
            onSeeAll: () => context.push('/entries'),
          ),
          for (final (index, tx) in data.recentTransactions.indexed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Reveal(
                index: index,
                child: TransactionTile(
                  transaction: tx,
                  onTap: () => context.push('/transaction/${tx.id}'),
                ),
              ),
            ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildHero(BuildContext context, DashboardSummary summary) {
    final net = summary.netAmount;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.32),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -24,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Balance',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xEBFFFFFF),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${net >= 0 ? '+' : ''}${formatCompact(net)}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AnimatedAmount(
                amount: summary.totalAccountBalance,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${summary.transactionCount} transactions this period',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xD9FFFFFF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, DashboardSummary summary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: _BalanceTile(
              title: 'Income',
              amount: summary.totalIncome,
              icon: Icons.south_west_rounded,
              color: AppColors.income,
              onTap: () => context.push('/entries'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _BalanceTile(
              title: 'Expenses',
              amount: summary.totalExpenses,
              icon: Icons.north_east_rounded,
              color: AppColors.expense,
              onTap: () => context.push('/entries'),
            ),
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

class _BalanceTile extends StatelessWidget {
  const _BalanceTile({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [appShadow()],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const Spacer(),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedAmount(
              amount: amount,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
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
      ),
    );
  }
}

class _PeriodSegmented extends StatelessWidget {
  const _PeriodSegmented({
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  final List<String> periods;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.field,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(periods.length, (index) {
          final period = periods[index];
          final isSelected = period == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.buttonGradient : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x334F46E5),
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  child: Center(child: Text(period)),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  const _QuickStatsSection({required this.stats});

  final QuickStats stats;

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('Today', stats.today),
      ('This Week', stats.week),
      ('This Month', stats.month),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [appShadow()],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Stats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final entry in rows)
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: entry.$1 == rows.last.$1 ? 0 : 10,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.$1,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.hint,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedAmount(
                            amount: entry.$2.net,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: entry.$2.net < 0
                                  ? AppColors.expense
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '+${formatCompact(entry.$2.income)} / '
                            '-${formatCompact(entry.$2.expenses)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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
        borderRadius: BorderRadius.circular(18),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => context.push('/account/${account.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    gradient: AppColors.buttonGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
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
                    AnimatedAmount(
                      amount: account.currentBalance,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${account.change >= 0 ? '+' : ''}${formatCompact(account.change)}',
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

String formatCompact(double value) {
  if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
  if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
  if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}k';
  return '₹${value.toStringAsFixed(0)}';
}