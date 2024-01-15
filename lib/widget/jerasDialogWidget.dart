import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/responsive.dart';

class JerasDialogWidget extends StatelessWidget {
  String lang = 'ar';
  Widget dialogContent;
  double? radius;
  double? padTop;
  double? padReight;
  double? padLeft;
  double? padButtom;

  JerasDialogWidget({
    required this.dialogContent,
    this.radius,
    this.padTop,
    this.padReight,
    this.padLeft,
    this.padButtom,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      contentTextStyle: TextStyle(
        fontFamily: lang == "ar"
            ? getTranslated(context, 'Ithra')
            : getTranslated(context, 'Montserrat'),
      ),
      contentPadding: EdgeInsets.only(
        right: padReight != null ? padReight! : AppPadding.p21_3.w,
        left: padLeft != null ? padLeft! : AppPadding.p38_6.w,
        top: padTop != null ? padTop! : AppPadding.p38_6.w,
        bottom: padButtom != null ? padButtom! : AppPadding.p21_3.h,
      ),
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? BorderRadius.all(
                Radius.circular(radius == null ? AppRadius.r35.r : radius!))
            : BorderRadius.all(
                Radius.circular(AppRadius.r21_3.r),
              ),
      ),
      scrollable: true,
      elevation: 0.0,
      content: (kIsWeb) ? dialogContent : dialogContent,
    );
  }
}
