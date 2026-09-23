import 'package:expense_tracker/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  bool destructive = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.surface,
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              backgroundColor: destructive ? AppColors.expense : AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              confirmLabel,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

Future<void> showAppSnack(BuildContext context, String message,
    {bool isError = false}) {
  if (!context.mounted) return Future.value();
  final messenger = ScaffoldMessenger.of(context);
  return messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.expense : null,
      duration: const Duration(seconds: 2),
    ),
  ).closed;
}