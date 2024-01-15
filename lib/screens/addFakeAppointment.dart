import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../models/user.dart';
import '../services/app_flyer_service.dart';
import '../widget/custom_back_button.dart';

class AddAppointmentScreen extends StatefulWidget {
  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false;
  late String userPhone, consultPhone, theme = "light", callNum, price;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(left: AppPadding.p20, right: AppPadding.p20, top: AppPadding.p10, bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(color: Colors.black),
                      const SizedBox(width: 10),
                      Text(
                        getTranslated(context, "addOrder"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize: (kIsWeb || size.width >= 500) ? 31.sp : 15.0.sp,
                          color: AppColors.black2,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= 500) ? size.width * .3 : 16.0,
                    right: (kIsWeb || size.width >= 500) ? size.width * .3 : 16.0,
                    bottom: AppPadding.p16,
                    top: AppPadding.p16),
                child: ListView(
                  children: <Widget>[
                    SizedBox(
                      height: 25.0,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        userPhone = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          //color: AppColors.black54,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "userPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h15,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        consultPhone = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          //color: AppColors.black54,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "consultPhone"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h15,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        callNum = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          //color: AppColors.black54,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "packageCall"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      textAlignVertical: TextAlignVertical.center,
                      validator: (String? val) {
                        if (val!.trim().isEmpty) {
                          return getTranslated(context, 'required');
                        }
                        return null;
                      },
                      onSaved: (val) {
                        price = val!;
                      },
                      enableInteractiveSelection: true,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                      ),
                      minLines: 1,
                      maxLines: 3,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                        helperStyle: GoogleFonts.poppins(
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        errorStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        hintStyle: GoogleFonts.poppins(
                          //color: AppColors.black54,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        //prefixIcon: Icon(Icons.title),
                        labelText: getTranslated(context, "price"),
                        labelStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r12),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Container(
                      height: 45.0,
                      width: (kIsWeb || size.width >= 500) ? size.width * .15 : double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: saving
                          ? Center(child: CircularProgressIndicator())
                          : MaterialButton(
                              onPressed: () {
                                save();
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r15.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.send,
                                    color: theme == "light" ? Colors.white : Colors.black,
                                    size: 20.0,
                                  ),
                                  SizedBox(
                                    width: AppSize.w10,
                                  ),
                                  Text(
                                    getTranslated(context, "save"),
                                    style: GoogleFonts.poppins(
                                      color: theme == "light" ? Colors.white : Colors.black,
                                      fontSize: AppFontsSizeManager.s15,
                                      fontWeight: AppFontsWeightManager.semiBold,
                                      letterSpacing: AppConstants.letterSpacing0_3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 25.0,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  save() async {
    GroceryUser user, consult;
    List<GroceryUser> users = [], consults = [];
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        //get userdata
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .where(
              'phoneNumber',
              isEqualTo: userPhone,
            )
            .get();

        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (users.length > 0) user = users[0];
        //get consultdata
        QuerySnapshot querySnapshot2 = await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .where(
              'phoneNumber',
              isEqualTo: consultPhone,
            )
            .get();

        for (var doc in querySnapshot2.docs) {
          consults.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (consults.length > 0) consult = consults[0];
        //add order
        DateTime date = DateTime.now();
        if (users.length > 0 && consults.length > 0) {
          String orderId = Uuid().v4();
          dynamic callPrice = double.parse(price.toString()) / int.parse(callNum);
          await FirebaseFirestore.instance.collection(Paths.ordersPath).doc(orderId).set({
            'orderStatus': "completed", //(consults[0].consultType=="perfect"||consults[0].consultType=="jeras")?'completed':'open',
            'consultType': "jeras",
            'orderId': orderId,
            'utcTime': date.toUtc().toString(),
            'orderTimestamp': Timestamp.now(),
            'date': {
              'day': date.day,
              'month': date.month,
              'year': date.year,
            },
            'orderTimeValue': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
            'packageId': "",
            'promoCodeId': "",
            'remainingCallNum': int.parse(callNum),
            'packageCallNum': int.parse(callNum),
            'answeredCallNum': 0,
            'callPrice': callPrice,
            "payWith": "support",
            "platform": Platform.isIOS
                ? "iOS"
                : Platform.isAndroid
                    ? "Android"
                    : "Web",
            'price': (double.parse(price.toString()) + ((double.parse(price.toString()) * 5) / 100)).toString(),
            'consult': {
              'uid': consults[0].uid,
              'name': consults[0].name,
              'image': consults[0].photoUrl,
              'phone': consults[0].phoneNumber,
              'countryCode': consults[0].countryCode,
              'countryISOCode': consults[0].countryISOCode,
            },
            'user': {
              'uid': users[0].uid,
              'name': users[0].name,
              'image': users[0].photoUrl,
              'phone': users[0].phoneNumber,
              'countryCode': users[0].countryCode,
              'countryISOCode': users[0].countryISOCode,
            },
          });
          //update consult order numbers
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(consults[0].uid).set({
            'openOrders': consults[0].openOrders + 1,
          }, SetOptions(merge: true));

          if (callNum == "1") {
            date = DateTime.now().toUtc();
            String appointmentId = Uuid().v4();
            await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(appointmentId).set({
              'appointmentId': appointmentId,
              'appointmentStatus': 'open',
              'remainingCallNum': 0,
              'callCost': 0.0,
              'allowCall': false,
              'type': 'support',
              "consultType": "jeras",
              'lessonTime': 60,
              'timestamp': DateTime.now().toUtc(),
              'timeValue': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
              'secondValue':
                  DateTime(date.year, date.month, date.day, date.hour, date.minute, date.second, date.millisecond).millisecondsSinceEpoch,
              'appointmentTimestamp': DateTime(date.year, date.month, date.day, date.hour, date.minute, date.second, date.millisecond),
              'utcTime': date.toString(),
              'consultChat': 0,
              'userChat': 0,
              'isUtc': true,
              'orderId': orderId,
              'callPrice': callPrice,
              'consult': {
                'uid': consults[0].uid,
                'name': consults[0].name,
                'image': consults[0].photoUrl,
                'phone': consults[0].phoneNumber,
                'countryCode': consults[0].countryCode,
                'countryISOCode': consults[0].countryISOCode,
              },
              'user': {
                'uid': users[0].uid,
                'name': users[0].name,
                'image': users[0].photoUrl,
                'phone': users[0].phoneNumber,
                'countryCode': users[0].countryCode,
                'countryISOCode': users[0].countryISOCode,
              },
              'date': {
                'day': date.day,
                'month': date.month,
                'year': date.year,
              },
              'time': {
                'hour': date.hour,
                'minute': date.minute,
              },
            }).then((value) async {
              await FirebaseFirestore.instance
                  .collection(Paths.ordersPath)
                  .doc(orderId)
                  .set({
                    'orderStatus': "completed",
                    'remainingCallNum': 0,
                  }, SetOptions(merge: true))
                  .then((value) async {})
                  .catchError((err) {});
            }).catchError((err) {});
          }
          //update user order numbers
          int userOrdersNumbers = 1;
          dynamic payedBalance = double.parse(price.toString());
          if (users[0].ordersNumbers != null) userOrdersNumbers = users[0].ordersNumbers! + 1;
          if (users[0].payedBalance != null) payedBalance = users[0].payedBalance + payedBalance;
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(users[0].uid).set({
            'ordersNumbers': userOrdersNumbers,
            'payedBalance': payedBalance,
          }, SetOptions(merge: true));
          //add event
          String eventName = "af_purchase";
          Map eventValues = {
            "af_revenue": price.toString(),
            "af_price": price.toString(),
            "af_content_id": consults[0].uid,
            "af_order_id": orderId,
            "af_currency": "USD",
          };
          AppFlyerService().logEvent(eventName, eventValues);
          appointmentDialog(MediaQuery.of(context).size, date.toString(), true);
        } else {
          appointmentDialog(MediaQuery.of(context).size, getTranslated(context, 'invalidNumbers'), false);
        }
        setState(() {
          saving = false;
        });
      } catch (e) {}
    }
  }

  appointmentDialog(Size size, String data, bool status) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(left: AppPadding.p16, right: AppPadding.p16, top: AppPadding.p20, bottom: AppPadding.p10),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              getTranslated(context, "appointments"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s14_5,
                fontWeight: AppFontsWeightManager.semiBold,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: AppSize.h15,
            ),
            Text(
              status ? getTranslated(context, "appointmentRegister") : getTranslated(context, "error"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: 14.0,
                fontWeight: AppFontsWeightManager.bold500,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: status ? Colors.black87 : Colors.red,
              ),
            ),
            Text(
              data,
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s15,
                fontWeight: FontWeight.bold,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width * .5,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black87,
                      fontSize: 13.5,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
