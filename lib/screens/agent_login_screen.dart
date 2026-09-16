import 'package:flutter/material.dart';

import '../auth/agent_email.dart';
import '../auth/login_id.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'agent_forgot_password_screen.dart';
import 'agent_home_screen.dart';

class AgentLoginScreen extends StatefulWidget {
  const AgentLoginScreen({super.key});

  @override
  State<AgentLoginScreen> createState() => _AgentLoginScreenState();
}

class _AgentLoginScreenState extends State<AgentLoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final s = S(AppScope.of(context).language);
    final address = AgentEmail.normalize(email.text);
    if (address.isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }
    if (!AgentEmail.isValid(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.invalidEmail)),
      );
      return;
    }

    setState(() => busy = true);
    try {
      final data = await ApiService.agentLogin(
        email: AgentEmail.normalize(email.text),
        password: password.text,
      );
      if (!mounted) return;
      final app = AppScope.of(context);
      app.applyRemoteLogin(data);
      if (app.currentRole != UserRole.agent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.incorrectCredentials)),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AgentHomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      final status = e is ApiException ? e.statusCode : null;
      final raw = e.toString().replaceFirst('Exception: ', '');
      final message = status == 401
          ? s.incorrectCredentials
          : (status == 429
              ? s.tooManyRequests
              : (raw.contains('did not respond') ||
                      raw.contains('TimeoutException')
                  ? s.connectionTimeout
                  : raw));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(title: Text(s.agentLoginTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            s.agentLoginHint,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: email,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: s.email,
              hintText: 'name@gmail.com',
              helperText: s.emailFormatHint,
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
              helperText: s.strongPasswordHint,
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => obscure = !obscure),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: busy
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AgentForgotPasswordScreen(
                            email: email.text,
                          ),
                        ),
                      );
                    },
              child: Text(
                s.forgotPassword,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
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
                      s.loginAsAgent,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
