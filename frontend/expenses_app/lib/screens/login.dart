import 'package:flutter/material.dart';
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
                              debugPrintCredentials();
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
