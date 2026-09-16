import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class MsaadaScreen extends StatelessWidget {
  const MsaadaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    final steps = s.isSw
        ? const [
            'Fungua Sajili card mpya.',
            'Weka namba ya card.',
            'Weka jina la kwanza la mteja.',
            'Weka jina la mwisho la mteja.',
            'Weka namba ya simu.',
            'Weka namba ya NIDA (namba 20).',
            'Bonyeza Endelea.',
            'Sogeza vidole vinne mbele ya kamera kuthibitisha.',
            'Subiri ujumbe Card imesajiliwa.',
          ]
        : const [
            'Open Register new card.',
            'Enter the card number.',
            'Enter the customer first name.',
            'Enter the customer last name.',
            'Enter the phone number.',
            'Enter the 20-digit NIDA number.',
            'Tap Continue.',
            'Hold four fingers in front of the camera to verify.',
            'Wait for Card registered.',
          ];

    return Scaffold(
      appBar: AppBar(title: Text(s.msaada)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            s.howToRegister,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...List.generate(steps.length, (i) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                radius: 16,
                child: Text('${i + 1}'),
              ),
              title: Text(steps[i]),
            );
          }),
          const SizedBox(height: 20),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: const Icon(Icons.emergency, color: Colors.red, size: 32),
              title: Text(s.emergency),
              subtitle: Text(
                s.emergencyNumber,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(const ClipboardData(text: '0800750750'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(s.success)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
