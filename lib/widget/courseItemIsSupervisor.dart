import 'package:flutter/material.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/screens/course/editCourseScreen.dart';

import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../models/courses.dart';

class CourseItemIsSupervisor extends StatefulWidget {
  final Courses course;

  CourseItemIsSupervisor({required this.course});

  @override
  State<CourseItemIsSupervisor> createState() => _CourseItemIsSupervisorState();
}

class _CourseItemIsSupervisorState extends State<CourseItemIsSupervisor> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditCourseScreen(
              course: widget.course,
            ),
          ),
        );
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey,
                      spreadRadius: 0.0,
                      blurRadius: 2.0,
                      offset: Offset(0.0, 1.0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(AppRadius.r25),
                ),
                child: ClipRRect(
                  borderRadius:
                  const BorderRadius.all(Radius.circular(AppRadius.r25)),
                  child: FadeInImage.assetNetwork(
                    height: size.height * AppSize.h0_15,
                    width: size.width * AppSize.w0_7,
                    placeholder: AssetsManager.lodeGif,
                    placeholderScale: 0.5,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        Image.asset(AssetsManager.whiteJerasLogoIconPath,
                            width: AppSize.w70, height: AppSize.h70, fit: BoxFit.fill),
                    image: "widget.course.image",
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: AppConstants.milliseconds250),
                    fadeInCurve: Curves.easeInOut,
                    fadeOutDuration: Duration(milliseconds: AppConstants.milliseconds150),
                    fadeOutCurve: Curves.easeInOut,
                  ),
                ),
              ),

            ],
          ),
          SizedBox(
            height: AppSize.h35,
          )
        ],
      ),
    );
  }
}
