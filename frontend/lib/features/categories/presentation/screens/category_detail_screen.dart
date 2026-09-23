import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/status_views.dart';
import 'package:expense_tracker/core/widgets/transaction_tile.dart';
import 'package:expense_tracker/features/categories/presentation/category_detail_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CategoryDetailScreen extends StatefulWidget {
  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    this.title = 'Category',
  });

  final int categoryId;
  final String title;

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<CategoryDetailCubit>()
        .load(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocBuilder<CategoryDetailCubit, CategoryDetailState>(
        builder: (context, state) {
          if (state.isLoading && state.transactions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state.failure != null && state.transactions.isEmpty) {
            return ErrorView(
              message: state.failure!.message,
              onRetry: () => context
                  .read<CategoryDetailCubit>()
                  .load(widget.categoryId),
            );
          }
          if (state.transactions.isEmpty) {
            return const EmptyView(
              icon: Icons.receipt_long_rounded,
              title: 'No transactions in this category',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context
                .read<CategoryDetailCubit>()
                .load(widget.categoryId),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                final tx = state.transactions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: TransactionTile(
                    transaction: tx,
                    appearIndex: index,
                    onTap: () => context.push('/transaction/${tx.id}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}