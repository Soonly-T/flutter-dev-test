import 'dart:convert';

import 'package:flutter/material.dart';
import '../widgets/alertBox.dart';
import 'package:http/http.dart' as http;

const double spaceHeight = 32;

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  ValueNotifier<String> signupStatusNotifier = ValueNotifier<String>('');

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<http.Response> signup() {
    return http.post(
      Uri.parse('http://10.0.2.2:3000/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
      }),
    );
  }

  void _handleSignup() {
    bool valid = true;
    if (usernameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.trim().isEmpty ||
        confirmPasswordController.text.trim().isEmpty) {
      alertBox.showAlertDialog(
        context,
        'Empty Fields',
        'Please fill in all the fields.',
      );
      valid = false;
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      alertBox.showAlertDialog(
        context,
        'Password Mismatch',
        'The passwords do not match.',
      );
      valid = false;
      return;
    }

    if (passwordController.text.length < 8) {
      alertBox.showAlertDialog(
        context,
        'Weak Password',
        'Password must be at least 8 characters long.',
      );
      valid = false;
      return;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(emailController.text.trim())) {
      alertBox.showAlertDialog(
        context,
        'Invalid Email Address',
        'Please enter a valid email address.',
      );
      valid = false;
      return;
    }

    // Add your signup logic here
    print('Username: ${usernameController.text}');
    print('Email: ${emailController.text}');
    print('Password: ${passwordController.text}');
    print('Confirm Password: ${confirmPasswordController.text}');

    if (valid) {
      signup()
          .then((response) {
            if (response.statusCode == 200 || response.statusCode == 201) {
              signupStatusNotifier.value = 'Signup successful!';
            } else {
              signupStatusNotifier.value = 'Signup failed: ${response.body}';
            }
          })
          .catchError((error) {
            signupStatusNotifier.value = 'Signup failed: $error';
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth * 0.75;

    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          // Added SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: contentWidth, // Set width to 75% of screen width
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Signup Screen",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _handleSignup,
                    child: const Text("Signup"),
                  ),
                  ValueListenableBuilder<String>(
                    valueListenable: signupStatusNotifier,
                    builder: (context, status, child) {
                      return Text(
                        status,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
