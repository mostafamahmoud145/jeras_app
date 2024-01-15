import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/widget/custom_outlined_button.dart';

class IconButton1 extends StatelessWidget {
  const IconButton1(
      {super.key,
      required this.onPress,
      required this.Width,
      required this.Height,
      this.ButtonRadius,
      this.ButtonBackground,
      this.Icon,
      this.GradientColor,
      this.GradientColor2,
      this.ButtonColor,
      this.IconColor,
      this.IconWidth,
      this.IconHeight,
      this.BoxShape1});

  final Function() onPress;

  final double? ButtonRadius;
  final Color? ButtonBackground;
  final double? Width, IconWidth;
  final double? Height, IconHeight;
  final String? Icon;

  ////

  final Color? GradientColor, GradientColor2;
  final Color? ButtonColor;
  final Color? IconColor;
  final BoxShape? BoxShape1;

  LinearGradient get Gradiant => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          GradientColor!,
          GradientColor2!,
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Height,
      width: Width,
      decoration: (ButtonBackground != null)
          ? BoxDecoration(
              color: ButtonBackground,
              borderRadius: BorderRadius.circular(ButtonRadius ?? 0),
              border: CustomOulinedButton.outlineBorder(),
            )
          : (BoxShape1 == null)
              ? BoxDecoration(
                  gradient: Gradiant,
                  borderRadius: BorderRadius.circular(ButtonRadius ?? 0),
                  border: CustomOulinedButton.outlineBorder(),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0x0d202020),
                        offset: Offset(0, 7),
                        blurRadius: 25,
                        spreadRadius: 0)
                  ],
                )
              : BoxDecoration(
                  gradient: Gradiant,
                  shape: BoxShape1!,
                  border: CustomOulinedButton.outlineBorder(),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0x0d202020),
                        offset: Offset(0, 7),
                        blurRadius: 25,
                        spreadRadius: 0)
                  ],
                ),
      child: Center(
        child: InkWell(
          onTap: onPress,
          child: (Icon!.substring(Icon!.length - 3, Icon!.length) == 'png')
              ? Image.asset(
                  Icon!,
                  width: IconWidth,
                  height: IconHeight,
                  color: IconColor,
                )
              : SvgPicture.asset(
                  Icon!,
                  width: IconWidth,
                  height: IconHeight,
                  color: IconColor,
                ),
        ),
      ),
    );
  }
}
