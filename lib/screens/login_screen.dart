import 'package:flutter/material.dart';

import '../auth/password_rule.dart';
import '../core/navigation/app_page_route.dart';
import '../home_shell.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/pin_boxes.dart';
import '../widgets/pin_error_shake.dart';
import 'agent_login_screen.dart';
import 'conductor_forgot_pin_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String pin = '';
  bool busy = false;
  bool wrongPin = false;
  bool pinOk = false;
  int wrongPulse = 0;

  Future<void> login() async {
    final s = S(AppScope.of(context).language);
    if (!PasswordRule.isValid(pin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.badPinFormat)),
      );
      return;
    }

    final app = AppScope.of(context);
    final username = app.hiddenUsername?.trim() ?? '';
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.noAccount)),
      );
      return;
    }

    setState(() {
      busy = true;
      pinOk = false;
      wrongPin = false;
    });
    // Clear any leftover snackbars from earlier attempts.
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      final response = await ApiService.login(
        username: username,
        pin: pin,
      );
      if (!mounted) return;
      app.applyRemoteLogin(response);
      if (!mounted) return;
      // Navigate immediately — no success flash / error flicker on this screen.
      await Navigator.pushReplacement(
        context,
        AppPageRoute(builder: (_) => const HomeShell()),
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
        return;
      }
      if (status == 401) {
        setState(() {
          pin = '';
          pinOk = false;
          wrongPin = true;
          wrongPulse++;
        });
        return;
      }
      final message = status == 404
          ? s.noAccount
          : status == 429
              ? (raw.toLowerCase().contains('pin')
                  ? s.pinLocked
                  : s.tooManyRequests)
              : (raw.contains('did not respond') ||
                      raw.contains('TimeoutException') ||
                      raw.contains('Could not reach')
                  ? s.connectionTimeout
                  : raw);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      // Only reset busy if we are still on this screen (login failed).
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const AppLogo(size: 96),
                const SizedBox(height: 20),
                Text(
                  s.appName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Mfumo wa Malipo ya Usafiri',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 36),
                PinBoxes(
                  key: ValueKey('login-pin-$wrongPulse'),
                  value: pin,
                  label: s.enterPin,
                  autofocus: true,
                  success: pinOk,
                  onChanged: (value) {
                    setState(() {
                      pin = value;
                      pinOk = false;
                      if (wrongPin) wrongPin = false;
                    });
                  },
                ),
                const SizedBox(height: 10),
                PinErrorShake(
                  visible: wrongPin,
                  pulse: wrongPulse,
                  message: s.pinIncorrect,
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (_) =>
                                  const ConductorForgotPinScreen(),
                            ),
                          );
                        },
                  child: Text(
                    s.forgotPin,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: busy || pin.length != 4 ? null : login,
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
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                  child: Text(s.signUp),
                ),
                TextButton(
                  onPressed: busy
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            AppPageRoute(
                              builder: (_) => const AgentLoginScreen(),
                            ),
                          );
                        },
                  child: Text(
                    s.loginAsAgent,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
