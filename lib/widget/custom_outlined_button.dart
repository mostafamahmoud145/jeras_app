import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_constat.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../controller/blocs/replace_video_bloc/cubit.dart';
import '../localization/localization_methods.dart';

class CustomOulinedButton extends StatelessWidget {
  String lang = "";

  CustomOulinedButton({
    super.key,
    this.color,
    this.borderColor,
    this.iconData,
    this.image,
    this.size,
    required this.onPress,
    this.loading = false,
  });

  final Color? color;

  final Color? borderColor;

  final IconData? iconData;

  final String? image;

  final double? size;

  final Function() onPress;

  final bool loading;

  static Border outlineBorder([Color? borderColor]) => Border.all(
      color: borderColor ?? AppColors.borderLightGrey, width: AppSize.w0_8);

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return InkWell(
      onTap: () {
        image == null ? Navigator.pop(context) : onPress;
        if (VideoCubit.get(context).replaceVidController != null) {
          VideoCubit.get(context).replaceVidController!.dispose();
        }
      },
      child: Container(
        height: (kIsWeb || _size.width >= AppConstants.kIsWebValue)
            ? AppSize.h75.r
            : AppSize.h50_6.h,
        width: (kIsWeb || _size.width >= AppConstants.kIsWebValue)
            ? AppSize.w75.r
            : AppSize.w50_6.w,
        decoration: decoration(_size),
        child: Center(
          child: Image.asset(
            lang == "ar"
                ? AssetsManager.newBackArrow
                : AssetsManager.newBackArrow2,
            width:
                (kIsWeb && _size.width > 400) ? AppSize.w40.r : AppSize.w32.r,
            height:
                (kIsWeb && _size.width > 400) ? AppSize.h40.r : AppSize.w32.r,
            color: (kIsWeb && _size.width > 400)
                ? AppColors.black
                : AppColors.primaryColor,
          ),
        ),
      ),
    );
  }

  BoxDecoration decoration(Size size) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppRadius.r20
              : AppRadius.r8),
      border: CustomOulinedButton.outlineBorder(),
      // boxShadow: [
      //   BoxShadow(
      //     color: Color.fromRGBO(123, 108, 150, 0.18),
      //     blurRadius: 8.0,
      //     spreadRadius: 0.0,
      //     offset: Offset(0.0, 1.0),
      //   )
      // ],
    );
  }
}
