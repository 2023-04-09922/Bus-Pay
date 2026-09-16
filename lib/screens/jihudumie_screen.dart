import 'package:flutter/material.dart';

import '../auth/agent_password_rule.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';

class JihudumieScreen extends StatefulWidget {
  const JihudumieScreen({super.key});

  @override
  State<JihudumieScreen> createState() => _JihudumieScreenState();
}

class _JihudumieScreenState extends State<JihudumieScreen> {
  final next = TextEditingController();
  final confirm = TextEditingController();
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  void save() {
    final app = AppScope.of(context);
    final s = S(app.language);
    if (!AgentPasswordRule.isValid(next.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.strongPasswordHint)),
      );
      return;
    }
    if (next.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.passwordMismatch)),
      );
      return;
    }
    final result = app.changePassword(
      newPassword: next.text,
      confirmPassword: confirm.text,
    );
    final message = switch (result) {
      'mismatch' => s.passwordMismatch,
      'ok' => s.success,
      _ => s.failed,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    if (result == 'ok') Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(title: Text(s.jihudumie)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            s.changePassword,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(s.strongPasswordHint, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          TextField(
            controller: next,
            obscureText: obscureNew,
            decoration: InputDecoration(
              labelText: s.newPassword,
              helperText: s.strongPasswordHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscureNew ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscureNew = !obscureNew),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: confirm,
            obscureText: obscureConfirm,
            decoration: InputDecoration(
              labelText: s.confirmPassword,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() => obscureConfirm = !obscureConfirm);
                },
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: save,
              child: Text(
                s.save,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
