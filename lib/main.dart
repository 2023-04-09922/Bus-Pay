import 'package:flutter/material.dart';

import 'core/di/injection.dart';
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
  }
}
