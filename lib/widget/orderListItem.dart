import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:timelines/timelines.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/order.dart';
import '../../screens/orderDetailsScreen.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../methods/check_if_web.dart';
import '../methods/convert_pt_to_px.dart';

class OrderListItem extends StatelessWidget {
  final Orders order;
  final String? type;
  final String? theme;
  final bool? fromSupport;
  String lang = "";
  OrderListItem({required this.order, this.type, this.theme, this.fromSupport});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    return Column(
      children: [
        Container( 
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppRadius.r50.r
                    : AppRadius.r35.r),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  offset: checkIfWeb(context)
                      ? Offset(0, 1.r)
                      : Offset(0, convertPtToPx(3.r)),
                  blurRadius: checkIfWeb(context) ? 3 : convertPtToPx(5.r),
                  spreadRadius: 0)
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(          
            top:  AppPadding.p21_3.r,
            right: AppPadding.p26_5.r,
            left: AppPadding.p26_5.r,
            bottom:   AppPadding.p28.r,
            ),
            child: Column(
              children: [
              
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsManager.calendarClockIconPath,
                      color: AppColors.primaryColor,
                      width: checkIfWeb(context)
                          ? AppSize.w20.w
                          : convertPtToPx(AppSize.w16.w),
                      height: checkIfWeb(context)
                          ? AppSize.h20.w
                          : convertPtToPx(AppSize.h16.w),
                    ),
                    SizedBox(
                      width: AppSize.w8.w,
                    ),
                    Text(
                      '${dateFormat.format(order.orderTimestamp.toDate())}',
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, "Montserratmedium"),
                        color: theme == "light"
                            ? checkIfWeb(context)
                                ? AppColors.primaryColor
                                : AppColors.grey1
                            : AppColors.white,
                        fontSize: (kIsWeb ||
                                size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s20.sp
                            : convertPtToPx(AppFontsSizeManager.s14.sp),
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          checkIfWeb(context) ? AppPadding.p30.w : 0.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: AppSize.h24.h,
                      ),
            
                      /// teacher name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              type != "USER"
                                  ? order.user.name!
                                  : order.consult.name!,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: "NotoKufiArabic-SemiBold",
                                color: theme == "light"
                                    ? AppColors.primaryColor
                                    : AppColors.white,
                                fontSize: (kIsWeb ||
                                        size.width >=
                                            AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s24.sp
                                    : convertPtToPx(
                                        AppFontsSizeManager.s16.sp),
                                fontWeight: FontWeight.bold,
                                letterSpacing:
                                    AppConstants.letterSpacing0_3,
                              )),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderDetails(
                                    order: order,
                                    type: type,
                                    fromSupport: fromSupport,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Text(getTranslated(context, 'Details'),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:"NotoKufiArabic-Regular",
                                      color: theme == "light"
                                          ? AppColors.primaryColor
                                          : AppColors.white,
                                      fontSize: checkIfWeb(context)
                                          ? AppFontsSizeManager.s20.sp
                                          : convertPtToPx(
                                              AppFontsSizeManager.s14.sp),
                                      fontWeight: FontWeight.normal,
                                    )),
                                    SizedBox(width: AppSize.w10_6.w,),
                                 SvgPicture.asset(
                                  AssetsManager.roundIosArrow,
                                  color: AppColors.primaryColor,
                                  width: checkIfWeb(context)
                                      ? AppSize.w22.w
                                      : AppSize.w21_3.w,
                                      height: checkIfWeb(context)
                                      ? AppSize.w22.w
                                      : AppSize.w21_3.w,
                                
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSize.h24.h,
                      ),
            
                      /// first row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              DotIndicator(
                                color: AppColors.pink,
                                size: AppSize.w21_3.w,
                              ),
                              SizedBox(
                                width: AppSize.w20.w,
                              ),
                              Text(
                                getTranslated(context, "packageCall"),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily:
                                      "NotoKufiArabic-Regular",
                                  color: theme == "light"
                                      ? AppColors.blackColor
                                      : AppColors.white,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s24.sp
                                      : convertPtToPx(
                                          AppFontsSizeManager.s16.sp),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: AppPadding.p16.w),
                            child: Text(order.packageCallNum.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: getTranslated(
                                      context, "Montserratbold"),
                                  color: theme == "light"
                                      ? AppColors.primaryColor
                                      : AppColors.white,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s20.sp
                                      : convertPtToPx(
                                          AppFontsSizeManager.s16.sp),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing:
                                      AppConstants.letterSpacing0_3,
                                )),
                          ),
                        ],
                      ),
            
                      SizedBox(
                        height: AppSize.h20.h,
                        child: Row(
                          children: [
                            SizedBox(width: AppSize.w6.w,),
                            SizedBox(
                              width: AppSize.w11.w,
                              child: Center(
                                child: SolidLineConnector(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      /// second row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: AppSize.w20.w,
                                height: AppSize.h20.h,
                                decoration: BoxDecoration(
                                  //  border: Border.all(color: AppColors.pink,width: 5),
                                  shape: BoxShape.rectangle,
                                  color: Colors.transparent,
                                ),
                                child:  SvgPicture.asset(
                                  AssetsManager.allDone,
                                  color: Colors.lightGreen,
                                  width: AppSize.w21_3.w,
                                  height: AppSize.w21_3.w,
                                ),
                              ),
                              SizedBox(
                                width: AppSize.w10.w,
                              ),
                              Text(
                                getTranslated(context, "answeredCall"),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily:
                                      "NotoKufiArabic-Regular",
                                  color: theme == "light"
                                      ? AppColors.blackColor
                                      : AppColors.white,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s24.sp
                                      : convertPtToPx(
                                          AppFontsSizeManager.s16.sp),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: AppPadding.p16.w),
                            child: Text(order.answeredCallNum.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: getTranslated(
                                      context, "Montserratbold"),
                                  color: theme == "light"
                                      ? AppColors.primaryColor
                                      : AppColors.white,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s20.sp
                                      : convertPtToPx(
                                          AppFontsSizeManager.s16.sp),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing:
                                      AppConstants.letterSpacing0_3,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSize.h5.h,
                      ),
                      SizedBox(
                        height: AppSize.h20.h,
                        child: Row(
                          children: [
                            SizedBox(width: AppSize.w6.w,),
                            SizedBox(
                              width: AppSize.w11.w,
                              child: Center(
                                child: SolidLineConnector(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
            
                      /// third row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              DotIndicator(
                                color: AppColors.red,
                                size: AppSize.w21_3.w,
                              ),
                              SizedBox(
                                width: AppSize.w10.w,
                              ),
                              Text(
                                getTranslated(context, "remainingCall"),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily:
                                      "NotoKufiArabic-Regular",
                                  color: theme == "light"
                                      ? AppColors.blackColor
                                      : AppColors.white,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s24.sp
                                      : convertPtToPx(
                                          AppFontsSizeManager.s16.sp),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(left: AppPadding.p16.w),
                            child: Text(order.remainingCallNum.toString(),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: getTranslated(
                                      context, "Montserratbold"),
                                  color: theme == "light"
                                      ? AppColors.primaryColor
                                      : AppColors.white,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s20.sp
                                      : convertPtToPx(
                                          AppFontsSizeManager.s16.sp),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing:
                                      AppConstants.letterSpacing0_3,
                                )),
                          ),
                        ],
                      ),
            
                      SizedBox(
                        height: AppSize.h20.h,
                      ),
            
                      /// fourth row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding:
                                EdgeInsets.only(right: AppPadding.p16.w),
                            child: Text(
                              getTranslated(context, "callprice"),
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily:
                                    "NotoKufiArabic-SemiBold",
                                color: theme == "light"
                                    ? AppColors.primaryColor
                                    : AppColors.white,
                                fontSize: (kIsWeb ||
                                        size.width >=
                                            AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s20.sp
                                    : convertPtToPx(
                                        AppFontsSizeManager.s16.sp),
                                fontWeight: AppFontsWeightManager.bold500,
                              ),
                            ),
                          ),
        
                          Card(
            
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: AppColors.pink,
                              ),
            
                              borderRadius: BorderRadius.circular((kIsWeb ||
                                  size.width >=
                                      AppConstants.kIsWebValue)
                                  ? AppRadius.r3.r
                                  : AppRadius.r4.r),//<-- SEE HERE
                            ),
                            child:
                          Container(color: AppColors.white,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w112.w
                                : AppSize.w112.w,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h42_6.h
                                : AppSize.h42_6.h,
                            padding: EdgeInsets.all(AppPadding.p2),
                            // decoration: BoxDecoration(
                            //
                            // ),
                            child: Center(
                              child: Text(
                                (order.price).toString() + "\$",
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: TextStyle(
                                  fontFamily: getTranslated(
                                      context, "Montserratsemibold"),
                                  color: theme == "light"
                                      ? AppColors.primaryColor
                                      : AppColors.primaryColor,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s20.sp
                                      : convertPtToPx(
                                          AppFontsSizeManager.s16.sp),
                                  fontWeight: FontWeight.w600,
                                  letterSpacing:
                                      AppConstants.letterSpacing0_3,
                                ),
                              ),
                            ),
                          ),),
                        ],
                      ),
            
                    ],
                  ),
                ),
                
        
              ],
            ),
          ),
        ),
      SizedBox(height: AppSize.h24.h,)
      ],
    );
  }
}
