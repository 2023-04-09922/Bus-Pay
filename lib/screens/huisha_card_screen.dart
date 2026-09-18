import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';

class HuishaCardScreen extends StatefulWidget {
  const HuishaCardScreen({super.key});

  @override
  State<HuishaCardScreen> createState() => _HuishaCardScreenState();
}

class _HuishaCardScreenState extends State<HuishaCardScreen> {
  final card = TextEditingController();
  bool busy = false;

  @override
  void dispose() {
    card.dispose();
    super.dispose();
  }

  Future<void> verify() async {
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
      await ApiService.freezeCard(
        token: token,
        serialNumber: card.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.cardDeactivated)),
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
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: busy ? null : verify,
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      s.continueBtn,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
