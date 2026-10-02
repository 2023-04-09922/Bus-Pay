import 'package:flutter/material.dart';

import 'core/di/injection.dart';
import 'core/navigation/app_page_route.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Injection.init();
  final state = AppState();
  await Future.wait([
    state.loadSavedAccount(),
    ApiService.warmup(),
  ]);

  ApiService.onSessionExpired = () {
    state.logout();
    final nav = DaladalaApp.navigatorKey.currentState;
    if (nav == null) return;
    nav.pushAndRemoveUntil(
      AppPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  };

  runApp(AppScope(notifier: state, child: const DaladalaApp()));
}

class DaladalaApp extends StatelessWidget {
  const DaladalaApp({super.key});

  /// Preserves the navigator across MaterialApp rebuilds (theme/language).
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Bus Pay',
          themeMode: app.themeMode,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(app.textScale),
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _OpaqueSlideTransitionsBuilder(),
                TargetPlatform.iOS: _OpaqueSlideTransitionsBuilder(),
                TargetPlatform.windows: _OpaqueSlideTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            pageTransitionsTheme: const PageTransitionsTheme(
              builders: {
                TargetPlatform.android: _OpaqueSlideTransitionsBuilder(),
                TargetPlatform.iOS: _OpaqueSlideTransitionsBuilder(),
                TargetPlatform.windows: _OpaqueSlideTransitionsBuilder(),
              },
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}

/// Slide transition that stays opaque — no see-through flash of the previous screen.
class _OpaqueSlideTransitionsBuilder extends PageTransitionsBuilder {
  const _OpaqueSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return authStyleTransition(
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
      enterFrom: const Offset(1.0, 0),
      exitTo: const Offset(-1.0, 0),
    );
  }
}
