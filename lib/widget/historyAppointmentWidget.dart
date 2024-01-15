import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../screens/AppointmentChatScreen.dart';

class CallHistoryWidget extends StatelessWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  final String theme;
  CallHistoryWidget(
      {required this.appointment,
      required this.loggedUser,
      required this.theme});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String time;
    DateTime localDate =
        DateTime.parse(appointment.appointmentTimestamp.toDate().toString())
            .toLocal();
    if (localDate.hour == 12)
      time = "12:00 Pm";
    else if (localDate.hour == 0)
      time = "12:00 Am";
    else if (localDate.hour > 12)
      time = (localDate.hour - 12).toString() +
          ":"+
          localDate.minute.toString().padLeft(2,"0") +
          " Pm";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString().padLeft(2,"0") +
          " Am";
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p15
                    : AppPadding.p7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppRadius.r40.r
                      : AppRadius.r24.r),
              boxShadow: [
                shadow(),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: AppPadding.p10,
                  right: AppPadding.p10,
                  top: AppPadding.p10,
                  bottom: AppPadding.p2),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            AssetsManager.calendarClockIconPath,
                            width: checkIfWeb(context)
                                ? AppSize.w24.w
                                : convertPtToPx(AppSize.w12),
                            color: AppColors.grey,
                          ),
                          SizedBox(
                            width: checkIfWeb(context)
                                ? AppSize.w32.w
                                : convertPtToPx(AppSize.w4.w),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: AppPadding.p6.w),
                            child: Text(
                              '${appointment.date.year}/${appointment.date.month}/${appointment.date.day}',
                              textAlign: TextAlign.start,
                              textDirection: TextDirection.ltr,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s18_6.sp,
                                fontWeight: AppFontsWeightManager.bold500,
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                              ),
                            ),
                          ),
                        ],
                      ),

                      /// time
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Color.fromRGBO(147, 147, 147, 1.0),
                            size: checkIfWeb(context)
                                ? AppSize.w24.w
                                : convertPtToPx(AppSize.w12),
                          ),
                          SizedBox(
                            width: checkIfWeb(context)
                                ? AppSize.w32.w
                                : convertPtToPx(AppSize.w4.w),
                          ),
                          Text(
                            time,
                            textAlign: TextAlign.start,
                            textDirection: TextDirection.ltr,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              color: Color.fromRGBO(147, 147, 147, 1.0),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s12.sp
                                  : AppFontsSizeManager.s16.sp,
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily: getTranslated(context, "Ithralight"),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: checkIfWeb(context)
                        ? AppSize.h40.h
                        : convertPtToPx(AppSize.h14.h),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: size.width * .43,
                        child: Text(
                          appointment.user.name != null
                              ? appointment.user.name!
                              : appointment.user.phone!,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: getTranslated(context, "Ithra"),
                            fontStyle: FontStyle.normal,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : 21.3.sp,//16 pt
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const Spacer(flex: 2),
                      Container(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w204.w
                                : AppSize.w70,
                        padding: EdgeInsets.symmetric(
                            vertical: AppPadding.p2, horizontal: AppPadding.p6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(
                                (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppRadius.r8.w
                                    : convertPtToPx(AppRadius.r4.w))),
                            border: Border.all(color: AppColors.primaryColor)),
                        child: Center(
                          child: Text(
                            double.parse(appointment.callPrice.toString())
                                    .toStringAsFixed(0) +
                                "\$",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme == "light"
                                  ? Theme.of(context).primaryColor
                                  : AppColors.black,
                              fontWeight: AppFontsWeightManager.semiBold,
                              fontFamily:
                                  getTranslated(context, "Montserratsemibold"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 32.sp
                                  : 18.6.sp,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),

                      /// chat icon.
                      InkWell(
                        splashColor: Colors.green.withOpacity(0.6),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentChatScreen(
                                  appointment: appointment, user: loggedUser),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryColor,
                          ),
                          padding: EdgeInsets.all(7),
                          //e
                          child: SvgPicture.asset(
                            AssetsManager.whiteChat2IconPath,
                            color: Colors.white,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w48.w
                                : convertPtToPx(AppSize.w16.w),
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h48.h
                                : convertPtToPx(AppSize.h16.h),
                          ),
                        ),
                      ),

                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     SizedBox(
                      //       height: AppSize.h20,
                      //     ),
                      //     Container(
                      //       padding: EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10, top: 2),
                      //       decoration: BoxDecoration(
                      //         color: AppColors.white,
                      //         borderRadius: BorderRadius.circular(AppRadius.r15.r),
                      //       ),
                      //       child: InkWell(
                      //         splashColor: Colors.green.withOpacity(0.6),
                      //         onTap: () async {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(
                      //               builder: (context) => AppointmentChatScreen(
                      //                   appointment: appointment, user: loggedUser),
                      //             ),
                      //           );
                      //         },
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Stack(
                      //                 alignment: Alignment.center,
                      //                 children: <Widget>[
                      //                   Image.asset(
                      //                     theme == "light"
                      //                         ? 'assets/applicationIcons/Iconly-Two-tone-Chat.png'
                      //                         : 'assets/applicationIcons/Iconly-Two-tone-Chat1.png',
                      //                     width: 12,
                      //                     height: 12,
                      //                   ),
                      //                   appointment.userChat > 0
                      //                       ? Positioned(
                      //                           left: 1.0,
                      //                           top: 1.0,
                      //                           child: Container(
                      //                             height: 5,
                      //                             width: 5,
                      //                             alignment: Alignment.center,
                      //                             decoration: BoxDecoration(
                      //                               shape: BoxShape.circle,
                      //                               color: Colors.amber,
                      //                             ),
                      //                           ),
                      //                         )
                      //                       : SizedBox()
                      //                 ]),
                      //             SizedBox(
                      //               width: 3,
                      //             ),
                      //             Text(
                      //               textAlign: TextAlign.start,
                      //               overflow: TextOverflow.ellipsis,
                      //               maxLines: 1,
                      //               style: TextStyle(
                      //                 fontFamily: getTranslated(context, "Ithra"),
                      //                 color: Theme.of(context).primaryColor,
                      //                 fontSize: 11.0,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),

                      // Container(
                      //   width: size.width * AppSize.w0_25,
                      //   child: Center(
                      //     child: Container(
                      //       height: 16,
                      //       width: size.width * .17,
                      //       decoration: BoxDecoration(
                      //         color: AppColors.white,
                      //         borderRadius: BorderRadius.circular(AppRadius.r12),
                      //       ),
                      //       child: Center(
                      //         child: Text(
                      //           double.parse(appointment.callPrice.toString())
                      //                   .toStringAsFixed(2) +
                      //               "\$",
                      //           textAlign: TextAlign.center,
                      //           style: TextStyle(
                      //             fontFamily: getTranslated(context, "Ithra"),
                      //             color: theme == "light"
                      //                 ? Theme.of(context).primaryColor
                      //                 : Colors.black,
                      //             fontSize: 11.0,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxShadow shadow() {
    return BoxShadow(
        color: const Color(0x0d202020),
        offset: Offset(0, 6),
        blurRadius: 18,
        spreadRadius: 0);
  }
}
