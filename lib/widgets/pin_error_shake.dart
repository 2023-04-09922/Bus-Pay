import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinErrorShake extends StatefulWidget {
  const PinErrorShake({
    super.key,
    required this.visible,
    required this.pulse,
    required this.message,
  });

  final bool visible;
  final int pulse;
  final String message;

  @override
  State<PinErrorShake> createState() => _PinErrorShakeState();
}

class _PinErrorShakeState extends State<PinErrorShake>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    if (widget.visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _play());
    }
  }

  @override
  void didUpdateWidget(covariant PinErrorShake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && widget.pulse != oldWidget.pulse) {
      _play();
    }
  }

  Future<void> _play() async {
    HapticFeedback.heavyImpact();
    await HapticFeedback.vibrate();
    if (!mounted) return;
    await _shake.forward(from: 0);
    if (!mounted) return;
    await HapticFeedback.vibrate();
    await _shake.forward(from: 0);
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) {
      return const SizedBox(height: 24);
    }

    return SizedBox(
      height: 24,
      child: AnimatedBuilder(
        animation: _shake,
        builder: (context, child) {
          final dx = math.sin(_shake.value * math.pi * 6) * 12;
          return Transform.translate(
            offset: Offset(dx, 0),
            child: child,
          );
        },
        child: Text(
          widget.message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
