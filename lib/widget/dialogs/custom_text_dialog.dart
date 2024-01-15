
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';



customTextDialog({
  required context ,
  required String text,
  String? title,
  required String buttonText,
  double textSize= AppFontsSizeManager.s21_3,
  required Function okFunction,
}) {
  return showDialog(
    builder: (context) => JerasDialogWidget(
      dialogContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  AssetsManager.cancel2,
                  width: 32.w,
                  height: 32.h,
                ),
              ),
              // SizedBox(width: 140.w),
              Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Image.asset(
                  AssetsManager.logoIconPath,
                  width: AppSize.h68.r,
                  // height: 53.5.r,
                ),
              ),
              SizedBox(),
            ],
          ),
          SizedBox(height: AppSize.h16.h),
          if(title!=null)
            Text(
              title,
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                fontSize: AppFontsSizeManager.s32.sp,
                color: AppColors.linear2,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
              ),
            ),
          SizedBox(height: AppSize.h16.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithralight'),
              fontSize: textSize.sp,
              color: AppColors.black4,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.normal,
            ),
          ),
          SizedBox(
            height: AppSize.h32.h,
          ),
          InkWell(
            onTap: () async {
              okFunction();
            },
            child: Container(
              width: 160.w,
              height: 56.h,
              //   alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.linear2,
                borderRadius:
                BorderRadius.circular(AppRadius.r10_6.r),
              ),
              child: Center(
                child: Text(
                  buttonText,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithra'),
                    fontSize: AppFontsSizeManager.s18_6.sp,
                    color: AppColors.white,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    barrierDismissible: false,
    context: context,
  );
}

