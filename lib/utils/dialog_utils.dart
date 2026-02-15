import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

/// Utility class for creating modern, consistently styled dialogs
class DialogUtils {
  /// Create a modern styled AlertDialog with app theme
  static AlertDialog createModernDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
    IconData? titleIcon,
    Color? titleColor,
  }) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          if (titleIcon != null) ...[
            Icon(
              titleIcon,
              color: titleColor ?? AppConstants.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: titleColor ?? AppConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
      content: content,
      actions: actions,
    );
  }

  /// Create a modern text input field for dialogs
  static Widget createDialogTextField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.inter(fontSize: 16),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppConstants.errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppConstants.errorColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Create a modern primary action button for dialogs
  static Widget createPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isDestructive = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isDestructive ? AppConstants.errorColor : AppConstants.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// Create a modern secondary action button for dialogs
  static Widget createSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey.shade600,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 18), const SizedBox(width: 8)],
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  /// Create a modern dropdown field for dialogs
  static Widget createDialogDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    required String labelText,
    IconData? prefixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        items: items,
        onChanged: onChanged,
        style: GoogleFonts.inter(fontSize: 16, color: Colors.black87),
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppConstants.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Create modern dialog content text
  static Widget createDialogText(String text, {TextStyle? style}) {
    return Text(
      text,
      style:
          style ??
          GoogleFonts.inter(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
    );
  }

  /// Create modern confirmation dialog
  static Future<bool?> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    IconData? titleIcon,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => createModernDialog(
            title: title,
            titleIcon: titleIcon,
            titleColor: isDestructive ? AppConstants.errorColor : null,
            content: createDialogText(message),
            actions: [
              createSecondaryButton(
                text: cancelText,
                onPressed: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: 8),
              createPrimaryButton(
                text: confirmText,
                isDestructive: isDestructive,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
    );
  }
}
