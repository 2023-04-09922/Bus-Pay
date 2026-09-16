import 'package:flutter/material.dart';

import '../auth/login_id.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'change_password_screen.dart';
import 'change_pin_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);
    final isAgent = app.currentRole == UserRole.agent;

    return Scaffold(
      appBar: AppBar(title: Text(s.security)),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(isAgent ? Icons.lock_outline : Icons.pin_outlined),
            title: Text(isAgent ? s.changePassword : s.changePin),
            subtitle: Text(
              isAgent ? s.changePasswordHint : s.changePinHint,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => isAgent
                      ? const ChangePasswordScreen()
                      : const ChangePinScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
