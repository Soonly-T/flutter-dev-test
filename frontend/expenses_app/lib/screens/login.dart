import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final storage = const FlutterSecureStorage();
  final prefs = SharedPreferences.getInstance();
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

  Future<http.Response> login() {
    return http.post(
      Uri.parse('http://10.0.2.2:3000/login'), //android emulator
      // Uri.parse('http://localhost:3000/login'), //andere
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'loginIdentifier': loginController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );
  }

  void storeData(responseBody) async {
    Map<String, dynamic> userData = responseBody['userData'];
    String token = responseBody['token'];
    String username = userData['USERNAME'];
    String email = userData['EMAIL'];
    int userId = userData['ID'];

    await storage.write(key: 'token', value: token);
    await storage.write(key: 'id', value: userId.toString());
    final preferences = await prefs;
    await preferences.setString('username', username);
    await preferences.setString('email', email);
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

      login()
          .then((response) {
            debugPrint("Response: ${response.statusCode}");
            debugPrint("Response body: ${response.body}");
            debugPrint("Response headers: ${response.headers}");
            debugPrint(
              "Response content type: ${response.headers['content-type']}",
            );
            debugPrint("Response content length: ${response.contentLength}");
            if (response.statusCode == 200 || response.statusCode == 201) {
              final responseBody = jsonDecode(response.body);
              loginStatusNotifier.value =
                  "Welcome back, ${responseBody['userData']["USERNAME"]}";
              storeData(responseBody);
            } else if (response.statusCode == 401) {
              final responseBody = jsonDecode(response.body);
              loginStatusNotifier.value =
                  responseBody['message'] ??
                  "Invalid credentials. Please try again.";
            } else if (response.statusCode == 500) {
              final responseBody = jsonDecode(response.body);
              loginStatusNotifier.value =
                  responseBody['message'] ??
                  "An internal server error occurred. Please try again later.";
            } else {
              loginStatusNotifier.value =
                  "An unexpected error occurred. Please try again.";
            }
          })
          .catchError((error) {
            loginStatusNotifier.value =
                'An error occurred: ${error.toString()}';
          })
          .whenComplete(() {
            setState(() {}); // Ensure UI updates after login attempt
          });
    }
  }

  @override
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
                              print("Button pressed");
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
