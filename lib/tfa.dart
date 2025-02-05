// ignore_for_file: library_private_types_in_public_api, must_be_immutable

import 'package:track_bus/utils/utils.dart';
import 'package:track_bus/verified.dart';
import 'package:track_bus/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'auth_provider/auth.dart';

class VerifyAccountScreen extends StatefulWidget {
  String verificationId;
  final String phone;
  VerifyAccountScreen(
      {super.key, required this.verificationId, required this.phone});

  @override
  _VerifyAccountScreenState createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  String? otpCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Verify Your Account',
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Twofactor.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 24.0),
              Text(
                'Please enter the 6 digit code sent to your phone ${widget.phone}',
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Pinput(
                length: 6,
                showCursor: true,
                defaultPinTheme: PinTheme(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color.fromARGB(255, 10, 10, 10),
                    ),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onCompleted: (value) {
                  setState(() {
                    otpCode = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive a pin?",
                    style: TextStyle(fontSize: 16),
                  ),
                  TextButton(
                    onPressed: resendCode,
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 24.0,
              ),
              SizedBox(
                  height: 50,
                  width: 150,
                  child: ButtonWidget(
                    title: "Verify",
                    onPress: () {
                      if (otpCode != null) {
                        verifyOtp(context, otpCode!);
                      } else {
                        showSnackBar(context, "Enter 6-Digit code");
                      }
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  // verify otp
  void verifyOtp(BuildContext context, String userOtp) {
    AuthProvider ap = AuthProvider();
    ap.verifyOtp(
      context: context,
      verificationId: widget.verificationId,
      userOtp: userOtp,
      onSuccess: () {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const VerificationScreen(),
            ),
            (route) => false);
      },
    );
  }

  void resendCode() {
    String phoneNumber = widget.phone;
    AuthProvider ap = AuthProvider();

    // Correct the callback: Only pass verificationId if signInWithPhone expects a single parameter
    ap.signInWithPhone(
      context, // Passing the BuildContext
      phoneNumber, // Passing the phone number directly as positional argument
      onCodeSent: (verificationId) {
        // Adjust the callback to expect only one argument
        setState(() {
          widget.verificationId = verificationId;
        });
        showSnackBar(context, "OTP sent again to $phoneNumber");
      },
      onError: (error) {
        showSnackBar(context, "Failed to resend code: $error");
      },
    );
  }
}
