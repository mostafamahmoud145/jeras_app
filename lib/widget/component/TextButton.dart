import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/app_constat.dart';
import '../../config/app_fonts.dart';

class TextButton1 extends StatelessWidget {
  const TextButton1(
      {super.key,
      required this.onPress,
      required this.Title,
      this.Width,
      this.Height,
      required this.ButtonRadius,
      required this.TextSize,
      this.ButtonBackground,
      required this.TextFont,
      required this.TextColor,
      this.Icon,
      this.GradientColor,
      this.GradientColor2,
      this.Padding,
      this.IconSpace,
      this.IconColor,
      this.Direction,
      this.Padding2,
      this.BoxShadow1,
      this.IconWidth,
      this.IconHeight});

  final Function() onPress;

  final double? ButtonRadius;
  final Color? ButtonBackground;
  final double? Width;
  final double? Height;
  final String Title;
  final String? TextFont;
  final double? TextSize;
  final Color? TextColor;
  final String? Icon;

  ////

  final Color? GradientColor, GradientColor2;
  final TextDirection? Direction;
  final double? Padding, Padding2;
  final double? IconSpace;
  final double? IconWidth;
  final double? IconHeight;
  final Color? IconColor;
  final List<BoxShadow>? BoxShadow1;

  LinearGradient get Gradiant => LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          GradientColor!,
          GradientColor2!,
        ],
      );

  @override
  Widget build(BuildContext context) {
    return (ButtonBackground != null)
        ? InkWell(
      onTap: onPress,
            child: Container(
                width: Width,
                height: Height,
                padding: EdgeInsets.symmetric(
                    vertical: Padding ?? 0, horizontal: Padding2 ?? 0),
                decoration: BoxShadow1 != null
                    ? BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(ButtonRadius ?? 0)),
                        boxShadow: BoxShadow1,
                        color: ButtonBackground,
                      )
                    : BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(ButtonRadius ?? 0)),
                        color: ButtonBackground,
                      ),
                child: Icon == null
                    ? Center(
                        child: Text(
                          Title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TextColor,
                            fontWeight: AppFontsWeightManager.semiBold,
                            fontFamily: TextFont,
                            fontStyle: FontStyle.normal,
                            fontSize: TextSize ?? 0,
                          ),
                        ),
                      )
                    : Directionality(
                        textDirection: Direction!,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Title,
                              style: TextStyle(
                                fontFamily: TextFont,
                                fontWeight: AppFontsWeightManager.bold300,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: TextSize ?? 15.sp,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                            ),
                            SizedBox(width: IconSpace),
                            (Icon!.substring(Icon!.length - 3, Icon!.length) ==
                                    'png')
                                ? Image.asset(
                                    Icon!,
                                    width: IconWidth,
                                    height: IconHeight,
                                    color: IconColor,
                                  )
                                : SvgPicture.asset(Icon!,
                                    color: IconColor,
                                    width: IconWidth,
                                    height: IconHeight),
                          ],
                        ),
                      )),
          )
        : InkWell(
            onTap: onPress,
            child: Container(
                width: Width,
                height: Height,
                padding: EdgeInsets.symmetric(
                    vertical: Padding ?? 0, horizontal: Padding2 ?? 0),
                decoration: BoxShadow1 != null
                    ? BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(ButtonRadius ?? 0)),
                        boxShadow: BoxShadow1,
                        gradient: Gradiant,
                      )
                    : BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(ButtonRadius ?? 0)),
                        gradient: Gradiant,
                      ),
                child: Icon == null
                    ? Center(
                      child: Text(
                          Title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: TextColor,
                            fontWeight: AppFontsWeightManager.semiBold,
                            fontFamily: TextFont,
                            fontStyle: FontStyle.normal,
                            fontSize: TextSize ?? 0,
                          ),
                        ),
                    )
                    : Directionality(
                        textDirection: Direction!,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              Title,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontWeight: AppFontsWeightManager.bold300,
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: TextSize ?? 15.sp,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                            ),
                            SizedBox(width: IconSpace),
                            (Icon!.substring(Icon!.length - 3, Icon!.length) ==
                                    'png')
                                ? Image.asset(
                                    Icon!,
                                    width: IconWidth,
                                    height: IconHeight,
                                    color: IconColor,
                                  )
                                : SvgPicture.asset(Icon!,
                                    color: IconColor,
                                    width: IconWidth,
                                    height: IconHeight),
                          ],
                        ),
                      )),
          );
  }
}
