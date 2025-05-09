import 'package:track_bus/bus_operator/bostarttrip.dart';
import 'package:flutter/material.dart';
import 'bus_shedule.dart';
import 'navigation/bottom_navigation.dart';
import 'viewBOprofile.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text("Ratings",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              )),
          actions: const []),
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
                  builder: (context) => const BOStartTrip(),
                ),
              );
            } else if (index == 1) {
              // Navigate to schedule
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BusScheduleScreen(),
                ),
              );
            } else if (index == 2) {
              // Navigate to star
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RatingScreen(),
                ),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileTypeScreen(),
                ),
              );
            }
          });
        },
      ),
    );
  }
}
