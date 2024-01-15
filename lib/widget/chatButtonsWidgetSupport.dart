import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:uuid/uuid.dart';

import '../config/app_constat.dart';
import '../localization/localization_methods.dart';
import '../models/AppAppointments.dart';
import '../models/user.dart';
import '../widget/rocordingWidget.dart';

class ChatButtonWidgetSupport extends StatefulWidget {
  final onSendMessage;
  AppAppointments? appointment;
  GroceryUser? user;

  ChatButtonWidgetSupport({
    Key? key,
    this.onSendMessage,
    this.appointment,
    this.user,
  }) : super(key: key);

  @override
  State<ChatButtonWidgetSupport> createState() =>
      _ChatButtonWidgetSupportState();
}

class _ChatButtonWidgetSupportState extends State<ChatButtonWidgetSupport> {
  bool loading = false, uploadVideo = false, load = false;
  ValueNotifier<String> text = ValueNotifier("");
  final TextEditingController textEditingController = TextEditingController();
  var image;
  File? selectedProfileImage;
  final FocusNode focusNode = new FocusNode();
  bool showPlayer = false;
  String? audioPath;
  String result = "recoding url";
  // static final formKey = GlobalKey<FormState>();
  // static Key _k1 = new GlobalKey();

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
          padding: EdgeInsets.symmetric(
              horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p394.w
                  : AppPadding.p13_3.r),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? null
                      : AppSize.w453_3.w,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h100.h
                      : AppSize.h72.h,
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p67.w
                              : 0),
                  decoration: BoxDecoration(
                    color: AppColors.grey4,
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r16.r
                            : AppRadius.r66_6.r),
                  ),
                  child: Row(
                    children: <Widget>[
                      (kIsWeb || size.width >= 500)
                          ? SizedBox()
                          : new IconButton(
                              icon: new SvgPicture.asset(
                                AssetsManager.docs,
                                width: (kIsWeb || size.width >= 500)
                                    ? AppSize.w40.w
                                    : AppSize.w26_6.w,
                                height: (kIsWeb || size.width >= 500)
                                    ? AppSize.h40.h
                                    : AppSize.h26_6.h,
                              ),
                              onPressed: () => _pickFile("file", size),
                              //cropImage(context), // getImage(0),
                              color: Theme.of(context).primaryColor),

                      // Button send image
                      new IconButton(
                          icon: new SvgPicture.asset(
                            AssetsManager.mdPhotos,
                            width: (kIsWeb || size.width >= 500)
                                ? AppSize.w40.w
                                : AppSize.w26_6.w,
                            height: (kIsWeb || size.width >= 500)
                                ? AppSize.h40.h
                                : AppSize.h26_6.h,
                          ),
                          onPressed: () => _pickUpImage(size),
                          //cropImage(context), // getImage(0),
                          color: Theme.of(context).primaryColor),
                      (kIsWeb || size.width >= 500)
                          ? SizedBox(
                              width: AppSize.w24.w,
                            )
                          : SizedBox(),
                      // Button send video
                      uploadVideo
                          ? CircularProgressIndicator()
                          : new IconButton(
                              icon: new SvgPicture.asset(
                                AssetsManager.mdiVideoOutline,
                                width: (kIsWeb || size.width >= 500)
                                    ? AppSize.h56.h
                                    : AppSize.w36.w,
                                height: (kIsWeb || size.width >= 500)
                                    ? AppSize.h56.h
                                    : AppSize.h40_6.h,
                              ),
                              onPressed: () => _pickFile("video", size),
                              //uploadToStorage(context),
                              color: Theme.of(context).primaryColor,
                            ),
                      (kIsWeb || size.width >= 500)
                          ? SizedBox(
                              width: AppSize.w68.w,
                            )
                          : SizedBox(),
                      // Edit text
                      Flexible(
                        child: Container(
                          child: TextField(
                            // key: _k1,
                            enableInteractiveSelection: true,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: Theme.of(context).primaryColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s28.sp
                                    : AppFontsSizeManager.s17.sp),
                            controller: textEditingController,
                            decoration: InputDecoration.collapsed(
                              hintText: getTranslated(context, "writeMessage"),
                              hintStyle: TextStyle(color: AppColors.grey),
                            ),
                            focusNode: focusNode,
                            onChanged: (str) {
                              text.value = str;
                            },
                          ),
                        ),
                      ),
                      // Button send message
                      loading
                          ? Center(child: CircularProgressIndicator())
                          : Container(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h63_4.h
                                  : AppSize.h40.h,
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w69_9.w
                                  : AppSize.w40.w,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: InkWell(
                                child: SvgPicture.asset(
                                  AssetsManager.sendFilled,
                                  width: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.w69_9.w
                                      : AppSize.w26_6.w,
                                  height: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.h63_4.h
                                      : AppSize.h26_6.h,
                                ),
                                onTap: () async {
                                  widget.onSendMessage(
                                      textEditingController.text, "text", size);
                                  textEditingController.clear();
                                },
                              ),
                            ),
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 0
                                  : AppSize.w21_3.w),
                    ],
                  ),
                ),
              ),
              SizedBox(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? 0
                      : AppSize.w21_3.w),
              // audioRecorder
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? SizedBox()
                  : Container(
                      height: AppSize.h72.h,
                      width: AppSize.w72.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.linear4,
                            AppColors.linear8,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        color: AppColors.blue,
                      ),
                      child: IconButton(
                        onPressed: () {
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
                                onSendMessage: widget.onSendMessage,
                                //  theme: "light",
                                focusNode: focusNode,
                                loggedId: FirebaseAuth
                                    .instance.currentUser!.uid, //widget.user.uid!
                              ),
                            ),
                          );
                        },
                        icon: SvgPicture.asset(
                          AssetsManager.outline_microphone_iconPath_svg,
                          width: AppSize.w18_6.w,
                          height: AppSize.h40.h,
                          color: AppColors.white,
                        ),
                        color: Theme.of(context).primaryColor,
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
}
