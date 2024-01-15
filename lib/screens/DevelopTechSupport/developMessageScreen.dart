import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:uuid/uuid.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/app_constat.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../controller/blocs/account_bloc/account_bloc.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/DevelopTechSupport.dart';
import '../../models/developMessage.dart';
import '../../models/user.dart';
import '../../widget/custom_back_button.dart';
import '../../widget/developItem.dart';
import '../../widget/processing_dialog.dart';
import '../../widget/rocordingWidget.dart';

var image;
File? selectedProfileImage;

typedef _Fn = void Function();

class DevelopMessageScreen extends StatefulWidget {
  final DevelopTechSupport develop;

  final GroceryUser user;

  const DevelopMessageScreen({required this.develop, required this.user});

  @override
  _DevelopMessageScreenState createState() => _DevelopMessageScreenState();
}

class _DevelopMessageScreenState extends State<DevelopMessageScreen> {
  bool loading = false;
  late bool isShowSticker, answered = false, loadStatus = false;
  late String imageUrl;
  var stCollection = 'messages', theme;
  String text = "";
  late Size size;
  late AccountBloc accountBloc;
  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  String? dropdownTypeValue;
  final FocusNode focusNode = new FocusNode();
  bool recording = false, uploadingRecord = false;
  late String recordFilePath;
  int i = 0;
  List<KeyValueModel> _typeArray = [
    KeyValueModel(key: "new", value: "New"),
    KeyValueModel(key: "open", value: "Open"),
    KeyValueModel(key: "done", value: "Done"),
    KeyValueModel(key: "closed", value: "Closed"),
  ];

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    accountBloc = BlocProvider.of<AccountBloc>(context);
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      if(mounted){
        setState(() {
          isShowSticker = false;
        });
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20, right: AppPadding.p20, top: AppPadding.p10, bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(color: AppColors.black),
                      const SizedBox(width: AppSize.w10),
                      Text(
                        widget.develop.userName,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight:AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s31.sp : AppFontsSizeManager.s15.sp,
                          color: AppColors.black2,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p20,
                vertical:
                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.height * AppPadding.p0_05 : AppPadding.p20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  getTranslated(context, "selectStatus"),
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black,
                    fontSize: AppFontsSizeManager.s18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: AppConstants.letterSpacing0_3,
                  ),
                ),
                SizedBox(
                  width: size.width * AppSize.w0_05,
                ),
                Container(
                    height: AppSize.h40,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_15
                        : size.width * AppSize.w0_5,
                    decoration: BoxDecoration(
                        color: theme == "light"
                            ? AppColors.white
                            : Colors.transparent,
                        border: Border.all(
                          color: AppColors.grey,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(AppRadius.r10))),
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                      child: DropdownButton<String>(
                        hint: Text(
                          getTranslated(context, "selectStatus"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            //color: Colors.black,
                            fontSize: AppFontsSizeManager.s15,
                            letterSpacing:AppConstants.letterSpacing0_5,
                          ),
                        ),
                        underline: Container(),
                        isExpanded: true,
                        value: dropdownTypeValue,
                        icon: Icon(Icons.keyboard_arrow_down,
                            color: AppColors.black),
                        iconSize: AppSize.w24,
                        elevation: 16,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color:AppColors.blue,
                          fontSize: AppFontsSizeManager.s13,
                          letterSpacing:AppConstants.letterSpacing0_5,
                        ),
                        items: _typeArray
                            .map((data) => DropdownMenuItem<String>(
                                child: Text(
                                  data.value.toString(),
                                  style: TextStyle(
                                    fontFamily:
                                        getTranslated(context, "Ithra"),
                                    color: AppColors.black,
                                    fontSize: AppFontsSizeManager.s15,
                                    letterSpacing:AppConstants.letterSpacing0_5,
                                  ),
                                ),
                                value: data.key.toString() //data.key,
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            dropdownTypeValue = value!;
                          });
                        },
                      ),
                    )),
              ],
            ),
          ),
          loadStatus
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: AppSize.h45,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_1
                      : size.width * AppSize.w0_5,
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: MaterialButton(
                    onPressed: () {
                      //add notificationMap
                      changeStatus(dropdownTypeValue!);
                    },
                    color: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r15.r),
                    ),
                    child: Text(
                      getTranslated(context, "save"),
                      style: GoogleFonts.poppins(
                        color: theme == "light" ? AppColors.white : AppColors.black,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: AppFontsWeightManager.semiBold,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ),
                ),
          Expanded(
            child: PaginateFirestore(
              scrollController: listScrollController,
              reverse: true,
              itemBuilderType: PaginateBuilderType.listView,
              padding: EdgeInsets.only(
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p20,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p20,
                  bottom: AppPadding.p20,
                  top: AppPadding.p20),
              //Change types accordingly
              itemBuilder: (context, documentSnapshot, index) {
                return DevelopItem(
                    message: DevelopMessage.fromMap(
                        documentSnapshot[index].data() as Map),
                    user: widget.user);
              },
              query: FirebaseFirestore.instance
                  .collection(Paths.dvelopChat)
                  .where('developTechSupportId',
                      isEqualTo: widget.develop.developTechSupportId)
                  .orderBy('messageTime', descending: true),
              isLive: true,
            ),
          ),
          buildInput(size),
        ],
      ),
    );
  }

  Widget buildInput(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? Container(
                width: size.width * AppSize.w0_5,
                height: 1,
                color: AppColors.lightGrey3,
              )
            : SizedBox(),
        Container(
          width:
              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppSize.w0_5 : double.infinity,
          child: Row(
            children: <Widget>[
              // Button send image
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: AppMargin.m1),
                  child: new IconButton(
                      icon: new Icon(Icons.image,
                          size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w40 : AppSize.w25),
                      onPressed: () => cropImage(context), // getImage(0),
                      color: Theme.of(context).primaryColor),
                ),
                color: AppColors.white,
              ),
              // Button send video

              //record button
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? SizedBox()
                  : AudioRecorder(
                      onSendMessage: onSendMessage,
                      theme: theme,
                      focusNode: focusNode,
                      loggedId: widget.user.uid!),

              // Edit text
              Flexible(
                child: Container(
                  child: TextField(
                    enableInteractiveSelection: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    style: TextStyle(
                        color: theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black,
                        fontSize: AppFontsSizeManager.s15),
                    controller: textEditingController,
                    decoration: InputDecoration.collapsed(
                      hintText: getTranslated(context, "typeMessage"),
                      hintStyle: TextStyle(color: AppColors.grey),
                    ),
                    focusNode: focusNode,
                    onChanged: (str) {
                      setState(() {
                        text = str;
                      });
                    },
                  ),
                ),
              ),
              // Button send message
              Material(
                child: new Container(
                  margin: new EdgeInsets.symmetric(horizontal: AppMargin.m8),
                  child: loading
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h50 : AppSize.h30,
                          width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w50 : AppSize.w30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor),
                          child: Center(
                            child: new IconButton(
                                icon: new Icon(
                                  Icons.send,
                                  color: Colors.white,
                                  size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w20 : AppSize.w15,
                                ),
                                onPressed: () => onSendMessage(
                                    textEditingController.text, "text", size),
                                color: Theme.of(context).primaryColor),
                          ),
                        ),
                ),
                color: AppColors.white,
              ),
            ],
          ),
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h100 : AppSize.h50,
          decoration: new BoxDecoration(
              border: new Border(
                  top: new BorderSide(color:AppColors.grey, width: AppSize.w0_5)),
              color: AppColors.white),
        ),
      ],
    );
  }

  Future<void> changeStatus(String status) async {
    //update appointment
    await FirebaseFirestore.instance
        .collection(Paths.developTechSupportPath)
        .doc(widget.develop.developTechSupportId)
        .set({
      'status': status,
    }, SetOptions(merge: true));

    Navigator.pop(context);
  }

  Future<void> onSendMessage(String content, String type, Size size) async {
    if (content.trim() != '') {
      textEditingController.clear();
      String messageId = Uuid().v4();
      String data = getTranslated(context, "attatchment");
      if (type == "text") data = content;
      await FirebaseFirestore.instance
          .collection(Paths.dvelopChat)
          .doc(messageId)
          .set({
        'type': type,
        'owner': widget.user.userType,
        'message': content,
        'messageTime': FieldValue.serverTimestamp(),
        'messageTimeUtc': DateTime.now().toUtc().toString(),
        'ownerName': widget.user.name,
        'userUid': widget.user.uid,
        'developTechSupportId': widget.develop.developTechSupportId,
      });

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: AppConstants.milliseconds300), curve: Curves.easeOut);
      setState(() {
        loading = false;
      });
      if (type == "voice") {
        setState(() {
          uploadingRecord = false;
        });
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevelopMessageScreen(
              develop: widget.develop,
              user: widget.user,
            ),
          ),
        );
      }
    } else {
      // Fluttertoast.showToast(msg: 'Nothing to send');
    }
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

  Future cropImage(context) async {
    setState(() {
      loading = true;
    });

    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    uploadImage(croppedFile);
    setState(() {
      selectedProfileImage = croppedFile;
    });
  }

  Future uploadImage(File image) async {
    Size size = MediaQuery.of(context).size;

    var uuid = Uuid().v4();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('profileImages/$uuid');
    await storageReference.putFile(image);

    var url = await storageReference.getDownloadURL();
    onSendMessage(url, "image", size);
  }

