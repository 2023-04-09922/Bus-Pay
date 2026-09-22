import 'package:flutter/material.dart';

/// Soft slide that stays opaque (no fade-through flash of the previous route).
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
      : super(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            );
          },
        );
}

Future<T?> pushSmooth<T extends Object?>(
  BuildContext context,
  Widget page,
) {
  return Navigator.push<T>(context, AppPageRoute(builder: (_) => page));
}

Future<T?> pushReplacementSmooth<T extends Object?, TO extends Object?>(
  BuildContext context,
  Widget page, {
  TO? result,
}) {
  return Navigator.pushReplacement<T, TO>(
    context,
    AppPageRoute(builder: (_) => page),
    result: result,
  );
}
