import 'package:flutter/material.dart';

import '../../../auth/money_amount.dart';
import '../../../core/di/injection.dart';
import '../../../l10n/strings.dart';
import '../../../services/api_service.dart';
import '../../../state/app_state.dart';

class TopUpCardPage extends StatefulWidget {
  const TopUpCardPage({super.key});

  @override
  State<TopUpCardPage> createState() => _TopUpCardPageState();
}

class _TopUpCardPageState extends State<TopUpCardPage> {
  final card = TextEditingController();
  final amount = TextEditingController();
  bool busy = false;
  String cardError = '';
  String amountError = '';
  String holderName = '';
  int? currentBalance;

  @override
  void dispose() {
    card.dispose();
    amount.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final serial = card.text.trim();
    if (serial.isEmpty) {
      setState(() {
        holderName = '';
        currentBalance = null;
      });
      return;
    }
    final token = AppScope.of(context).authToken ?? '';
    try {
      final data = await ApiService.lookupCard(
        token: token,
        serialNumber: serial,
      );
      if (!mounted) return;
      final customer = data['customer'] as Map<String, dynamic>? ?? {};
      final cardData = data['card'] as Map<String, dynamic>? ?? {};
      setState(() {
        cardError = '';
        holderName =
            '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'.trim();
        currentBalance = (cardData['balance'] as num?)?.toInt();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        holderName = '';
        currentBalance = null;
        cardError = S(AppScope.of(context).language).unknownUser;
      });
    }
  }

  Future<void> submit() async {
    final s = S(AppScope.of(context).language);
    final serial = card.text.trim();
    final value = MoneyAmount.parse(amount.text);
    setState(() {
      cardError = serial.isEmpty ? s.cardRequired : '';
      amountError = value <= 0 ? s.amountRequired : '';
    });
    if (cardError.isNotEmpty || amountError.isNotEmpty) return;

    final token = AppScope.of(context).authToken ?? '';
    setState(() => busy = true);
    try {
      final result = await Injection.topUpCard(
        token: token,
        serialNumber: serial,
        amount: value,
      );
      if (!mounted) return;
      final cardData = result['card'] as Map<String, dynamic>? ?? {};
      final customer = result['customer'] as Map<String, dynamic>? ?? {};
      final name =
          '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'.trim();
      final credited = (result['credited'] as num?)?.toInt() ?? value;
      final previous = (result['previousBalance'] as num?)?.toInt();
      final next = (cardData['balance'] as num?)?.toInt() ?? 0;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.topUpOk),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.isEmpty ? serial : name),
              const SizedBox(height: 8),
              Text('${s.amountAdded}: ${s.tzs(credited)}'),
              if (previous != null) Text('${s.currentBalance}: ${s.tzs(previous)}'),
              Text(
                '${s.newBalance}: ${s.tzs(next)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.done),
            ),
          ],
        ),
      );
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(title: Text(s.topUpCard)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            s.amountRequired,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: card,
            textInputAction: TextInputAction.next,
            onEditingComplete: _lookup,
            onChanged: (_) {
              if (cardError.isNotEmpty) setState(() => cardError = '');
            },
            decoration: InputDecoration(
              labelText: '${s.cardNumber} *',
              prefixIcon: const Icon(Icons.credit_card),
              errorText: cardError.isEmpty ? null : cardError,
              errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          if (holderName.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '$holderName • ${s.currentBalance}: ${s.tzs(currentBalance ?? 0)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 14),
          TextField(
            controller: amount,
            keyboardType: TextInputType.number,
            inputFormatters: const [MoneyFormatter()],
            onChanged: (_) {
              if (amountError.isNotEmpty) setState(() => amountError = '');
            },
            decoration: InputDecoration(
              labelText: '${s.amount} *',
              hintText: s.amountRequired,
              prefixIcon: const Icon(Icons.payments_outlined),
              errorText: amountError.isEmpty ? null : amountError,
              errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: busy ? null : submit,
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      s.topUpCard,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
