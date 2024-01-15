import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/widget/responsive.dart';

import '../Utils/styles.dart';
import '../config/app_values.dart';
import '../models/courseRate.dart';

class RateItem extends StatelessWidget {
  CourseRate courseRate;
  final bool isFinalOne;
  RateItem({Key? key, required this.courseRate, required this.isFinalOne})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p20, vertical: AppPadding.p20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: size.width * AppSize.w0_9,
            child: Row(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: AppColors.moveColor2,
                      borderRadius: BorderRadius.circular(AppRadius.r30.r)),
                  width: AppSize.w35.w,
                  height: AppSize.h35.h,
                  child: Icon(
                    Icons.person_outlined,
                    color: AppColors.pink,
                    size: AppSize.w15,
                  ),
                ),
                SizedBox(width: AppSize.w10.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${courseRate.name}",
                      style: Styles.getTextStyle(
                        color: AppColors.black1,
                        fontSize: AppFontsSizeManager.s12.sp,
                      ),
                    ),
                    Container(
                        width: AppSize.w230.w,
                        height: AppSize.h35.h,
                        child: Text(
                          maxLines: 2,
                          "${courseRate.desc}",
                          style: Styles.getTextStyle(
                            color: AppColors.grey,
                            fontSize: AppFontsSizeManager.s11.sp,
                          ),
                        )),
                  ],
                ),
                SizedBox(
                  width: AppSize.w10.w,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: AppColors.yellow,
                      size: AppSize.w10,
                    ),
                    SizedBox(
                       width: AppSize.w5.w,
                    ),
                    Text(
                      "${courseRate.rate}",
                      style: Styles.getTextStyle(
                          color: AppColors.lightGrey1, fontSize: AppFontsSizeManager.s13.sp),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: AppSize.h5.h,
          ),
          if (!isFinalOne)
            Container(
              height: AppSize.h1.h,
              width: size.width * AppSize.w0_8,
              color: AppColors.lightGrey1,
            )
        ],
      ),
    );
  }
}
