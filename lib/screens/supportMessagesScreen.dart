import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/chatButtonsWidgetSupport.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/SupportList.dart';
import '../../models/SupportMessage.dart';
import '../../models/user.dart';
import '../../providers/user_data_provider.dart';
import '../../widget/AppointChatMessageItem.dart';
import '../../widget/processing_dialog.dart';
import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../widget/custom_outlined_button.dart';

var image;
File? selectedProfileImage;

class SupportMessageScreen extends StatefulWidget {
  final SupportList item;
  final GroceryUser user;
  final String theme;

  const SupportMessageScreen(
      {required this.item, required this.user, required this.theme});

  @override
  _SupportMessageScreenState createState() => _SupportMessageScreenState();
}

class _SupportMessageScreenState extends State<SupportMessageScreen> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();

  bool loading = false;
  bool loadingCall = false;
  late String imageUrl;
  var stCollection = 'messages', theme = "light";
  final ScrollController listScrollController = new ScrollController();
  bool answered = false, done = true, endingCall = false, pending = false;
  bool checkAgora = false;
  final FocusNode focusNode = new FocusNode();
  String mobileNumber = '..';
  bool isRTL = false;
  late Size size;
  static final formKey = GlobalKey<FormState>();
  static Key _k1 = new GlobalKey();

  @override
  void initState() {
    super.initState();
    loading = false;
    pending = widget.item.pending!;
    getUserMobileNumber();
    userReadHisMessage(widget.user.userType!);
  }

  getUserMobileNumber() async {
    DocumentReference userRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.item.userUid);
    final DocumentSnapshot userSnapshot = await userRef.get();
    var phone = GroceryUser.fromMap(userSnapshot.data() as Map).phoneNumber;
    setState(() {
      mobileNumber = phone!;
    });
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return WillPopScope(
      onWillPop: endSupport,
      child: Form(
        key: formKey,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Column(
            children: <Widget>[
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? SizedBox(
                      height: AppSize.h10.h,
                    )
                  : SizedBox(),
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? Container(
                      height: AppSize.h1.h,
                      color: AppColors.grey2,
                    )
                  : SizedBox(),
              headerWidget(size),
              Visibility(
                  visible: widget.user.userType == "SUPPORT",
                  child: supportWidget()),
              Visibility(
                visible: widget.user.userType != "SUPPORT",
                child: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? SizedBox()
                    : helpWidget(),
                //helpWidget()
              ),
              /* Expanded(
                child: RealtimeDBPagination(
                  reverse: false,
                  isLive: true,
                  query: UserDataProvider.realtimeDbRef
                      .child('/SupportMessage/${widget.item.supportListId}')
                      .orderByChild('messageTime'),
                  itemBuilder: (context, dataSnapshot, index) {
                    final data = dataSnapshot.value as Map;
                     return  AppointChatMessageItem(
                         message: SupportMessage.fromDatabase(
                           Map<String, dynamic>.from(data),),
                         user: widget.user
                     );
                    // Do something cool with the data
                  }, orderBy: 'messageTime',
                ),
              ),*/
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    refreshChangeListener.refreshed = true;
                  },
                  child: StreamBuilder(
                    stream: UserDataProvider.realtimeDbRef
                        .child('/SupportMessage/${widget.item.supportListId}')
                        .orderByChild('messageTime')
                        .onValue,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.data == null || !snapshot.hasData) {
                        return Center(
                          child: Text(
                            getTranslated(context, "writeMessageToSupport"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithralight"),
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                              color: AppColors.grey3,
                              fontSize: AppFontsSizeManager.s26_6,
                            ),
                          ),
                        );
                      } else if ((snapshot.data!).snapshot.value == null) {
                        return Center(
                          child: Text(
                            getTranslated(context, "writeMessageToSupport"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithralight"),
                              fontWeight: FontWeight.w300,
                              fontStyle: FontStyle.normal,
                              color: AppColors.grey3,
                              fontSize: AppFontsSizeManager.s26_6.sp,
                            ),
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
                          padding: EdgeInsets.only(
                              left: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppPadding.p0_25
                                  : 0,
                              right: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppPadding.p0_25
                                  : 0),
                          //padding: EdgeInsets.zero,
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
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? SizedBox(
                      height: AppSize.h20.h,
                    )
                  : SizedBox(),
              // buildInput(size),
              ChatButtonWidgetSupport(
                key: _k1,
                onSendMessage: onSendMessage,
              ),
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? SizedBox(
                      height: AppSize.h220.h,
                    )
                  : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  _scrollToBottom() {
    FirebaseDatabase.instance
        .ref()
        .child('/SupportMessage/${widget.item.supportListId}')
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

  Widget roundedButton(String buttonLabel, Color bgColor, Color textColor) {
    var loginBtn = new Container(
      padding: EdgeInsets.all(AppPadding.p5),
      alignment: FractionalOffset.center,
      decoration: new BoxDecoration(
        color: bgColor,
        borderRadius:
            new BorderRadius.all(const Radius.circular(AppRadius.r10)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: new TextStyle(
            color: textColor,
            fontSize: AppFontsSizeManager.s20.sp,
            fontWeight: FontWeight.w300),
      ),
    );
    return loginBtn;
  }

  twilioCall() async {}

  rateSupport() {
    onSendMessage(
        getTranslated(context, "closeSupportChatText"), "closing", size);
  }

  Future<void> onSendMessage(String content, String type, Size size) async {
    FocusScope.of(context).unfocus();
    if ((content.trim() != '' && type == "text") || type != "text") {
      if (widget.user.userType == "SUPPORT") {
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': FieldValue.increment(1),
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type == "text"
              ? content
              : type == "image"
                  ? "imageFile"
                  : "voiceFile",
        }, SetOptions(merge: true));
      } else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'supportMessageNum': FieldValue.increment(1),
          'supportListStatus': false,
          'userName': widget.user.name,
          'messageTime': FieldValue.serverTimestamp(),
          'lastMessage': type == "text"
              ? content
              : type == "image"
                  ? "imageFile"
                  : "voiceFile",
        }, SetOptions(merge: true));
      String messageId = Uuid().v4();
      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      sendNotification(data, widget.user.name.toString());
      await UserDataProvider.realtimeDbRef
          .child("SupportMessage/${widget.item.supportListId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'supportId': widget.item.supportListId,
      });

      //listScrollController.animateTo(0.0,  duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> sendNotification(
    String text,
    String from,
  ) async {
    // Get reference to collection
    final collectionRef = FirebaseFirestore.instance.collection('Users');

// Build query
    final query = collectionRef.where('userType', isEqualTo: 'SUPPORT');

// Get documents
    QuerySnapshot querySnapshot = await query.get();

// Loop through documents
    for (DocumentSnapshot documentSnapshot in querySnapshot.docs) {
      // Extract data as Map
      Map<dynamic, dynamic> data = await documentSnapshot.data() as Map;

      // Print specific field
      // print('6256');
      // print(data['uid']);

      try {
        await sendFCMCallNotification(data['tokenId'], from, text);
        // Map notifMap = Map();
        // notifMap.putIfAbsent('title', () => "Chat");
        // notifMap.putIfAbsent('body', () => text);
        // notifMap.putIfAbsent('userId', () => data['uid']);
        // // notifMap.putIfAbsent(
        // //     'appointmentId', () => widget.appointment.appointmentId);
        // var refundRes = await http.post(
        //   Uri.parse(
        //       'https://fcm.googleapis.com/fcm/send'),
        //   body: notifMap,
        // );
      } catch (e) {}
    }
    // try {
    //   Map notifMap = Map();
    //   notifMap.putIfAbsent('title', () => "Chat");
    //   notifMap.putIfAbsent('body', () => text);
    //   notifMap.putIfAbsent('userId', () => userId);
    //   // notifMap.putIfAbsent(
    //   //     'appointmentId', () => widget.appointment.appointmentId);
    //   var refundRes = await http.post(
    //     Uri.parse(
    //         'https://us-central1-dream-43bb8.cloudfunctions.net/sendChatNotification'),
    //     body: notifMap,
    //   );
    // } catch (e) {
    //
    // }
  }

  Future<void> sendFCMCallNotification(
      String fcmToken, String from, String body) async {
    try {
      var url = Uri.parse("https://fcm.googleapis.com/fcm/send");
      var headers = {
        "Content-Type": "application/json",
        "Authorization":
            "key=AAAAdx0YJPM:APA91bHIgSma88jdHe_Pj7LgGoxyNEmxCdU8F0B2cv94oH1oO8ACR78byZjYMcEdKanprXICdORGQ2a1S069-S3_YcO4h-_wFzfhucweuLTg6FfKbIqBhuRQq_uymcXPCh98Slw3T1Xa",
      };
      var message = {
        "to": fcmToken,
        "priority": "high",
        "notification": {
          "title": "new message from $from",
          "body": body,
          "channel_id": "new-support_channel",
          "sound": "default",
          "vibrate_timings": [0, 1000, 500, 1000, 500],
          "default_vibrate_timings": true,
          "default_sound": true,
          "importance": "high",
          "visibility": "public",
          "notification_count": 1,
        }
      };
      var response =
          await http.post(url, headers: headers, body: jsonEncode(message));
      if (response.statusCode == 200) {
      } else {}
    } catch (e) {
      print("Error sending FCM call notification: $e");
    }
  }

  Future<void> callAnswered() async {
    showUpdatingDialog();
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'supportListStatus': false,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'supportListStatus': true,
      'openingStatus': false,
      'supportMessageNum': 0,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.user.uid)
        .set({
      'answeredSupportNum':
          int.parse(widget.user.answeredSupportNum.toString()) + 1,
    }, SetOptions(merge: true));
    var date = DateTime.now();
    await FirebaseFirestore.instance
        .collection(Paths.supportAnalysisPath)
        .doc(Uuid().v4())
        .set({
      'time': DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
      'techSupportUser': widget.user.uid,
    }, SetOptions(merge: true));
    Navigator.pop(context);
  }

  Future<void> userReadHisMessage(String type) async {
    try {
      if (type == "SUPPORT")
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          //'supportMessageNum': 0,
          'openingStatus': true,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));
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

  Future<bool> endSupport() async {
    try {
      if (widget.user.userType == "SUPPORT")
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'openingStatus': false,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection("SupportList")
            .doc(widget.item.supportListId)
            .set({
          'userMessageNum': 0,
        }, SetOptions(merge: true));
      Navigator.of(context).pop(true);
      return Future.value(true);
    } catch (e) {
      return Future.value(true);
    }
  }

  void showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
  }

  jitsiCall() async {
    try {
      FirebaseFunctions functions = FirebaseFunctions.instance;
      //   functions.useFunctionsEmulator('127.0.0.1', 5001);
      //functions("10.0.2.2", 5001);

//
      HttpsCallable callable = functions.httpsCallable("checkUserCallState");

      final res = await callable.call({
        'appointmentId': widget.item.supportListId,
        'reciverId': widget.item.userUid,
        'isNormal': false
      });

      if (res.data['code'] == 101) {
        Fluttertoast.showToast(msg: res.data['message']);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: res.data['message']));
      } else if (res.data['code'] == 200) {
        // Future(() =>
        //     Navigator.of(context).push(MaterialPageRoute(builder: (con) =>
        //         CallSample(host: widget.item.supportListId, iscaller: true,
        //           loggedUser: widget
        //               .user, isVideo: false,normalCall: false,CallerId: FirebaseAuth.instance.currentUser!.uid!
        //           ,ReciverId: widget.item.userUid,)
        //     )));
      }
    } catch (e) {}
  }

  Future<void> pendChat() async {
    showUpdatingDialog();
    await FirebaseFirestore.instance
        .collection("SupportList")
        .doc(widget.item.supportListId)
        .set({
      'pending': pending,
    }, SetOptions(merge: true));
    Navigator.pop(context);
  }

  headerWidget(Size size) {
    return Container(
        width: size.width,
        child: Padding(
          padding: EdgeInsets.only(
              left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 0
                  : AppPadding.p32.w,
              right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 0
                  : AppPadding.p32.w,
              top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 0
                  : AppPadding.p10,
              bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 0
                  : AppPadding.p10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  widget.user.userType == "SUPPORT"
                      ? Container(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w75.w
                                  : AppSize.w45.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h75.h
                                  : AppSize.h45.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular((kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r25.r
                                : AppRadius.r13.r),
                          ),
                          child: CustomOulinedButton(
                            onPress: () {
                              endSupport();
                            },
                            iconData: Icons.arrow_back_ios,
                            color: AppColors.black,
                            borderColor: Colors.black,
                          ),
                        )
                      : SizedBox(),
                  widget.user.userType != "SUPPORT"
                      ? (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? SizedBox()
                          : Row(
                              children: [
                                SvgPicture.asset(
                                  AssetsManager.headphones,
                                  width: AppSize.w36.w,
                                  height: AppSize.h40_6.h,
                                ),
                                SizedBox(width: AppSize.w10.w),
                                Text(
                                  getTranslated(context, "tecSupport"),
                                  style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s31.sp
                                          : AppFontsSizeManager.s26_6.sp,
                                      color: AppColors.pureBlack,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            )
                      : Column(
                          children: [
                            Text(
                              widget.user.userType == "SUPPORT"
                                  ? widget.item.userName == null
                                      ? " "
                                      : widget.item.userName
                                  : getTranslated(context, "tecSupport"),
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s31.sp
                                      : AppFontsSizeManager.s20.sp,
                                  color: Colors.black.withOpacity(0.8),
                                  fontWeight: FontWeight.w300),
                            ),
                            Text(
                              mobileNumber,
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s31.sp
                                      : AppFontsSizeManager.s20.sp,
                                  color: Colors.black.withOpacity(0.8),
                                  fontWeight: FontWeight.w300),
                            )
                          ],
                        ),
                ],
              ),
              widget.user.userType == "SUPPORT"
                  ? Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r50),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.white.withOpacity(0.6),
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: mobileNumber));
                                showSnack(getTranslated(context, "copyDone"),
                                    context);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                width: AppSize.w38.w,
                                height: AppSize.h35.h,
                                child: Icon(
                                  Icons.copy,
                                  color: AppColors.pink,
                                  size: AppSize.w24,
                                ),
                              ),
                            ),
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r50),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: Colors.white.withOpacity(0.6),
                              onTap: () {
                                jitsiCall();
                                //  twilioCall();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                width: AppSize.w38.w,
                                height: AppSize.h35.h,
                                child: Icon(
                                  Icons.wifi_calling,
                                  color: AppColors.pink,
                                  size: AppSize.w24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ],
          ),
        ));
  }

  supportWidget() {
    return Padding(
      padding: EdgeInsets.only(
          right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppPadding.p0_2
              : AppPadding.p10,
          left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppPadding.p0_2
              : AppPadding.p10,
          top: AppPadding.p15,
          bottom: AppPadding.p15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: answered,
                onChanged: (value) {
                  setState(() {
                    answered = !answered;
                    callAnswered();
                  });
                },
              ),
              Text(
                getTranslated(context, "answered"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s15.sp,
                  color: AppColors.grey,
                ),
              ),
              Spacer(),
              OutlinedButton(
                onPressed: () {
                  rateSupport();
                },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r15.r),
                  )),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 20,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      getTranslated(context, 'rateUs'),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s15.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                value: pending,
                onChanged: (value) {
                  setState(() {
                    pending = !pending;
                    pendChat();
                  });
                },
              ),
              Text(
                getTranslated(context, "pendChat"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s15.sp,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  helpWidget() {
    return Padding(
      padding: EdgeInsets.only(
          left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppPadding.p0_25
              : AppPadding.p32.w,
          right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppPadding.p0_25
              : AppPadding.p32.w,
          top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.height * AppPadding.p0_1
              : AppPadding.p10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h34.r
                : AppSize.h34.h,
            width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h34.r
                : AppSize.w34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.pink, width: .1),
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: Center(
              child: SvgPicture.asset(
                AssetsManager.help,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h34.r
                    : AppSize.w34_6.r,
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h34.r
                    : AppSize.h34_6.r,
              ),
            ),
          ),
          SizedBox(
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w5.w
                  : AppSize.w16.w),
          Text(
            getTranslated(context, "helpText"),
            style: TextStyle(
              fontFamily: getTranslated(context, "Ithra"),
              color: AppColors.linear8,
              fontSize: AppFontsSizeManager.s26_6.sp,
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.normal,
            ),
          )
        ],
      ),
    );
  }
}
