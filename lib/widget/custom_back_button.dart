import 'package:flutter/material.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/custom_outlined_button.dart';
import 'package:jeras/widget/responsive.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.color, this.borderColor});

  final Color? color;

  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return CustomOulinedButton(
      onPress: Navigator.of(context).pop,
      iconData: Icons.arrow_back_ios,
      color: color ?? AppColors.pink,
      size: convertPtToPx(AppSize.w38.w),
      borderColor: borderColor ?? Colors.transparent,
    );
  }
}
