String formatAmount(dynamic value, {bool showSymbol = true}) {
  final amount = value is double
      ? value
      : double.tryParse('${value ?? 0}') ?? 0;
  final sign = amount < 0 ? '-' : '';
  final fixed = amount.abs().toStringAsFixed(2);
  final parts = fixed.split('.');
  final whole = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < whole.length; i++) {
    if (i > 0 && (whole.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(whole[i]);
  }
  final symbol = showSymbol ? '₹' : '';
  return '$sign$symbol$buffer.${parts[1]}';
}

double parseAmount(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? 0}') ?? 0;
}

String formatDate(String? isoDate) {
  if (isoDate == null || isoDate.isEmpty) return '';
  final parts = isoDate.split('-');
  if (parts.length < 3) return isoDate;
  final year = parts[0];
  final month = int.tryParse(parts[1]) ?? 1;
  final day = parts[2];
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final label = labels[(month - 1).clamp(0, 11)];
  return '$day $label $year';
}

String formatDateTime(String? isoDateTime) {
  if (isoDateTime == null || isoDateTime.isEmpty) return '';
  final datePart = isoDateTime.split('T').first;
  return formatDate(datePart);
}

String monthLabel(String monthKey) {
  const labels = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final parts = monthKey.split('-');
  if (parts.length < 2) return monthKey;
  final month = int.tryParse(parts[1]) ?? 1;
  return labels[(month - 1).clamp(0, 11)];
}

String toApiDate(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
