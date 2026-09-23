import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

export 'package:expense_tracker/core/widgets/animated_amount.dart'
    show CountUpText, formatThousands;

class PeriodSelector extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  final List<String> periods;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: periods.map((period) {
          final isSelected = period == selected;
          return GestureDetector(
            onTap: () => onChanged(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                gradient: isSelected ? AppColors.buttonGradient : null,
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: Color(0x334F46E5),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                child: Text(period),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}