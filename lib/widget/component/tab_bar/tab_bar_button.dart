
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/responsive.dart';

import '../../../config/colors_file.dart';
import '../../../localization/localization_methods.dart';


class TabBarButton extends StatelessWidget {
  const TabBarButton({
    Key? key,
    required this.isSelected,
    required this.function,
    this.activeColor,
    this.notActiveColor= Colors.transparent,
    this.radius,
    this.height,
    this.width,
    required this.text,
    this.activeTextColor= AppColors.white,
    this.notActiveTextColor=  AppColors.pink,
    this.textSize= AppFontsSizeManager.s21_3,
    this.fontFamily,
    this.fontWeight= FontWeight.bold,
  }) : super(key: key);

  final bool isSelected;
  final Function function;
  final Color? activeColor;
  final Color? notActiveColor;
  final Color? activeTextColor;
  final Color? notActiveTextColor;
  final String text;
  final double? width;
  final double? height;
  final double? radius;
  final double? textSize;
  final FontWeight? fontWeight;
  final String? fontFamily;



  @override
  Widget build(BuildContext context) {
    Size size= MediaQuery.of(context).size;

    return InkWell(
      onTap: () async {
        function();
      },
      child: Container(
        width: (size.width*0.9)/3, // convertPtToPx(width.w),
        height: convertPtToPx(height!.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor??AppColors.pink : notActiveColor,
          borderRadius: BorderRadius.circular(radius!.r),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            height: 0.0,
            fontFamily: fontFamily?? getTranslated(context, 'Ithra'),
            color: isSelected ? activeTextColor : notActiveTextColor,
            fontSize: textSize!.sp,
            fontWeight: fontWeight,
            fontStyle:  FontStyle.normal,
          ),
        ),
      ),
    );
  }
}