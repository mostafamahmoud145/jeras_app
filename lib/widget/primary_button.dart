import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';

import '../config/app_constat.dart';
import '../config/app_fonts.dart';

class PrimaryButton extends StatelessWidget {
  PrimaryButton(
      {super.key,
      required this.onPress,
      required this.text,
      this.width,
      this.height,
      this.textSize,
      this.buttonRadius,
      this.normal = false,
      this.colors = false,
      this.color,
      this.save = false});

  final Function() onPress;

  final String text;
  final double? textSize;
  final double? buttonRadius;
  final double? width;
  final bool? colors;
  bool? normal;
  bool? save;
  Color? color;

  final double? height;
  static LinearGradient get gradiant3 => LinearGradient(
        end: Alignment.topCenter,
        begin: Alignment.bottomCenter,
        colors: [
          AppColors.gradiant1,
          AppColors.gradiant2,
        ],
      );

  static LinearGradient get gradiant => LinearGradient(
        begin: Alignment(-0.026087120175361633, 0.5),
        end: Alignment(1.0575249195098877, 0.5),
        colors: [
          AppColors.linear1,
          AppColors.linear2,
        ],
      );
  static LinearGradient get gradiant2 => LinearGradient(
        //   begin: Alignment(-0.026087120175361633, 0.5),
        //   end: Alignment(1.1, 0.5),
        //   colors: [
        //     AppColors.linear1,
        //     AppColors.linear2,
        //   ],
        // );
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          HexColor("#7b6c96"), // CSS color #7b6c96
          HexColor("#ae9cce"), // CSS color #ae9cce
        ],
        // If you want to specify the stops, uncomment and adjust these
        stops: [1.92, -0.33],
      );
  static LinearGradient get saveGradiant => LinearGradient(
        begin: Alignment(-0.026087120175361633, 0.5),
        end: Alignment(1.1, 0.5),
        colors: [
          AppColors.save2,
          AppColors.save1,
        ],
      );

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: width ?? size.width * AppSize.w0_7,
      height: height ?? 60,
      decoration: BoxDecoration(
          color: color != null ? color! : null,
          borderRadius: BorderRadius.all(Radius.circular(buttonRadius ?? 25)),
          gradient: color != null
              ? null
              :
              //  save == true
              //     ? saveGradiant
              //     :
              gradiant3),
      child: MaterialButton(
        onPressed: onPress,
        // color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius ?? 19),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
            fontWeight: normal == true
                ? AppFontsWeightManager.normal
                : AppFontsWeightManager.bold300,
            fontStyle: FontStyle.normal,
            color: Colors.white,
            fontSize: textSize ?? 15,
            letterSpacing: AppConstants.letterSpacing0_5,
          ),
        ),
      ),
    );
  }
}
