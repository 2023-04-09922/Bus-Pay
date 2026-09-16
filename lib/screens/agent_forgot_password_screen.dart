import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/agent_email.dart';
import '../auth/agent_password_rule.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';

class AgentForgotPasswordScreen extends StatefulWidget {
  const AgentForgotPasswordScreen({super.key, this.email = ''});

  final String email;

  @override
  State<AgentForgotPasswordScreen> createState() =>
      _AgentForgotPasswordScreenState();
}

class _AgentForgotPasswordScreenState extends State<AgentForgotPasswordScreen> {
  late final TextEditingController email;
  final code = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  bool obscure = true;
  bool obscureConfirm = true;
  bool busy = false;
  int step = 0;
  String? sentHint;

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: AgentEmail.normalize(widget.email));
  }

  @override
  void dispose() {
    email.dispose();
    code.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> sendCode() async {
    final s = S(AppScope.of(context).language);
    final address = AgentEmail.normalize(email.text);
    if (!AgentEmail.isValid(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.invalidEmail)),
      );
      return;
    }

    setState(() => busy = true);
    try {
      final data = await ApiService.forgotAgentPassword(email: address);
      if (!mounted) return;
      final sentCode = data['code']?.toString();
      setState(() {
        step = 1;
        sentHint = sentCode;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.resetCodeSent)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> resetPassword() async {
    final s = S(AppScope.of(context).language);
    final address = AgentEmail.normalize(email.text);
    if (code.text.length != 6 ||
        password.text.isEmpty ||
        confirm.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }
    if (!AgentPasswordRule.isValid(password.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.strongPasswordHint)),
      );
      return;
    }
    if (password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.passwordMismatch)),
      );
      return;
    }

    setState(() => busy = true);
    try {
      await ApiService.resetAgentPassword(
        email: address,
        code: code.text.trim(),
        password: password.text,
        confirmPassword: confirm.text,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(s.confirm),
          content: Text(s.passwordResetOk),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.confirm),
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
      appBar: AppBar(title: Text(s.forgotPassword)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            step == 0 ? s.forgotPasswordHint : s.enterResetCode,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: email,
            enabled: step == 0,
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
          if (step == 1) ...[
            const SizedBox(height: 14),
            if (sentHint != null && sentHint!.isNotEmpty)
              Text(
                '${s.devResetCode}: $sentHint',
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: code,
              keyboardType: TextInputType.number,
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: s.resetCode,
                counterText: '',
                prefixIcon: const Icon(Icons.pin_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: password,
              obscureText: obscure,
              decoration: InputDecoration(
                labelText: s.newPassword,
                helperText: s.strongPasswordHint,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: busy ? null : (step == 0 ? sendCode : resetPassword),
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      step == 0 ? s.sendCode : s.resetPassword,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
