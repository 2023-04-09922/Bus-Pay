import 'package:flutter/material.dart';

import '../../../auth/money_amount.dart';
import '../../../auth/tz_phone.dart';
import '../../../core/di/injection.dart';
import '../../../l10n/strings.dart';
import '../../../nfc/nfc_uid.dart';
import '../../../state/app_state.dart';

class RenewCardPage extends StatefulWidget {
  const RenewCardPage({super.key});

  @override
  State<RenewCardPage> createState() => _RenewCardPageState();
}

class _RenewCardPageState extends State<RenewCardPage> {
  final card = TextEditingController();
  final uid = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final load = TextEditingController();
  bool busy = false;

  @override
  void initState() {
    super.initState();
    phone.text = TzPhone.format('');
  }

  @override
  void dispose() {
    card.dispose();
    uid.dispose();
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    load.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final s = S(AppScope.of(context).language);
    if (card.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }
    final token = AppScope.of(context).authToken ?? '';
    setState(() => busy = true);
    try {
      await Injection.renewCard(
        token: token,
        serialNumber: card.text.trim(),
        nfcUid: uid.text.trim().isEmpty ? null : uid.text.trim(),
        firstName: firstName.text.trim().isEmpty ? null : firstName.text.trim(),
        lastName: lastName.text.trim().isEmpty ? null : lastName.text.trim(),
        phone: TzPhone.isValid(phone.text) ? TzPhone.toApi(phone.text) : null,
        amount: MoneyAmount.parse(load.text),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.cardRenewed)),
      );
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
      appBar: AppBar(title: Text(s.renewCard)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: card,
            decoration: InputDecoration(
              labelText: s.cardNumber,
              prefixIcon: const Icon(Icons.credit_card),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: uid,
            inputFormatters: const [NfcUidFormatter()],
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              labelText: s.nfcUid,
              prefixIcon: const Icon(Icons.nfc),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: firstName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: s.firstName,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: lastName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: s.lastName,
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            inputFormatters: const [TzPhoneFormatter()],
            decoration: InputDecoration(
              labelText: s.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: load,
            keyboardType: TextInputType.number,
            inputFormatters: const [MoneyFormatter()],
            decoration: InputDecoration(
              labelText: s.firstLoad,
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
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
                      s.renewCard,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
