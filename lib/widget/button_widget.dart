import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final Function onPress;
  final Color color;
  const ButtonWidget(
      {Key? key,
      required this.title,
      required this.onPress,
      this.color = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Navigate to Home page
        onPress();
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
          )),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
    );
  }
}
