import 'dart:io';

import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/error/failure.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/features/accounts/presentation/accounts_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/categories_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/transaction_form_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/transactions_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/dashboard_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class TransactionFormScreen extends StatefulWidget {
  const TransactionFormScreen({super.key, this.type = 'expense', this.editId});

  final String type;
  final int? editId;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  late String _type;
  int? _categoryId;
  int? _accountId;
  DateTime _date = DateTime.now();
  String? _receiptPath;
  bool _isEditLoading = false;

  @override
  void initState() {
    super.initState();
    _type = widget.type;
    _loadOptions();
    if (widget.editId != null) _loadTransaction();
  }

  Future<void> _loadOptions() async {
    final categoriesBloc = context.read<CategoriesBloc>();
    if (categoriesBloc.state.items.isEmpty && categoriesBloc.state.status == CategoriesStatus.initial) {
      categoriesBloc.add(const CategoriesLoaded('month'));
    }
    final accountsBloc = context.read<AccountsBloc>();
    if (accountsBloc.state.accounts.isEmpty && accountsBloc.state.status == AccountsStatus.initial) {
      accountsBloc.add(const AccountsLoaded());
    }
  }

  Future<void> _loadTransaction() async {
    setState(() => _isEditLoading = true);
    final result = await transactionRepository.getTransaction(widget.editId!);
    if (!mounted) return;
    result.when(
      success: (tx) {
        setState(() {
          _type = tx.transactionType;
          _titleController.text = tx.title;
          _amountController.text = formatAmount(tx.amount);
          _categoryId = tx.category?.id;
          _accountId = tx.account?.id;
          if (tx.date != null) {
            final parts = tx.date!.split('-');
            if (parts.length == 3) {
              _date = DateTime(
                int.tryParse(parts[0]) ?? DateTime.now().year,
                int.tryParse(parts[1]) ?? 1,
                int.tryParse(parts[2]) ?? 1,
              );
            }
          }
          _notesController.text = tx.notes ?? '';
          _tagsController.text = tx.tags ?? '';
          _receiptPath = null;
          _isEditLoading = false;
        });
      },
      failure: (failure) {
        setState(() => _isEditLoading = false);
        showAppSnack(context, failure.message, isError: true);
        context.pop();
      },
    );
  }

  Future<void> _pickReceipt() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() => _receiptPath = picked.path);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      showAppSnack(context, 'Enter a valid amount', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    context.read<TransactionFormBloc>().add(
          TransactionFormSubmitted(
            id: widget.editId,
            payload: TransactionPayload(
              title: _titleController.text.trim(),
              amount: amount,
              transactionType: _type,
              categoryId: _categoryId,
              accountId: _accountId,
              date: _date,
              notes: _notesController.text.trim().isEmpty
                  ? null
                  : _notesController.text.trim(),
              tags: _tagsController.text.trim().isEmpty
                  ? null
                  : _tagsController.text.trim(),
              receiptPath: _receiptPath,
            ),
          ),
        );
  }

  void _refreshRelated() {
    context.read<TransactionsBloc>().add(const TransactionsRefreshed());
    context.read<DashboardBloc>().add(const DashboardRefreshed());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          widget.editId == null ? 'Add Transaction' : 'Edit Transaction',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: BlocConsumer<TransactionFormBloc, TransactionFormState>(
        listenWhen: (previous, current) =>
            current.result != null || current.failure != null,
        listener: (context, state) {
          final failure = state.failure;
          if (failure != null) {
            if (failure is ValidationFailure && failure.fieldErrors.isNotEmpty) {
              return;
            }
            showAppSnack(context, failure.message, isError: true);
            return;
          }
          if (state.result != null) {
            _refreshRelated();
            showAppSnack(context,
                widget.editId == null ? 'Transaction added' : 'Transaction updated');
            context.pop();
          }
        },
        builder: (context, state) {
          final fieldErrors = state.fieldErrors;
          if (_isEditLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'expense',
                        label: Text('Expense'),
                        icon: Icon(Icons.trending_down_rounded, size: 18),
                      ),
                      ButtonSegment(
                        value: 'income',
                        label: Text('Income'),
                        icon: Icon(Icons.trending_up_rounded, size: 18),
                      ),
                    ],
                    selected: {_type},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) =>
                        setState(() => _type = selection.first),
                  ),
                  const SizedBox(height: 22),
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    hintText: 'e.g. Lunch at café',
                    prefixIcon: Icons.label_outline_rounded,
                    validator: (value) =>
                        fieldErrors['title']?.first ??
                        (value == null || value.trim().isEmpty
                            ? 'Enter a title'
                            : null),
                    errorText: fieldErrors['title']?.first,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _amountController,
                    label: 'Amount',
                    hintText: '0.00',
                    prefixIcon: Icons.currency_rupee_rounded,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) =>
                        fieldErrors['amount']?.first ??
                        (value == null || double.tryParse(value) == null
                            ? 'Enter a valid amount'
                            : null),
                    errorText: fieldErrors['amount']?.first,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Category'),
                  _buildCategoryDropdown(),
                  const SizedBox(height: 16),
                  _FieldLabel('Account'),
                  _buildAccountDropdown(),
                  const SizedBox(height: 16),
                  _FieldLabel('Date'),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.field,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE4E7EC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.hint,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            formatDate(toApiDate(_date)),
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _notesController,
                    label: 'Notes (optional)',
                    hintText: 'Add a note…',
                    prefixIcon: Icons.notes_rounded,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _tagsController,
                    label: 'Tags (optional)',
                    hintText: 'comma, separated, tags',
                    prefixIcon: Icons.sell_outlined,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel('Receipt (optional)'),
                  _buildReceiptField(),
                  const SizedBox(height: 12),
                  if (fieldErrors['date'] != null)
                    _ErrorText(fieldErrors['date']!.first),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: widget.editId == null ? 'Save Transaction' : 'Update Transaction',
                    icon: Icons.check_rounded,
                    isLoading: state.isSubmitting,
                    onPressed: state.isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return BlocBuilder<CategoriesBloc, CategoriesState>(
      builder: (context, state) {
        final items = state.items;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _categoryId,
              isExpanded: true,
              hint: const Text(
                'Select category',
                style: TextStyle(fontFamily: 'Inter', color: AppColors.hint),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('No category'),
                ),
                for (final item in items)
                  DropdownMenuItem<int?>(
                    value: item.id,
                    child: Text(item.title),
                  ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.hint),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAccountDropdown() {
    return BlocBuilder<AccountsBloc, AccountsState>(
      builder: (context, state) {
        final accounts = state.accounts;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE4E7EC)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?>(
              value: _accountId,
              isExpanded: true,
              hint: const Text(
                'Select account',
                style: TextStyle(fontFamily: 'Inter', color: AppColors.hint),
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('No account'),
                ),
                for (final account in accounts)
                  DropdownMenuItem<int?>(
                    value: account.id,
                    child: Text(account.title),
                  ),
              ],
              onChanged: (value) => setState(() => _accountId = value),
              dropdownColor: AppColors.surface,
              icon: const Icon(Icons.expand_more_rounded, color: AppColors.hint),
            ),
          ),
        );
      },
    );
  }

  Widget _buildReceiptField() {
    return InkWell(
      onTap: _pickReceipt,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 20,
              color: AppColors.hint,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _receiptPath == null
                    ? 'Tap to attach a photo'
                    : File(_receiptPath!).uri.pathSegments.last,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: _receiptPath == null
                      ? AppColors.hint
                      : AppColors.textPrimary,
                ),
              ),
            ),
            if (_receiptPath != null)
              IconButton(
                onPressed: () => setState(() => _receiptPath = null),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.expense,
                ),
              )
            else
              const Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF5A6472),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        color: AppColors.expense,
      ),
    );
  }
}