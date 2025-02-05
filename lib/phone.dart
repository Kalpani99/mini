import 'package:track_bus/auth_provider/auth.dart';
import 'package:flutter/material.dart';
import 'package:track_bus/widget/button_widget.dart';

class TwoFactorAuthScreen extends StatefulWidget {
  const TwoFactorAuthScreen({super.key});

  @override
  State<TwoFactorAuthScreen> createState() => _TwoFactorAuthScreenState();
}

String? _errorMessage;

class _TwoFactorAuthScreenState extends State<TwoFactorAuthScreen> {
  TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Verify Your Phone Number',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 24.0),
              const CircleAvatar(
                radius: 100,
                backgroundImage: AssetImage('assets/images/phonenum.png'),
              ),
              const SizedBox(height: 30.0),
              const Text(
                'Please Enter Your Phone Number',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number(+94xxxxxxxxx)',
                  labelStyle:
                      const TextStyle(color: Colors.black), // Label text color
                  errorText: _errorMessage,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.black), // Black underline when focused
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                        color:
                            Colors.black), // Black underline when not focused
                  ),
                ),
                cursorColor: Colors.black, // Cursor color
                style: const TextStyle(color: Colors.black), // Text color
              ),
              const SizedBox(height: 30.0),
              SizedBox(
                height: 50,
                width: 150,
                child: ButtonWidget(
                  title: "Next",
                  onPress: () {
                    sendPhoneNumber();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text;

    bool isPhoneNumValid(String phoneNumber) {
      phoneNumber = phoneNumber.trim();
      final phoneRegex = RegExp(r'^\+94\d{9}$');
      return phoneRegex.hasMatch(phoneNumber);
    }

    if (!isPhoneNumValid(phoneNumber)) {
      setState(() {
        _errorMessage = 'Please enter a valid phone number.';
      });
      return;
    }

    try {
      AuthProvider ap = AuthProvider();
      ap.signInWithPhone(
        context,
        phoneNumber,
        onCodeSent: (verificationId) {
          // Handle the code sent here (e.g., navigate to the next screen)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VerificationCodeScreen(verificationId: verificationId),
            ),
          );
        },
        onError: (error) {
          setState(() {
            _errorMessage = error.toString();
          });
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Error'),
            content:
                const Text('An error occurred while processing your request.'),
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
}

class VerificationCodeScreen extends StatelessWidget {
  final String verificationId;

  const VerificationCodeScreen({super.key, required this.verificationId});

  @override
  Widget build(BuildContext context) {
    // Your verification code screen implementation
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Verification Code'),
      ),
      body: Center(
        child: Text('Verification ID: $verificationId'),
      ),
    );
  }
}
