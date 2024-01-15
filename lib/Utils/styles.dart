import 'package:flutter/material.dart';

class Styles
{
  static TextStyle getTextStyle(
      {Color? color, FontWeight? fontWeight, double? fontSize, dynamic fontfamily}) =>
      TextStyle(
        fontSize: fontSize!,
        fontWeight: fontWeight,
        color: color,
        fontFamily: fontfamily ?? "Ithra",
      );
}