import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_shadow.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/colors_file.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../screens/AppointmentChatScreen.dart';
import '../blocs/jitsi_meet/jitsi_meet_rining_screeen.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../localization/localization_methods.dart';
import '../methods/checkinternet.dart';
import '../methods/show_call_permissions_dialog.dart';
import 'no_internet_component.dart';

class AppointmentWiget extends StatefulWidget {
  final GroceryUser loggedUser;
  final AppAppointments appointment;
  final String theme;
  AppointmentWiget(
      {required this.appointment,
      required this.loggedUser,
      required this.theme});

  @override
  _AppointmentWigetState createState() => _AppointmentWigetState();
}

class _AppointmentWigetState extends State<AppointmentWiget>
    with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  bool joinMeeting = false;
  bool acceptLoad = false, loadingCall = false;
  @override
  void initState() {
    super.initState();

    accountBloc = BlocProvider.of<AccountBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    String time;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
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
      time = "12  :00 Am";
    else if (localDate.hour > 12)
      time = (localDate.hour - 12).toString() +
          ":" +
          localDate.minute.toString().padLeft(2, "0") +
          " Pm";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString().padLeft(2, "0") +
          " Am";

    return (kIsWeb || size.width >= 500)
        ? Container(
            width: (kIsWeb || size.width >= 500) ? AppSize.w616_8.w : 0,
            height: (kIsWeb || size.width >= 500) ? AppSize.h322_8.h : 0,
            padding: EdgeInsets.only(
                top: (kIsWeb || size.width >= 500) ? AppSize.h30 : 32.h,
                left: (kIsWeb || size.width >= 500) ? AppSize.w35 : 26.w,
                right: (kIsWeb || size.width >= 500) ? AppSize.w35 : 26.w,
                bottom: (kIsWeb || size.width >= 500) ? AppSize.h24 : 0),
            //card radius
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.all(
                  Radius.circular((kIsWeb || size.width >= 500) ? 50.r : 28.r)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x0d202020),
                    offset: Offset(0, 7),
                    blurRadius: 25,
                    spreadRadius: 0)
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: (kIsWeb || size.width >= 500)
                          ? AppSize.w64_4.w
                          : 46.6.w,
                      height: (kIsWeb || size.width >= 500)
                          ? AppSize.h64_4.h
                          : 46.6.h,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white,
                          boxShadow: [AppShadow.greyshadow]),
                      // padding: EdgeInsets.all(7),

                      child:
                          Stack(alignment: Alignment.center, children: <Widget>[
                        SvgPicture.asset(
                          AssetsManager.calls,
                          width: (kIsWeb || size.width >= 500)
                              ? AppSize.w31_7.w
                              : 24.13.w,
                          height: (kIsWeb || size.width >= 500)
                              ? AppSize.h31_7.w
                              : 24.13.h,
                        ),
                        widget.appointment.userChat > 0
                            ? Positioned(
                                left: 1.0,
                                top: 1.0,
                                child: Container(
                                  height: 5.r,
                                  width: 5.r,
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
                    Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '${dateFormat.format(localDate)}',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Montserrat"),
                                color: Color.fromRGBO(147, 147, 147, 1),
                                fontWeight: FontWeight.normal,
                                fontSize: (kIsWeb || size.width >= 500)
                                    ? AppFontsSizeManager.s14.sp
                                    : 16.sp,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            SvgPicture.asset(
                              '${AppConstants.iconsPath}calendar_check.svg',
                              color: AppColors.primaryColor,
                              width: (kIsWeb || size.width >= 500)
                                  ? AppSize.w21_7.w
                                  : convertPtToPx(12.w),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: (kIsWeb || size.width >= 500)
                              ? AppSize.h5.h
                              : 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              time,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: (kIsWeb || size.width >= 500)
                                    ? getTranslated(context, "Montserrat")
                                    : getTranslated(context, "Ithralight"),
                                color: Color.fromRGBO(147, 147, 147, 1),
                                fontWeight: FontWeight.normal,
                                fontSize: (kIsWeb || size.width >= 500)
                                    ? AppFontsSizeManager.s14.sp
                                    : 16.sp,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Icon(
                              Icons.access_time_rounded,
                              color: AppColors.primaryColor,
                              size: (kIsWeb || size.width >= 500)
                                  ? AppSize.w21_7.w
                                  : convertPtToPx(14.w),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h19_2.h,
                ),
                SvgPicture.asset(
                  AssetsManager.RightMark,
                  width: (kIsWeb || size.width >= 500) ? AppSize.w23_6.w : 26.w,
                  height:
                      (kIsWeb || size.width >= 500) ? AppSize.h18_9.h : 26.h,
                ),
                SizedBox(
                  height: AppSize.h6_6.h,
                ),
                Text(
                  widget.loggedUser.userType == "USER"
                      ? widget.appointment.consult.name != null
                          ? widget.appointment.consult.name!
                          : widget.appointment.consult.phone!
                      : widget.appointment.consult.name != null
                          ? widget.appointment.user.name!
                          : widget.appointment.user.phone!,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black1,
                    fontSize: (kIsWeb || size.width >= 500)
                        ? AppFontsSizeManager.s22.sp
                        : 21.3.sp,
                  ),
                ),
                SizedBox(
                  height: 29.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Text(
                    //       getTranslated(context, "remainingCalls") +
                    //           " : " +
                    //           widget.appointment.remainingCallNum.toString(),
                    //       textAlign: TextAlign.start,
                    //       overflow: TextOverflow.ellipsis,
                    //       maxLines: 1,
                    //       style: TextStyle(
                    //         fontFamily: getTranslated(context, "Ithralight"),
                    //         color: AppColors.primaryColor,
                    //         fontWeight: FontWeight.normal,
                    //         fontSize: (kIsWeb || size.width >= 500) ? 24.sp : 18.6.sp,
                    //       ),
                    //     ),
                    //     SizedBox(
                    //       height: 10.h,
                    //     ),
                    //     Text(
                    //       getTranslated(context, "price") +
                    //           " : " +
                    //           double.parse(widget.appointment.callPrice.toString())
                    //               .toStringAsFixed(2) +
                    //           "\$",
                    //       textAlign: TextAlign.start,
                    //       overflow: TextOverflow.ellipsis,
                    //       maxLines: 1,
                    //       style: TextStyle(
                    //         fontFamily: getTranslated(context, "Ithralight"),
                    //         color: AppColors.primaryColor,
                    //         fontWeight: FontWeight.normal,
                    //         fontSize: (kIsWeb || size.width >= 500) ? 24.sp : 18.6.sp,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
                // SizedBox(
                //   height: 16.h,
                // ),
                Padding(
                  padding: EdgeInsets.only(
                      top: (kIsWeb || size.width >= 500) ? AppSize.h29.h : 24.h,
                      bottom:
                          (kIsWeb || size.width >= 500) ? AppSize.h19_3.h : 3),
                  child: Container(
                    height: .5.h,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Spacer(),
                        joinMeeting
                            ? CircularProgressIndicator()
                            : InkWell(
                                splashColor: Colors.green.withOpacity(0.6),
                                onTap: () async {
                                  startMeeting();
                                },
                                child: Container(
                                  width: (kIsWeb || size.width >= 500)
                                      ? AppSize.w64_8.w
                                      : 46.6.w,
                                  height: (kIsWeb || size.width >= 500)
                                      ? AppSize.h64_8.w
                                      : 46.6.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.greenAccent3,
                                  ),
                                  padding: EdgeInsets.all(7),
                                  //p
                                  child: SvgPicture.asset(
                                    AssetsManager.whiteCallIconPath,
                                    width: (kIsWeb || size.width >= 500)
                                        ? AppSize.w26.w
                                        : 26.w,
                                    height: (kIsWeb || size.width >= 500)
                                        ? AppSize.h26.h
                                        : 26.h,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                        const Spacer(),
                        VerticalDivider(
                          color: Color(0xffededed),
                          width: .5.w,
                        ),
                        Spacer(),
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
                            width: (kIsWeb || size.width >= 500)
                                ? AppSize.w64_8.w
                                : 46.6.w,
                            height: (kIsWeb || size.width >= 500)
                                ? AppSize.h64_8.h
                                : 46.6.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.blueAccent,
                            ),
                            // padding: EdgeInsets.all(7),

                            child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    AssetsManager.whiteChat2IconPath,
                                    width: (kIsWeb || size.width >= 500)
                                        ? AppSize.w26.w
                                        : 24.13.w,
                                    height: (kIsWeb || size.width >= 500)
                                        ? AppSize.h26.h
                                        : 24.13.h,
                                  ),
                                  widget.appointment.userChat > 0
                                      ? Positioned(
                                          left: 1.0,
                                          top: 1.0,
                                          child: Container(
                                            height: 5.r,
                                            width: 5.r,
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
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Container(
            width: (kIsWeb || size.width >= 500) ? 613.w : 0,
            height: (kIsWeb || size.width >= 500) ? 316.h : 0,
            padding: EdgeInsets.only(
                top: (kIsWeb || size.width >= 500) ? 30 : 32.h,
                left: (kIsWeb || size.width >= 500) ? 30 : 26.w,
                right: (kIsWeb || size.width >= 500) ? 30 : 26.w,
                bottom: 0),
            //card radius
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                  Radius.circular((kIsWeb || size.width >= 500) ? 50.r : 28.r)),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x0d202020),
                    offset: Offset(0, 7),
                    blurRadius: 25,
                    spreadRadius: 0)
              ],
            ),
            child: Column(
              children: [
                Text(
                  widget.loggedUser.userType == "USER"
                      ? widget.appointment.consult.name != null
                          ? widget.appointment.consult.name!
                          : widget.appointment.consult.phone!
                      : widget.appointment.consult.name != null
                          ? widget.appointment.user.name!
                          : widget.appointment.user.phone!,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black1,
                    fontSize: (kIsWeb || size.width >= 500) ? 32 : 21.3.sp,
                  ),
                ),
                SizedBox(
                  height: 20.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              '${AppConstants.iconsPath}calendar_check.svg',
                              color: AppColors.primaryColor,
                              width: (kIsWeb || size.width >= 500)
                                  ? 24.w
                                  : convertPtToPx(12.w),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '${dateFormat.format(localDate)}',
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Montserrat"),
                                color: Color.fromRGBO(147, 147, 147, 1),
                                fontWeight: FontWeight.normal,
                                fontSize: (kIsWeb || size.width >= 500)
                                    ? 24.sp
                                    : 16.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: AppColors.primaryColor,
                              size: (kIsWeb || size.width >= 500)
                                  ? 24.w
                                  : convertPtToPx(14.w),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              time,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: (kIsWeb || size.width >= 500)
                                    ? getTranslated(context, "Montserrat")
                                    : getTranslated(context, "Ithralight"),
                                color: Color.fromRGBO(147, 147, 147, 1),
                                fontWeight: FontWeight.normal,
                                fontSize: (kIsWeb || size.width >= 500)
                                    ? 24.sp
                                    : 16.sp,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          getTranslated(context, "remainingCalls") +
                              " : " +
                              widget.appointment.remainingCallNum.toString(),
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithralight"),
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.normal,
                            fontSize:
                                (kIsWeb || size.width >= 500) ? 24.sp : 18.6.sp,
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Text(
                          getTranslated(context, "price") +
                              " : " +
                              double.parse(
                                      widget.appointment.callPrice.toString())
                                  .toStringAsFixed(2) +
                              "\$",
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithralight"),
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.normal,
                            fontSize:
                                (kIsWeb || size.width >= 500) ? 24.sp : 18.6.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 16.h,
                ),
                Padding(
                  padding: EdgeInsets.only(
                      top: (kIsWeb || size.width >= 500) ? 24.h : 24.h,
                      bottom: (kIsWeb || size.width >= 500) ? 10 : 3),
                  child: Container(
                    height: .5.h,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      children: [
                        Spacer(),
                        joinMeeting
                            ? CircularProgressIndicator()
                            : InkWell(
                                splashColor: Colors.green.withOpacity(0.6),
                                onTap: () async {
                                  startMeeting();
                                },
                                child: Container(
                                  width: (kIsWeb || size.width >= 500)
                                      ? 46.6
                                      : 46.6.w,
                                  height: (kIsWeb || size.width >= 500)
                                      ? 46.6
                                      : 46.6.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryColor,
                                  ),
                                  padding: EdgeInsets.all(7),
                                  //p
                                  child: SvgPicture.asset(
                                    AssetsManager.whiteCallIconPath,
                                    width: (kIsWeb || size.width >= 500)
                                        ? 26
                                        : 26.w,
                                    height: (kIsWeb || size.width >= 500)
                                        ? 20.4
                                        : 26.h,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                        const Spacer(),
                        VerticalDivider(
                          color: Color(0xffededed),
                          width: .5.w,
                        ),
                        Spacer(),
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
                            width:
                                (kIsWeb || size.width >= 500) ? 46.6 : 46.6.w,
                            height:
                                (kIsWeb || size.width >= 500) ? 46.6 : 46.6.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryColor.withOpacity(0.2),
                            ),
                            // padding: EdgeInsets.all(7),

                            child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  SvgPicture.asset(
                                    AssetsManager.chat3IconPath,
                                    width: (kIsWeb || size.width >= 500)
                                        ? 24.13
                                        : 24.13.w,
                                    height: (kIsWeb || size.width >= 500)
                                        ? 24.13
                                        : 24.13.h,
                                  ),
                                  widget.appointment.userChat > 0
                                      ? Positioned(
                                          left: 1.0,
                                          top: 1.0,
                                          child: Container(
                                            height: 5.r,
                                            width: 5.r,
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
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  void startMeeting() async {
    if (kIsWeb) {
      Future(() => Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (con) => JitsiMeetRiningScreen(
                    host: widget.appointment.appointmentId,
                    iscaller: true,
                    loggedUser: widget.loggedUser,
                    appointment: widget.appointment,
                    isVideo: false,
                    normalCall: false,
                    CallerId: FirebaseAuth.instance.currentUser!.uid,
                    ReciverId: widget.appointment.user.uid,
                  )),
          (predict) => predict.isCurrent ? false : true));
    } else {
      Permission.microphone.request().then((mic) {
        Permission.camera.request().then((camera) {
          if (mic.isGranted == true && camera.isGranted == true) {
            webRtcCall();
          } else if (mic.isDenied == true || camera.isDenied == true) {
            showPermissionsDialog(
              context: context,
              text: getTranslated(context, 'getPermissions'),
              buttonTitle: getTranslated(context, 'allow'),
              function: () {
                Navigator.pop(context);
              },
              refusedFunction: () {
                Navigator.pop(context);
              },
            );
          } else if (mic.isPermanentlyDenied == true ||
              camera.isPermanentlyDenied == true) {
            showPermissionsDialog(
              context: context,
              text: getTranslated(context, 'getSettings'),
              buttonTitle: getTranslated(context, 'goToSettings'),
              function: () {
                Navigator.pop(context);
                AppSettings.openAppSettings(
                  type: AppSettingsType.settings,
                );
              },
              refusedFunction: () {
                Navigator.pop(context);
              },
            );
          }
        });
      });
    }
  }

  webRtcCall() async {
    try {
      setState(() {
        joinMeeting = true;
      });

      if (await isConnectedToInternet()) {
        Future(() => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (con) => JitsiMeetRiningScreen(
                      host: widget.appointment.appointmentId,
                      iscaller: true,
                      loggedUser: widget.loggedUser,
                      appointment: widget.appointment,
                      isVideo: false,
                      normalCall: false,
                      CallerId: FirebaseAuth.instance.currentUser!.uid,
                      ReciverId: widget.appointment.user.uid,
                    )),
            (predict) => predict.isCurrent ? false : true));
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoInternetComponent(),
            ));
      }

      setState(() {
        joinMeeting = false;
      });
    } catch (e) {}
  }
}
