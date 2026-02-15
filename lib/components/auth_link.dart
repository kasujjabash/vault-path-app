import 'package:flutter/material.dart';

/// Reusable auth link component for navigation between login/register
class AuthLink extends StatelessWidget {
  final String question;
  final String linkText;
  final VoidCallback onTap;

  const AuthLink({
    super.key,
    required this.question,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          question,
          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
