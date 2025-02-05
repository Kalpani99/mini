import 'package:track_bus/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:track_bus/password_reset_result_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  String? _errorMessage;

  Future<void> _sendPasswordResetEmail() async {
    String email = _emailController.text;

    if (!_isEmailValid(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const PasswordResetResultScreen()),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Email Not Registered'),
            content: const Text(
                'The email you entered is not registered. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  bool _isEmailValid(String email) {
    // Basic email validation using regular expression
    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 100),
              child: const Text(
                'Forgot Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Image.asset(
              'assets/images/forgot_password.png',
              height: 150,
              width: 150,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Enter your registered email below to receive\npassword reset instructions',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 40),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter an email:',
                        errorText: _errorMessage,
                        suffixIcon:
                            const Icon(Icons.email, color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 250,
                      height: 50,
                      child: ButtonWidget(
                        title: "Reset Password",
                        onPress: () {
                          _sendPasswordResetEmail();
                        },
                      ),
                    ),
                    const SizedBox(height: 20)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
