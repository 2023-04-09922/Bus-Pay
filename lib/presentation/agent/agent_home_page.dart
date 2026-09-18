import 'package:flutter/material.dart';

import '../../../l10n/strings.dart';
import '../../../screens/login_screen.dart';
import '../../../screens/msaada_screen.dart';
import '../../../screens/profile_screen.dart';
import '../../../screens/sajili_card_screen.dart';
import '../../../state/app_state.dart';
import 'renew_card_page.dart';
import 'top_up_card_page.dart';
import 'widgets/floating_action_card.dart';

class AgentHomePage extends StatelessWidget {
  const AgentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF3F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primary, primary.withValues(alpha: 0.72)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.displayName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  app.agentTill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.wakalaDesk,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            s.cardServices,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.02,
            children: [
              FloatingActionCard(
                icon: Icons.add_card_outlined,
                label: s.sajiliCard,
                subtitle: s.sajiliCardHint,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SajiliCardScreen()),
                ),
              ),
              FloatingActionCard(
                icon: Icons.autorenew,
                label: s.renewCard,
                subtitle: s.renewCardHint,
                accent: const Color(0xFF2E7D32),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RenewCardPage()),
                ),
              ),
              FloatingActionCard(
                icon: Icons.account_balance_wallet_outlined,
                label: s.topUpCard,
                subtitle: s.topUpCardHint,
                accent: const Color(0xFFEF6C00),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TopUpCardPage()),
                ),
              ),
              FloatingActionCard(
                icon: Icons.person_outline,
                label: s.profile,
                subtitle: s.agent,
                accent: const Color(0xFF5E35B1),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: Text(s.profile)),
                      body: const ProfileScreen(),
                    ),
                  ),
                ),
              ),
              FloatingActionCard(
                icon: Icons.help_outline,
                label: s.msaada,
                subtitle: s.howToRegister,
                accent: const Color(0xFF00838F),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MsaadaScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
