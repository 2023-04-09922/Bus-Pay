import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../screens/login_screen.dart';
import '../state/app_state.dart';
import 'huisha_card_screen.dart';
import 'jihudumie_screen.dart';
import 'msaada_screen.dart';
import 'profile_screen.dart';
import 'sajili_card_screen.dart';
import 'security_screen.dart';

class AgentHomeScreen extends StatelessWidget {
  const AgentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);
    final tiles = [
      _Tile(Icons.person_outline, s.profile, () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: Text(s.profile)),
              body: const ProfileScreen(),
            ),
          ),
        );
      }),
      _Tile(Icons.credit_card, s.sajiliCard, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SajiliCardScreen()),
        );
      }),
      _Tile(Icons.credit_card_off, s.huishaCard, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HuishaCardScreen()),
        );
      }),
      _Tile(Icons.security_outlined, s.security, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SecurityScreen()),
        );
      }),
      _Tile(Icons.help_outline, s.msaada, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MsaadaScreen()),
        );
      }),
      _Tile(Icons.support_agent, s.jihudumie, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const JihudumieScreen()),
        );
      }),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Text(s.appName),
        actions: [
          IconButton(
            tooltip: s.logout,
            onPressed: () {
              app.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.displayName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  app.agentTill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
            children: tiles.map((tile) {
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 1,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: tile.onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          tile.icon,
                          size: 32,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const Spacer(),
                        Text(
                          tile.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Tile {
  const _Tile(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
