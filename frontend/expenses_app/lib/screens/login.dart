import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/alertBox.dart';
import 'signup.dart';

const double spaceHeight = 32;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginController = TextEditingController();
  final passwordController = TextEditingController();
  ValueNotifier<String> loginStatusNotifier = ValueNotifier<String>('');
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    loginController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void debugPrintCredentials() {
    bool filled = false;
    print("printing credentials");
    print('Login: ${loginController.text}');
    print('Password: ${passwordController.text}');

    if (loginController.text.isEmpty && passwordController.text.isEmpty) {
      print('Both login and password fields are empty');
      alertBox.showAlertDialog(
        context,
        "Please fill in the credentials",
        "Both username/email and password fields are empty",
      );
    } else if (loginController.text.isEmpty) {
      print('Login field is empty');
      alertBox.showAlertDialog(
        context,
        "Please fill in the credentials",
        "Username/email field is empty",
      );
    } else if (passwordController.text.isEmpty) {
      print('Password field is empty');
      alertBox.showAlertDialog(
        context,
        "Please fill in the credentials",
        "Password field is empty",
      );
    } else {
      print('Both fields are filled');
      filled = true;
    }
  }

  @override
  Future<http.Response> login() {
    return http.post(
      Uri.parse('http://10.0.2.2:3000/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loginIdentifier': loginController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );
  }

  void handleLogin() {
    bool filled = false;
    print("printing credentials");
    print('Login: ${loginController.text}');
    print('Password: ${passwordController.text}');

    if (loginController.text.isEmpty && passwordController.text.isEmpty) {
      print('Both login and password fields are empty');
      alertBox.showAlertDialog(
        context,
        "Please fill in the credentials",
        "Both username/email and password fields are empty",
      );
    } else if (loginController.text.isEmpty) {
      print('Login field is empty');
      alertBox.showAlertDialog(
        context,
        "Please fill in the credentials",
        "Username/email field is empty",
      );
    } else if (passwordController.text.isEmpty) {
      print('Password field is empty');
      alertBox.showAlertDialog(
        context,
        "Please fill in the credentials",
        "Password field is empty",
      );
    } else {
      print('Both fields are filled');

      login().then((response) {
        debugPrint("Response: $response.statusCode");
        debugPrint("Response body: ${response.body}");
        debugPrint("Response headers: ${response.headers}");
        debugPrint(
          "Response content type: ${response.headers['content-type']}",
        );
        debugPrint("Response content length: ${response.contentLength}");
        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseBody = jsonDecode(response.body);
          if (responseBody['status'] == 'success') {
            loginStatusNotifier.value = 'Login successful';
            alertBox.showAlertDialog(
              context,
              "Login Successful",
              "Welcome back, ${responseBody['username']}",
            );
          } else {
            loginStatusNotifier.value = 'Login failed';
            alertBox.showAlertDialog(
              context,
              "Login Failed",
              responseBody['message'],
            );
          }
        } else {
          loginStatusNotifier.value = 'Login failed';
          alertBox.showAlertDialog(
            context,
            "Login Failed",
            "An error occurred. Please try again.",
          );
        }
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch, // Use stretch to make children take full width
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Expense Tracker App',
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: spaceHeight),
            LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth * 0.75;
                return Column(
                  children: [
                    SizedBox(
                      width: width,
                      child: TextFormField(
                        controller: loginController,
                        decoration: InputDecoration(
                          labelText: 'Username or Email',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: false,
                      ),
                    ),
                    const SizedBox(height: spaceHeight),
                    SizedBox(
                      width: width,
                      child: TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: spaceHeight),
                    SizedBox(
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              handleLogin();
                            },
                            child: const Text('Login'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Signup(),
                                ),
                              );
                            },
                            child: const Text('Sign Up'),
                          ),
                        ],
                      ),
                    ),
                    ValueListenableBuilder<String>(
                      valueListenable: loginStatusNotifier,
                      builder: (context, status, child) {
                        return Text(
                          status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
