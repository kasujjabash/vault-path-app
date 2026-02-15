import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// Dialog to show network troubleshooting steps
class NetworkTroubleshootingDialog extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const NetworkTroubleshootingDialog({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  static Future<void> show(
    BuildContext context, {
    required String errorMessage,
    VoidCallback? onRetry,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => NetworkTroubleshootingDialog(
            errorMessage: errorMessage,
            onRetry: onRetry,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final troubleshootingSteps = AuthService.getNetworkTroubleshootingSteps();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          const Text(
            'Network Issue',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errorMessage, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text(
              'Try these steps:',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            ...troubleshootingSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: TextButton.styleFrom(foregroundColor: Colors.grey.shade700),
          child: const Text('Close'),
        ),
        if (onRetry != null)
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry!();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006E1F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: const Text('Try Again'),
          ),
      ],
    );
  }
}
