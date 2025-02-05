import 'package:track_bus/bus_operator/bus_operator_profile_page.dart';
import 'package:track_bus/signup.dart';
import 'package:track_bus/passenger/user_profile_page.dart';
import 'package:track_bus/widget/button_widget.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  final UserType userType;

  const WelcomeScreen({Key? key, required this.userType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String welcomeMessage = '';

    if (userType == UserType.busOperator) {
      welcomeMessage =
          "Welcome!\nYou have successfully signed up as a\nBus Operator.";
    } else if (userType == UserType.passenger) {
      welcomeMessage =
          "Welcome!\nYou have successfully signed up as a\nPassenger.";
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 300,
              height: 200,
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                //color: Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24.0),
                  Text(
                    welcomeMessage,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    height: 50,
                    width: 150,
                    child: ButtonWidget(
                      title: "Proceed",
                      onPress: () {
                        if (userType == UserType.busOperator) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BusOperatorProfileScreen(),
                            ),
                          );
                        } else if (userType == UserType.passenger) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserProfileScreen(),
                            ),
                          );
                        }
                      },
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
