import 'package:track_bus/login.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/success.png',
              width: 150,
              height: 150,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24.0),
                  const Text(
                    'Yahoo! \nYou have successfully verified your account.\nStart your journey now',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32.0, vertical: 16.0),
                    ),
                    child: const Text(
                      'Get Started',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
