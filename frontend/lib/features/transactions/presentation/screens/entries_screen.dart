import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/di/service_locator.dart';
import 'package:expense_tracker/core/utils/debouncer.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/core/widgets/app_text_field.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/core/widgets/shimmer.dart';
import 'package:expense_tracker/core/widgets/status_views.dart';
import 'package:expense_tracker/core/widgets/transaction_tile.dart';
import 'package:expense_tracker/features/accounts/presentation/accounts_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/categories_bloc.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/presentation/transactions_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class EntriesScreen extends StatefulWidget {
  const EntriesScreen({super.key});

  @override
  State<EntriesScreen> createState() => _EntriesScreenState();
}

class _EntriesScreenState extends State<EntriesScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 600));
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<TransactionsBloc>().add(const TransactionsStarted());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      context.read<TransactionsBloc>().add(const TransactionsLoadMore());
    }
  }

  Future<void> _openFilters(TransactionsState state) async {
    final result = await showModalBottomSheet<TransactionFilter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => TransactionFilterSheet(initial: state.filter),
    );
    if (result == null) return;
    if (!mounted) return;
    context.read<TransactionsBloc>().add(TransactionsFilterChanged(result));
  }

  Future<void> _delete(Transaction tx) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete entry',
      message: 'Delete "${tx.title}"? This cannot be undone.',
    );
    if (!confirmed) return;
    if (!mounted) return;
    final result = await transactionRepository.deleteTransaction(tx.id);
    result.when(
      success: (_) => context
          .read<TransactionsBloc>()
          .add(const TransactionsRefreshed()),
      failure: (failure) =>
          showAppSnack(context, failure.message, isError: true),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          return Column(
            children: [
              _buildHeader(context, state),
              if (state.summary != null) _SummaryStrip(summary: state.summary!),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TransactionsState state) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Transactions',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _openFilters(state),
                icon: Badge(
                  isLabelVisible: _hasActiveFilter(state.filter),
                  label: const SizedBox(
                    width: 6,
                    height: 6,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.tune_rounded,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(
            controller: _searchController,
            label: '',
            hintText: 'Search entries…',
            prefixIcon: Icons.search_rounded,
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      _debouncer.run(
                        () => context
                            .read<TransactionsBloc>()
                            .add(const TransactionsSearchChanged('')),
                      );
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.hint,
                      size: 20,
                    ),
                  ),
            onChanged: (value) {
              setState(() {});
              _debouncer.run(
                () => context
                    .read<TransactionsBloc>()
                    .add(TransactionsSearchChanged(value)),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _hasActiveFilter(TransactionFilter filter) {
    return filter.type != 'all' ||
        filter.period != 'all' ||
        filter.categoryId != null ||
        filter.accountId != null ||
        filter.amountMin != null ||
        filter.amountMax != null ||
        filter.hasCustomRange;
  }

  Widget _buildBody(TransactionsState state) {
    switch (state.status) {
      case TransactionsStatus.initial:
      case TransactionsStatus.loading:
        if (state.items.isEmpty) return _buildSkeleton();
        return _buildList(state);
      case TransactionsStatus.failure:
        return ErrorView(
          message: state.failure?.message ?? 'Unable to load entries',
          onRetry: () =>
              context.read<TransactionsBloc>().add(const TransactionsStarted()),
        );
      case TransactionsStatus.loaded:
      case TransactionsStatus.loadingMore:
        if (state.items.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => context
                .read<TransactionsBloc>()
                .add(const TransactionsRefreshed()),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                const EmptyView(
                  icon: Icons.receipt_long_rounded,
                  title: 'No entries found',
                  subtitle: 'Tap + to add your first transaction',
                ),
              ],
            ),
          );
        }
        return _buildList(state);
    }
  }

  Widget _buildList(TransactionsState state) {
    return RefreshIndicator(
      onRefresh: () async =>
          context.read<TransactionsBloc>().add(const TransactionsRefreshed()),
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        itemCount: state.items.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: AppColors.primary,
                  ),
                ),
              ),
            );
          }
          final tx = state.items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TransactionTile(
              transaction: tx,
              appearIndex: index,
              onTap: () => context.push('/transaction/${tx.id}'),
              onDelete: () => _delete(tx),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListSkeleton(count: 8);
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({required this.summary});

  final TxSummaryResponse summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _Stat(
              label: 'Income',
              amount: summary.totalIncome,
              color: AppColors.income,
            ),
          ),
          Expanded(
            child: _Stat(
              label: 'Expenses',
              amount: summary.totalExpenses,
              color: AppColors.expense,
            ),
          ),
          Expanded(
            child: _Stat(
              label: 'Net',
              amount: summary.netAmount,
              color: summary.netAmount < 0
                  ? AppColors.expense
                  : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.amount, required this.color});

  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.hint,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatAmount(amount),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class TransactionFilterSheet extends StatefulWidget {
  const TransactionFilterSheet({super.key, required this.initial});

  final TransactionFilter initial;

  @override
  State<TransactionFilterSheet> createState() => _TransactionFilterSheetState();
}

class _TransactionFilterSheetState extends State<TransactionFilterSheet> {
  late String _type;
  late String _period;
  DateTime? _from;
  DateTime? _to;
  int? _categoryId;
  int? _accountId;
  String? _amountMin;
  String? _amountMax;
  late String _ordering;
  final _minController = TextEditingController();
  final _maxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final filter = widget.initial;
    _type = filter.type;
    _period = filter.hasCustomRange ? 'custom' : filter.period;
    _from = filter.dateFrom;
    _to = filter.dateTo;
    _categoryId = filter.categoryId;
    _accountId = filter.accountId;
    _amountMin = filter.amountMin?.toStringAsFixed(0);
    _amountMax = filter.amountMax?.toStringAsFixed(0);
    _ordering = filter.ordering;
    _minController.text = _amountMin ?? '';
    _maxController.text = _amountMax ?? '';
    if (_from != null && _to != null) _period = 'custom';

