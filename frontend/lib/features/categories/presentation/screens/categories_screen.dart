import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:expense_tracker/core/widgets/confirm_dialog.dart';
import 'package:expense_tracker/core/widgets/gradient_button.dart';
import 'package:expense_tracker/core/widgets/shimmer.dart';
import 'package:expense_tracker/core/widgets/status_views.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/categories_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoriesBloc>().add(const CategoriesLoaded());
  }

  Future<void> _addCategory() async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.surface,
          title: const Text(
            'New Category',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Category name',
              hintText: 'e.g. Groceries',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            GradientButton(
              label: 'Create',
              expanded: false,
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    final title = controller.text.trim();
    if (confirmed == true && title.isNotEmpty) {
      if (!mounted) return;
      context.read<CategoriesBloc>().add(CategoryCreated(title));
    }
  }

  Future<void> _delete(CategoryWithStats category) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete category',
      message: 'Delete "${category.title}"?',
    );
    if (!confirmed) return;
    if (!mounted) return;
    context.read<CategoriesBloc>().add(CategoryDeleted(category.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCategory,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Category',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: BlocConsumer<CategoriesBloc, CategoriesState>(
        listenWhen: (previous, current) =>
            current.failure != null && current.failure != previous.failure,
        listener: (context, state) {
          if (state.failure != null) {
            showAppSnack(context, state.failure!.message, isError: true);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<CategoriesBloc>().add(const CategoriesRefreshed()),
            child: SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 6),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: _buildBody(state),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(CategoriesState state) {
    switch (state.status) {
      case CategoriesStatus.initial:
      case CategoriesStatus.loading:
        if (state.items.isEmpty) return _buildSkeleton();
        return _buildList(state);
      case CategoriesStatus.failure:
        return SliverToBoxAdapter(
          child: SizedBox(
            height: 360,
            child: ErrorView(
              message: state.failure?.message ?? 'Unable to load categories',
              onRetry: () => context
                  .read<CategoriesBloc>()
                  .add(const CategoriesRefreshed()),
            ),
          ),
        );
      case CategoriesStatus.loaded:
        if (state.items.isEmpty) {
          return const SliverToBoxAdapter(
            child: SizedBox(
              height: 360,
              child: EmptyView(
                icon: Icons.category_outlined,
                title: 'No categories yet',
                subtitle: 'Add categories to organise spending',
              ),
            ),
          );
        }
        return _buildList(state);
    }
  }

  Widget _buildSkeleton() {
    return SliverToBoxAdapter(
      child: SizedBox(height: 560, child: ListSkeleton(count: 8)),
    );
  }

  Widget _buildList(CategoriesState state) {
    final total = state.items.fold<double>(
      0,
      (sum, item) => sum + item.totalAmount,
    );
    return SliverToBoxAdapter(
      child: Column(
        children: [
          for (final (index, category) in state.items.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 320 + index * 50),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: child,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [appShadow()],
                  ),
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(
                        '/category/${category.id}?title=${Uri.encodeQueryComponent(category.title)}',
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.category_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${category.transactionCount} transactions',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _delete(category),
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: AppColors.hint,
                                size: 22,
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatAmount(category.totalAmount),
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.expense,
                                  ),
                                ),
                                if (total > 0)
                                  Text(
                                    '${(category.totalAmount / total * 100).toStringAsFixed(0)}%',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.hint,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}