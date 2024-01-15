import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/screens/course/editCourseScreen.dart';
import 'package:jeras/widget/component/textWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../models/courses.dart';
import '../models/user.dart';
import '../screens/courseDetailsScreen.dart';

class CourseItem extends StatefulWidget {
  Courses course;
  GroceryUser? loggedUser;
  String? userType;
  double? width;

  CourseItem(
      {Key? key,
      required this.course,
      this.loggedUser,
      this.userType,
      this.width})
      : super(key: key);

  @override
  State<CourseItem> createState() => _CourseItemState();
}

class _CourseItemState extends State<CourseItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Container(
          width: widget.width ?? AppSize.w456.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppRadius.r50.r
                    : AppRadius.r33.r),
          ),
          child: Image.asset(
            AssetsManager.coursesCart,
            fit: BoxFit.fill,
          ),
        ),
        Container(
          width: widget.width ?? AppSize.w456.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppRadius.r50.r
                    : AppRadius.r33.r),
            image: DecorationImage(
                image: AssetImage(AssetsManager.coursesCart), fit: BoxFit.fill),
            gradient: LinearGradient(
              end: Alignment(0.5, 0),
              begin: Alignment(0.0, 7),
              colors: [
                AppColors.linear1.withOpacity(0.05),
                AppColors.linear1.withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: checkIfWeb(context)
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: size.width >= 500 ? AppSize.h20.h : AppSize.h26_6.h,
              ),
              Expanded(
                flex: 2,
                child: GradientText(
                  widget.course.name,
                  textAlign:
                      checkIfWeb(context) ? TextAlign.center : TextAlign.start,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: size.width >= 500
                          ? AppFontsSizeManager.s38.sp
                          : AppFontsSizeManager.s24.sp,
                      fontFamily: "Bukra",
                      fontWeight: FontWeight.bold),
                  // gradientType: GradientType.radial,
                  radius: 2.5,
                  colors: const [
                    Color.fromRGBO(246, 195, 75, 1),
                    AppColors.primaryColor,
                  ],
                ),
              ),
              SizedBox(
                height: checkIfWeb(context) ? AppSize.h32.h : AppSize.h5_3.h,
              ),
              SmoothStarRating(
                allowHalfRating: true,
                starCount: 5,
                rating: 4,
                size: AppSize.w18_6.r,
                color: AppColors.yellow,
                borderColor: AppColors.yellow,
                spacing: 1.0,
              ),
              SizedBox(
                height: checkIfWeb(context) ? AppSize.h32.h : AppSize.h23.h,
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSize.w67_3.w),
                  child: TextWidget(
                    text: widget.course.summary!,
                    color: AppColors.primaryColor,
                    size: size.width >= 500
                        ? AppFontsSizeManager.s24.sp
                        : AppFontsSizeManager.s13_3.sp,
                    weight: AppFontsWeightManager.bold500,
                    lines: 2,
                    family: "Bukra",
                    align: checkIfWeb(context)
                        ? TextAlign.center
                        : TextAlign.start,
                  ),
                ),
              ),
              // SizedBox(
              //   height: AppSize.h16.h,
              // ),

              Container(
                width: AppSize.w186_6.w,
                child: MaterialButton(
                  color: AppColors.primaryColor,
                  height: checkIfWeb(context) ? AppSize.h73_3.r : AppSize.h48.h,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                    checkIfWeb(context)
                        ? AppRadius.r8.r
                        : convertPtToPx(AppRadius.r4),
                  )),
                  onPressed: () {
                    if (widget.loggedUser != null &&
                        widget.loggedUser!.userType == "CONSULTANT" &&
                        widget.loggedUser!.isSupervisor == true)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditCourseScreen(
                            course: widget.course,
                          ),
                        ),
                      );
                    else
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(
                              name:
                                  'courses?course_id=${widget.course.courseId}',
                              arguments: {"course_id": widget.course.courseId}),
                          builder: (context) => CourseDetailScreen(
                            courseId: '${widget.course.courseId}',
                          ),
                        ),
                      );
                  },
                  child: TextWidget(
                    text: getTranslated(context, 'knowMore'),
                    color: Colors.white,
                    size: size.width >= 500
                        ? AppFontsSizeManager.s24.sp
                        : AppFontsSizeManager.s16.sp,
                    weight: FontWeight.bold,
                    lines: 1,
                    family: "Bukra",
                    align: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: checkIfWeb(context) ? AppSize.h32.h : AppSize.h26_6.h,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
