import 'package:flutter/material.dart';

import '../auth/agent_password_rule.dart';
import '../auth/nida_id.dart';
import '../auth/tz_phone.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'login_screen.dart';

class CreateWakalaScreen extends StatefulWidget {
  const CreateWakalaScreen({super.key});

  @override
  State<CreateWakalaScreen> createState() => _CreateWakalaScreenState();
}

class _CreateWakalaScreenState extends State<CreateWakalaScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final nida = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    phone.text = TzPhone.format('');
  }

  @override
  void dispose() {
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    phone.dispose();
    nida.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final s = S(AppScope.of(context).language);
    if (firstName.text.trim().isEmpty ||
        lastName.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        !TzPhone.isValid(phone.text) ||
        !NidaId.isValid(nida.text) ||
        !AgentPasswordRule.isValid(password.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }
    final token = AppScope.of(context).authToken ?? '';
    setState(() => busy = true);
    try {
      final result = await ApiService.createWakala(
        token: token,
        firstName: firstName.text,
        lastName: lastName.text,
        email: email.text,
        phone: TzPhone.toApi(phone.text),
        nida: NidaId.toApi(nida.text),
        password: password.text,
      );
      if (!mounted) return;
      final username = (result['username'] ?? '').toString();
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.wakalaCreated),
          content: Text(
            '${firstName.text.trim()} ${lastName.text.trim()}\n'
            '${email.text.trim()}\n'
            '${s.giveWakalaPassword}'
            '${username.isEmpty ? '' : '\n$username'}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.done),
            ),
          ],
        ),
      );
      firstName.clear();
      lastName.clear();
      email.clear();
      phone.text = TzPhone.format('');
      nida.clear();
      password.clear();
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
    final app = AppScope.of(context);
    final s = S(app.language);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.createWakala),
        actions: [
          IconButton(
            tooltip: s.logout,
            onPressed: () {
              app.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(s.createWakalaHint, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 18),
          TextField(
            controller: firstName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: s.firstName,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: lastName,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: s.lastName,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: s.email,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: phone,
            keyboardType: TextInputType.phone,
            inputFormatters: const [TzPhoneFormatter()],
            decoration: InputDecoration(
              labelText: s.phone,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: nida,
            keyboardType: TextInputType.number,
            inputFormatters: const [NidaFormatter()],
            decoration: InputDecoration(
              labelText: s.nida,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: s.agentPassword,
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscure = !obscure),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 8),
          Text(s.strongPasswordHint, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 22),
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
                      s.createWakala,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
