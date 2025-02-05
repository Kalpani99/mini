import 'package:track_bus/bus_operator/navigation/bottom_navigation.dart';
import 'package:track_bus/passenger/passengerhome.dart';
import 'package:track_bus/passenger/viewSchedule.dart';
import 'package:track_bus/passenger/view_Passenger_Profile.dart';
import 'package:flutter/material.dart';

class PRatingScreen extends StatefulWidget {
  const PRatingScreen({super.key});

  @override
  State<PRatingScreen> createState() => _PRatingScreenState();
}

class _PRatingScreenState extends State<PRatingScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Ratings"),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: 45.0), // Reduce horizontal padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment
                  .stretch, // Make elements stretch horizontally
              children: [
                Text(
                  "Very Good Driver",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20), // Reduce vertical spacing
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTabTapped: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 0) {
              // Navigate to home
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PassengerHomeScreen(),
                ),
              );
            } else if (index == 1) {
              // Navigate to schedule
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PassengerScheduleScreen(),
                ),
              );
            } else if (index == 2) {
              // Navigate to star
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileTypeScreenP(),
                ),
              );
            }
          });
        },
      ),
    );
  }
}
