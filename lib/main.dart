import 'package:flutter/material.dart';
import 'package:flutunes/api/client.dart';
import 'package:flutunes/routes/login.dart';
import 'package:flutunes/routes/splash.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: "/login",
      builder: (_, __) => LoginScreen(),
    ),
    GoRoute(
      path: "/",
      builder: (_, __) => SplashScreen(),
    ),
  ],
);

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => JellyfinClient(),
      child: MaterialApp.router(
        title: 'Flutunes',
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: EdgeInsets.all(20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              gapPadding: 8.0,
            ),
          ),
        ),
        routerConfig: _router,
      ),
    );
  }
}
