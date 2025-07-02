class AccountModel {
  final int id;
  final String title;
  final String initial;
  final int user;
  final String currentBalance;

  AccountModel({
    required this.id,
    required this.title,
    required this.initial,
    required this.user,
    required this.currentBalance,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'],
      title: json['title'],
      initial: json['initial'],
      user: json['user'],
      currentBalance: json['current_balance'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'initial': initial,
      'user': user,
      'current_balance': currentBalance,
    };
  }
}
