import 'package:flutter/material.dart';

import 'l10n/strings.dart';
import 'screens/malipo_screen.dart';
import 'screens/miamala_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/toa_pesa_screen.dart';
import 'screens/tuma_pesa_screen.dart';
import 'state/app_state.dart';
import 'widgets/app_drawer.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);
    final titles = [
      s.malipo,
      s.miamala,
      s.toaPesa,
      s.tumaPesa,
      s.settings,
      s.profile,
    ];

    final pages = const [
      MalipoScreen(),
      MiamalaScreen(),
      ToaPesaScreen(),
      TumaPesaScreen(),
      SettingsScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[index],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      drawer: AppDrawer(
        selected: index,
        onSelect: (value) => setState(() => index = value),
      ),
      body: IndexedStack(
        index: index,
        children: pages,
      ),
    );
  }
}
