import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../screens/AppointmentChatScreen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../methods/check_if_web.dart';
import '../methods/convert_pt_to_px.dart';

class UserAppointmentWiget extends StatefulWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  bool? done;

  UserAppointmentWiget(
      {required this.appointment, required this.loggedUser, this.done = false});

  @override
  State<UserAppointmentWiget> createState() => _UserAppointmentWigetState();
}

class _UserAppointmentWigetState extends State<UserAppointmentWiget> {
  bool joinMeeting = false;
  bool acceptLoad = false, loadingCall = false;
  late String lang;

  @override
  Widget build(BuildContext context) {
    lang = getTranslated(context, "lang");
    var size = MediaQuery.of(context).size;
    String time;
    String sizebox = " ";
    String? name = "";
    if (widget.appointment.course != null)
      name = widget.appointment.course!.name;
    else
      name = widget.appointment.consult.name!;
    DateFormat dateFormat = DateFormat('yyyy MMM dd');
    DateTime localDate;
    if (widget.appointment.utcTime != null)
      localDate = DateTime.parse(widget.appointment.utcTime).toLocal();
    else
      localDate = DateTime.parse(
              widget.appointment.appointmentTimestamp.toDate().toString())
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
      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.w200.w
          : AppSize.w437_7.w,

      // height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
      //     ? 560.h
      //     : AppSize.h262_6.h,
      padding: EdgeInsets.only(
          top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? 0
              : AppPadding.p21_3.h,
          left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.w34.w
              : 0,
          right: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 30 : 0,
          bottom: 0),
      //card radius
      decoration: BoxDecoration(
          border: Border.all(
              width: 1,
              color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? null!
                  : AppColors.greyAppoint),
          borderRadius: BorderRadius.all(
            Radius.circular((kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppRadius.r50.r
                : AppRadius.r28.r),
          ),
          boxShadow: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? [
                  BoxShadow(
                      color: const Color(0x0d202020),
                      offset: Offset(0, 7),
                      blurRadius: 25,
                      spreadRadius: 0)
                ]
              : []),
      child: Column(
        children: [
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? SizedBox(
                  height: AppSize.h48.h,
                )
              : SizedBox(),
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? widget.done == false
                  ? Text(
                      widget.appointment.consult.name != null
                          ? widget.appointment.consult.name!
                          : widget.appointment.consult.phone!,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: AppFontsWeightManager.bold300,
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black2,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : AppFontsSizeManager.s21_3.sp,
                      ),
                    )
                  : Row(
                      children: [
                        Spacer(),
                        Row(
                          children: [
                            Text(
                              widget.appointment.consult.name != null
                                  ? widget.appointment.consult.name!
                                  : widget.appointment.consult.phone!,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontWeight: AppFontsWeightManager.bold300,
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.black2,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32
                                    : AppFontsSizeManager.s21_3.sp,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w32.w,
                            ),
                            InkWell(
                              splashColor: AppColors.greenAccent,
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AppointmentChatScreen(
                                        appointment: widget.appointment,
                                        user: widget.loggedUser),
                                  ),
                                );
                              },
                              child: Container(
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w65.h
                                    : AppSize.w46_6.r,
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h65.h
                                    : AppSize.w46_6.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.grey4,
                                ),
                                padding: EdgeInsets.all(AppRadius.r7.r),
                                child: Stack(
                                    alignment: Alignment.center,
                                    children: <Widget>[
                                      SvgPicture.asset(
                                        AssetsManager.greyChat2IconPath,
                                        // "assets/jeras_icons/greyChat2.svg.svg"

                                        width: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.w36.r
                                            : AppSize.w30.r,
                                        height: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h36.r
                                            : AppSize.h30.r,
                                      ),
                                      widget.appointment.consultChat > 0
                                          ? Positioned(
                                              left: 1.0,
                                              top: 1.0,
                                              child: Container(
                                                height: AppSize.h5.r,
                                                width: AppSize.w5.r,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.amber,
                                                ),
                                              ),
                                            )
                                          : SizedBox()
                                    ]),
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                      ],
                    )
              : Text(
                  widget.appointment.consult.name != null
                      ? widget.appointment.consult.name!
                      : widget.appointment.consult.phone!,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: AppFontsWeightManager.bold300,
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black2,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32
                        : AppFontsSizeManager.s21_3.sp,
                  ),
                ),

          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? SizedBox(
                  height: AppSize.h48.h,
                )
              : SizedBox(),
          Padding(
            padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? EdgeInsets.all(0)
                : EdgeInsets.only(
                    top: AppPadding.p18.h,
                    left: AppPadding.p32.w,
                    right: AppPadding.p32.w,
                    bottom: AppPadding.p18_6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //data
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(AssetsManager.calendarClockIconPath,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w24.w
                                : AppSize.w16.w,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w24.w
                                : AppSize.w16.w),
                        SizedBox(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w4_8.w
                                : AppSize.w10_6.w),

                        //date
                        Text(
                          '${dateFormat.format(localDate)}',
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Montserrat"),
                            color: AppColors.greyUpdate,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s24.sp
                                : AppFontsSizeManager.s18_6.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: AppSize.h13_3.h,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: AppColors.linear8,
                          size: checkIfWeb(context)
                              ? AppSize.w24.w
                              : convertPtToPx(AppSize.w16.w),
                        ),
                        SizedBox(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w4_8.w
                                : AppSize.w10_6.w),

                        //time old 13*1.3.sp
                        Text(
                          time,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Montserrat"),
                            color: AppColors.greyUpdate,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s24.sp
                                : AppFontsSizeManager.s18_6.sp,
                            fontWeight: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsWeightManager.bold400
                                : null,
                          ),
                        ),
                      ],
                    )
                  ],
                ),

                Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 0
                          : AppPadding.p8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //remaining courses
                      Row(
                        children: [
                          Text(
                            getTranslated(context, "remainingCalls") + " : ",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: lang == "ar"
                                  ? AppColors.greyArab
                                  : AppColors.greyUpdate,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsWeightManager.bold700
                                  : null,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s24.sp
                                  : AppFontsSizeManager.s18_6.sp,
                            ),
                          ),
                          Text(
                            widget.appointment.remainingCallNum.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppColors.grey
                                  : lang == "ar"
                                      ? HexColor('#939393')
                                      : AppColors.greyUpdate,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsWeightManager.bold700
                                  : null,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s24.sp
                                  : AppFontsSizeManager.s18_6.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h9_1.h
                                : AppSize.h10.h,
                      ),
                      //appointment price
                      Row(
                        children: [
                          Text(
                            getTranslated(context, "price") + " : ",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppColors.grey
                                  : lang == "ar"
                                      ? AppColors.greyArab
                                      : AppColors.greyUpdate,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsWeightManager.bold700
                                  : null,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s24.sp
                                  : AppFontsSizeManager.s18_6.sp,
                            ),
                          ),
                          Text(
                            double.parse(
                                    widget.appointment.callPrice.toString())
                                .toStringAsFixed(2),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppColors.grey
                                  : AppColors.greyUpdate,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsWeightManager.bold700
                                  : null,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s24.sp
                                  : AppFontsSizeManager.s18_6.sp,
                            ),
                          ),
                          Text(
                            "\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppColors.grey
                                  : AppColors.greyUpdate,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsWeightManager.bold700
                                  : null,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s24.sp
                                  : AppFontsSizeManager.s18_6.sp,
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
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h47_3.h
                : AppSize.h1.h,
          ),
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? widget.done == true
                  ? SizedBox()
                  : Divider(
                      height: AppSize.h0_1,
                      color: AppColors.grey4,
                    )
              : Divider(
                  height: AppSize.h0_1.h,
                  color: AppColors.greyAppoint,
                ),
          //icon size
          widget.appointment.course == null
              ? Container()
              : Padding(
                  padding: EdgeInsets.only(
                      top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 0
                          : AppPadding.p2.h),
                  child: Text(
                    widget.appointment.course!.name,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontWeight: AppFontsWeightManager.bold300,
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black2,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s18 * 1.3.sp
                              : AppFontsSizeManager.s15 * 1.3.sp,
                    ),
                  ),
                ),
          // name

          // Padding(
          //   padding: EdgeInsets.only(
          //       top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          //           ? 0.h
          //           : AppPadding.p24.h,
          //       bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          //           ? AppPadding.p25.h
          //           : AppPadding.p3),
          //   child: Container(
          //     height: AppSize.h0_5.h,
          //     // color: Colors.grey,
          //   ),
          // ),

          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? widget.done == true
                  ? Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: AppSize.h24.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    getTranslated(context, "doneMeet"),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: AppColors.primaryColor,
                                      fontWeight: AppFontsWeightManager.bold700,
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s28.sp
                                          : AppFontsSizeManager.s18_6.sp,
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSize.w8.w,
                                  ),
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          AssetsManager.doneIcon,
                                          // "assets/jeras_icons/greyChat2.svg.svg"

                                          width: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.w32.r
                                              : AppSize.w30.r,
                                          height: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.h32.r
                                              : AppSize.h30.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: Center(
                        child: message(context, size),
                      ),
                    )
              : Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          color: AppColors.grey4,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(AppRadius.r28.r),
                              bottomRight: Radius.circular(AppRadius.r28.r))),
                      child: message(context, size)),
                )
        ],
      ),
    );
  }

  Widget message(BuildContext context, Size size) {
    return InkWell(
      splashColor: Colors.green.withOpacity(0.6),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppointmentChatScreen(
                appointment: widget.appointment, user: widget.loggedUser),
          ),
        );
      },
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? InkWell(
                splashColor: Colors.green.withOpacity(0.6),
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AppointmentChatScreen(
                          appointment: widget.appointment,
                          user: widget.loggedUser),
                    ),
                  );
                },
                child: Expanded(
                  child: Container(
                    // color: Colors.red,
                    child: Column(
                      children: [
                        SizedBox(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h25.h
                                  : AppSize.h1.h,
                        ),
                        Expanded(
                          child: Container(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w70.h
                                : AppSize.w46_6.r,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h70.h
                                : AppSize.w46_6.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.grey4,
                            ),
                            padding: EdgeInsets.all(AppRadius.r7.r),
                            child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    AssetsManager.chat1IconPath,
                                    // "assets/jeras_icons/greyChat2.svg.svg"

                                    width: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.w36.r
                                        : AppSize.w30.r,
                                    height: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.h36.r
                                        : AppSize.h30.r,
                                  ),
                                  widget.appointment.consultChat > 0
                                      ? Positioned(
                                          left: 1.0,
                                          top: 1.0,
                                          child: Container(
                                            height: AppSize.h5.r,
                                            width: AppSize.w5.r,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.amber,
                                            ),
                                          ),
                                        )
                                      : SizedBox()
                                ]),
                          ),
                        ),
                        SizedBox(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h25.h
                                  : AppSize.h1.h,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Spacer(),
                  Container(
                      child: widget.done == true
                          ? Column(
                              children: [
                                Spacer(),
                                Text(
                                  getTranslated(context, "doneMeet"),
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.primaryColor,
                                    fontWeight: AppFontsWeightManager.bold,
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s24.sp
                                        : AppFontsSizeManager.s18_6.sp,
                                  ),
                                ),
                                Spacer(),
                              ],
                            )
                          : SizedBox()),
                  SizedBox(
                    width: AppSize.w13_3.w,
                  ),
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppointmentChatScreen(
                              appointment: widget.appointment,
                              user: widget.loggedUser),
                        ),
                      );
                    },
                    child: Container(
                      // color: Colors.red,
                      child: Column(
                        children: [
                          Spacer(),
                          SvgPicture.asset(
                            AssetsManager.chat3IconPath,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w20.r
                                : AppSize.w28.r,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h20.r
                                : AppSize.h28.r,
                          ),
                          widget.appointment.consultChat > 0
                              ? Positioned(
                                  left: 1.0,
                                  top: 1.0,
                                  child: Container(
                                    height: AppSize.h5.r,
                                    width: AppSize.w5.r,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.amber,
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          Spacer(),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
      ),
    );
  }
}
