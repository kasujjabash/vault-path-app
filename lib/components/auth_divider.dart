import 'package:flutter/material.dart';

/// Reusable divider component with "or" text
class AuthDivider extends StatelessWidget {
  final String text;

  const AuthDivider({super.key, this.text = 'or'});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
        ),
      ],
    );
  }
}
