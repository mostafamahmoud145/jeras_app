import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' as intl;
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../config/app_constat.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/AppAppointments.dart';
import '../models/user.dart';
import '../providers/user_data_provider.dart';
import '../widget/rocordingWidget.dart';
import 'package:http/http.dart' as http;

class ChatButtonWidget extends StatefulWidget {
  final onSendMessage;
  AppAppointments? appointment;
  GroceryUser? user;

  ChatButtonWidget({
    Key? key,
    this.onSendMessage,
    this.appointment,
    this.user,
  }) : super(key: key);

  @override
  State<ChatButtonWidget> createState() => _ChatButtonWidgetState();
}

class _ChatButtonWidgetState extends State<ChatButtonWidget> {
  bool loading = false, uploadVideo = false, load = false;
  ValueNotifier<String> text = ValueNotifier("");
  final TextEditingController textEditingController =
      new TextEditingController();
  var image;
  File? selectedProfileImage;
  final FocusNode focusNode = new FocusNode();
  bool showPlayer = false;
  String? audioPath;
  String result = "recoding url";

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? Container(
                width: size.width * AppSize.w0_5,
                height: AppSize.h1.h,
                color: AppColors.lightGrey3,
              )
            : SizedBox(),
        Padding(
          padding: EdgeInsets.only(
              right: AppPadding.p32.w,
              left: AppPadding.p32.w,
              bottom: AppPadding.p21_3.h),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: (kIsWeb || size.width >= 500) ? null : AppSize.h72.r,
                  padding: EdgeInsets.symmetric(horizontal: AppPadding.p21_3.w),
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_5
                      : double.infinity,
                  // height: (kIsWeb||size.width >= 500)
                  decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.r81_3.r),
                      border: new Border(
                          top: new BorderSide(
                              color: (kIsWeb || size.width >= 500)
                                  ? Colors.grey
                                  : AppColors.white,
                              width: AppSize.w0_5.w)),
                      color: AppColors.grey4),

                  child: Row(
                    children: <Widget>[
                      // Button send image

                      InkWell(
                        child: SvgPicture.asset(
                          AssetsManager.galleryIcon,
                          width: AppSize.w37_3.r,
                          height: AppSize.h37_3.r,
                        ),

                        onTap: () => _pickUpImage(size),
                        //cropImage(context), // getImage(0),
                      ),
                      SizedBox(
                        width: AppSize.w10_6.w,
                      ),

                      // Button send video
                      uploadVideo
                          ? CircularProgressIndicator()
                          : InkWell(
                              child: SvgPicture.asset(
                                AssetsManager.vedioIcon,
                                width: AppSize.w37_3.r,
                                height: AppSize.h37_3.r,
                              ),
                              onTap: () => _pickFile("video", size),
                              //uploadToStorage(context),
                            ),
                      SizedBox(
                        width: AppSize.w10_6.w,
                      ),
                      InkWell(
                        child: SvgPicture.asset(
                          AssetsManager.fileIcon,
                          width: AppSize.w37_3.r,
                          height: AppSize.h37_3.r,
                        ),
                        onTap: () => _pickFile("file", size),
                        //cropImage(context), // getImage(0),
                      ),
                      SizedBox(
                        width: AppSize.w21_3.w,
                      ),

                      // Edit text
                      Flexible(
                        child: Container(
                          child: ValueListenableBuilder<String>(
                            valueListenable: text,
                            builder: (context, value, child) => Directionality(
                              textDirection:
                                  intl.Bidi.detectRtlDirectionality(text.value)
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                              child: TextField(
                                enableInteractiveSelection: true,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                style: TextStyle(
                                    fontFamily:
                                        getTranslated(context, "Ithralight"),
                                    color: Theme.of(context).primaryColor,
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s28.sp
                                        : AppFontsSizeManager.s18_6.sp),
                                controller: textEditingController,
                                decoration: InputDecoration.collapsed(
                                  hintText:
                                      getTranslated(context, "writeMessage"),
                                  hintStyle: TextStyle(color: AppColors.grey),
                                ),
                                focusNode: focusNode,
                                onChanged: (str) {
                                  text.value = str;
                                },
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Button send message
                      loading
                          ? Center(child: CircularProgressIndicator())
                          : InkWell(
                              child: SvgPicture.asset(
                                AssetsManager.sendIcon,
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w29_5.w
                                    : AppSize.w42_6.r,
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h34.h
                                    : AppSize.h40.r,
                              ),
                              onTap: () async {
                                widget.onSendMessage(
                                    textEditingController.text, "text", size);
                                textEditingController.clear();
                              },
                            ),
                    ],
                  ),
                ),
              ),

              //record button
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? SizedBox()
                  : Padding(
                      padding: EdgeInsets.only(right: AppPadding.p21_3.w),
                      child: Container(
                        height: AppSize.h72.r,
                        width: AppSize.w72.r,
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r81_3.r)),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              showModalBottomSheet(
                                elevation: 10,
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) => Container(
                                  height: AppSize.h200.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grey9,
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: AudioRecorder(
                                    onSendMessage: onSendMessage,
                                    //  theme: "light",
                                    focusNode: focusNode,
                                    loggedId: FirebaseAuth.instance.currentUser!
                                        .uid, //widget.user.uid!
                                  ),
                                ),
                              );
                            },
                            child: SvgPicture.asset(
                              AssetsManager.recordIcon,
                              width: AppSize.w21_5.r,
                              height: AppSize.h33_7.r,
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  sendMassageDialoge(
      BuildContext context, Size size, FilePickerResult result, dynamic file) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(right: AppSize.w10_6.w, top: AppSize.h10_6.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h24.h),
                    child: Container(
                      child: kIsWeb == true
                          ? Image.memory(
                              file,
                              width: AppSize.w800.w,
                              height: AppSize.h600.h,
                            )
                          : Image.file(
                              file,
                            ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSize.w32.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            AssetsManager.moveCloseIconPath,
                            width: AppSize.w50.w,
                            height: AppSize.h50.h,
                          ),
                        ),
                        Spacer(),
                        load
                            ? CircularProgressIndicator(
                                color: AppColors.linear2,
                              )
                            : InkWell(
                                onTap: () async {
                                  print('/////////////////$load');
                                  setState(() {
                                    load = true;
                                  });
                                  String url = "";
                                  if (kIsWeb) {
                                    String fileName = result.files.first.name;
                                    Reference storageReference = FirebaseStorage
                                        .instance
                                        .ref()
                                        .child('uploads111/$fileName');
                                    await storageReference.putData(file);
                                    url =
                                        await storageReference.getDownloadURL();
                                    widget.onSendMessage(url, "image", size);
                                  } else {
                                    var uuid = Uuid().v4();
                                    Reference storageReference = FirebaseStorage
                                        .instance
                                        .ref()
                                        .child('files/$uuid');
                                    await storageReference.putFile(file);
                                    url =
                                        await storageReference.getDownloadURL();
                                    widget.onSendMessage(url, "image", size);
                                  }

                                  Navigator.pop(context);
                                  setState(() {
                                    load = false;
                                  });
                                },
                                child: SvgPicture.asset(
                                  AssetsManager.sendIconPath,
                                  width: AppSize.w50.w,
                                  height: AppSize.h50.h,
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  sendMassageDialoge2(BuildContext context, Size size, FilePickerResult result,
      dynamic file, String type) {
    String name2 = result.files.first.name;
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.close,
                    size: 32.w,
                  ),
                ),
                SizedBox(width: 140.w),
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Colors.red,
                    size: AppSize.h53_3,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h21_3.h),
            Text(
              name2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                fontSize: AppFontsSizeManager.s28.sp,
                color: AppColors.linear2,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: AppSize.h16.h),
            load
                ? CircularProgressIndicator(
                    color: AppColors.linear2,
                  )
                : InkWell(
                    onTap: () async {
                      setState(() {
                        load = true;
                      });
                      String url = "";
                      if (kIsWeb) {
                        final fileBytes = result.files.first.bytes;
                        final fileName = result.files.first.name;
                        File file = File.fromRawPath(fileBytes!);
                        print('filename');
                        print(fileName);

                        Reference storageReference = FirebaseStorage.instance
                            .ref()
                            .child('uploads111/$fileName');
                        await storageReference.putData(fileBytes);
                        url = await storageReference.getDownloadURL();
                        print('url');
                        print(url.toString());
                        widget.onSendMessage(url, type, size);
                      } else {
                        var uuid = Uuid().v4();
                        Reference storageReference =
                            FirebaseStorage.instance.ref().child('files/$uuid');

                        await storageReference.putFile(file);
                        url = await storageReference.getDownloadURL();
                        widget.onSendMessage(url, type, size);
                      }

                      Navigator.pop(context);
                      setState(() {
                        load = false;
                      });
                    },
                    child: SvgPicture.asset(
                      AssetsManager.sendIconPath,
                      width: AppSize.w50.w,
                      height: AppSize.h50.h,
                    ),
                  ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  Future<void> _pickUpImage(Size size) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    File file;

    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.first.bytes;
        sendMassageDialoge(context, size, result, fileBytes);
      } else {
        file = File(result.files.single.path.toString());
        sendMassageDialoge(context, size, result, file);
      }

      setState(() {
        load = false;
      });
    }
  }

  Future<void> _pickFile(String type, Size size) async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type == "image"
            ? FileType.custom
            : type == "voice"
                ? FileType.custom
                : type == "file"
                    ? FileType.custom
                    : FileType.custom,
        allowedExtensions: type == "image"
            ? ['png', 'jpg', 'jpeg', 'gif']
            : type == "voice"
                ? ['mp3']
                : type == "file"
                    ? [
                        'pdf',
                        'doc',
                        'docx',
                        'pages',
                        '_pdf',
                        'word',
                      ]
                    : ['mp4']);

    File file;
    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.first.bytes;
        file = File.fromRawPath(fileBytes!);

        sendMassageDialoge2(context, size, result, file, type);
      } else {
        File file = File(result.files.single.path.toString());
        sendMassageDialoge2(context, size, result, file, type);
      }
    }
    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> onSendMessage(String content, String type, Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId = Uuid().v4();
      await UserDataProvider.realtimeDbRef
          .child(
              "appointmentsChatMessage/${widget.appointment!.appointmentId}/$messageId")
          .set({
        'type': type,
        'owner': widget.user!.userType,
        'message': content,
        'messageTime': ServerValue.timestamp,
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user!.name,
        'userUid': widget.user!.uid,
        'appointmentId': widget.appointment!.appointmentId,
        'isReceived': false,
        'isRead': false,
      });

      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      if (widget.user!.userType == "CONSULTANT") {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment!.appointmentId)
            .set({
          'consultChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment!.user.uid!, data);
      } else {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(widget.appointment!.appointmentId)
            .set({
          'userChat': FieldValue.increment(1),
        }, SetOptions(merge: true));
        sendNotification(widget.appointment!.consult.uid!, data);
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
          'appointmentId', () => widget.appointment!.appointmentId);
      await http.post(
        Uri.parse(
            'https://us-central1-app-jeras.cloudfunctions.net/sendChatNotification'),
        body: notifMap,
      );
    } catch (e) {}
  }
}
