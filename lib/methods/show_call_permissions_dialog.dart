

import 'package:flutter/material.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../localization/localization_methods.dart';

showPermissionsDialog({
  required context,
  required String text,
  required String buttonTitle,
  required Function function,
  required Function refusedFunction}) {
  return showDialog(
    context: context,
    builder:  (context) =>
        JerasDialogWidget(
          dialogContent: Padding(
            padding: EdgeInsets.only(right: AppPadding.p10_6.w),
            child: Column(
              children: [
                SizedBox(height: AppSize.h32_6.h),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.normal,
                    fontFamily: getTranslated(context, 'Ithra'),
                    color: AppColors.black1,
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    //fontSize: checkIfWeb(context)? 30.sp: convertPtToPx(14.sp),
                  ),
                ),
                SizedBox(
                  height: AppSize.h64_6.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () async{
                        //if(await checkCallPermissions(context)){
                        function();
                      },
                      child:Container(
                        width: AppSize.w160.w,
                        height:AppSize.h56.h,
                        //   alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color:AppColors.linear2,
                          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                        ),
                        child:Center(
                          child: Text(
                            buttonTitle,
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
                    Spacer(),
                    InkWell(
                      onTap: () async{
                        refusedFunction();
                      },
                      child:Container(
                        width: AppSize.w160.w,
                        height:AppSize.h56.h,
                        //   alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(AppRadius.r10_6.r)
                            ),
                            border: Border.all(
                              color: AppColors.linear2,
                              width: 1.5.w,
                            )
                        ),
                        child:Center(
                          child: Text(
                            getTranslated(context, 'cancel'),
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              fontSize: AppFontsSizeManager.s18_6.sp,
                              color: AppColors.linear2,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
  );
}

