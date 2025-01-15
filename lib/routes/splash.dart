import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutunes/api/client.dart';
import 'package:flutunes/models/user.dart';
import 'package:flutunes/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1), _checkIfLoggedIn);
  }

  Future<void> _checkIfLoggedIn() async {
    void gotoLogin() {
      if (mounted) context.go("/login");
    }

    String? accessToken =
        await asyncPrefs.getString(PreferenceKeys.ACCESS_TOKEN.key);
    if (await asyncPrefs.getString(PreferenceKeys.SERVER_URL.key) == null) {
      gotoLogin();
    } else if (accessToken == null) {
      gotoLogin();
    } else {
      final username = await asyncPrefs.getString(PreferenceKeys.USERNAME.key);
      final userId = await asyncPrefs.getString(PreferenceKeys.USER_ID.key);
      final enableAutoLogin =
          await asyncPrefs.getBool(PreferenceKeys.SHOULD_AUTO_LOGIN.key);

      if ([username, userId, enableAutoLogin].every((e) => e != null)) {
        if (mounted) {
          Provider.of<JellyfinClient>(context, listen: false).http.currentUser =
              UserModel(
            name: username!,
            id: userId!,
            enableAutoLogin: enableAutoLogin!,
          );
          try {
            await Provider.of<JellyfinClient>(context, listen: false)
                .http
                .users
                .me();
            if (mounted) context.go("/home");
          } on DioException {
            gotoLogin();
          }
        }
      }
      gotoLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Flutunes",
          style: Theme.of(context).textTheme.displayLarge,
        ),
      ),
    );
  }
}
