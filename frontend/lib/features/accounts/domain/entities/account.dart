import 'package:equatable/equatable.dart';

class Account extends Equatable {
  const Account({
    required this.id,
    required this.title,
    required this.initial,
    required this.currentBalance,
    this.user,
  });

  final int id;
  final String title;
  final double initial;
  final double currentBalance;
  final int? user;

  double get change => currentBalance - initial;

  @override
  List<Object?> get props => [id, title, initial, currentBalance, user];
}

class AccountSummary extends Equatable {
  const AccountSummary({
    required this.totalAccounts,
    required this.totalInitialBalance,
    required this.totalCurrentBalance,
    required this.totalChange,
    required this.accounts,
  });

  final int totalAccounts;
  final double totalInitialBalance;
  final double totalCurrentBalance;
  final double totalChange;
  final List<Account> accounts;

  @override
  List<Object?> get props => [
        totalAccounts,
        totalInitialBalance,
        totalCurrentBalance,
        totalChange,
        accounts,
      ];
}

class BalanceHistoryEntry extends Equatable {
  const BalanceHistoryEntry({
    required this.date,
    required this.balance,
    required this.title,
    required this.amount,
    required this.type,
  });

  final String date;
  final double balance;
  final String title;
  final double amount;
  final String type;

  @override
  List<Object?> get props => [date, balance, title, amount, type];
}

class BalanceHistory extends Equatable {
  const BalanceHistory({
    required this.initialBalance,
    required this.currentBalance,
    required this.entries,
  });

  final double initialBalance;
  final double currentBalance;
  final List<BalanceHistoryEntry> entries;

  @override
  List<Object?> get props => [initialBalance, currentBalance, entries];
}