import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    Key? key,
    required this.icon,
  }) : super(key: key);
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: CircleAvatar(
        backgroundColor: Colors.grey,
        radius: 30,
        child: Icon(
          icon,
          size: 36,
          color: Colors.orangeAccent,
        ),
      ),
    );
  }
}