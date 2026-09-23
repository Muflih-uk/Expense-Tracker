import 'package:expense_tracker/core/utils/formatters.dart';
import 'package:flutter/material.dart';

class AnimatedAmount extends StatelessWidget {
  const AnimatedAmount({
    super.key,
    required this.amount,
    this.style,
    this.duration = 800,
  });

  final double amount;
  final TextStyle? style;
  final int duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: Duration(milliseconds: duration),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(formatAmount(value), style: style),
    );
  }
}

class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    this.style,
  });

  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(
      value.replaceAll('₹', '').replaceAll(',', ''),
    );
    if (amount == null) return Text(value, style: style);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: amount),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        final sign = amount < 0 ? '-' : '';
        return Text(
          '$sign${formatThousands(animated.abs())}',
          style: style,
        );
      },
    );
  }
}

String formatThousands(double value) {
  final fixed = value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) buffer.write(',');
    buffer.write(whole[i]);
  }
  return '₹$buffer.${parts[1]}';
}