//======================
  _Fn getRecorderFn() {
    /* if (!_mRecorderIsInited || !_mPlayer.isStopped) {
      return () {};
    }*/
    return recording ? stopRecord : startRecord;
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      ////statusText = "Recording...";
      recordFilePath = await getFilePath();
      //isComplete = false;
      setState(() {
        recording = true;
      });
      RecordMp3.instance.start(recordFilePath, (type) {
        //statusText = "Record error--->$type";
      });
    } else {
      //statusText = "No microphone permission";
    }
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/record";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    return sdPath + "/test1111_${i++}.mp3";
  }

  stopRecord() async {
    setState(() {
      recording = false;
      uploadingRecord = true;
    });
    bool s = RecordMp3.instance.stop();
    if (s) {
      //statusText = "Record complete";
      //isComplete = true;
      setState(() {});
      if (File(recordFilePath).existsSync()) {
        File recordFile = new File(recordFilePath);
        uploadRecord(recordFile);
      } else {}
    }
  }

  Future uploadRecord(File voice) async {
    var uuid = Uuid().v4();
    Reference storageReference =
        firebase_storage.FirebaseStorage.instance.ref().child('audio/$uuid');
    await storageReference.putFile(voice);
    var url = await storageReference.getDownloadURL();
    onSendMessage(url, "voice", size);
    setState(() {
      uploadingRecord = false;
    });
  }
}
