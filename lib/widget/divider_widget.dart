import 'package:flutter/material.dart';
import 'package:jeras/config/app_values.dart';

import '../config/colors_file.dart';
class DividerWidget extends StatelessWidget {
  double width;
  double height;

  DividerWidget({Key? key, required this.height, required this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
        color: AppColors.lightGrey, height: AppSize.h1, width: size.width);
  }
}
