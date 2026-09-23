import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/core/widgets/status_views.dart';
import 'package:expense_tracker/features/dashboard/presentation/dashboard_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/transaction_detail_cubit.dart';
import 'package:expense_tracker/features/transactions/presentation/transactions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TransactionDetailScreen extends StatefulWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<TransactionDetailCubit>()
        .load(widget.transactionId);
  }

  Future<void> _delete(Transaction transaction) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete entry',
      message: 'Delete "${transaction.title}"? This cannot be undone.',
    );
    if (!confirmed) return;
    if (!mounted) return;
    context
        .read<TransactionDetailCubit>()
        .delete(transaction.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Entry Details',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<TransactionDetailCubit, TransactionDetailState>(
        listenWhen: (previous, current) =>
            current.deleted || (current.failure != null && current.failure != previous.failure),
        listener: (context, state) {
          if (state.deleted) {
            context.read<TransactionsBloc>().add(const TransactionsRefreshed());
            context.read<DashboardBloc>().add(const DashboardRefreshed());
            showAppSnack(context, 'Entry deleted');
            context.pop();
            return;
          }
          final failure = state.failure;
          if (failure != null) {
            showAppSnack(context, failure.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final transaction = state.transaction;
          if (transaction == null) {
            return ErrorView(
              message: state.failure?.message ?? 'Entry not found',
              onRetry: () => context
                  .read<TransactionDetailCubit>()
                  .load(widget.transactionId),
            );
          }
          return _DetailContent(
            transaction: transaction,
            isDeleting: state.isDeleting,
            onDelete: () => _delete(transaction),
            onEdit: () => context.push(
              '/add-transaction?editId=${transaction.id}&type=${transaction.transactionType}',
            ),
          );
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.transaction,
    required this.isDeleting,
    required this.onDelete,
    required this.onEdit,
  });

  final Transaction transaction;
  final bool isDeleting;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.isExpense;
    final color = isExpense ? AppColors.expense : AppColors.income;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [appShadow()],
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpense
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: color,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${isExpense ? '-' : '+'}${formatAmount(transaction.amount)}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                transaction.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (transaction.date != null) ...[
                const SizedBox(height: 4),
                Text(
                  formatDate(transaction.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [appShadow()],
          ),
          child: Column(
            children: [
              _Row(
                label: 'Type',
                value: isExpense ? 'Expense' : 'Income',
              ),
              _Row(
                label: 'Category',
                value: transaction.category?.title ?? 'Uncategorized',
              ),
              _Row(
                label: 'Account',
                value: transaction.account?.title ?? '—',
              ),
              if (transaction.notes != null && transaction.notes!.isNotEmpty)
                _Row(label: 'Notes', value: transaction.notes!),
              if (transaction.tags != null && transaction.tags!.isNotEmpty)
                _Row(label: 'Tags', value: transaction.tags!),
              if (transaction.receipt != null && transaction.receipt!.isNotEmpty)
                _Row(label: 'Receipt', value: 'Attached'),
            ],
          ),
        ),
        if (transaction.receipt != null && transaction.receipt!.isNotEmpty) ...[
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              transaction.receipt!,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(
                height: 100,
                color: AppColors.field,
                alignment: Alignment.center,
                child: const Text(
                  'Receipt unavailable',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.hint,
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientButton(
                label: isDeleting ? '…' : 'Delete',
                icon: Icons.delete_outline_rounded,
                expanded: true,
                isLoading: isDeleting,
                onPressed: isDeleting ? null : onDelete,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.hint,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}