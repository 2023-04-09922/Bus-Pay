import 'package:flutter/material.dart';

import '../auth/login_id.dart';
import '../core/constants/app_config.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'create_wakala_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    email.text = AppConfig.adminDemoEmail;
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final s = S(AppScope.of(context).language);
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }
    setState(() => busy = true);
    try {
      final data = await ApiService.adminLogin(
        email: email.text.trim(),
        password: password.text,
      );
      if (!mounted) return;
      final app = AppScope.of(context);
      app.applyRemoteLogin(data);
      if (app.currentRole != UserRole.admin) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.incorrectCredentials)),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CreateWakalaScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      final raw = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            raw.contains('did not respond') ? s.connectionTimeout : raw,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(title: Text(s.adminLogin)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(s.adminLoginHint, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          TextField(
            controller: email,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: s.email,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: password,
            obscureText: obscure,
            decoration: InputDecoration(
              labelText: s.agentPassword,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscure = !obscure),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: busy ? null : login,
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      s.adminLogin,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
