import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/nida_id.dart';
import '../auth/password_rule.dart';
import '../auth/tz_phone.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../widgets/pin_boxes.dart';

class ConductorForgotPinScreen extends StatefulWidget {
  const ConductorForgotPinScreen({super.key});

  @override
  State<ConductorForgotPinScreen> createState() =>
      _ConductorForgotPinScreenState();
}

class _ConductorForgotPinScreenState extends State<ConductorForgotPinScreen> {
  final phone = TextEditingController();
  final nida = TextEditingController();
  final code = TextEditingController();
  String pin = '';
  String confirmPin = '';
  bool busy = false;
  int step = 0;
  String? sentHint;

  @override
  void initState() {
    super.initState();
    phone.text = TzPhone.format('');
  }

  @override
  void dispose() {
    phone.dispose();
    nida.dispose();
    code.dispose();
    super.dispose();
  }

  Future<void> sendCode() async {
    final s = S(AppScope.of(context).language);
    final number = TzPhone.toApi(phone.text);
    final id = NidaId.toApi(nida.text);
    if (!TzPhone.isValid(phone.text) || !NidaId.isValid(nida.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !TzPhone.isValid(phone.text) ? s.badPhoneFormat : s.badNidaFormat,
          ),
        ),
      );
      return;
    }

    setState(() => busy = true);
    try {
      final data = await ApiService.forgotPin(phone: number, nida: id);
      if (!mounted) return;
      setState(() {
        step = 1;
        sentHint = data['code']?.toString();
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

  Future<void> resetPin() async {
    final s = S(AppScope.of(context).language);
    if (code.text.length != 6 ||
        !PasswordRule.isValid(pin) ||
        !PasswordRule.isValid(confirmPin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }
    if (pin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.pinMismatch)),
      );
      return;
    }

    setState(() => busy = true);
    try {
      final data = await ApiService.resetPin(
        phone: TzPhone.toApi(phone.text),
        nida: NidaId.toApi(nida.text),
        code: code.text.trim(),
        pin: pin,
        confirmPin: confirmPin,
      );
      if (!mounted) return;
      final username = data['username']?.toString() ?? '';
      if (username.isNotEmpty) {
        await AppScope.of(context).rememberAccount(username);
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(s.confirm),
          content: Text(s.pinResetOk),
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
      appBar: AppBar(title: Text(s.forgotPin)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            step == 0 ? s.forgotPinHint : s.enterPinResetCode,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: phone,
            enabled: step == 0,
            keyboardType: TextInputType.phone,
            inputFormatters: const [TzPhoneFormatter()],
            decoration: InputDecoration(
              labelText: s.phone,
              prefixIcon: const Icon(Icons.phone_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: nida,
            enabled: step == 0,
            keyboardType: TextInputType.number,
            inputFormatters: const [NidaFormatter()],
            decoration: InputDecoration(
              labelText: s.nida,
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
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
                labelText: s.verificationCode,
                counterText: '',
                prefixIcon: const Icon(Icons.pin_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            PinBoxes(
              value: pin,
              label: s.newPin,
              onChanged: (value) => setState(() => pin = value),
            ),
            const SizedBox(height: 16),
            PinBoxes(
              value: confirmPin,
              label: s.hakikiPin,
              onChanged: (value) => setState(() => confirmPin = value),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: busy ? null : (step == 0 ? sendCode : resetPin),
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      step == 0 ? s.sendVerificationCode : s.resetPin,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
