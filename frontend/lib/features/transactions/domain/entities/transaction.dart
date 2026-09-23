import 'package:equatable/equatable.dart';

class Ref extends Equatable {
  const Ref({this.id, this.title});

  final int? id;
  final String? title;

  @override
  List<Object?> get props => [id, title];
}

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.transactionType,
    this.category,
    this.account,
    this.date,
    this.notes,
    this.receipt,
    this.tags,
    this.createdAt,
  });

  final int id;
  final String title;
  final double amount;
  final String transactionType;
  final Ref? category;
  final Ref? account;
  final String? date;
  final String? notes;
  final String? receipt;
  final String? tags;
  final String? createdAt;

  bool get isExpense => transactionType == 'expense';

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        transactionType,
        category,
        account,
        date,
        notes,
        receipt,
        tags,
        createdAt,
      ];
}

class TransactionPayload extends Equatable {
  const TransactionPayload({
    required this.title,
    required this.amount,
    required this.transactionType,
    this.categoryId,
    this.accountId,
    required this.date,
    this.notes,
    this.tags,
    this.receiptPath,
  });

  final String title;
  final double amount;
  final String transactionType;
  final int? categoryId;
  final int? accountId;
  final DateTime date;
  final String? notes;
  final String? tags;
  final String? receiptPath;

  @override
  List<Object?> get props => [
        title,
        amount,
        transactionType,
        categoryId,
        accountId,
        date,
        notes,
        tags,
        receiptPath,
      ];
}

class TxSummaryResponse extends Equatable {
  const TxSummaryResponse({
    required this.totalIncome,
    required this.totalExpenses,
    required this.netAmount,
    required this.transactionCount,
    required this.recentTransactions,
  });

  final double totalIncome;
  final double totalExpenses;
  final double netAmount;
  final int transactionCount;
  final List<Transaction> recentTransactions;

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpenses,
        netAmount,
        transactionCount,
        recentTransactions,
      ];
}

class TransactionFilter extends Equatable {
  const TransactionFilter({
    this.search = '',
    this.type = 'all',
    this.period = 'all',
    this.categoryId,
    this.accountId,
    this.amountMin,
    this.amountMax,
    this.dateFrom,
    this.dateTo,
    this.ordering = '-created_at',
  });

  final String search;
  final String type;
  final String period;
  final int? categoryId;
  final int? accountId;
  final double? amountMin;
  final double? amountMax;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String ordering;

  bool get hasCustomRange => dateFrom != null && dateTo != null;

  TransactionFilter copyWith({
    String? search,
    String? type,
    String? period,
    int? Function()? categoryId,
    int? Function()? accountId,
    double? Function()? amountMin,
    double? Function()? amountMax,
    DateTime? Function()? dateFrom,
    DateTime? Function()? dateTo,
    String? ordering,
  }) {
    return TransactionFilter(
      search: search ?? this.search,
      type: type ?? this.type,
      period: period ?? this.period,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      accountId: accountId != null ? accountId() : this.accountId,
      amountMin: amountMin != null ? amountMin() : this.amountMin,
      amountMax: amountMax != null ? amountMax() : this.amountMax,
      dateFrom: dateFrom != null ? dateFrom() : this.dateFrom,
      dateTo: dateTo != null ? dateTo() : this.dateTo,
      ordering: ordering ?? this.ordering,
    );
  }

  @override
  List<Object?> get props => [
        search,
        type,
        period,
        categoryId,
        accountId,
        amountMin,
        amountMax,
        dateFrom,
        dateTo,
        ordering,
      ];
}