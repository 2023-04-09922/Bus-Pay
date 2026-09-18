import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../l10n/strings.dart';
import '../nfc/nfc_uid.dart';
import '../services/api_service.dart';
import '../state/app_state.dart';
import 'payment_success_screen.dart';

class NfcScannerScreen extends StatefulWidget {
  const NfcScannerScreen({super.key, required this.amount});

  final int amount;

  @override
  State<NfcScannerScreen> createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool found = false;
  bool resolving = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _listen());
  }

  @override
  void dispose() {
    stopNfc();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _listen() async {
    if (!await nfcEnabled() || !mounted) return;
    await NfcManagerSession.start((uid) {
      if (!mounted || found || resolving) return;
      _pay(nfcUid: uid);
    });
  }

  Future<void> _simulate() async {
    final s = S(AppScope.of(context).language);
    final serial = TextEditingController();
    final entered = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.enterCardToPay),
        content: TextField(
          controller: serial,
          autofocus: true,
          decoration: InputDecoration(labelText: s.cardNumber),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, serial.text.trim()),
            child: Text(s.continueBtn),
          ),
        ],
      ),
    );
    serial.dispose();
    if (entered == null || entered.isEmpty || !mounted) return;
    await _pay(serialNumber: entered);
  }

  Future<void> _pay({String? serialNumber, String? nfcUid}) async {
    if (resolving) return;
    resolving = true;
    setState(() => found = true);
    final app = AppScope.of(context);
    final token = app.authToken ?? '';
    var name = '';
    try {
      final looked = await ApiService.lookupCard(
        token: token,
        serialNumber: serialNumber,
        nfcUid: nfcUid,
      );
      final customer = looked['customer'] as Map<String, dynamic>? ?? {};
      final card = looked['card'] as Map<String, dynamic>? ?? {};
      name =
          '${customer['firstName'] ?? ''} ${customer['lastName'] ?? ''}'.trim();
      final result = await ApiService.tapPay(
        token: token,
        amount: widget.amount,
        serialNumber: serialNumber ?? card['serialNumber']?.toString(),
        nfcUid: nfcUid ?? card['nfcUid']?.toString(),
      );
      if (name.isEmpty) {
        name = (result['passenger'] ?? '').toString();
      }
      await app.refreshLedger();
      if (!mounted) return;
      await stopNfc();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: widget.amount,
            passengerName: name.isEmpty ? 'Passenger' : name,
            reference: (result['reference'] ?? '').toString(),
            success: true,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      await stopNfc();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amount: widget.amount,
            passengerName: name.isEmpty
                ? e.toString().replaceFirst('Exception: ', '')
                : name,
            success: false,
            onRetry: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => NfcScannerScreen(amount: widget.amount),
                ),
              );
            },
          ),
        ),
      );
    } finally {
      resolving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);

    return Scaffold(
      appBar: AppBar(title: Text(s.lipia)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: AnimatedBuilder(
                  animation: _pulse,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _PulsePainter(
                        progress: _pulse.value,
                        color: found
                            ? Colors.green
                            : Theme.of(context).colorScheme.primary,
                      ),
                      child: child,
                    );
                  },
                  child: Icon(
                    found ? Icons.check_circle : Icons.contactless,
                    size: 84,
                    color: found
                        ? Colors.green
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                found ? s.cardFound : s.bringCard,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                found ? s.scanning : s.nfcHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 28),
              Text(
                s.tzs(widget.amount),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              if (!found)
                TextButton(
                  onPressed: _simulate,
                  child: Text(s.enterCardToPay),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NfcManagerSession {
  static Future<void> start(void Function(String uid) onUid) async {
    await NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (tag) {
        final uid = uidFromTag(tag);
        if (uid != null) onUid(uid);
      },
    );
  }
}

class _PulsePainter extends CustomPainter {
  _PulsePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    for (var i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1.0;
      final radius = 40 + t * 70;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = color.withValues(alpha: (1 - t) * 0.45);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulsePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
