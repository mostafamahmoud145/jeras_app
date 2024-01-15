import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../localization/localization_methods.dart';
import '../models/AppAppointments.dart';
import '../models/order.dart';
import '../models/setting.dart';

class EndCallDialog extends StatefulWidget {
  final AppAppointments appointment;
  final GroceryUser user;
  dynamic result;

  EndCallDialog({
    required this.appointment,
    required this.user,
    this.result,
  });

  @override
  _EndCallDialogState createState() => _EndCallDialogState();
}

class _EndCallDialogState extends State<EndCallDialog> {
  bool endingCall = false, endingCallTwo = false, done = true, discount = false;
  final _infoStrings = <String>[];
  bool muted = false,
      join = false,
      camera = false,
      firstTime = false,
      callStart = false,
      speaker = false;
  late RtcEngine _engine;
  late Size size;
  int minutes = 0, seconds = 0;
  String? image, name;
  String appId = "680d9b31416c46b3850f1709f2a54d9e",
      uidCloud = "",
      sid = "",
      resourceId = '';
  static final _users = <int>[];
  late AccountBloc accountBloc;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    initialize();
  }

  Future<void> initialize() async {
    try {
      _addAgoraEventHandlers();
      await _engine.joinChannel(
          null, widget.appointment.appointmentId, null, 0);
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateTime t2 = DateTime.now();
    DateTime t1 = DateTime(2023, 7, 17, 8);

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
          " Pm";
    else
      time = (localDate.hour).toString() +
          ":" +
          localDate.minute.toString() +
          " Am";

    final views = _getRenderViews();
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppRadius.r15),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.only(
          left: AppPadding.p32.w, right: AppPadding.p32.w, top: AppPadding.p20, bottom: AppPadding.p32.h),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (route) => false,
                      );
                    },
                    child: SvgPicture.asset(
                      AssetsManager.moveCloseIconPath,
                      width: AppSize.w32.w,
                      height: AppSize.h32.h,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: AppSize.h40.h,
              ),
              Text(
                getTranslated(context, "areYouSureCloseAppointment"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s26_6.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black1,

                ),
              ),
              SizedBox(
                height: AppSize.h32.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  endingCall
                      ? Center(child: CircularProgressIndicator())
                      : InkWell(
                    onTap: () async {
                      setState(() {
                        endingCall = true;
                      });
                      callDone(context);
                    },
                    child: Container(
                      height: AppSize.h35,
                      width: AppSize.w178_6.w,
                      padding: const EdgeInsets.all(AppPadding.p2),
                      decoration: BoxDecoration(
                        color: AppColors.pink,
                        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, "yes"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: Colors.white,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () async {
                      await FirebaseFirestore.instance
                          .collection(Paths.appAppointments)
                          .doc(widget.appointment.appointmentId)
                          .set({
                        'allowCall': false,
                      }, SetOptions(merge: true));
                      Navigator.pop(context);
                      //Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                            (route) => false,
                      );
                    },
                    child: Container(
                      height: AppSize.h35,
                      width: AppSize.w178_6.w,
                      padding: const EdgeInsets.all(AppPadding.p2),
                      decoration: BoxDecoration(
                        color: AppColors.lightPink,
                        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                          border: Border.all(
                            color: AppColors.linear2,
                            width: 1.5.w,
                          )
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, "no"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.pink,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  //-----------
  confirmEndCallDialog(Size size, BuildContext context) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16, right: AppPadding.p16, top: AppPadding.p20, bottom: AppPadding.p10),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: AppSize.h15,
                ),
                Text(
                  getTranslated(context, "areYouSureCloseAppointment"),
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.pink,
                  ),
                ),
                SizedBox(
                  height: AppSize.h10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection(Paths.appAppointments)
                            .doc(widget.appointment.appointmentId)
                            .set({
                          'allowCall': false,
                        }, SetOptions(merge: true));
                        Navigator.pop(context);
                        //Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      child: Container(
                        height: AppSize.h35,
                        width: AppSize.w50,
                        padding: const EdgeInsets.all(AppPadding.p2),
                        decoration: BoxDecoration(
                          color: AppColors.lightPink,
                          borderRadius: BorderRadius.circular(AppRadius.r10),
                        ),
                        child: Center(
                          child: Text(
                            getTranslated(context, "no"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pink,
                                fontSize: AppFontsSizeManager.s11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    endingCall
                        ? Center(child: CircularProgressIndicator())
                        : InkWell(
                            onTap: () async {
                              setState(() {
                                endingCall = true;
                              });
                              callDone(context);
                            },
                            child: Container(
                              height: AppSize.h35,
                              width: AppSize.w50,
                              padding: const EdgeInsets.all(AppPadding.p2),
                              decoration: BoxDecoration(
                                color: AppColors.pink,
                                borderRadius: BorderRadius.circular(AppRadius.r10),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "yes"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.white,
                                    fontSize: AppFontsSizeManager.s11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(
          uid: uid,
          channelId: '',
        )));
    return list;
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          uidCloud = uid.toString();
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });

        //acquire();
      },
      leaveChannel: (stats) {
        Fluttertoast.showToast(
            msg: "You are alone now",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.red,
            textColor: AppColors.white,
            fontSize: AppFontsSizeManager.s16);
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          callStart = true;
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
    ));
  }

  Future<void> callDone(BuildContext context) async {
    try {
      //update appointment
      var answeredCallNum = 0, packageCallNum = 0, remainingCall = 0;
      var dateNow = DateTime.now();
      if (done &&
          widget.user.userType == "CONSULTANT") {
        done = false;
        //close appointment

        if (widget.appointment.consultType == "vocal") {
          await FirebaseFirestore.instance
              .collection(Paths.appAppointments)
              .doc(widget.appointment.appointmentId)
              .set({
            'appointmentStatus': "closed",
            'allowCall': false,
            'closedUtcTime': dateNow.toUtc().toString(),
            'closedDate': {
              'day': dateNow.toUtc().day,
              'month': dateNow.toUtc().month,
              'year': dateNow.toUtc().year,
            },
          }, SetOptions(merge: true));
        } else {
          await FirebaseFirestore.instance
              .collection(Paths.forEverAppointmentsPath)
              .doc(Uuid().v4())
              .set({
            'appointmentId': widget.appointment.appointmentId,
            'appointmentStatus': 'closed',
            'timestamp': DateTime.now().toUtc(),
            'utcTime': DateTime.now().toUtc().toString(),
            "consultType": widget.appointment.consultType,
            'orderId': widget.appointment.orderId,
            'callPrice': widget.appointment.callPrice,
            'consult': {
              'uid': widget.appointment.consult.uid,
              'name': widget.appointment.consult.name,
              'image': widget.appointment.consult.image,
              'phone': widget.appointment.consult.phone,
              'countryCode': widget.appointment.consult.countryCode,
              'countryISOCode': widget.appointment.consult.countryISOCode,
            },
            'user': {
              'uid': widget.appointment.user.uid,
              'name': widget.appointment.user.name,
              'image': widget.appointment.user.image,
              'phone': widget.appointment.user.phone,
              'countryCode': widget.appointment.user.countryCode,
              'countryISOCode': widget.appointment.user.countryISOCode,
            },
            'date': {
              'day': DateTime.now().toUtc().day,
              'month': DateTime.now().toUtc().month,
              'year': DateTime.now().toUtc().year,
            },
            'time': {
              'hour': DateTime.now().toUtc().hour,
              'minute': DateTime.now().toUtc().minute,
            },
          });
        }

        //update order
        await FirebaseFirestore.instance
            .collection(Paths.ordersPath)
            .doc(widget.appointment.orderId)
            .get()
            .then((value) async {
          packageCallNum = Orders.fromMap(value.data() as Map).packageCallNum;
          if (widget.appointment.consultType == "glorified" ||
              widget.appointment.consultType == "vocal") {
            await FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .where(
                  'orderId',
                  isEqualTo: widget.appointment.orderId,
                )
                .get()
                .then((value) async {
              if (value.docs.length > 0) {
                remainingCall = packageCallNum - value.docs.length;
                for (var doc in value.docs) {
                  if (doc['appointmentStatus'] != null &&
                      doc['appointmentStatus'] == 'closed') answeredCallNum++;
                }
              } else {
                remainingCall = packageCallNum;
                answeredCallNum = 0;
              }
              await FirebaseFirestore.instance
                  .collection(Paths.ordersPath)
                  .doc(widget.appointment.orderId)
                  .set({
                'answeredCallNum': answeredCallNum,
                'orderStatus': packageCallNum == answeredCallNum
                    ? "closed"
                    : remainingCall == 0
                        ? 'completed'
                        : 'open',
                'remainingCallNum': remainingCall > 0 ? remainingCall : 0,
              }, SetOptions(merge: true));
            }).catchError((err) {
              errorLog("callDone", err.toString());
            });
          } else {
            await FirebaseFirestore.instance
                .collection(Paths.forEverAppointmentsPath)
                .where(
                  'orderId',
                  isEqualTo: widget.appointment.orderId,
                )
                .get()
                .then((value) async {
              if (value.docs.length > 0) {
                remainingCall = (packageCallNum - value.docs.length) > 0
                    ? (packageCallNum - value.docs.length)
                    : 0;
                answeredCallNum = value.docs.length;
              } else {
                remainingCall = packageCallNum;
                answeredCallNum = 0;
              }

              await FirebaseFirestore.instance
                  .collection(Paths.ordersPath)
                  .doc(widget.appointment.orderId)
                  .set({
                'answeredCallNum': answeredCallNum,
                'orderStatus':
                    answeredCallNum >= packageCallNum ? "closed" : 'completed',
                'remainingCallNum': remainingCall
              }, SetOptions(merge: true));
              DateTime newDate = DateTime.parse(widget.appointment.utcTime);
              for (int x = 1; x < 15; x++) {
                var _now2 = newDate.add(Duration(days: x));

                if (widget.user.workDays!.contains(_now2.weekday.toString())) {
                  await FirebaseFirestore.instance
                      .collection(Paths.appAppointments)
                      .doc(widget.appointment.appointmentId)
                      .set({
                    'utcTime': _now2.toString(),
                    'date': {
                      'day': _now2.day,
                      'month': _now2.month,
                      'year': _now2.year,
                    },
                    'remainingCallNum': (packageCallNum - answeredCallNum) > 0
                        ? (packageCallNum - answeredCallNum)
                        : 0,
                    'appointmentStatus':
                        answeredCallNum >= packageCallNum ? "closed" : 'open',
                    'allowCall': false
                  }, SetOptions(merge: true));
                  break;
                } else {}
              }
            }).catchError((err) {
              errorLog("callDone", err.toString());
            });
          }

          //update consultbalance
          DocumentReference docRef = FirebaseFirestore.instance
              .collection(Paths.settingPath)
              .doc("pzBqiphy5o2kkzJgWUT7");
          final DocumentSnapshot taxDocumentSnapshot = await docRef.get();
          var taxes = Setting.fromMap(taxDocumentSnapshot.data() as Map).taxes;

          DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(widget.user.uid)
              .get();
          GroceryUser currentUser =
              GroceryUser.fromMap(documentSnapshot.data() as Map);
          dynamic taxesvalue = (widget.appointment.callPrice * taxes) / 100;
          dynamic consultBalance2 = double.parse(
              ((widget.appointment.callPrice - taxesvalue).toString()));

          dynamic consultBalance = double.parse(currentUser.balance.toString());
          dynamic openOrders = double.parse(currentUser.openOrders.toString());
          dynamic payedBalance = consultBalance2;
          if (currentUser.payedBalance != null)
            payedBalance = payedBalance + currentUser.payedBalance;


          if (currentUser.balance != null)
            consultBalance2 = consultBalance + consultBalance2;

          //update consult order numbers
          int consultOrdersNumbers = 1;
          if (widget.user.ordersNumbers != null)
            consultOrdersNumbers = 1 + widget.user.ordersNumbers!;

          endingCall == false
              ? await FirebaseFirestore.instance
                  .collection(Paths.usersPath)
                  .doc(widget.user.uid)
                  .set({
                  'payedBalance': payedBalance,
                  'ordersNumbers': consultOrdersNumbers,
                  'consultOpenAppointmentDates':
                      widget.user.consultOpenAppointmentDates
                }, SetOptions(merge: true))
              : await FirebaseFirestore.instance
                  .collection(Paths.usersPath)
                  .doc(widget.user.uid)
                  .set({
                  'balance': consultBalance2,
                  'payedBalance': payedBalance,
                  'ordersNumbers': consultOrdersNumbers,
                  'consultOpenAppointmentDates':
                      widget.user.consultOpenAppointmentDates,
            'openOrders': openOrders - 1
                }, SetOptions(merge: true));
          if (widget.appointment.course != null) {
            sendCourseReviewNotification("test Course Name", "test Course Id",
                "${widget.user.uid}", "${widget.appointment.appointmentId}");
          }

          if (answeredCallNum >= packageCallNum ||
              answeredCallNum == packageCallNum / 2) {
            sendReviewNotification(
                widget.appointment.consult.name!,
                widget.appointment.consult.uid!,
                widget.appointment.user.uid!,
                widget.appointment.appointmentId);
          }

          /*  setState(() {
            endingCall=false;
          });*/
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          accountBloc.add(GetLoggedUserEvent());
        }).catchError((err) {
          errorLog("callDone", err.toString());
        });
      }
    } catch (e) {
      errorLog("callDone", e.toString());
    }
  }



  Future<void> sendReviewNotification(String consultName, String consultUid,
      String userId, String appointmentId) async {
    try {
      Map notifMap = Map(); //sendReviewNotification
      notifMap.putIfAbsent(
          'consultName', () => widget.appointment.consult.name);
      notifMap.putIfAbsent('consultUid', () => widget.appointment.consult.uid);
      notifMap.putIfAbsent('userId', () => widget.appointment.user.uid);
      notifMap.putIfAbsent(
          'appointmentId', () => widget.appointment.appointmentId);
      await http.post(
        Uri.parse(
            'https://us-central1-app-jeras.cloudfunctions.net/sendReviewNotification'),
        body: notifMap,
      );
    } catch (e) {
      /*  setState(() {
            endingCall=false;
          });*/
      Navigator.pop(context);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
        (route) => false,
      );
      accountBloc.add(GetLoggedUserEvent());
    }
  }

  Future<void> sendCourseReviewNotification(String courseName, String courseid,
      String userId, String appointmentId) async {
    try {
      Map notifMap = Map(); //sendReviewNotification
      notifMap.putIfAbsent('courseName', () => widget.appointment.course!.name);
      notifMap.putIfAbsent('courseid', () => widget.appointment.course!.id);
      notifMap.putIfAbsent('userId', () => widget.appointment.user.uid);
      notifMap.putIfAbsent(
          'appointmentId', () => widget.appointment.appointmentId);
      await http.post(
        Uri.parse(
            'https://us-central1-app-jeras.cloudfunctions.net/sendCourseReviewNotification'),
        body: notifMap,
      );
    } catch (e) {}
  }

  errorLog(String function, String error) async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': widget.user == null ? " " : widget.user.phoneNumber,
      'screen': "videoScreen",
      'function': function,
    });
  }
}
