import 'package:flutter/material.dart';

import '../auth/nida_id.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'fingerprint_scan_screen.dart';

class HuishaCardScreen extends StatefulWidget {
  const HuishaCardScreen({super.key});

  @override
  State<HuishaCardScreen> createState() => _HuishaCardScreenState();
}

class _HuishaCardScreenState extends State<HuishaCardScreen> {
  final card = TextEditingController();
  final nida = TextEditingController();

  @override
  void dispose() {
    card.dispose();
    nida.dispose();
    super.dispose();
  }

  Future<void> verify() async {
    final s = S(AppScope.of(context).language);
    if (card.text.isEmpty || !NidaId.isValid(nida.text)) {
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
      SnackBar(content: Text(s.cardDeactivated)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(title: Text(s.huishaCard)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: card,
            decoration: InputDecoration(
              labelText: s.lostCardNumber,
              prefixIcon: const Icon(Icons.credit_card_off),
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
              onPressed: verify,
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
