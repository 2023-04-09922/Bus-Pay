import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class PaymentVerifyScreen extends StatelessWidget {
  const PaymentVerifyScreen({
    super.key,
    required this.amount,
    required this.passengerName,
  });

  final int amount;
  final String passengerName;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.verifyTitle),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: s.cancel,
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 44,
              child: Text(
                passengerName.substring(0, 1),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              passengerName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              s.passenger,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(s.nauli, style: const TextStyle(fontSize: 14)),
                  Text(
                    s.tzs(amount),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              s.isSw
                  ? 'Bonyeza tiki kuthibitisha au X kughairi'
                  : 'Tap the tick to confirm or X to cancel',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 72,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Icon(Icons.close, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 72,
                    child: ElevatedButton(
                      onPressed: () {
                        app.addNauliPayment(
                          passengerName: passengerName,
                          amount: amount,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Icon(Icons.check, size: 40),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      s.cancel,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      s.confirm,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
