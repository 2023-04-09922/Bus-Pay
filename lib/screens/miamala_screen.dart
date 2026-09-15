import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class MiamalaScreen extends StatelessWidget {
  const MiamalaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);

    if (app.transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(s.noTx, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: app.transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final tx = app.transactions[i];
        final isIn = tx.type == TransactionType.nauli;
        final subtitle = switch (tx.type) {
          TransactionType.nauli => s.paid,
          TransactionType.toaPesa => '${s.withdrawn} • ${tx.detail}',
          TransactionType.tumaPesa => '${s.sent} • ${tx.detail}',
        };
        final time =
            '${tx.time.hour.toString().padLeft(2, '0')}:${tx.time.minute.toString().padLeft(2, '0')}';

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isIn
                  ? Colors.green.withValues(alpha: 0.15)
                  : Colors.orange.withValues(alpha: 0.15),
              child: Icon(
                isIn ? Icons.person : Icons.swap_horiz,
                color: isIn ? Colors.green : Colors.orange,
              ),
            ),
            title: Text(
              tx.passengerName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('$subtitle • $time'),
            trailing: Text(
              '${isIn ? '+' : '-'}${s.tzs(tx.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isIn ? Colors.green : Colors.orange.shade800,
              ),
            ),
          ),
        );
      },
    );
  }
}
