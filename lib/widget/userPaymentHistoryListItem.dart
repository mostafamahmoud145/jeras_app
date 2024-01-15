import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/TextButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../localization/localization_methods.dart';
import '../../models/userPaymentHistory.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/colors_file.dart';

class UserPaymentHistoryListItem extends StatefulWidget {
  final UserPaymentHistory history;
  final String theme;

  UserPaymentHistoryListItem({required this.history, required this.theme});

  @override
  State<UserPaymentHistoryListItem> createState() =>
      _UserPaymentHistoryListItemState();
}

class _UserPaymentHistoryListItemState
    extends State<UserPaymentHistoryListItem> {
  late String lang;

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    return Directionality(
      textDirection: lang == "ar" ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        // margin: EdgeInsets.only(bottom: 25),
        padding: EdgeInsets.only(
            left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p50.w
                : AppPadding.p30.w,
            right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p50.w
                : AppPadding.p30.w,
            top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p40.h
                : AppPadding.p21_3.h,
            bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p40.h
                : AppPadding.p20.h),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(AppRadius.r23.r)),
            border: Border.all(
              color: AppColors.lightGrey,
              width: 1,
            ),
            color: const Color(0xffffffff)),
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsManager.calendarCheckIconPath,
                      color: AppColors.primaryColor,
                      width: AppSize.w16.w,
                      height: AppSize.h16.h,
                    ),
                    SizedBox(width: AppSize.w5.w),
                    Text(
                      customFormatDate(widget.history.payDateValue, getTranslated(context, "lang")),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: AppFontsWeightManager.bold500,
                        fontFamily: size.width >= 500
                            ? getTranslated(context, "Ithralight")
                            : getTranslated(context, "Ithralight"),
                        fontStyle: FontStyle.normal,
                        fontSize: (kIsWeb || size.width >= 500)
                            ? AppFontsSizeManager.s22.sp
                            : AppFontsSizeManager.s16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: AppSize.w16.w),
                Row(
                  children: [
                    SvgPicture.asset(
                      AssetsManager.clockIconPath,
                      color: AppColors.primaryColor,
                      width: AppSize.w16.w,
                      height: AppSize.h16.h,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      formatTimeWithCustomAmPm(widget.history.payDateValue, getTranslated(context, "lang")),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: AppFontsWeightManager.bold500,
                        fontFamily: size.width >= 500
                            ? getTranslated(context, "Ithralight")
                            : getTranslated(context, "Ithralight"),
                        fontStyle: FontStyle.normal,
                        fontSize: (kIsWeb || size.width >= 500)
                            ? AppFontsSizeManager.s22.sp
                            : AppFontsSizeManager.s16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 28.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xfff3f5f7),
                    ),
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w75.w
                        : AppSize.w53.w,
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h75.h
                        : AppSize.h53_3.h,
                    child: Center(
                      child: widget.history.otherData.image!.isEmpty
                          ? Image.asset(
                              AssetsManager.greyPersonIconPath,
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 30.w
                                  : AppSize.w20.w,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100.0.r),
                              child: FadeInImage.assetNetwork(
                                placeholder: AssetsManager.iconPersonIconPath,
                                placeholderScale: 0.5,
                                imageErrorBuilder:
                                    (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        color: AppColors.black,
                                        size: AppSize.w50),
                                image: widget.history.otherData.image!,
                                fit: BoxFit.cover,
                                fadeInDuration: Duration(
                                    milliseconds: AppConstants.milliseconds250),
                                fadeInCurve: Curves.easeInOut,
                                fadeOutDuration: Duration(
                                    milliseconds: AppConstants.milliseconds150),
                                fadeOutCurve: Curves.easeInOut,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: AppSize.w10_6.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //name
                        Text(
                          widget.history.otherData.name!,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: const Color(0xff202020),
                            fontWeight: AppFontsWeightManager.semiBold,
                            fontFamily: size.width >= 500
                                ? getTranslated(context, "Ithra")
                                : getTranslated(context, "Ithra"),
                            fontStyle: FontStyle.normal,
                            fontSize: (kIsWeb || size.width >= 500)
                                ? AppFontsSizeManager.s32.sp
                                : AppFontsSizeManager.s21_3.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                      width: (kIsWeb || size.width >= 500)
                          ? AppSize.w10_6.w
                          : AppSize.w5.w),
                  //dollar number
                  Text(
                    "\$",
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    maxLines: 1,
                    style: TextStyle(
                        color: const Color(0xff7b6c96),
                        fontWeight: AppFontsWeightManager.semiBold,
                        fontFamily: "Arial",
                        fontStyle: FontStyle.normal,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 23.sp
                                : 21.3.sp),
                  ),
                  Text(
                    double.parse(widget.history.amount.toString())
                        .toStringAsFixed(3),
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    maxLines: 1,
                    style: TextStyle(
                        color: const Color(0xff7b6c96),
                        fontWeight: AppFontsWeightManager.semiBold,
                        fontFamily: size.width >= 500
                            ? getTranslated(context, "Montserratsemibold")
                            : getTranslated(context, "Montserratsemibold"),
                        fontStyle: FontStyle.normal,
                        fontSize:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? 23.sp
                            : 21.3.sp),
                  ),
                ],
              ),
            ),
            SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? 35.h
                    : 28.h),
            //pb
            TextButton1(
              onPress: () {},
              Padding2: 24.w,
              Padding: 8.h,
              Title: widget.history.payType == "send"
                  ? getTranslated(context, "send")
                  : widget.history.payType == "refund"
                      ? getTranslated(context, "refund")
                      : getTranslated(context, "receive"),
              Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w280.w
                  : AppSize.w134_6.w,
              Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h60.h
                  : AppSize.h40.h,
              ButtonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppRadius.r30.r
                  : AppRadius.r5_3.r,
              TextSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s23.sp
                  : AppFontsSizeManager.s18_6.sp,
              TextFont: size.width >= 500
                  ? getTranslated(context, "Ithra")
                  : getTranslated(context, "Ithra"),
              TextColor: Color(0xff00d34f),
              ButtonBackground: Color(0x2412df5f),
            ),
          ],
        ),
      ),
    );

  }

  String customFormatDate(int millisecondsSinceEpoch, String locale) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String year = dateTime.year.toString();
    String day = dateTime.day.toString().padLeft(2, '0');
    String monthName = getMonthName(dateTime.month, locale);

    return "$year $day $monthName";
  }

  String getMonthName(int month, String locale) {
    var months = {
      'ar': ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"],
      'en': ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"],
      'fr': ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"],
      'id': ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"],
    };

    return months[locale]![month - 1];
  }

  String formatTimeWithCustomAmPm(int millisecondsSinceEpoch, String locale) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    String formattedTime = DateFormat.jm().format(dateTime);

    if (locale == 'ar') {
      // Replace AM/PM for Arabic
      return formattedTime
          .replaceAll('AM', 'صباحاً') // Replace with Arabic symbol for AM
          .replaceAll('PM', 'مساءً'); // Replace with Arabic symbol for PM
    } else {
      // For English or any other language, use default AM/PM
      return formattedTime;
    }
  }
}
