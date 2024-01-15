import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../localization/localization_methods.dart';
import '../../models/SupportMessage.dart';
import '../../models/user.dart';
import '../../providers/user_data_provider.dart';
import '../../widget/AppointChatMessageItem.dart';
import '../../widget/processing_dialog.dart';
import '../FireStorePagnation/bloc/pagination_listeners.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../models/chat.dart';
import '../widget/chatButtonsWidget.dart';

class ChatDetailScreen extends StatefulWidget {
  final Chat item;
  final GroceryUser user;
  final String theme;

  const ChatDetailScreen(
      {required this.item, required this.user, required this.theme});

  @override
  _ChatDetailScreenState createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  PaginateRefreshedChangeListener refreshChangeListener =
      PaginateRefreshedChangeListener();
  late Size size;
  bool loading = false;
  bool loadingCall = false, uploadVideo = false;
  late String imageUrl;
  var stCollection = 'messages', theme = "light";
  final ScrollController listScrollController = new ScrollController();
  bool answered = false, done = true, endingCall = false;
  bool checkAgora = false;
  final FocusNode focusNode = new FocusNode();
  String mobileNumber = '..';
  bool isRTL = false;
  String lang = "";

  @override
  void initState() {
    super.initState();
    userReadHisMessage(widget.user.userType!);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(width: AppSize.w32.w),
                    CustomBackButton(),
                    SizedBox(width: AppSize.w21_3.w),
                    // Text(
                    //   widget.user.userType == "USER"
                    //       ? (getTranslated(context, "conslt") + " ")
                    //       : (getTranslated(context, "client") + " "),
                    //   textAlign: TextAlign.left,
                    //   style: TextStyle(
                    //       fontFamily: getTranslated(context, "Ithra"),
                    //       fontSize:
                    //           (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    //               ? AppFontsSizeManager.s31
                    //               : AppFontsSizeManager.s16,
                    //       color: Colors.black.withOpacity(0.8),
                    //       fontWeight: FontWeight.w300),
                    // ),
                    Flexible(
                      child: new Text(
                        widget.user.userType == "USER"
                            ? widget.item.consult.name.toString()
                            : widget.item.user.name.toString(),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        maxLines: 1,
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: (kIsWeb &&
                                    size.width > AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s31
                                : AppFontsSizeManager.s21_3.sp,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ],
                )),
            Center(
                child: Padding(
              padding: EdgeInsets.only(top: AppPadding.p16.h),
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1.h,
                  width: size.width),
            )),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  refreshChangeListener.refreshed = true;
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_25
                            : AppPadding.p30.h,
                    vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p20
                        : AppPadding.p10.h,
                  ),
                  child: StreamBuilder(
                    stream: FirebaseDatabase.instance
                        .ref()
                        .child('/ChatMessage/${widget.item.chatId}')
                        .orderByChild('messageTime')
                        // .startAfter('${DateTime.now().subtract(Duration(days: 7)).toUtc()}')
                        .onValue,
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.data == null || !snapshot.hasData) {
                        return Center(
                          child:
                              Text(getTranslated(context, "sendFirstMessage")),
                        );
                      } else if ((snapshot.data!).snapshot.value == null) {
                        return Center(
                          child:
                              Text(getTranslated(context, "sendFirstMessage")),
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
            ChatButtonWidget(
              onSendMessage: onSendMessage,
            )
          ],
        ),
      ),
    );
  }

  _scrollToBottom() {
    FirebaseDatabase.instance
        .ref()
        .child('/ChatMessage/${widget.item.chatId}')
        .onValue
        .listen((event) {
      if (listScrollController.hasClients)
        listScrollController.animateTo(
          listScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: AppConstants.milliseconds300),
          curve: Curves.easeOut,
        );
    });
  }

  Future<void> onSendMessage(String content, String type, Size size) async {
    FocusScope.of(context).unfocus();
    if ((content.trim() != '' && type == "text") || type != "text") {
      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      if (widget.user.userType == "CONSULTANT") {
        await FirebaseFirestore.instance
            .collection("Chat")
            .doc(widget.item.chatId)
            .set({
          'userMessageNum': FieldValue.increment(1),
          'messageTime': FieldValue.serverTimestamp(),
          'consult': {
            'uid': widget.user.uid,
            'name': widget.user.name,
            'image': widget.user.photoUrl,
            'phone': widget.user.phoneNumber,
            'countryCode': widget.user.countryCode,
            'countryISOCode': widget.user.countryISOCode,
          },
          'lastMessage': type == "text"
              ? content
              : type == "image"
                  ? "imageFile"
                  : "voiceFile",
        }, SetOptions(merge: true));
        sendNotification(widget.item.user.uid!, data);
      } else {
        await FirebaseFirestore.instance
            .collection("Chat")
            .doc(widget.item.chatId)
            .set({
          'consultMessageNum': FieldValue.increment(1),
          'messageTime': FieldValue.serverTimestamp(),
          'user': {
            'uid': widget.user.uid,
            'name': widget.user.name,
            'image': widget.user.photoUrl,
            'phone': widget.user.phoneNumber,
            'countryCode': widget.user.countryCode,
            'countryISOCode': widget.user.countryISOCode,
          },
          'lastMessage': type == "text"
              ? content
              : type == "image"
                  ? "imageFile"
                  : "voiceFile",
        }, SetOptions(merge: true));
        sendNotification(widget.item.consult.uid!, data);
      }
      String messageId = Uuid().v4();
      await UserDataProvider.realtimeDbRef
          .child("ChatMessage/${widget.item.chatId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'chatId': widget.item.chatId,
      });

      // listScrollController.animateTo(0.0,duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() {
        loading = false;
        uploadVideo = false;
      });
    }
  }

  Future<void> sendNotification(String userId, String text) async {
    try {
      Map notifMap = Map();
      notifMap.putIfAbsent('title', () => "Chat");
      notifMap.putIfAbsent('body', () => text);
      notifMap.putIfAbsent('userId', () => userId);
      notifMap.putIfAbsent('appointmentId', () => widget.item.chatId);
      await http.post(
        Uri.parse(
            'https://us-central1-app-jeras.cloudfunctions.net/sendChatNotification'),
        body: notifMap,
      );
    } catch (e) {}
  }

  Future<void> userReadHisMessage(String type) async {
    try {
      if (type == "CONSULTANT")
        await FirebaseFirestore.instance
            .collection("Chat")
            .doc(widget.item.chatId)
            .set({
          'consultMessageNum': 0,
        }, SetOptions(merge: true));
      else
        await FirebaseFirestore.instance
            .collection("Chat")
            .doc(widget.item.chatId)
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
}
