import 'package:flutter/material.dart';

import '../auth/nida_id.dart';
import '../auth/tz_phone.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'fingerprint_scan_screen.dart';

class SajiliCardScreen extends StatefulWidget {
  const SajiliCardScreen({super.key});

  @override
  State<SajiliCardScreen> createState() => _SajiliCardScreenState();
}

class _SajiliCardScreenState extends State<SajiliCardScreen> {
  final card = TextEditingController();
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final nida = TextEditingController();

  @override
  void initState() {
    super.initState();
    phone.text = TzPhone.format('');
  }

  @override
  void dispose() {
    card.dispose();
    firstName.dispose();
    lastName.dispose();
    phone.dispose();
    nida.dispose();
    super.dispose();
  }

  Future<void> continueToScan() async {
    final s = S(AppScope.of(context).language);
    if (card.text.isEmpty ||
        firstName.text.isEmpty ||
        lastName.text.isEmpty ||
        !TzPhone.isValid(phone.text) ||
        !NidaId.isValid(nida.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }

    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const FingerprintScanScreen()),
    );
    if (!mounted || ok != true) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.cardRegistered)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(title: Text(s.sajiliCard)),
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
            controller: nida,
            keyboardType: TextInputType.number,
            inputFormatters: const [NidaFormatter()],
            decoration: InputDecoration(
              labelText: s.nida,
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: continueToScan,
              child: Text(
                s.continueBtn,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
