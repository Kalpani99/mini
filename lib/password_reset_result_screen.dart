import 'package:track_bus/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:track_bus/login.dart';

class PasswordResetResultScreen extends StatelessWidget {
  const PasswordResetResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 100),
            child: const Text(
              'Check Your Email',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Image.asset(
            'assets/images/check_your_email.png',
            height: 150,
            width: 150,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'We have sent password recovery instructions to your mail',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 80,
                      height: 40,
                      child: ButtonWidget(
                        title: "OK",
                        onPress: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const Login()),
                            (route) => false,
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
