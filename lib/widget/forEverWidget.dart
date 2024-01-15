import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class ForEverWidget extends StatefulWidget {
  final ForEverAppointments appointment;
  final String theme;
  final GroceryUser loggedUser;

  ForEverWidget(
      {required this.appointment,
      required this.theme,
      required this.loggedUser});

  @override
  _ForEverWidgetState createState() => _ForEverWidgetState();
}

class _ForEverWidgetState extends State<ForEverWidget>
    with SingleTickerProviderStateMixin {
  bool userChating = false, consultChating = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
        padding: EdgeInsets.all((kIsWeb || size.width >= 500) ? AppPadding.p20 : AppPadding.p10),
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
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: Color(0xffb8b4b4),
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.appointment.user.name!,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: Color(0xff202020),
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
                              color: Color(0xff202020),
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= 500) ? AppSize.h10 : AppSize.h2,
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
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: Color(0xffb8b4b4),
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      widget.appointment.consult.name!,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: Color(0xff202020),
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
                              color: Color(0xff202020),
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= 500) ? AppSize.h10 : AppSize.h2,
            ),
            SizedBox(
              height: (kIsWeb || size.width >= 500) ? AppSize.h15 : AppSize.h5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: AppSize.h40,
                  width: (kIsWeb || size.width >= 500)
                      ? size.width * AppSize.w0_05
                      : size.width * AppSize.w0_3,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Center(
                    child: Text(
                      getTranslated(context, "closed"),
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
                SizedBox(
                  width: (kIsWeb || size.width >= 500) ? AppSize.w15 : AppSize.w5,
                ),
                Container(
                  height: 40,
                  width: (kIsWeb || size.width >= 500)
                      ? size.width * AppSize.w0_05
                      : size.width * AppSize.w0_3,
                  decoration: BoxDecoration(
                    color: Colors.pink[50],
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Center(
                    child: Text(
                      widget.appointment.callPrice.toString(),
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
                SizedBox(
                  width: (kIsWeb || size.width >= 500) ? AppSize.w15 : AppSize.w5,
                ),
              ],
            ),
            SizedBox(
              height: AppSize.h6,
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
                      widget.appointment.date.year.toString() +
                          "/" +
                          widget.appointment.date.month.toString() +
                          "/" +
                          widget.appointment.date.day.toString(),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: Color(0xff202020),
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
                      widget.appointment.time.hour.toString() +
                          ":" +
                          widget.appointment.time.minute.toString(),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: Color(0xff202020),
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: AppConstants.letterSpacing0_3,
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
