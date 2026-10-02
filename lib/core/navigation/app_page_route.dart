import 'package:flutter/material.dart';

/// Soft slide for normal in-app navigation (stays opaque).
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required WidgetBuilder builder, super.settings})
      : super(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return authStyleTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
              enterFrom: const Offset(0.08, 0),
              exitTo: const Offset(-0.08, 0),
            );
          },
        );
}

/// Full horizontal reveal used after a successful conductor / agent login.
/// Outgoing PIN/login face slides left; home enters from the right.
class AuthSuccessRoute<T> extends PageRouteBuilder<T> {
  AuthSuccessRoute({required WidgetBuilder builder, super.settings})
      : super(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: const Duration(milliseconds: 440),
          reverseTransitionDuration: const Duration(milliseconds: 340),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return authStyleTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
              enterFrom: const Offset(1.0, 0),
              exitTo: const Offset(-1.0, 0),
            );
          },
        );
}

/// Shared-axis horizontal slide (incoming from [enterFrom], covered page to [exitTo]).
Widget authStyleTransition({
  required Animation<double> animation,
  required Animation<double> secondaryAnimation,
  required Widget child,
  required Offset enterFrom,
  required Offset exitTo,
}) {
  const curve = Cubic(0.22, 1.0, 0.36, 1.0);
  final primary = CurvedAnimation(
    parent: animation,
    curve: curve,
    reverseCurve: Curves.easeInCubic,
  );
  final secondary = CurvedAnimation(
    parent: secondaryAnimation,
    curve: curve,
  );

  return SlideTransition(
    position: Tween<Offset>(
      begin: Offset.zero,
      end: exitTo,
    ).animate(secondary),
    child: SlideTransition(
      position: Tween<Offset>(
        begin: enterFrom,
        end: Offset.zero,
      ).animate(primary),
      child: child,
    ),
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

/// PIN / login success → home (conductor or wakala).
Future<T?> pushAuthSuccess<T extends Object?, TO extends Object?>(
  BuildContext context,
  Widget page, {
  TO? result,
}) {
  return Navigator.pushReplacement<T, TO>(
    context,
    AuthSuccessRoute(builder: (_) => page),
    result: result,
  );
}

/// Same reveal, clearing the whole stack (e.g. after phone+PIN on a new device).
Future<T?> pushAuthSuccessClearingStack<T extends Object?>(
  BuildContext context,
  Widget page,
) {
  return Navigator.pushAndRemoveUntil<T>(
    context,
    AuthSuccessRoute(builder: (_) => page),
    (route) => false,
  );
}
