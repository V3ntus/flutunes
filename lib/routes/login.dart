import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutunes/api/client.dart';
import 'package:flutunes/api/routes/users.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginModal extends StatefulWidget {
  final Uri serverName;

  const LoginModal({super.key, required this.serverName});

  @override
  State<LoginModal> createState() => _LoginModalState();
}

class _LoginModalState extends State<LoginModal> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoggingIn = false;
  String? loginFailedMessage;

  Future<bool> tryLogin() async {
    setState(() {
      isLoggingIn = true;
      loginFailedMessage = null;
    });

    try {
      final user = await Provider.of<JellyfinClient>(context, listen: false).login(
        widget.serverName.toString(),
        _usernameController.text,
        _passwordController.text,
      );
      setState(() {
        isLoggingIn = false;
        loginFailedMessage = null;
      });
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Logged in as ${user.name}")));
      }
    } on IncorrectCredentialsError {
      setState(() {
        isLoggingIn = false;
        loginFailedMessage = "Incorrect password";
      });
    } on DioException catch (error) {
      setState(() {
        isLoggingIn = false;
        loginFailedMessage = "Server error";
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${error.message}")));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 14.0,
            right: 14.0,
            top: 48.0,
          ),
          child: Flex(
            direction: Axis.vertical,
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Login to ${widget.serverName.host}",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: context.pop,
                    icon: Icon(
                      Icons.close,
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Username",
                  error: loginFailedMessage != null ? Container() : null,
                ),
                controller: _usernameController,
              ),
              TextField(
                decoration: InputDecoration(
                  labelText: "Password",
                  errorText: loginFailedMessage,
                ),
                obscureText: true,
                autocorrect: false,
                controller: _passwordController,
              ),
              AnimatedCrossFade(
                firstChild: FloatingActionButton.extended(
                  onPressed: () {
                    if (_usernameController.text.trim().isEmpty) {
                      setState(() {
                        isLoggingIn = false;
                        loginFailedMessage = "Username cannot be empty";
                      });
                    } else if (_passwordController.text.isEmpty) {
                      setState(() {
                        isLoggingIn = false;
                        loginFailedMessage = "Password cannot be empty";
                      });
                    } else {
                      tryLogin();
                    }
                  },
                  label: Text("Sign in"),
                  icon: Icon(Icons.login),
                  backgroundColor: Theme.of(context).buttonTheme.colorScheme?.primary,
                  foregroundColor: Theme.of(context).buttonTheme.colorScheme?.onPrimary,
                ),
                secondChild: LinearProgressIndicator(),
                crossFadeState: isLoggingIn ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 250),
                firstCurve: Curves.easeInCubic,
                secondCurve: Curves.easeInCubic,
                sizeCurve: Curves.easeInCubic,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _serverController = TextEditingController();
  bool isServerNameValid = true;
  bool isChecking = false;

  Future<bool> checkServer() async {
    if (!RegExp(r"https?://[\w.]+\.(?:[A-Za-z]+)?(?::\d{1,5})?/?").hasMatch(_serverController.text)) {
      return false;
    }
    try {
      final response = await Provider.of<JellyfinClient>(context, listen: false).http.dio.request(_serverController.text);
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! <= 399) {
        return true;
      }
    } on DioException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${error.message}")));
    }
    return false;
  }

  void serverOnTap() async {
    setState(() {
      isServerNameValid = true;
      isChecking = true;
    });
    final serverStatus = await checkServer();
    setState(() {
      isServerNameValid = serverStatus;
      isChecking = false;
    });

    if (mounted && serverStatus) {
      showDialog(
        context: context,
        builder: (_) => BottomSheet(
          onClosing: () {},
          builder: (_) => LoginModal(
            serverName: Uri.parse(_serverController.text),
          ),
        ),
      );
    }
  }

  void historyOnTap(String host) async {
    setState(() {
      _serverController.text = host;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Flex(
          direction: Axis.vertical,
          spacing: 24,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Flutunes",
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Container(
              constraints: BoxConstraints(
                maxWidth: 400,
              ),
              child: AnimatedCrossFade(
                firstCurve: Curves.easeInCubic,
                secondCurve: Curves.easeInCubic,
                sizeCurve: Curves.easeInCubic,
                crossFadeState: isChecking ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 250),
                firstChild: Flex(
                  spacing: 8,
                  direction: Axis.vertical,
                  children: [
                    TextField(
                      onSubmitted: (_) => _serverController.text.isEmpty ? null : serverOnTap(),
                      decoration: InputDecoration(
                        labelText: "Server",
                        hintText: "http://my.jellyfin.com:8096",
                        errorText: isServerNameValid ? null : "The server name is invalid",
                        suffixIcon: IconButton(
                          onPressed: () => _serverController.text.isEmpty ? null : serverOnTap(),
                          icon: Icon(Icons.arrow_circle_right),
                        ),
                      ),
                      controller: _serverController,
                    ),
                  ],
                ),
                secondChild: LinearProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
