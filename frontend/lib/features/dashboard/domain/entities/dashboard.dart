import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class DashboardPeriod extends Equatable {
  const DashboardPeriod({
    required this.type,
    required this.startDate,
    required this.endDate,
  });

  final String type;
  final String startDate;
  final String endDate;

  @override
  List<Object?> get props => [type, startDate, endDate];
}

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
    required this.transactionCount,
    required this.totalAccountBalance,
  });

  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final int transactionCount;
  final double totalAccountBalance;

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpenses,
        netAmount,
        transactionCount,
        totalAccountBalance,
      ];
}

class CategoryBreakdown extends Equatable {
  const CategoryBreakdown({
    required this.title,
    required this.total,
    this.count = 0,
  });

  final String title;
  final double total;
  final int count;

  @override
  List<Object?> get props => [title, total, count];
}

class AccountSummaryItem extends Equatable {
  const AccountSummaryItem({
    required this.id,
    required this.title,
    required this.initialBalance,
    required this.currentBalance,
    required this.change,
  });

  final int id;
  final String title;
  final double initialBalance;
  final double currentBalance;
  final double change;

  @override
  List<Object?> get props => [
        id,
        title,
        initialBalance,
        currentBalance,
        change,
      ];
}

class MonthlyTrend extends Equatable {
  const MonthlyTrend({
    required this.month,
    required this.income,
    required this.expenses,
    required this.net,
  });

  final String month;
  final double income;
  final double expenses;
  final double net;

  @override
  List<Object?> get props => [month, income, expenses, net];
}

class DashboardData extends Equatable {
  const DashboardData({
    required this.period,
    required this.summary,
    required this.categoryBreakdown,
    required this.accountSummary,
    required this.recentTransactions,
    required this.monthlyTrend,
    required this.topCategories,
  });

  final DashboardPeriod period;
  final DashboardSummary summary;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<AccountSummaryItem> accountSummary;
  final List<Transaction> recentTransactions;
  final List<MonthlyTrend> monthlyTrend;
  final List<CategoryBreakdown> topCategories;

  @override
  List<Object?> get props => [
        period,
        summary,
        categoryBreakdown,
        accountSummary,
        recentTransactions,
        monthlyTrend,
        topCategories,
      ];
}

class QuickStat extends Equatable {
  const QuickStat({
    required this.income,
    required this.expenses,
    required this.net,
    required this.count,
  });

  final double income;
  final double expenses;
  final double net;
  final int count;

  @override
  List<Object?> get props => [income, expenses, net, count];
}

class QuickStats extends Equatable {
  const QuickStats({
    required this.today,
    required this.week,
    required this.month,
  });

  final QuickStat today;
  final QuickStat week;
  final QuickStat month;

  @override
  List<Object?> get props => [today, week, month];
}