import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.passengerName,
    this.reference = '',
    this.success = true,
    this.onRetry,
  });

  final int amount;
  final String passengerName;
  final String reference;
  final bool success;
  final VoidCallback? onRetry;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _exit;
  late final Animation<Offset> _slide;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _exit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0),
    ).animate(CurvedAnimation(
      parent: _exit,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _exit.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    if (_leaving || !mounted) return;
    setState(() => _leaving = true);
    await _exit.forward();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);

    return SlideTransition(
      position: _slide,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const Spacer(),
                Icon(
                  widget.success ? Icons.check_circle : Icons.cancel,
                  color: widget.success ? Colors.green : Colors.red,
                  size: 108,
                ),
                const SizedBox(height: 20),
                Text(
                  widget.success ? s.paymentComplete : s.paymentFailed,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: widget.success
                        ? Colors.green.shade800
                        : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.passengerName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  s.tzs(widget.amount),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.reference.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    widget.reference,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
                const Spacer(),
                if (!widget.success)
                  TextButton(
                    onPressed: _leaving
                        ? null
                        : (widget.onRetry ?? () => Navigator.pop(context)),
                    child: Text(
                      s.tryAgain,
                      style: const TextStyle(fontSize: 14, color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _leaving ? null : _done,
                    child: Text(
                      s.done,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
