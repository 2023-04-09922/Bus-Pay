import 'package:flutter/material.dart';

import '../auth/money_amount.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';

const _networks = ['M-Pesa', 'Tigo Pesa', 'Airtel Money', 'HaloPesa'];

class TumaPesaScreen extends StatefulWidget {
  const TumaPesaScreen({super.key});

  @override
  State<TumaPesaScreen> createState() => _TumaPesaScreenState();
}

class _TumaPesaScreenState extends State<TumaPesaScreen> {
  String network = _networks.first;
  final phoneController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void submit() {
    final app = AppScope.of(context);
    final s = S(app.language);
    final amount = MoneyAmount.parse(amountController.text);

    if (phoneController.text.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }

    final ok = app.sendMobileMoney(
      network: network,
      phone: phoneController.text,
      amount: amount,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? s.success : s.lowBalance)),
    );
    if (ok) {
      phoneController.clear();
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
        Text(s.network, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _networks.map((n) {
            final selected = network == n;
            return ChoiceChip(
              label: Text(n),
              selected: selected,
              onSelected: (_) => setState(() => network = n),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: s.phone,
            hintText: '07XX XXX XXX',
            prefixIcon: const Icon(Icons.phone),
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
              s.send,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
