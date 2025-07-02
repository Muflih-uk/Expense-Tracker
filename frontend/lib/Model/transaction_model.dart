
class TransactionModel {
  String title;
  String amount;
  String transactionType;
  int? category;
  int? account;
  DateTime date;
  String? notes;
  String? tags;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.transactionType,
    required this.category,
    required this.account,
    required this.date,
    required this.notes,
    required this.tags
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['title'],
      amount: json['amount'],
      transactionType: json['transactionType'],
      category: json['category'],
      account: json['account'],
      date: json['date'],
      notes: json['notes'],
      tags: json['tags']
    );
  }

  Map<String, dynamic> toJson() {
  return {
    "title": title,
    "amount": amount,
    "transaction_type": transactionType,
    "category": category,
    "account": account,
    "date": "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}", // ✅ Correct format
    "notes": notes,
    "tags": tags
  };
}

}
