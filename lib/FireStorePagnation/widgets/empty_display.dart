import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/responsive.dart';

class EmptyDisplay extends StatelessWidget {
  const EmptyDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Align(
        alignment: Alignment.center,
        child: Column(
          children: [
            SizedBox(
              height: AppSize.h260.h,
            ),
            SvgPicture.asset(
              AssetsManager.searchIcon,
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w50_6.r
                  : AppSize.w48.w,
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h50_6.r
                  : AppSize.h48.h,
            ),
            SizedBox(height: AppSize.h16.h),
            Text(
              getTranslated(context, "noResultsSearch"),
              style: TextStyle(
                  color: AppColors.grey,
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s26_6.sp),
            ),
          ],
        ));
  }
}
