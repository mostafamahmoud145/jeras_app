import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/config/paths.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';

import '../Utils/helper.dart';
import '../localization/localization_methods.dart';
import '../models/courses.dart';

class CourseController {
  File? pickedImage;

  Future onPickImage(BuildContext context) async {
    pickedImage = await Helper.pickImage(
      context: context,
    );
  }

  deleteCourseDialoge(BuildContext context, Size size, Courses course) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    AssetsManager.moveCloseIconPath,
                    width: AppSize.w42_6.w,
                    height: AppSize.h42_6.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h22_6.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "DoYouWantDeleteCourse"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h42_6.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          await FirebaseFirestore.instance
                              .collection(Paths.coursesPath)
                              .doc(course.courseId)
                              .delete();

                          /* await FirebaseFirestore.instance
                              .collection("Program")
                              .doc(course.programId)
                              .set({
                            'courseNum': FieldValue.increment(-1),
                            'lessonNum':
                                FieldValue.increment(-course.lessonNum),
                          }, SetOptions(merge: true));*/

                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.linear2,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'delete'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
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
                      //SizedBox(width: AppSize.w57_3.w),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10_6.r)),
                              border: Border.all(
                                color: AppColors.linear2,
                                width: 1.5.w,
                              )),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'cancel'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.linear2,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
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
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
