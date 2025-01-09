import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Flutunes"),
            SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(hintText: "Username"),
                controller: _usernameController,
              ),
            ),
            SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(hintText: "Password"),
                obscureText: true,
                autocorrect: false,
                controller: _passwordController,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
