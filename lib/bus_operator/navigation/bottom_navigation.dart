import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTabTapped;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
  });

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: BottomNavigationBar(
        currentIndex: widget.currentIndex,
        onTap: widget.onTabTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromARGB(255, 0, 0, 0),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
              size: 20,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.schedule_rounded,
              size: 20,
            ),
            label: 'Bus Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.star_rounded,
              size: 20,
            ),
            label: 'Rate',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              size: 20,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
