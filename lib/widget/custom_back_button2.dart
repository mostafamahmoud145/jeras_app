import 'package:flutter/material.dart';

class CustomBackButton2 extends StatelessWidget {
  const CustomBackButton2({super.key, this.color, this.borderColor});

  final Color? color;

  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: Navigator.of(context).pop,
      color: color,
      icon: Icon(Icons.arrow_forward_ios_outlined),
    );
  }
}
