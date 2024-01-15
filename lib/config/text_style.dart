import 'package:flutter/material.dart';

import '../localization/localization_methods.dart';

class Text_Style extends StatelessWidget {
  String text;
  String ?fontFamily;
  double? fontSize;
  FontWeight? fontWeight;
  Color ?textColor;
  Text_Style({
    required this.text,
    required this.fontWeight,
    required this.fontFamily,
    required this.fontSize,
    required this.textColor,
});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: getTranslated(context, fontFamily.toString()),
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: textColor,
      ),
    );
  }
}