    final categoriesBloc = context.read<CategoriesBloc>();
    if (categoriesBloc.state.items.isEmpty) {
      categoriesBloc.add(const CategoriesLoaded('month'));
    }
    final accountsBloc = context.read<AccountsBloc>();
    if (accountsBloc.state.accounts.isEmpty) {
      accountsBloc.add(const AccountsLoaded());
    }
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _type = 'all';
      _period = 'all';
      _from = null;
      _to = null;
      _categoryId = null;
      _accountId = null;
      _amountMin = null;
      _amountMax = null;
      _ordering = '-created_at';
      _minController.clear();
      _maxController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryItems = context.watch<CategoriesBloc>().state.items;
    final accountItems = context.watch<AccountsBloc>().state.accounts;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SheetLabel('Type'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'all',
                  label: Text('All'),
                  icon: Icon(Icons.all_inclusive_rounded, size: 18),
                ),
                ButtonSegment(
                  value: 'income',
                  label: Text('Income'),
                  icon: Icon(Icons.trending_up_rounded, size: 18),
                ),
                ButtonSegment(
                  value: 'expense',
                  label: Text('Expense'),
                  icon: Icon(Icons.trending_down_rounded, size: 18),
                ),
              ],
              selected: {_type},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _type = selection.first),
            ),
            const SizedBox(height: 18),
            _SheetLabel('Period'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in const [
                  ('all', 'All'),
                  ('today', 'Today'),
                  ('week', 'This Week'),
                  ('month', 'This Month'),
                  ('year', 'This Year'),
                  ('custom', 'Custom'),
                ])
                  _Chip(
                    label: entry.$2,
                    selected: _period == entry.$1,
                    onTap: () {
                      setState(() {
                        if (entry.$1 == 'custom' && (_from == null || _to == null)) {
                          _from = DateTime.now();
                          _to = DateTime.now();
                        }
                        _period = entry.$1;
                      });
                    },
                  ),
              ],
            ),
            if (_period == 'custom') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'From',
                      value: _from,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _from ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) =>
                              Theme(data: Theme.of(context), child: child!),
                        );
                        if (picked != null) setState(() => _from = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'To',
                      value: _to,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _to ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                          builder: (context, child) =>
                              Theme(data: Theme.of(context), child: child!),
                        );
                        if (picked != null) setState(() => _to = picked);
                      },
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            _SheetLabel('Category'),
            _DropdownField<int?>(
              value: _categoryId,
              hint: 'All categories',
              items: [
                for (final item in categoryItems)
                  DropdownMenuItem(value: item.id, child: Text(item.title)),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: 18),
            _SheetLabel('Account'),
            _DropdownField<int?>(
              value: _accountId,
              hint: 'All accounts',
              items: [
                for (final account in accountItems)
                  DropdownMenuItem(
                    value: account.id,
                    child: Text(account.title),
                  ),
              ],
              onChanged: (value) => setState(() => _accountId = value),
            ),
            const SizedBox(height: 18),
            _SheetLabel('Amount range'),
            Row(
              children: [
                Expanded(
                  child: _AmountField(
                    controller: _minController,
                    hint: 'Minimum',
                    onChanged: (value) => setState(() => _amountMin = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AmountField(
                    controller: _maxController,
                    hint: 'Maximum',
                    onChanged: (value) => setState(() => _amountMax = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SheetLabel('Sort by'),
            _DropdownField<String>(
              value: _ordering,
              items: const [
                DropdownMenuItem(value: '-created_at', child: Text('Newest first')),
                DropdownMenuItem(value: 'created_at', child: Text('Oldest first')),
                DropdownMenuItem(value: '-amount', child: Text('Amount: high to low')),
                DropdownMenuItem(value: 'amount', child: Text('Amount: low to high')),
              ],
              onChanged: (value) => setState(() => _ordering = value!),
            ),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Apply Filters',
              icon: Icons.check_rounded,
              onPressed: () {
                final customRange = _period == 'custom' && _from != null && _to != null;
                Navigator.of(context).pop(
                  TransactionFilter(
                    search: widget.initial.search,
                    type: _type,
                    period: customRange ? 'all' : _period,
                    categoryId: _categoryId,
                    accountId: _accountId,
                    amountMin: double.tryParse(_amountMin ?? ''),
                    amountMax: double.tryParse(_amountMax ?? ''),
                    dateFrom: customRange ? _from : null,
                    dateTo: customRange ? _to : null,
                    ordering: _ordering,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  const _SheetLabel(this.label);

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
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppColors.buttonGradient : null,
          color: selected ? null : const Color(0xFFEDF0F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E7EC)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.hint,
            ),
            const SizedBox(width: 10),
            Text(
              value == null ? label : formatDate(toApiDate(value!)),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: value == null
                    ? AppColors.hint
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  const _AmountField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(
          Icons.currency_rupee_rounded,
          size: 18,
          color: AppColors.hint,
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint ?? 'Select',
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.hint,
            ),
          ),
          items: items,
          onChanged: onChanged,
          dropdownColor: AppColors.surface,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          icon: const Icon(Icons.expand_more_rounded, color: AppColors.hint),
        ),
      ),
    );
  }
}