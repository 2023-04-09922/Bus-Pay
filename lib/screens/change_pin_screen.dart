import 'package:flutter/material.dart';

import '../auth/password_rule.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../widgets/pin_boxes.dart';
import '../widgets/pin_error_shake.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  String currentPin = '';
  String newPin = '';
  String confirmPin = '';
  bool busy = false;
  bool wrongPin = false;
  int wrongPulse = 0;

  Future<void> submit() async {
    final s = S(AppScope.of(context).language);
    if (!PasswordRule.isValid(currentPin) ||
        !PasswordRule.isValid(newPin) ||
        !PasswordRule.isValid(confirmPin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.badPinFormat)),
      );
      return;
    }
    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.pinMismatch)),
      );
      return;
    }

    final token = AppScope.of(context).authToken ?? '';
    setState(() => busy = true);
    try {
      await ApiService.changePin(
        token: token,
        currentPin: currentPin,
        newPin: newPin,
        confirmPin: confirmPin,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.pinChanged)),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final status = e is ApiException ? e.statusCode : null;
      final raw = e.toString().replaceFirst('Exception: ', '');
      if (status == 401) {
        setState(() {
          currentPin = '';
          wrongPin = true;
          wrongPulse++;
        });
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(raw)),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    return Scaffold(
      appBar: AppBar(title: Text(s.changePin)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(s.changePinHint, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          PinBoxes(
            value: currentPin,
            label: s.currentPin,
            autofocus: true,
            onChanged: (value) => setState(() {
              currentPin = value;
              if (wrongPin) wrongPin = false;
            }),
          ),
          const SizedBox(height: 10),
          PinErrorShake(
            visible: wrongPin,
            pulse: wrongPulse,
            message: s.pinIncorrect,
          ),
          const SizedBox(height: 20),
          PinBoxes(
            value: newPin,
            label: s.newPin,
            onChanged: (value) => setState(() => newPin = value),
          ),
          const SizedBox(height: 20),
          PinBoxes(
            value: confirmPin,
            label: s.confirmNewPin,
            onChanged: (value) => setState(() => confirmPin = value),
          ),
          const SizedBox(height: 28),
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
                      s.changePin,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
