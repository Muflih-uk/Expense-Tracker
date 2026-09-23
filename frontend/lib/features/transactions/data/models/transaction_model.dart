import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class TransactionModel {
  const TransactionModel({
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      amount: parseAmount(json['amount']),
      transactionType: json['transaction_type'] as String? ?? 'expense',
      category: _parseRef(json['category'] ?? json['category_detail']),
      account: _parseRef(json['account'] ?? json['account_detail']),
      date: json['date'] as String?,
      notes: json['notes'] as String?,
      receipt: json['receipt'] as String?,
      tags: json['tags'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  static Ref? _parseRef(dynamic value) {
    if (value == null) return null;
    if (value is Map) {
      return Ref(
        id: value['id'] as int?,
        title: value['title']?.toString(),
      );
    }
    if (value is int) return Ref(id: value);
    if (value is String && value.isNotEmpty) return Ref(title: value);
    return null;
  }

  Transaction toEntity() => Transaction(
        id: id,
        title: title,
        amount: amount,
        transactionType: transactionType,
        category: category,
        account: account,
        date: date,
        notes: notes,
        receipt: receipt,
        tags: tags,
        createdAt: createdAt,
      );
}