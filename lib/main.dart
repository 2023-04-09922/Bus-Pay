import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(AppScope(notifier: AppState(), child: const DaladalaApp()));
}

class DaladalaApp extends StatelessWidget {
  const DaladalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Daladala',
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
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            fontFamily: 'Roboto',
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),
          home: const LoginScreen(),
        );
      },
    );
  }
}
