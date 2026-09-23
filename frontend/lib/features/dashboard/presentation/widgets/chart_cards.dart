import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:expense_tracker/core/widgets/animated_amount.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

const List<Color> chartPalette = [
  AppColors.primary,
  Color(0xFF22D3EE),
  Color(0xFF7C3AED),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFFF43F5E),
  Color(0xFF14B8A6),
  Color(0xFFF97316),
];

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [appShadow()],
  );
}

class TrendChartCard extends StatefulWidget {
  const TrendChartCard({super.key, required this.data});

  final List<({String month, double income, double expenses})> data;

  @override
  State<TrendChartCard> createState() => _TrendChartCardState();
}

class _TrendChartCardState extends State<TrendChartCard> {
  bool _showIncome = true;
  bool _showExpenses = true;
  int? _selected;

  List<({String month, double income, double expenses})> get _data =>
      widget.data;

  @override
  Widget build(BuildContext context) {
    if (_data.isEmpty) {
      return _EmptyChart(message: 'No trend data yet');
    }
    final hasIncome = _showIncome;
    final hasExpenses = _showExpenses;
    var maxValue = 0.0;
    for (final d in _data) {
      if (hasIncome && d.income > maxValue) maxValue = d.income;
      if (hasExpenses && d.expenses > maxValue) maxValue = d.expenses;
    }
    final maxY = (maxValue * 1.2).clamp(100, double.infinity).toDouble();
    final selected = _selected != null && _selected! < _data.length
        ? _data[_selected!]
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Monthly Trend',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              _LegendToggle(
                color: AppColors.income,
                label: 'Income',
                active: _showIncome,
                onTap: () => setState(() => _showIncome = !_showIncome),
              ),
              const SizedBox(width: 10),
              _LegendToggle(
                color: AppColors.expense,
                label: 'Expenses',
                active: _showExpenses,
                onTap: () => setState(() => _showExpenses = !_showExpenses),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 190,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                minY: 0,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final rodCount =
                          (hasIncome ? 1 : 0) + (hasExpenses ? 1 : 0);
                      if (rodCount == 1) {
                        final label = _showIncome ? 'Income' : 'Expenses';
                        return BarTooltipItem(
                          '${_data[groupIndex].month}\n$label ${formatCompact(rod.toY)}',
                          const TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }
                      final label = rodIndex == 0 ? 'Income' : 'Expenses';
                      return BarTooltipItem(
                        '$label\n${formatCompact(rod.toY)}',
                        const TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                  touchCallback: (event, response) {
                    if (event.isInterestedForInteractions &&
                        response != null &&
                        response.spot != null) {
                      setState(() => _selected = response.spot!.touchedBarGroupIndex);
                    } else if (event is FlTapUpEvent) {
                      if (response == null || response.spot == null) {
                        setState(() => _selected = null);
                      }
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= _data.length) {
                          return const SizedBox.shrink();
                        }
                        final month = _data[index].month;
                        final parts = month.split('-');
                        final label = parts.length == 2 ? parts[1] : month;
                        final isSelected = index == _selected;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(_data.length, (index) {
                  final item = _data[index];
                  final isDimmed =
                      _selected != null && index != _selected;
                  return BarChartGroupData(
                    x: index,
                    barsSpace: 3,
                    barRods: [
                      if (hasIncome)
                        BarChartRodData(
                          toY: item.income,
                          width: hasExpenses ? 9 : 12,
                          color: isDimmed
                              ? AppColors.income.withValues(alpha: 0.35)
                              : AppColors.income,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      if (hasExpenses)
                        BarChartRodData(
                          toY: item.expenses,
                          width: hasIncome ? 9 : 12,
                          color: isDimmed
                              ? AppColors.expense.withValues(alpha: 0.35)
                              : AppColors.expense,
                          borderRadius: BorderRadius.circular(4),
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected == null
                  ? AppColors.field
                  : AppColors.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: selected == null
                ? const Text(
                    'Tap a bar to compare income & expenses',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.hint,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        selected.month,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'I ${formatCompact(selected.income)}  ·  E ${formatCompact(selected.expenses)}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Net ${formatCompact(selected.income - selected.expenses)}',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: selected.income - selected.expenses < 0
                                  ? AppColors.expense
                                  : AppColors.income,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class CategoryBreakdownCard extends StatefulWidget {
  const CategoryBreakdownCard({super.key, required this.items});

  final List<({String title, double total})> items;

  @override
  State<CategoryBreakdownCard> createState() => _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState extends State<CategoryBreakdownCard> {
  int? _selected;

  List<({String title, double total})> get _items => widget.items;

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return _EmptyChart(message: 'No spending by category yet');
    }
    final total = _items.fold<double>(0, (a, b) => a + b.total);
    final effective = total <= 0 ? 1.0 : total;
    final selected = _selected != null && _selected! < _items.length
        ? _items[_selected!]
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending by Category',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 44,
                    startDegreeOffset: -90,
                    sections: List.generate(_items.length, (index) {
                      final item = _items[index];
                      final isSelected = index == _selected;
                      final color = chartPalette[index % chartPalette.length];
                      return PieChartSectionData(
                        value: item.total,
                        color: isSelected
                            ? color
                            : _selected == null
                                ? color
                                : color.withValues(alpha: 0.3),
                        radius: isSelected ? 60 : 56,
                        showTitle: false,
                        borderSide: isSelected
                            ? const BorderSide(color: Colors.white, width: 2)
                            : BorderSide.none,
                      );
                    }),
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (event is FlTapUpEvent) {
                          final touched = response?.touchedSection?.touchedSectionIndex;
                          setState(() {
                            _selected = _selected == touched ? null : touched;
                          });
                        }
                      },
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selected?.title ?? 'Total spent',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.hint,
                        ),
                      ),
                      const SizedBox(height: 2),
                      selected == null
                          ? AnimatedAmount(
                              amount: total,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : Column(
                              children: [
                                Text(
                                  '${(selected.total / effective * 100).toStringAsFixed(0)}%',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                AnimatedAmount(
                                  amount: selected.total,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final percent = (item.total / effective * 100);
            final isSelected = index == _selected;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() {
                _selected = isSelected ? null : index;
              }),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: chartPalette[index % chartPalette.length],
                        shape: BoxShape.circle,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: chartPalette[index %
                                          chartPalette.length]
                                      .withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 74,
                      child: Text(
                        formatCompact(item.total),
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Tap a slice or row to inspect a category',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: AppColors.hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration(),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}

class _LegendToggle extends StatelessWidget {
  const _LegendToggle({
    required this.color,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: active ? color : AppColors.hint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? AppColors.textPrimary : AppColors.hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatCompact(double value) {
  if (value >= 10000000) return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
  if (value >= 100000) return '₹${(value / 100000).toStringAsFixed(1)}L';
  if (value >= 1000) return '₹${(value / 1000).toStringAsFixed(1)}k';
  return '₹${value.toStringAsFixed(0)}';
}