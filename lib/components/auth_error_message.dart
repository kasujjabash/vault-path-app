import 'package:flutter/material.dart';

/// Reusable error message component for authentication screens
class AuthErrorMessage extends StatelessWidget {
  final String? error;

  const AuthErrorMessage({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        error!,
        style: const TextStyle(color: Colors.redAccent, fontSize: 14),
      ),
    );
  }
}
