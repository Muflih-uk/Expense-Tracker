import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.id, required this.title});

  final int id;
  final String title;

  @override
  List<Object?> get props => [id, title];
}

class CategoryWithStats extends Equatable {
  const CategoryWithStats({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.transactionCount,
  });

  final int id;
  final String title;
  final double totalAmount;
  final int transactionCount;

  @override
  List<Object?> get props => [
        id,
        title,
        totalAmount,
        transactionCount,
      ];
}