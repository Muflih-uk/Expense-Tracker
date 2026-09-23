import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/core/widgets/status_views.dart';
import 'package:expense_tracker/core/widgets/transaction_tile.dart';
import 'package:expense_tracker/features/accounts/presentation/account_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AccountDetailScreen extends StatefulWidget {
  const AccountDetailScreen({super.key, required this.accountId});

  final int accountId;

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  static const _periods = [
    ('week', 'Week'),
    ('month', 'Month'),
    ('year', 'Year'),
  ];

  @override
  void initState() {
    super.initState();
    context
        .read<AccountDetailCubit>()
        .load(widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Account Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<AccountDetailCubit, AccountDetailState>(
        builder: (context, state) {
          if (state.isLoading && state.account == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.failure != null && state.account == null) {
            return ErrorView(
              message: state.failure!.message,
              onRetry: () => context
                  .read<AccountDetailCubit>()
                  .load(widget.accountId),
            );
          }
          final account = state.account;
          if (account == null) {
            return const ErrorView(message: 'Account not found');
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<AccountDetailCubit>()
                .load(widget.accountId),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildBalanceCard(state.account!),
                const SizedBox(height: 14),
                _buildPeriodChips(state),
                const SizedBox(height: 8),
                _buildHistoryCard(state),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 10, 4, 8),
                  child: Text(
                    'Transactions',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (state.transactions.isEmpty)
                  const SizedBox(
                    height: 200,
                    child: EmptyView(
                      icon: Icons.receipt_long_rounded,
                      title: 'No transactions',
                    ),
                  )
                else
                  for (final (index, tx) in state.transactions.indexed)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TransactionTile(
                        transaction: tx,
                        appearIndex: index,
                        onTap: () => context.push('/transaction/${tx.id}'),
                      ),
                    ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(account) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            account.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xD9FFFFFF),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            formatAmount(account.currentBalance),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${account.change >= 0 ? '+' : ''}${formatAmount(account.change)} '
            'from initial ${formatAmount(account.initial)}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xD9FFFFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodChips(AccountDetailState state) {
    return Row(
      children: [
        for (final period in _periods)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context
                  .read<AccountDetailCubit>()
                  .changePeriod(widget.accountId, period.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: state.period == period.$1
                      ? AppColors.buttonGradient
                      : null,
                  color: state.period == period.$1
                      ? null
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  period.$2,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: state.period == period.$1
                        ? Colors.white
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHistoryCard(AccountDetailState state) {
    final history = state.history;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667085).withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: history == null || history.entries.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No balance history yet',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.hint,
                  ),
                ),
              ),
            )
          : SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: _minBalance(history) * 0.98,
                  maxY: _maxBalance(history) * 1.02,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (final (index, entry) in history.entries.indexed)
                          FlSpot(index.toDouble(), entry.balance),
                      ],
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _interval(),
                    getDrawingHorizontalLine: (value) => const FlLine(
                      color: Color(0xFFEDF0F4),
                      strokeWidth: 1,
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        getTitlesWidget: (value, meta) {
                          final v = value.toInt();
                          final step = (v.abs() >= 100000) ? 100000 : 1000;
                          if (v % step != 0) return const SizedBox.shrink();
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              v == 0 ? '0' : '${v ~/ 1000}k',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: AppColors.hint,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= history.entries.length) {
                            return const SizedBox.shrink();
                          }
                          final entry = history.entries[index];
                          final parts = entry.date.split('-');
                          final label = parts.length == 3
                              ? '${parts[1]}/${parts[2]}'
                              : entry.date;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              label,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9,
                                color: AppColors.hint,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  double _minBalance(history) {
    if (history.entries.isEmpty) return 0;
    return history.entries
        .map((e) => e.balance)
        .reduce((a, b) => a < b ? a : b);
  }

  double _maxBalance(history) {
    if (history.entries.isEmpty) return 0;
    return history.entries
        .map((e) => e.balance)
        .reduce((a, b) => a > b ? a : b);
  }

  double _interval() {
    return 100000;
  }
}