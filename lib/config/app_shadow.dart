import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';

import 'colors_file.dart';

class AppShadow {
  static final primaryShadow = BoxShadow(
    color: AppColors.primaryColor.withOpacity(.08),
    blurRadius: 8.5.r,
    spreadRadius: 0.0,
    offset: Offset(0.0, 1.0), // shadow direction: bottom right
  );
  static final fabshadow = BoxShadow(
      offset: Offset(0, 14.0),
      blurRadius: 10.0,
      spreadRadius: 1.0,
      color: Color.fromRGBO(123, 108, 150, 0.2));
  static final greyshadow = BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 10.0,
      spreadRadius: 1.0,
      color: AppColors.chat);
  static final greyshadow2 = BoxShadow(
      offset: Offset(0, 0),
      blurRadius: 10.0,
      spreadRadius: 1.0,
      color: AppColors.grey230);
}
