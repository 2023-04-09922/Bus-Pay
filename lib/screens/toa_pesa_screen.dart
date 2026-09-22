import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../auth/money_amount.dart';
import '../l10n/strings.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';

class ToaPesaScreen extends StatefulWidget {
  const ToaPesaScreen({super.key});

  @override
  State<ToaPesaScreen> createState() => _ToaPesaScreenState();
}

class _ToaPesaScreenState extends State<ToaPesaScreen> {
  final tillController = TextEditingController();
  final amountController = TextEditingController();

  /// 0 = enter TILL, 1 = enter amount + confirm
  int step = 0;
  bool busy = false;
  String? tillNormalized;
  String agentName = '';
  String amountError = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).refreshLedger();
    });
  }

  @override
  void dispose() {
    tillController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _lookupTill() async {
    final s = S(AppScope.of(context).language);
    final till = tillController.text.trim();
    if (till.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.fillAll)),
      );
      return;
    }

    final token = AppScope.of(context).authToken ?? '';
    setState(() => busy = true);
    try {
      final data = await ApiService.lookupWakalaTill(
        token: token,
        tillNumber: till,
      );
      if (!mounted) return;
      final agent = data['agent'] as Map<String, dynamic>? ?? {};
      setState(() {
        tillNormalized = (data['tillNumber'] ?? till).toString();
        agentName = (agent['name'] ?? '').toString().trim();
        step = 1;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _withdraw() async {
    final app = AppScope.of(context);
    final s = S(app.language);
    final amount = MoneyAmount.parse(amountController.text);
    setState(() {
      amountError = amount <= 0
          ? s.amountRequired
          : (amount > app.walletBalance ? s.lowBalance : '');
    });
    if (amountError.isNotEmpty || tillNormalized == null) return;

    final token = app.authToken ?? '';
    setState(() => busy = true);
    try {
      final result = await ApiService.withdrawToWakala(
        token: token,
        tillNumber: tillNormalized!,
        amount: amount,
      );
      if (!mounted) return;

      await app.refreshLedger();
      if (!mounted) return;

      final reference = (result['reference'] ?? '').toString();
      final agent = result['agent'] as Map<String, dynamic>? ?? {};
      final name =
          (agent['name'] ?? agentName).toString().trim();
      final available = (result['available'] as num?)?.toInt() ??
          AppScope.of(context).walletBalance;

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(s.withdrawOk),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.isEmpty ? (tillNormalized ?? '') : name),
              Text('${s.wakalaTill}: ${tillNormalized ?? ''}'),
              const SizedBox(height: 8),
              Text('${s.amount}: ${s.tzs(amount)}'),
              if (reference.isNotEmpty) Text('${s.reference}: $reference'),
              Text(
                '${s.newBalance}: ${s.tzs(available)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.done),
            ),
          ],
        ),
      );
      if (!mounted) return;
      tillController.clear();
      amountController.clear();
      setState(() {
        step = 0;
        tillNormalized = null;
        agentName = '';
      });
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
    final app = AppScope.of(context);
    final s = S(app.language);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: ListView(
        key: ValueKey(step),
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: Text(s.wallet),
              trailing: Text(
                s.tzs(app.walletBalance),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (step == 0) ..._tillStep(s) else ..._amountStep(s, app),
        ],
      ),
    );
  }

  List<Widget> _tillStep(S s) {
    return [
      Text(
        s.toaPesaHint,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text(
        s.toaPesaTillHint,
        style: TextStyle(color: Colors.grey.shade700),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: tillController,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d-]'))],
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => busy ? null : _lookupTill(),
        decoration: InputDecoration(
          labelText: '${s.wakalaTill} *',
          prefixIcon: const Icon(Icons.storefront_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      const SizedBox(height: 24),
      SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: busy ? null : _lookupTill,
          child: busy
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  s.continueBtn,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    ];
  }

  List<Widget> _amountStep(S s, AppState app) {
    return [
      Text(
        s.enterWithdrawAmount,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              agentName.isEmpty ? (tillNormalized ?? '') : agentName,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '${s.wakalaTill}: ${tillNormalized ?? ''}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: amountController,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: const [MoneyFormatter()],
        onChanged: (_) {
          if (amountError.isNotEmpty) setState(() => amountError = '');
        },
        decoration: InputDecoration(
          labelText: '${s.amount} *',
          prefixIcon: const Icon(Icons.payments_outlined),
          errorText: amountError.isEmpty ? null : amountError,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      const SizedBox(height: 24),
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: busy
                  ? null
                  : () => setState(() {
                        step = 0;
                        amountController.clear();
                        amountError = '';
                      }),
              child: Text(s.back),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: busy ? null : _withdraw,
                child: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        s.withdraw,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}
