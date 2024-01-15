import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jeras/blocs/user_chat/user_chat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/SupportMessage.dart';
import '../../models/user.dart';
import '../../providers/user_data_provider.dart';
import '../../widget/AppointChatMessageItem.dart';
import '../../widget/processing_dialog.dart';
import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../widget/chatButtonsWidget.dart';
import '../widget/custom_back_button.dart';
import 'AgoraCallScreen/agoraVideoCallScreen.dart';

var image;
File? selectedProfileImage;

class AppointmentChatScreen extends StatefulWidget {
  final AppAppointments appointment;
  final GroceryUser user;

  const AppointmentChatScreen({required this.appointment, required this.user});

  @override
  _AppointmentChatScreenState createState() => _AppointmentChatScreenState();
}

class _AppointmentChatScreenState extends State<AppointmentChatScreen> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  bool loadingCall = false, joinMeeting = false;
  late String imageUrl;
  var stCollection = 'messages', theme = "light";
  ValueNotifier<String> text = ValueNotifier("");
  late AccountBloc accountBloc;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  bool answered = false, done = true, endingCall = false;
  bool checkAgora = false, uploadVideo = false;
  final FocusNode focusNode = new FocusNode();
  late Size size;
  late DocumentReference reference;
  bool checkCall = false;
  late StreamSubscription? _updateReadListener;

  @override
  void initState() {
    super.initState();
    // var zoom = ZoomVideoSdk();
    // InitConfig initConfig = InitConfig(
    //   domain: "zoom.us",
    //   enableLog: true,
    // );
    // zoom.initSdk(initConfig);
    loading = false;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    userReadHisMessage(widget.user.userType!);
    reference = FirebaseFirestore.instance
        .collection('AppAppointments')
        .doc(widget.appointment.appointmentId);
    checkStatus();
    addChatListener();
  }

  addChatListener() async {
    _updateReadListener = await UserChat().updateReadMessagesForUser(
        appointmentId: widget.appointment.appointmentId,
        userType: widget.user.userType!);
  }

  Future<void> checkStatus() async {
    reference.snapshots().listen((querySnapshot) {
      if (mounted)
        setState(() {
          checkCall = querySnapshot.get("allowCall");
        });
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    if (_updateReadListener != null) {
      print('_updateReadListener cancelled');
      _updateReadListener!.cancel();
    }
    super.dispose();
  }

  Future<void> userReadHisMessage(String type) async {
    try {
      if (type == "CONSULTANT")
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'userChat': 0,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'consultChat': 0,
        }, SetOptions(merge: true));
    } catch (e) {}
  }

  void launchAnotherApp() async {
    if (!await launchUrl(
        Uri.parse("https://meet.jit.si/8c23f3d7-ac88-40c2-a8c3-79f9fcee9c31"),
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch ';
    }
  }

  _scrollToBottom() {
    FirebaseDatabase.instance
        .ref()
        .child('appointmentsChatMessage/${widget.appointment.appointmentId}')
        .onValue
        .listen((event) {
      if (listScrollController.hasClients)
        listScrollController.animateTo(
          listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            child: SafeArea(
              child: Padding(
                padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? EdgeInsets.only(
                        left: AppPadding.p140.w,
                        right: AppPadding.p140.w,
                        bottom: AppPadding.p25.w,
                        top: AppPadding.p69.h)
                    : EdgeInsets.only(
                        left: AppPadding.p20,
                        right: AppPadding.p20,
                        top: AppPadding.p10,
                        bottom: AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    //c
                    Container(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w75.w
                                : AppSize.w45.w,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h75.h
                                : AppSize.h45.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r40.r
                                  : AppRadius.r13.r),
                        ),
                        child: CustomBackButton(color: Colors.black)),
                    SizedBox(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w31_5.w
                                : AppSize.w10.w),
                    Expanded(
                      child: Text(
                        widget.user.userType == "USER"
                            ? widget.appointment.consult.name!
                            : widget.appointment.user.name!,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s31.sp
                                : AppFontsSizeManager.s25.sp,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w300),
                      ),
                    ),

                    (widget.appointment.appointmentStatus == "open" &&
                            kIsWeb == false)
                        ? agoraCallWidget()
                        : SizedBox(),
                    // SizedBox(width: AppSize.w10.w),
                    // widget.user.userType=="CONSULTANT"?zoomCallWidget():SizedBox()
                  ],
                ),
              ),
            ),
          ),
          Center(
              child: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? Container(
                      color: AppColors.lightGrey,
                      height: AppSize.h1.h,
                      width: size.width * .6)
                  : Container(
                      color: AppColors.lightGrey,
                      height: AppSize.h2.h,
                      width: size.width)),
          SizedBox(
            height: AppSize.h10.h,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                refreshChangeListener.refreshed = true;
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_25
                      : AppSize.w5,
                  vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h20.h
                      : AppSize.h20.h,
                ),
                child: StreamBuilder(
                  stream: FirebaseDatabase.instance
                      .ref()
                      .child(
                          'appointmentsChatMessage/${widget.appointment.appointmentId}')
                      .orderByChild('messageTime')
                      .onValue,
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.data == null || !snapshot.hasData) {
                      return Center(
                        child: Text(getTranslated(context, "sendFirstMessage"),
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"))),
                      );
                    } else if ((snapshot.data!).snapshot.value == null) {
                      return Center(
                        child: Text(
                          getTranslated(context, "sendFirstMessage"),
                          style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra")),
                        ),
                      );
                    } else {
                      List<dynamic> messages = Map<String, dynamic>.from(
                              (snapshot.data!).snapshot.value
                                  as Map<dynamic, dynamic>)
                          .values
                          .toList()
                        ..sort((a, b) =>
                            a['messageTime'].compareTo(b['messageTime']));

                      messages = messages.reversed.toList();
                      return ListView.builder(
                        shrinkWrap: true,
                        reverse: true,
                        padding: EdgeInsets.zero,
                        controller: listScrollController,
                        itemCount: messages.length,
                        itemBuilder: (ctx, index) => AppointChatMessageItem(
                            message: SupportMessage.fromDatabase(
                              Map<String, dynamic>.from(messages[index]),
                            ),
                            user: widget.user),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          widget.appointment.appointmentStatus != "closed"
              ? ChatButtonWidget(
                  onSendMessage: onSendMessage,
                  user: widget.user,
                  appointment: widget.appointment,
                )
              : SizedBox(),
        ],
      ),
    );
  }

  // Future<void> _startZoomMeeting() async{
  //   DatabaseReference ref = FirebaseDatabase.instance.ref("zoomMeeting/${widget.appointment.orderId}");
  //   await ref.set({
  //     "consultId": widget.appointment.consult.uid,
  //     "userId": widget.appointment.user.uid,
  //     "userMeetAccept" : "waiting"
  //   });
  //   Navigator.pushNamed(
  //       context, "/Call",
  //       arguments: CallArguments(
  //           widget.appointment.orderId,
  //           "",
  //           widget.appointment.consult.name.toString(),
  //           "40",
  //           "1",
  //           false,
  //           widget.user.userType.toString(),
  //         widget.appointment,
  //         widget.user
  //       ));
  // }
  //
  // Future<void> _joinZoomMeeting() async{
  //   Navigator.pushNamed(
  //       context, "/Call",
  //       arguments: CallArguments(
  //           widget.appointment.orderId,
  //           "",
  //           widget.appointment.user.name.toString(),
  //           "40",
  //           "0",
  //           true,
  //           widget.user.userType.toString(),
  //           widget.appointment,
  //           widget.user
  //       ));
  // }

  Widget agoraCallWidget() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r50.r),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: Colors.white.withOpacity(0.5),
          onTap: () {
            agoraCall();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            width: AppSize.w50.w,
            height: AppSize.h50.h,
            child: checkCall
                ? Image.asset(
                    AssetsManager.callGif,
                    width: AppSize.w50.w,
                    height: AppSize.h50.h,
                  )
                : Icon(
                    Icons.wifi_calling,
                    color: AppColors.grey,
                    size: AppSize.w24,
                  ),
          ),
        ),
      ),
    );
  }

  // Widget zoomCallWidget(){
  //   return  ClipRRect(
  //     borderRadius: BorderRadius.circular(50.0.r),
  //     child: Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //         splashColor: Colors.white.withOpacity(0.5),
  //         onTap: () {
  //           //showConsultMeetingDialog(context);
  //         },
  //         child: Container(
  //           decoration: BoxDecoration(
  //             color: Colors.transparent,
  //           ),
  //           width: 50.0.w,
  //           height: 50.0.h,
  //           child: Image.asset(
  //             'assets/icons/zoom.png',width: 50.w,height: 50.h,),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<void> onSendMessage(String content, String type, Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId = Uuid().v4();
      await UserDataProvider.realtimeDbRef
          .child(
              "appointmentsChatMessage/${widget.appointment.appointmentId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'appointmentId': widget.appointment.appointmentId,
        'isReceived': false,
        'isRead': false,
      });

      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      if (widget.user.userType == "CONSULTANT") {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'consultChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment.user.uid!, data);
      } else {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment.appointmentId)
            .set({
          'userChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment.consult.uid!, data);
      }
      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
        uploadVideo = false;
      });
    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Future<void> sendNotification(String userId, String text) async {
    try {
      Map notifMap = Map();
      notifMap.putIfAbsent('title', () => "Chat");
      notifMap.putIfAbsent('body', () => text);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent(
          'appointmentId', () => widget.appointment.appointmentId);
      await http.post(
        Uri.parse(
            'https://us-central1-app-jeras.cloudfunctions.net/sendChatNotification'),
        body: notifMap,
      );
    } catch (e) {}
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }

  agoraCall() async {
    if (widget.user.userType == "CONSULTANT") {
      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(widget.appointment.appointmentId)
          .set({
        'allowCall': true,
      }, SetOptions(merge: true));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AgoraVideoCallScreen(
            loggedUser: widget.user,
            appointment: widget.appointment,
          ),
        ),
      );
    } else {
      DocumentReference docRef2 = FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(widget.appointment.appointmentId);
      var doc = await docRef2.get();
      if (AppAppointments.fromMap(doc.data() as Map).allowCall) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgoraVideoCallScreen(
              loggedUser: widget.user,
              appointment: widget.appointment,
            ),
          ),
        );
      } else {
        if (widget.appointment.freeCall == true) {
          /*await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
            'freeCall':true,
          }, SetOptions(merge: true));*/
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgoraVideoCallScreen(
                loggedUser: widget.user,
                appointment: widget.appointment,
              ),
            ),
          );
        } else {
          Fluttertoast.showToast(
              msg: getTranslated(context, "notAllowed"),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: AppColors.red,
              textColor: AppColors.white,
              fontSize: AppFontsSizeManager.s16);
          setState(() {
            joinMeeting = false;
          });
        }
        //add free call
        //enter dialog
        // 20 minute only
        // yes or no
      }
    }
  }
}
