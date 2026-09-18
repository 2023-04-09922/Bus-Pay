import 'package:flutter/material.dart';

import '../auth/money_amount.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';

class ToaPesaScreen extends StatefulWidget {
  const ToaPesaScreen({super.key});

  @override
  State<ToaPesaScreen> createState() => _ToaPesaScreenState();
}

class _ToaPesaScreenState extends State<ToaPesaScreen> {
  final agentController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    agentController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void submit() {
    final app = AppScope.of(context);
    final s = S(app.language);
    final amount = MoneyAmount.parse(amountController.text);

    if (agentController.text.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }

    final ok = app.withdrawToAgent(
      agentName: 'Wakala ${agentController.text}',
      amount: amount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? s.success : s.lowBalance)),
    );
    if (ok) {
      agentController.clear();
      amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: Text(s.wallet),
            trailing: Text(
              s.tzs(app.walletBalance),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          s.isSw
              ? 'Toa pesa kupitia wakala'
              : 'Withdraw through an agent',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: agentController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: s.agentCode,
            hintText: 'Mfano: 123456',
            prefixIcon: const Icon(Icons.storefront),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          inputFormatters: const [MoneyFormatter()],
          decoration: InputDecoration(
            labelText: s.amount,
            prefixIcon: const Icon(Icons.payments),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: submit,
            child: Text(
              s.withdraw,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
