import 'package:flutter/material.dart';

import '../auth/password_rule.dart';
import '../core/navigation/app_page_route.dart';
import '../core/navigation/auth_reveal.dart';
import '../home_shell.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import '../widgets/app_logo.dart';
import '../widgets/pin_boxes.dart';
import '../widgets/pin_error_shake.dart';
import 'agent_login_screen.dart';
import 'conductor_account_login_screen.dart';
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
  int wrongPulse = 0;
  bool lockInset = false;
  final _captureKey = GlobalKey();

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
      wrongPin = false;
    });
    ScaffoldMessenger.of(context).clearSnackBars();

    try {
      final response = await ApiService.login(
        username: username,
        pin: pin,
      );
      if (!mounted) return;

      // Freeze layout, drop keyboard, snapshot the PIN face (GPU bitmap).
      setState(() => lockInset = true);
      await dismissKeyboardAndWait(context);
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;

      final image = await captureBoundary(
        _captureKey,
        pixelRatio: MediaQuery.devicePixelRatioOf(context),
      );

      // Apply session WITHOUT rebuilding the tree mid-transition.
      app.applyRemoteLogin(response, notify: false, scheduleLedger: false);
      if (!mounted) return;

      await playAuthReveal(
        context: context,
        outgoing: _face(interactive: false),
        outgoingImage: image,
        incoming: const HomeShell(),
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
    final muted = Colors.grey.shade600;

    return Scaffold(
      resizeToAvoidBottomInset: interactive && !lockInset,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 16, 28, 12),
                  child: Column(
                    children: [
                      const AppLogo(size: 88),
                      const SizedBox(height: 16),
                      Text(
                        s.appName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Mfumo wa Malipo ya Usafiri',
                        style: TextStyle(fontSize: 15, color: muted),
                      ),
                      const SizedBox(height: 28),
                      PinBoxes(
                        key: ValueKey('login-pin-$wrongPulse-$interactive'),
                        value: pin,
                        label: s.wekaPin,
                        autofocus: interactive && !busy,
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
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: interactive && !busy && pin.length == 4
                              ? login
                              : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
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
                      const SizedBox(height: 18),
                      if (interactive) ...[
                        TextButton(
                          onPressed: busy
                              ? null
                              : () => pushSmooth(
                                    context,
                                    const ConductorAccountLoginScreen(),
                                  ),
                          child: Text(
                            s.haveAccount,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: busy
                              ? null
                              : () =>
                                  pushSmooth(context, const SignupScreen()),
                          child: Text(
                            s.noAccountSignUp,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          s.haveAccount,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.noAccountSignUp,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Column(
                children: [
                  if (interactive)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () =>
                              pushSmooth(context, const AgentLoginScreen()),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: muted,
                      ),
                      child: Text(
                        s.loginAsAgent,
                        style: const TextStyle(fontSize: 12),
                      ),
                    )
                  else
                    Text(
                      s.loginAsAgent,
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  if (interactive)
                    TextButton(
                      onPressed: busy
                          ? null
                          : () => pushSmooth(
                                context,
                                const ConductorForgotPinScreen(),
                              ),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: muted,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      child: Text(
                        s.forgotPin,
                        style: const TextStyle(fontSize: 11),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        s.forgotPin,
                        style: TextStyle(fontSize: 11, color: muted),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _captureKey,
      child: _face(interactive: true),
    );
  }
}
