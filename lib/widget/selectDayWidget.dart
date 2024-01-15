import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';

class SelectDay extends StatefulWidget {
  final GroceryUser consultant;

  SelectDay({required this.consultant});

  @override
  _ConsultTimeWidgetState createState() => _ConsultTimeWidgetState();
}

class _ConsultTimeWidgetState extends State<SelectDay>
    with SingleTickerProviderStateMixin {
  List<String> daysList = [];

  bool selected = false, loadInterest = true;
  String languages = "",
      workDays = "",
      workDaysValue = "",
      from = "",
      to = "",
      lang = "";
  int selectDayIndex = -1;
  String? days;

  onSelectDays(int index) {
    setState(() {
      selectDayIndex = index;
      days = daysList[index];
    });
  }


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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h56.h
                : AppSize.h36.h,
          ),

          //days
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(
                right:(kIsWeb || size.width >= AppConstants.kIsWebValue)? AppPadding.p138.w:AppPadding.p10_6.w,
                left:(kIsWeb || size.width >= AppConstants.kIsWebValue)? AppPadding.p138.w: AppPadding.p10_6.w,
                top: AppPadding.p5_3.h,
                bottom:(kIsWeb || size.width >= AppConstants.kIsWebValue)? AppPadding.p95.w:  AppPadding.p5_3.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 3 : 3,
              childAspectRatio:
              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 3 : 2,
              mainAxisSpacing: (kIsWeb || size.width >= AppConstants.kIsWebValue) ?48.h:6.5.h,
              crossAxisSpacing:(kIsWeb || size.width >= AppConstants.kIsWebValue) ? 48.w:21.5.w,
            ),
            shrinkWrap: true,
            itemCount: daysList.length - 1,
            itemBuilder: (BuildContext context, int index) {
              return Center(
                child: InkWell(
                  onTap: (){
                    setState(() {
                      onSelectDays(index);
                    });
                  },
                  child: Container(
                    //pb width from 82.6 to 92.6 due to text pb
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w250.w
                        : lang == "ar"?AppSize.w120.w:AppSize.w150.w,
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h95.h
                        : AppSize.h52_6.h,
                    decoration: BoxDecoration(
                      color:selectDayIndex !=index ?AppColors.white:AppColors.linear2 ,
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r12.r
                              : AppRadius.r5_3.r),
                      border: Border.all(
                        width: selectDayIndex != null &&
                            selectDayIndex == index
                            ? AppSize.w0_9
                            : AppSize.h0_5,
                        color: selectDayIndex != null &&
                            selectDayIndex == index
                            ? AppColors.white
                            : AppColors.linear1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        daysList[index],
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color:selectDayIndex !=index ?AppColors.linear2:AppColors.white ,
                          fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s32.sp
                              : AppFontsSizeManager.s18_6.sp,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h56.h
                : AppSize.h21_3.h,
          ),

        ],
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
