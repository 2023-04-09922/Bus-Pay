import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';
import 'payment_verify_screen.dart';

const _demoPassengers = [
  'Amina Hassan',
  'Juma Ally',
  'Fatuma Said',
  'Peter Mwamba',
  'Neema John',
  'Hassan Bakari',
];

class NfcScannerScreen extends StatefulWidget {
  const NfcScannerScreen({super.key, required this.amount});

  final int amount;

  @override
  State<NfcScannerScreen> createState() => _NfcScannerScreenState();
}

class _NfcScannerScreenState extends State<NfcScannerScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _timer;
  bool found = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _timer = Timer(const Duration(seconds: 3), _onCardFound);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _onCardFound() {
    if (!mounted) return;
    setState(() => found = true);
    final passenger = _demoPassengers[Random().nextInt(_demoPassengers.length)];
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentVerifyScreen(
            amount: widget.amount,
            passengerName: passenger,
          ),
        ),
      );
    });
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
                  onPressed: _onCardFound,
                  child: Text(
                    s.isSw ? 'Simulia kadi (demo)' : 'Simulate card (demo)',
                  ),
                ),
            ],
          ),
        ),
      ),
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
