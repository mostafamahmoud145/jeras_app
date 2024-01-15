import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/assets_manager.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/SupportList.dart';
import '../../models/user.dart';
import '../../screens/supportMessagesScreen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';

class TechAppointmentWiget extends StatefulWidget {
  final AppAppointments appointment;
  final String theme;
  final GroceryUser loggedUser;

  TechAppointmentWiget(
      {required this.appointment,
      required this.theme,
      required this.loggedUser});

  @override
  _TechAppointmentWigetState createState() => _TechAppointmentWigetState();
}

class _TechAppointmentWigetState extends State<TechAppointmentWiget>
    with SingleTickerProviderStateMixin {
  bool userChating = false, consultChating = false;

  @override
  void initState() {
    super.initState();
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
      time = "12 Pm";
    else if (localDate.hour == 0)
      time = "12 Am";
    else if (localDate.hour > 12)
      time = (localDate.hour - 12).toString() +
          ":" +
          localDate.minute.toString() +
          "Pm";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString() +
          "Am";

    return Container(
        padding: EdgeInsets.all((kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppPadding.p20 : AppPadding.p10),
        decoration: BoxDecoration(
          color: AppColors.grey4,
          borderRadius: BorderRadius.circular(AppRadius.r25),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, "client"),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                        color:AppColors.textLightGrey,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.appointment.user.name!,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                        color:AppColors.black2,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ],
                ),
                userChating
                    ? CircularProgressIndicator()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.6),
                            onTap: () {
                              startUserChating();
                            },
                            child: Icon(
                              Icons.chat_outlined,
                              color:AppColors.black2,
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h10 : AppSize.h2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, "const"),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                        color:AppColors.textLightGrey,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.appointment.consult.name!,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                        color:AppColors.black2,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ],
                ),
                consultChating
                    ? CircularProgressIndicator()
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.6),
                            onTap: () {
                              startConsultChating();
                            },
                            child: Icon(
                              Icons.chat_outlined,
                              color:AppColors.black2,
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h10 : AppSize.h2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: AppSize.h40,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_05
                      : size.width * AppSize.w0_2,
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Center(
                    child: Text(
                      double.parse(widget.appointment.callPrice.toString())
                              .toStringAsFixed(1) +
                          "\$",
                      //getTranslated(context, "callStatus"),

                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w15 : AppSize.w5,
                ),
                Container(
                  height: AppSize.h40,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_05
                      : size.width * AppSize.w0_2,
                  decoration: BoxDecoration(
                    color: AppColors.pink50,
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Center(
                    child: Text(
                      widget.appointment.appointmentStatus == "new"
                          ? getTranslated(context, "new")
                          : widget.appointment.appointmentStatus == "open"
                              ? getTranslated(context, "open")
                              : widget.appointment.appointmentStatus == "closed"
                                  ? getTranslated(context, "closed")
                                  : getTranslated(context, "canceled"),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w15 : AppSize.w5,
                ),
                widget.appointment.type == null
                    ? SizedBox()
                    : Container(
                        height: AppSize.h40,
                        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppSize.w0_05
                            : size.width * AppSize.w0_2,
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(AppRadius.r20),
                        ),
                        child: Center(
                          child: Text(
                            widget.appointment.type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.black,
                              fontSize: AppFontsSizeManager.s13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h15 : AppSize.h6,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      AssetsManager.calendarClockIconPath,
                      width: AppSize.w25,
                      height: AppSize.h25,
                    ),
                    SizedBox(
                      width: AppSize.w5,
                    ),
                    Text(
                      '${dateFormat.format(localDate)}',
                      //'${dateFormat.format(widget.appointment.appointmentTimestamp.toDate())}',
                      // DateFormat.yMMMd().format(DateTime.parse(widget.appointment.appointmentTimestamp.toDate().toString())).toString(), // Apr
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black2,
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ],
                )),
                SizedBox(
                  width: AppSize.w30,
                ),
                Container(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                   SvgPicture.asset(
                      AssetsManager.clockIconPath,
                      width: AppSize.w25,
                      height: AppSize.h25,
                    ),
                    SizedBox(
                      width: AppSize.w5,
                    ),
                    Text(
                      time,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color:AppColors.black2,
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ))
              ],
            ),
            SizedBox(
              height: AppSize.h6,
            ),
          ],
        ));
  }

  startUserChating() async {
    setState(() {
      userChating = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("SupportList")
        .where(
          'userUid',
          isEqualTo: widget.appointment.user.uid,
        )
        .limit(1)
        .get();
    if (querySnapshot.docs.length != 0) {
      var item = SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      item.userName = widget.appointment.user.name!;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
            item: item,
            user: widget.loggedUser,
            theme: 'light',
          ),
        ),
      );
      setState(() {
        userChating = false;
      });
    } else {
      setState(() {
        userChating = false;
      });
    }
  }

  startConsultChating() async {
    setState(() {
      consultChating = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("SupportList")
        .where(
          'userUid',
          isEqualTo: widget.appointment.consult.uid,
        )
        .limit(1)
        .get();
    if (querySnapshot.docs.length != 0) {
      var item = SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      item.userName = widget.appointment.consult.name!;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
            item: item,
            user: widget.loggedUser,
            theme: 'light',
          ),
        ),
      );
      setState(() {
        consultChating = false;
      });
    } else {
      setState(() {
        consultChating = false;
      });
    }
  }
}
