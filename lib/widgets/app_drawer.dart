import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../screens/login_screen.dart';
import '../screens/security_screen.dart';
import '../state/app_state.dart';
import 'app_logo.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);
    final profileName = app.displayName;
    final profileId = app.displayId;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              color: Theme.of(context).colorScheme.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(size: 64, radius: 16),
                  const SizedBox(height: 12),
                  Text(
                    profileName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    profileId,
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _item(context, 0, Icons.payments_outlined, s.malipo),
                  _item(context, 1, Icons.receipt_long_outlined, s.miamala),
                  _item(context, 2, Icons.storefront_outlined, s.toaPesa),
                  _item(context, 3, Icons.send_outlined, s.tumaPesa),
                  _item(context, 4, Icons.settings_outlined, s.settings),
                  _item(context, 5, Icons.person_outline, s.profile),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: Text(s.security),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SecurityScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(s.logout),
              onTap: () {
                Navigator.pop(context);
                app.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(
    BuildContext context,
    int index,
    IconData icon,
    String label,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected == index,
      onTap: () {
        Navigator.pop(context);
        onSelect(index);
      },
    );
  }
}
