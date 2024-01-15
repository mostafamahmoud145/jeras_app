import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_shadow.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/assets_manager.dart';

class ConsultTimeWidget extends StatefulWidget {
  final GroceryUser consultant;

  ConsultTimeWidget({required this.consultant});

  @override
  _ConsultTimeWidgetState createState() => _ConsultTimeWidgetState();
}

class _ConsultTimeWidgetState extends State<ConsultTimeWidget>
    with SingleTickerProviderStateMixin {
  List<String> daysList = [];

  bool selected = false, loadInterest = true;
  String languages = "",
      workDays = "",
      workDaysValue = "",
      from = "",
      to = "",
      lang = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    if (widget.consultant.workDays!.length > 0) {
      workDays = "";
      if (widget.consultant.workDays!.contains("1")) {
        workDays = workDays + getTranslated(context, "monday") + " , ";
      }
      if (widget.consultant.workDays!.contains("2")) {
        workDays = workDays + getTranslated(context, "tuesday") + " , ";
      }
      if (widget.consultant.workDays!.contains("3")) {
        workDays = workDays + getTranslated(context, "wednesday") + " , ";
      }
      if (widget.consultant.workDays!.contains("4")) {
        workDays = workDays + getTranslated(context, "thursday") + " , ";
      }
      if (widget.consultant.workDays!.contains("5")) {
        workDays = workDays + getTranslated(context, "friday") + " , ";
      }
      if (widget.consultant.workDays!.contains("6")) {
        workDays = workDays + getTranslated(context, "saturday") + " , ";
      }
      if (widget.consultant.workDays!.contains("7")) {
        workDays = workDays + getTranslated(context, "sunday");
      }
      setState(() {
        workDaysValue = "";
        workDaysValue = workDays;
        daysList = workDaysValue.split(',');
      });
    }
    var localFrom = DateTime.parse(widget.consultant.fromUtc!).toLocal().hour;
    var localTo = DateTime.parse(widget.consultant.toUtc!).toLocal().hour;
    if (localTo == 0) localTo = 24;
    if (widget.consultant.workTimes!.length > 0) {
      if (localFrom == 12)
        from = "12.00 ${getTranslated(context, 'pm')}";
      else if (localFrom == 0)
        from = "12.00 ${getTranslated(context, 'am')}";
      else if (localFrom > 12)
        from = ((localFrom) - 12).toString() +
            ".00 ${getTranslated(context, 'pm')}";
      else
        from = (localFrom).toString() + ".00 ${getTranslated(context, 'am')}";
    }
    if (widget.consultant.workTimes!.length > 0) {
      if (localTo == 12)
        to = "12.00 ${getTranslated(context, 'pm')}";
      else if (localTo == 0 || localTo == 24)
        to = "12.00 ${getTranslated(context, 'am')}";
      else if (localTo > 12)
        to =
            ((localTo) - 12).toString() + ".00 ${getTranslated(context, 'pm')}";
      else
        to = (localTo).toString() + " ${getTranslated(context, 'am')}";
    }
    return (kIsWeb || size.width >= AppConstants.kIsWebValue)
        ? Center(
            child: Container(
              padding: EdgeInsets.only(
                  top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppPadding.p30.h
                      : 0),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? Border.all(color: AppColors.white, width: AppSize.w2.w)
                    : null,
                boxShadow: [
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppShadow.greyshadow
                      : AppShadow.fabshadow
                ],
                borderRadius: BorderRadius.circular(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppRadius.r50.r
                        : AppRadius.r5.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: AppPadding.p10),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r8.r
                                : AppRadius.r5.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: AppSize.h79.h,
                            width: AppSize.w116.w,
                            decoration: BoxDecoration(
                                boxShadow: [
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppShadow.fabshadow
                                      : AppShadow.fabshadow
                                ],
                                color: AppColors.white,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r25.r)),
                            child: Center(
                              child: SvgPicture.asset(
                                AssetsManager.calendarClockIconPath,
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h42.r
                                    : AppSize.h21_3.h,
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w42.r
                                    : AppSize.w21_3.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h54.h
                        : AppSize.h36.h,
                  ),

                  //days
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p80.w),
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 5
                                : 3,
                        childAspectRatio:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 3
                                : 2,
                        mainAxisSpacing: 6.5.h,
                        crossAxisSpacing: 1.w,
                      ),
                      shrinkWrap: true,
                      itemCount: daysList.length - 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  daysList[index],
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.black,
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s18_6.sp,
                                    fontWeight: AppFontsWeightManager.normal,
                                  ),
                                ),
                              ),
                              Text(",")
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h62.h
                        : AppSize.h21_3.h,
                  ),

                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: AppPadding.p130.w),
                    child: Container(
                      width: AppSize.w438.w,
                      height: AppSize.h91.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r10.r),
                        border: Border.all(
                          color: AppColors.grey2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SvgPicture.asset(AssetsManager.clockIconPath,
                          //     color: AppColors.primaryColor),
                          // SizedBox(
                          //   width: AppRadius.r13.w,
                          // ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Text(
                              //   getTranslated(context, "from"),
                              //   textAlign: TextAlign.center,
                              //   maxLines: 3,
                              //   style: TextStyle(
                              //     fontFamily: getTranslated(context, "Ithra"),
                              //     color: AppColors.grey,
                              //     fontSize: (kIsWeb ||
                              //             size.width >=
                              //                 AppConstants.kIsWebValue)
                              //         ? AppFontsSizeManager.s29.sp
                              //         : AppFontsSizeManager.s17.sp,
                              //     fontWeight: FontWeight.normal,
                              //     letterSpacing: AppConstants.letterSpacing0_5,
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: AppSize.w3.w,
                              // ),
                              Text(
                                "$from - ",
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.grey,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s29.sp
                                      : AppFontsSizeManager.s17.sp,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                              ),
                              // Text(
                              //   getTranslated(context, "to2"),
                              //   textAlign: TextAlign.center,
                              //   maxLines: 3,
                              //   style: TextStyle(
                              //     fontFamily: getTranslated(context, "Ithra"),
                              //     color: AppColors.grey,
                              //     fontSize: (kIsWeb ||
                              //             size.width >=
                              //                 AppConstants.kIsWebValue)
                              //         ? AppFontsSizeManager.s29.sp
                              //         : AppFontsSizeManager.s17.sp,
                              //     fontWeight: FontWeight.normal,
                              //     letterSpacing: AppConstants.letterSpacing0_5,
                              //   ),
                              // ),
                              // SizedBox(
                              //   width: AppSize.w3.w,
                              // ),
                              Text(
                                to,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.grey,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s29.sp
                                      : AppFontsSizeManager.s17.sp,
                                  fontWeight: FontWeight.normal,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h57.h
                        : AppSize.h41_3.h,
                  ),
                ],
              ),
            ),
          )
        : Center(
            child: Container(
              width: size.width * .9,
              padding: const EdgeInsets.only(
                  top: AppPadding.p10,
                  bottom: AppPadding.p15,
                  left: AppPadding.p35,
                  right: AppPadding.p35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppRadius.r72.r
                        : AppRadius.r28.r),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      // height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      //     ? AppSize.h66.h
                      //     : AppSize.h48.h,
                      // width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      //     ? 351.w
                      //     : lang == "ar"?AppSize.w300.w:AppSize.w357,
                      padding: EdgeInsets.symmetric(vertical: AppPadding.p10),
                      decoration: BoxDecoration(
                        color: AppColors.grey4,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r8.r
                                : AppRadius.r5.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getTranslated(context, 'AppointmentsAvailable'),
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.black,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(
                            width: AppSize.w10_6.w,
                          ),
                          Center(
                            child: SvgPicture.asset(
                              AssetsManager.calendarClockIconPath,
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h42.r
                                  : AppSize.h21_3.h,
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w42.r
                                  : AppSize.w21_3.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h56.h
                        : AppSize.h36.h,
                  ),

                  //days
                  GridView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(
                        right: AppPadding.p10_6.w,
                        left: AppPadding.p10_6.w,
                        top: AppPadding.p5_3.h,
                        bottom: AppPadding.p5_3.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 2
                              : 3,
                      childAspectRatio:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 3
                              : 2,
                      mainAxisSpacing: 6.5.h,
                      crossAxisSpacing: 8.w,
                    ),
                    shrinkWrap: true,
                    itemCount: daysList.length - 1,
                    itemBuilder: (BuildContext context, int index) {
                      return Row(
                        children: [
                          SvgPicture.asset(
                            AssetsManager.roundCheckIconPath,
                            width: AppSize.w21.w,
                            height: AppSize.h21.h,
                          ),
                          Text(
                            daysList[index],
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.primaryColor,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s24.sp
                                  : AppFontsSizeManager.s18_6.sp,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h56.h
                        : AppSize.h21_3.h,
                  ),

                  Container(
                    // width: AppSize.w342_6.w,
                    // height: AppSize.h53_3.h,
                    padding: EdgeInsets.all(AppPadding.p10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
                      border: Border.all(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AssetsManager.clockIconPath,
                            color: AppColors.primaryColor),
                        SizedBox(
                          width: AppRadius.r13.w,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "from"),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.primaryColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s24.sp
                                    : AppFontsSizeManager.s17.sp,
                                fontWeight: FontWeight.normal,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w3.w,
                            ),
                            Text(
                              "$from - ",
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.primaryColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s24.sp
                                    : AppFontsSizeManager.s17.sp,
                                fontWeight: FontWeight.normal,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                            ),
                            Text(
                              getTranslated(context, "to2"),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.primaryColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s24.sp
                                    : AppFontsSizeManager.s17.sp,
                                fontWeight: FontWeight.normal,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w3.w,
                            ),
                            Text(
                              to,
                              textAlign: TextAlign.center,
                              maxLines: 3,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.primaryColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s24.sp
                                    : AppFontsSizeManager.s17.sp,
                                fontWeight: FontWeight.normal,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h57.h
                        : AppSize.h41_3.h,
                  ),
                ],
              ),
            ),
          );
  }

  BoxShadow shadow() {
    return BoxShadow(
      color: AppColors.lightGrey,
      blurRadius:
          kIsWeb || (MediaQuery.of(context).size.width >= 500) ? 23 : 2.0,
      spreadRadius: 0.0,
      offset: Offset(
          0.0,
          kIsWeb || (MediaQuery.of(context).size.width >= 500)
              ? 3
              : 1.0), // shadow direction: bottom right
    );
  }
}
