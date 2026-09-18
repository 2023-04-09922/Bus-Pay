import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class MiamalaScreen extends StatefulWidget {
  const MiamalaScreen({super.key});

  @override
  State<MiamalaScreen> createState() => _MiamalaScreenState();
}

class _MiamalaScreenState extends State<MiamalaScreen> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    setState(() => loading = true);
    await AppScope.of(context).refreshLedger();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);

    if (loading && app.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: app.transactions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final tx = app.transactions[i];
          final isIn = tx.type == TransactionType.nauli;
          final subtitle = switch (tx.type) {
            TransactionType.nauli => tx.reference.isEmpty
                ? s.paid
                : '${s.paid} • ${tx.reference}',
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
      ),
    );
  }
}
