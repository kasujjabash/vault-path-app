import 'package:flutter/material.dart';

class CustomSnackBar {
  static void show({
    required BuildContext context,
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = const Color(0xFF006E1F); // Dark green
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = const Color(0xFFD32F2F); // Dark red
        textColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = const Color(0xFFF57C00); // Dark orange
        textColor = Colors.white;
        icon = Icons.warning_outlined;
        break;
      case SnackBarType.info:
        backgroundColor = const Color(0xFF006E1F); // Dark green
        textColor = Colors.white;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        action:
            actionLabel != null && onActionPressed != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: textColor,
                  onPressed: onActionPressed,
                )
                : null,
      ),
    );
  }

  // Convenience methods
  static void showSuccess(BuildContext context, String message) {
    show(context: context, message: message, type: SnackBarType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context: context, message: message, type: SnackBarType.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context: context, message: message, type: SnackBarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context: context, message: message, type: SnackBarType.info);
  }
}

enum SnackBarType { success, error, warning, info }
