import 'package:flutter/material.dart';

/// Reusable button component for authentication screens
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isPrimary;
  final Widget? icon;
  final bool isEnabled;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isPrimary = true,
    this.icon,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: (isLoading || !isEnabled) ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isEnabled ? Colors.white : Colors.white.withOpacity(0.3),
            foregroundColor:
                isEnabled
                    ? const Color(0xFF006E1F)
                    : const Color(0xFF006E1F).withOpacity(0.5),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
          child:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF006E1F),
                      ),
                    ),
                  )
                  : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 54,
        child: OutlinedButton.icon(
          onPressed: (isLoading || !isEnabled) ? null : onPressed,
          icon:
              isLoading
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : (icon ?? const SizedBox()),
          label:
              isLoading
                  ? const SizedBox()
                  : Text(
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(27),
            ),
          ),
        ),
      );
    }
  }
}
