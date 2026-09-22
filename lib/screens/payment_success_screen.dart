import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class PaymentSuccessScreen extends StatelessWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.passengerName,
    this.reference = '',
    this.success = true,
    this.onRetry,
  });

  final int amount;
  final String passengerName;
  final String reference;
  final bool success;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                success ? Icons.check_circle : Icons.cancel,
                color: success ? Colors.green : Colors.red,
                size: 108,
              ),
              const SizedBox(height: 20),
              Text(
                success ? s.paymentComplete : s.paymentFailed,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: success ? Colors.green.shade800 : Colors.red.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                passengerName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                s.tzs(amount),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (reference.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(reference, style: const TextStyle(color: Colors.grey)),
              ],
              const Spacer(),
              if (!success)
                TextButton(
                  onPressed: onRetry ?? () => Navigator.pop(context),
                  child: Text(
                    s.tryAgain,
                    style: const TextStyle(fontSize: 14, color: Colors.red),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    s.done,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
