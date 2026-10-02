import 'package:flutter/material.dart';

import '../auth/password_rule.dart';
import '../auth/tz_phone.dart';
import '../core/navigation/auth_reveal.dart';
import '../home_shell.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../widgets/pin_boxes.dart';
import '../widgets/pin_error_shake.dart';

/// Phone + PIN login for conductors who already have an account (new device).
class ConductorAccountLoginScreen extends StatefulWidget {
  const ConductorAccountLoginScreen({super.key});

  @override
  State<ConductorAccountLoginScreen> createState() =>
      _ConductorAccountLoginScreenState();
}

class _ConductorAccountLoginScreenState
    extends State<ConductorAccountLoginScreen> {
  final phone = TextEditingController();
  String pin = '';
  bool busy = false;
  bool wrongPin = false;
  int wrongPulse = 0;
  bool lockInset = false;

  @override
  void initState() {
    super.initState();
    phone.text = TzPhone.format('');
  }

  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final s = S(AppScope.of(context).language);
    if (!TzPhone.isValid(phone.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.badPhoneFormat)),
      );
      return;
    }
    if (!PasswordRule.isValid(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.badPinFormat)),
      );
      return;
    }

    setState(() {
      busy = true;
      wrongPin = false;
    });
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      final response = await ApiService.login(
        phone: TzPhone.toApi(phone.text),
        pin: pin,
      );
      if (!mounted) return;
      final app = AppScope.of(context);
      setState(() => lockInset = true);
      await dismissKeyboardAndWait(context);
      if (!mounted) return;
      app.applyRemoteLogin(response, notify: false, scheduleLedger: false);
      if (!mounted) return;
      await playAuthReveal(
        context: context,
        outgoing: _face(interactive: false),
        incoming: const HomeShell(),
        clearStack: true,
        onSettled: app.finishLoginReveal,
      );
    } catch (e) {
      if (!mounted) return;
      final status = e is ApiException ? e.statusCode : null;
      final raw = e.toString().replaceFirst('Exception: ', '');
      final lower = raw.toLowerCase();
      if (status == 404 || lower.contains('account not found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.noAccount)),
        );
      } else if (status == 401) {
        setState(() {
          pin = '';
          wrongPin = true;
          wrongPulse++;
        });
      } else {
        final message = status == 429
            ? (lower.contains('pin') ? s.pinLocked : s.tooManyRequests)
            : (raw.contains('did not respond') ||
                    raw.contains('TimeoutException') ||
                    raw.contains('Could not reach')
                ? s.connectionTimeout
                : raw);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _face({required bool interactive}) {
    final s = S(AppScope.of(context).language);
    final muted = Theme.of(context).hintColor;

    return Scaffold(
      resizeToAvoidBottomInset: interactive && !lockInset,
      appBar: AppBar(title: Text(s.accountLoginTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        children: [
          Text(
            s.accountLoginHint,
            style: TextStyle(color: muted, height: 1.4),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: phone,
            autofocus: interactive && !busy,
            enabled: interactive,
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
          const SizedBox(height: 22),
          PinBoxes(
            key: ValueKey('account-pin-$wrongPulse-$interactive'),
            value: pin,
            label: s.wekaPin,
            autofocus: false,
            onChanged: interactive
                ? (value) {
                    setState(() {
                      pin = value;
                      if (wrongPin) wrongPin = false;
                    });
                  }
                : (_) {},
          ),
          const SizedBox(height: 6),
          PinErrorShake(
            visible: wrongPin,
            pulse: wrongPulse,
            message: s.pinIncorrect,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: interactive && !busy && pin.length == 4 ? login : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'INGIA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _face(interactive: true);
}
