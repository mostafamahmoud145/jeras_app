import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key,
        required this.title,
        // this.width = 348,
        // this.height = 56,
        this.radius = AppRadius.r30,
        this.backgroundColor,
        this.horizontalPadding,
        this.verticalPadding ,
        this.margin,
        required this.onTap,
        this.style,
        this.decoration,
        this.textColor,
        this.hasBackgroundColor = true,
        this.borderColor = false,
        this.iconWidget})
      : super(key: key);
  final void Function()? onTap;
  final String title;
  // final double width, height;
  final Color? backgroundColor;
  final double? radius;
  final TextStyle? style;
  final double? horizontalPadding, verticalPadding;
  final BoxDecoration? decoration;
  final Widget? iconWidget;
  final bool hasBackgroundColor, borderColor;
  final Color? textColor;
  final EdgeInsetsGeometry? margin;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        //height: height.h,
        //width: width.w,
        padding: EdgeInsets.symmetric(vertical: verticalPadding??14, horizontal: horizontalPadding ??0),
        margin: margin?? EdgeInsets.symmetric(horizontal: AppMargin.m8),
        decoration: decoration ??
            BoxDecoration(
              color: backgroundColor,
              // gradient: hasBackgroundColor ? ThemeClass.gradientBtn : null,
              borderRadius: radius == null
                  ? BorderRadius.circular(AppRadius.r10)
                  : BorderRadius.circular(radius!),
              border: borderColor == true
                  ? Border.all(color: textColor ?? AppColors.pink)
                  : Border.all(
                color: hasBackgroundColor
                    ? Colors.transparent
                    : backgroundColor ?? AppColors.pink,
                width: 2,
              ),
            ),
        child: iconWidget != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Text(
                title,
                style: style ??
                    TextStyle(
                      color: AppColors.white,
                      fontSize: AppFontsSizeManager.s16,
                      fontFamily: "Ithra",
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            iconWidget!
          ],
        )
            : Text(
          title,
          style: style ??
              TextStyle(
                  color: textColor ?? AppColors.white,
                  fontSize: AppFontsSizeManager.s16,
                  fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}