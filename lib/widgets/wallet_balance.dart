import 'dart:ui';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class WalletBalanceText extends StatelessWidget {
  const WalletBalanceText({
    super.key,
    required this.style,
    this.showToggle = false,
    this.toggleColor,
  });

  final TextStyle style;
  final bool showToggle;
  final Color? toggleColor;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S(app.language);
    final amount = Text(s.tzs(app.walletBalance), style: style);

    return Row(
      children: [
        Flexible(
          child: ClipRect(
            child: app.walletHidden
                ? ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: amount,
                  )
                : amount,
          ),
        ),
        if (showToggle)
          IconButton(
            onPressed: app.toggleWalletHidden,
            color: toggleColor ?? style.color,
            icon: Icon(
              app.walletHidden ? Icons.visibility_off : Icons.visibility,
            ),
          ),
      ],
    );
  }
}
