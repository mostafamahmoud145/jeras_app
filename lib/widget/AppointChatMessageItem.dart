import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/responsive_layout.dart';
import 'package:linkwell/linkwell.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/SupportMessage.dart';
import '../../models/supportReview.dart';
import '../../models/user.dart';
import '../../widget/playVideoWidget.dart';
import '../../widget/playrecordWidget.dart';
import '../config/colors_file.dart';
import '../services/files_service.dart';

class AppointChatMessageItem extends StatefulWidget {
  final SupportMessage message;
  final GroceryUser user;

  const AppointChatMessageItem(
      {Key? key, required this.message, required this.user})
      : super(key: key);

  @override
  State<AppointChatMessageItem> createState() => _AppointChatMessageItemState();

  static Widget chatImage(BuildContext context, String chatContent, bool type,
      bool? isRead, bool? isReceived) {
    return Container(
        padding: EdgeInsets.only(
            left: AppPadding.p14,
            right: AppPadding.p14,
            top: AppPadding.p10,
            bottom: AppPadding.p10),
        child: Align(
          alignment: (type ? Alignment.topLeft : Alignment.topRight),
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.r21_3.r),
                        topRight: Radius.circular(AppRadius.r21_3.r),
                        bottomLeft: Radius.circular(AppRadius.r21_3.r))),
                padding: EdgeInsets.only(
                    top: AppSize.h10.h,
                    bottom: AppPadding.p38_6.h,
                    left: AppPadding.p10.w,
                    right: AppPadding.p10.w),
                child: InkWell(
                  child: MediaQuery.of(context).size.width >= 500
                      ? widgetShowImages(chatContent, 250)
                      : widgetShowImages(chatContent, 226.6),
                  onTap: () async {
                    // launchURL(chatContent);
                    var url = chatContent;
                    if (!url.contains('http')) {
                      url = 'https://$url';
                    }
                    await launch(url);
                  },
                ),
                margin: type
                    ? EdgeInsets.only(
                        bottom: AppPadding.p10, right: AppPadding.p10)
                    : EdgeInsets.only(left: AppPadding.p10),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: AppSize.w30.w, vertical: AppSize.w10.h),
                child: Icon(
                    isRead == true || isReceived == true
                        ? Icons.done_all
                        : Icons.done,
                    size: AppSize.w18_6.r,
                    color: isRead == true ? AppColors.blue : AppColors.white1),
              ),
            ],
          ),
        ));
  }

  // Show Images from network
  static Widget widgetShowImages(String imageUrl, double imageSize) {
    return FadeInImage.assetNetwork(
      placeholder: AssetsManager.lodeGif,
      placeholderScale: 0.5,
      imageErrorBuilder: (context, error, stackTrace) => Icon(
        Icons.image_not_supported,
        size: AppSize.w50,
      ),
      height: imageSize.r,
      width: imageSize.r,
      image: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: Duration(milliseconds: AppConstants.milliseconds250),
      fadeInCurve: Curves.easeInOut,
      fadeOutDuration: Duration(milliseconds: AppConstants.milliseconds150),
      fadeOutCurve: Curves.easeInOut,
    );
  }
}

class _AppointChatMessageItemState extends State<AppointChatMessageItem> {
  bool adding = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ResponsiveLayout(
      desktop: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
                left: AppPadding.p14,
                right: AppPadding.p14,
                top: AppPadding.p10,
                bottom: AppPadding.p10),
            child: Align(
              alignment: (widget.message.userUid != widget.user.uid
                  ? Alignment.topLeft
                  : Alignment.topRight),
              child: widget.message.type == "image"
                  ? AppointChatMessageItem.chatImage(
                      context,
                      widget.message.message!,
                      widget.message.userUid == widget.user.uid,
                      widget.message.isRead,
                      widget.message.isReceived)
                  : widget.message.type == "voice"
                      ? Container(
                          child: Row(
                            mainAxisAlignment:
                                widget.message.userUid == widget.user.uid
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                            children: [
                              if (widget.message.userUid == widget.user.uid)
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppSize.w4.w),
                                  child: Icon(
                                    widget.message.isRead == true ||
                                            widget.message.isReceived == true
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: AppSize.w25.r,
                                    color: widget.message.isRead == true
                                        ? AppColors.blue
                                        : AppColors.grey,
                                  ),
                                ),
                              PlayRecordWidget(
                                url: widget.message.message!,
                                owner:
                                    widget.message.userUid != widget.user.uid,
                              ),
                            ],
                          ),
                        )
                      : widget.message.type == "file"
                          ? Column(
                              mainAxisAlignment:
                                  widget.message.userUid == widget.user.uid
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                              children: [
                                Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: <Widget>[
                                    Container(
                                      width: 220.w,
                                      height: 120.h,
                                      color: AppColors.primaryColor,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.insert_drive_file,
                                          color: Colors.red,
                                        ),
                                        SizedBox(
                                          height: 15.h,
                                        ),
                                        Text(
                                          "File",
                                          style: TextStyle(
                                              fontSize: 25.sp,
                                              color: widget.message.userUid !=
                                                      widget.user.uid
                                                  ? Colors.black
                                                  : Colors.black),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                    height: 80,
                                    child: IconButton(
                                        onPressed: () {
                                          if (kIsWeb) {
                                            download(widget.message.message!
                                                .toString());
                                          } else {
                                            downloadpdf(widget.message.message!
                                                .toString());
                                          }
                                        },
                                        icon: Icon(
                                          Icons.file_download,
                                          color: widget.message.userUid !=
                                                  widget.user.uid
                                              ? Colors.black
                                              : Colors.black,
                                        )))
                              ],
                            )
                          : widget.message.type == "video"
                              ? Row(
                                  mainAxisAlignment:
                                      widget.message.userUid == widget.user.uid
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                  children: [
                                    if (widget.message.userUid ==
                                        widget.user.uid)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: AppSize.w4.w),
                                        child: Icon(
                                          widget.message.isRead == true ||
                                                  widget.message.isReceived ==
                                                      true
                                              ? Icons.done_all
                                              : Icons.done,
                                          size: AppSize.w25.r,
                                          color: widget.message.isRead == true
                                              ? AppColors.blue
                                              : AppColors.grey,
                                        ),
                                      ),
                                    PlayVideoWidget(
                                        url: widget.message.message!),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      widget.message.userUid != widget.user.uid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                                AppRadius.r26_5.r),
                                            topRight: Radius.circular(
                                                AppRadius.r26_5.r),
                                            bottomLeft: Radius.circular(
                                                widget.message.userUid !=
                                                        widget.user.uid
                                                    ? 0.0
                                                    : 26.5.w),
                                            bottomRight: Radius.circular(
                                                widget.message.userUid !=
                                                        widget.user.uid
                                                    ? AppSize.w26_5.w
                                                    : 0.0),
                                          ),
                                          color: (widget.message.userUid !=
                                                  widget.user.uid
                                              ? Colors.grey.shade200
                                              : AppColors.pink),
                                        ),
                                        padding: EdgeInsets.only(
                                            left: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppPadding.p75.w
                                                : AppPadding.p28.w,
                                            right: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppPadding.p75.w
                                                : AppPadding.p28.w,
                                            top: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppPadding.p22_5.h
                                                : AppPadding.p12.h,
                                            bottom: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppPadding.p22_5.h
                                                : AppPadding.p12.h),
                                        child:
                                            _createTextMessage(context, size),
                                      ),
                                      SizedBox(
                                          height: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.h20.h
                                              : AppSize.h5_5.h),
                                      widget.message.messageTimeUtc != null
                                          ? Row(
                                              mainAxisAlignment:
                                                  widget.message.userUid ==
                                                          widget.user.uid
                                                      ? MainAxisAlignment.start
                                                      : MainAxisAlignment.end,
                                              children: [
                                                if (widget.message.userUid ==
                                                    widget.user.uid)
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal:
                                                                AppSize.w4.w),
                                                    child: Icon(
                                                      widget.message.isRead ==
                                                                  true ||
                                                              widget.message
                                                                      .isReceived ==
                                                                  true
                                                          ? Icons.done_all
                                                          : Icons.done,
                                                      size: AppSize.w25.r,
                                                      color: widget.message
                                                                  .isRead ==
                                                              true
                                                          ? AppColors.blue
                                                          : AppColors.grey,
                                                    ),
                                                  ),
                                                // PlayRecordWidget(
                                                //   url: widget.message.message!,
                                                //   owner:
                                                //       widget.message.userUid !=
                                                //           widget.user.uid,
                                                // ),
                                              ],
                                            )
                                          : widget.message.type == "file"
                                              ? Column(
                                                  mainAxisAlignment: widget
                                                              .message
                                                              .userUid ==
                                                          widget.user.uid
                                                      ? MainAxisAlignment.start
                                                      : MainAxisAlignment.end,
                                                  children: [
                                                    Stack(
                                                      alignment:
                                                          AlignmentDirectional
                                                              .center,
                                                      children: <Widget>[
                                                        Container(
                                                          width: 220.w,
                                                          height: 120.h,
                                                          color: AppColors
                                                              .primaryColor,
                                                        ),
                                                        Column(
                                                          children: <Widget>[
                                                            Icon(
                                                              Icons
                                                                  .insert_drive_file,
                                                              color: Colors.red,
                                                            ),
                                                            SizedBox(
                                                              height: 15.h,
                                                            ),
                                                            Text(
                                                              "File",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      25.sp,
                                                                  color: widget
                                                                              .message
                                                                              .userUid !=
                                                                          widget
                                                                              .user
                                                                              .uid
                                                                      ? Colors
                                                                          .black
                                                                      : Colors
                                                                          .black),
                                                            )
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                    Container(
                                                        height: 80,
                                                        child: IconButton(
                                                            onPressed: () {
                                                              print('now');
                                                              print(widget
                                                                  .message
                                                                  .message!
                                                                  .toString());
                                                              downloadpdf(widget
                                                                  .message
                                                                  .message!
                                                                  .toString());
                                                            },
                                                            icon: Icon(
                                                              Icons
                                                                  .file_download,
                                                              color: widget
                                                                          .message
                                                                          .userUid !=
                                                                      widget
                                                                          .user
                                                                          .uid
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .black,
                                                            )))
                                                  ],
                                                )
                                              : widget.message.type == "video"
                                                  ? Row(
                                                      mainAxisAlignment: widget
                                                                  .message
                                                                  .userUid ==
                                                              widget.user.uid
                                                          ? MainAxisAlignment
                                                              .start
                                                          : MainAxisAlignment
                                                              .end,
                                                      children: [
                                                        if (widget.message
                                                                .userUid ==
                                                            widget.user.uid)
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        AppSize
                                                                            .w4
                                                                            .w),
                                                            child: Icon(
                                                              widget.message.isRead ==
                                                                          true ||
                                                                      widget.message.isReceived ==
                                                                          true
                                                                  ? Icons
                                                                      .done_all
                                                                  : Icons.done,
                                                              size:
                                                                  AppSize.w25.r,
                                                              color: widget
                                                                          .message
                                                                          .isRead ==
                                                                      true
                                                                  ? AppColors
                                                                      .blue
                                                                  : AppColors
                                                                      .grey,
                                                            ),
                                                          ),
                                                        PlayVideoWidget(
                                                            url: widget.message
                                                                .message!),
                                                      ],
                                                    )
                                                  : Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment: widget
                                                                  .message
                                                                  .userUid !=
                                                              widget.user.uid
                                                          ? CrossAxisAlignment
                                                              .end
                                                          : CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r26_5
                                                                          .r),
                                                              topRight: Radius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r26_5
                                                                          .r),
                                                              bottomLeft: Radius
                                                                  .circular(widget
                                                                              .message
                                                                              .userUid !=
                                                                          widget
                                                                              .user
                                                                              .uid
                                                                      ? 0.0
                                                                      : 26.5.w),
                                                              bottomRight: Radius
                                                                  .circular(widget
                                                                              .message
                                                                              .userUid !=
                                                                          widget
                                                                              .user
                                                                              .uid
                                                                      ? AppSize
                                                                          .w26_5
                                                                          .w
                                                                      : 0.0),
                                                            ),
                                                            color: (widget
                                                                        .message
                                                                        .userUid !=
                                                                    widget.user
                                                                        .uid
                                                                ? Colors.grey
                                                                    .shade200
                                                                : AppColors
                                                                    .pink),
                                                          ),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left:
                                                                      AppPadding
                                                                          .p28
                                                                          .w,
                                                                  right:
                                                                      AppPadding
                                                                          .p28
                                                                          .w,
                                                                  top:
                                                                      AppPadding
                                                                          .p12
                                                                          .h,
                                                                  bottom:
                                                                      AppPadding
                                                                          .p12
                                                                          .h),
                                                          child:
                                                              _createTextMessage(
                                                                  context,
                                                                  size),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                AppSize.h5_5.h),
                                                        widget.message
                                                                    .messageTimeUtc !=
                                                                null
                                                            ? Row(
                                                                mainAxisAlignment: widget
                                                                            .message
                                                                            .userUid ==
                                                                        widget
                                                                            .user
                                                                            .uid
                                                                    ? MainAxisAlignment
                                                                        .start
                                                                    : MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  if (widget
                                                                          .message
                                                                          .userUid ==
                                                                      widget
                                                                          .user
                                                                          .uid)
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(
                                                                          horizontal: AppSize
                                                                              .w4
                                                                              .w),
                                                                      child:
                                                                          Icon(
                                                                        widget.message.isRead == true ||
                                                                                widget.message.isReceived == true
                                                                            ? Icons.done_all
                                                                            : Icons.done,
                                                                        size: AppSize
                                                                            .w25
                                                                            .r,
                                                                        color: widget.message.isRead ==
                                                                                true
                                                                            ? AppColors.blue
                                                                            : AppColors.darkGrey3,
                                                                      ),
                                                                    ),
                                                                  Text(
                                                                    // DateTime.parse(message.messageTimeUtc).toLocal().toString(),
                                                                    '${new DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(widget.message.messageTimeUtc!).toLocal())}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily: getTranslated(
                                                                          context,
                                                                          "Ithra"),
                                                                      fontSize:
                                                                          AppFontsSizeManager
                                                                              .s12
                                                                              .sp,
                                                                      color: AppColors
                                                                          .grey,
                                                                      fontWeight:
                                                                          AppFontsWeightManager
                                                                              .bold300,
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .normal,
                                                                    ),
                                                                  ),
                                                                  // if (widget.message.userUid ==
                                                                  //     widget.user.uid)
                                                                  //   Padding(
                                                                  //     padding: EdgeInsets.symmetric(horizontal: AppSize.w4.w),
                                                                  //     child: Icon(
                                                                  //       widget.message.isRead == true ||
                                                                  //           widget.message.isReceived ==
                                                                  //               true
                                                                  //           ? Icons.done_all
                                                                  //           : Icons.done,
                                                                  //       size: AppSize.w25.r,
                                                                  //       color: widget.message.isRead == true
                                                                  //           ? AppColors.blue
                                                                  //           : Color.fromRGBO(
                                                                  //           167, 165, 165, 1),
                                                                  //     ),
                                                                  //   ),
                                                                ],
                                                              )
                                                            : SizedBox(),
                                                      ],
                                                    ),
                                    ]),
            ),

            ///
          ),
          SizedBox(
            height: AppSize.h5,
          ),
        ],
      ),

      ///=====================================
      mobile: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: AppPadding.p32.h,
            ),
            child: Align(
              alignment: (widget.message.userUid != widget.user.uid
                  ? Alignment.topLeft
                  : Alignment.topRight),
              child: widget.message.type == "image"
                  ? AppointChatMessageItem.chatImage(
                      context,
                      widget.message.message!,
                      widget.message.userUid == widget.user.uid,
                      widget.message.isRead,
                      widget.message.isReceived)
                  : widget.message.type == "voice"
                      ? Row(
                          mainAxisAlignment:
                              widget.message.userUid == widget.user.uid
                                  ? MainAxisAlignment.start
                                  : MainAxisAlignment.end,
                          children: [
                            if (widget.message.userUid == widget.user.uid)
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppSize.w4.w),
                                child: Icon(
                                  widget.message.isRead == true ||
                                          widget.message.isReceived == true
                                      ? Icons.done_all
                                      : Icons.done,
                                  size: AppSize.w25.r,
                                  color: widget.message.isRead == true
                                      ? AppColors.blue
                                      : AppColors.grey,
                                ),
                              ),
                            PlayRecordWidget(
                              url: widget.message.message!,
                              owner: widget.message.userUid != widget.user.uid,
                            ),
                          ],
                        )
                      : widget.message.type == "file"
                          ? Column(
                              mainAxisAlignment:
                                  widget.message.userUid == widget.user.uid
                                      ? MainAxisAlignment.start
                                      : MainAxisAlignment.end,
                              children: [
                                /*if (widget.message.userUid ==
                      widget.user.uid)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: AppSize.w4.w),
                      child: Icon(
                        widget.message.isRead == true ||
                            widget.message.isReceived ==
                                true
                            ? Icons.done_all
                            : Icons.done,
                        size: AppSize.w25.r,
                        color: widget.message.isRead == true
                            ? AppColors.blue
                            : AppColors.grey,
                      ),
                    ),*/
                                Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: <Widget>[
                                    Container(
                                      width: 120.w,
                                      height: 90.h,
                                      color: AppColors.primaryColor,
                                    ),
                                    Column(
                                      children: <Widget>[
                                        Icon(
                                          Icons.insert_drive_file,
                                          color: Colors.red,
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Text(
                                          "File",
                                          style: TextStyle(
                                              fontSize: 20.sp,
                                              color: widget.message.userUid !=
                                                      widget.user.uid
                                                  ? Colors.black
                                                  : Colors.black),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                                Container(
                                    height: 40,
                                    child: IconButton(
                                        onPressed: () {
                                          print('now');
                                          print(
                                              '=================msg ${widget.message}');

                                          print(widget.message.message!
                                              .toString());
                                          if (kIsWeb) {
                                            download(widget.message.message!
                                                .toString());
                                          } else {
                                            downloadpdf(widget.message.message!
                                                .toString());
                                          }
                                        },
                                        icon: Icon(
                                          Icons.file_download,
                                          color: widget.message.userUid !=
                                                  widget.user.uid
                                              ? Colors.black
                                              : Colors.black,
                                        )))
                              ],
                            )
                          : widget.message.type == "video"
                              ? Row(
                                  mainAxisAlignment:
                                      widget.message.userUid == widget.user.uid
                                          ? MainAxisAlignment.start
                                          : MainAxisAlignment.end,
                                  children: [
                                    if (widget.message.userUid ==
                                        widget.user.uid)
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: AppSize.w4.w),
                                        child: Icon(
                                          widget.message.isRead == true ||
                                                  widget.message.isReceived ==
                                                      true
                                              ? Icons.done_all
                                              : Icons.done,
                                          size: AppSize.w25.r,
                                          color: widget.message.isRead == true
                                              ? AppColors.blue
                                              : AppColors.grey,
                                        ),
                                      ),
                                    PlayVideoWidget(
                                        url: widget.message.message!),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      widget.message.userUid != widget.user.uid
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.start,
                                  children: [
                                    Stack(
                                      alignment: widget.message.userUid !=
                                              widget.user.uid
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  AppRadius.r38_6.r),
                                              topRight: Radius.circular(
                                                  AppRadius.r38_6.r),
                                              bottomLeft: Radius.circular(
                                                  widget.message.userUid !=
                                                          widget.user.uid
                                                      ? 0.0
                                                      : AppRadius.r38_6.r),
                                              bottomRight: Radius.circular(
                                                  widget.message.userUid !=
                                                          widget.user.uid
                                                      ? AppSize.w26_5.w
                                                      : 0.0),
                                            ),
                                            color: (widget.message.userUid !=
                                                    widget.user.uid
                                                ? AppColors.greyShade300
                                                : AppColors.pink),
                                          ),
                                          padding: EdgeInsets.only(
                                              left: widget.message.userUid !=
                                                      widget.user.uid
                                                  ? AppPadding.p13_3.w
                                                  : AppPadding.p46_6.w,
                                              right: widget.message.userUid !=
                                                      widget.user.uid
                                                  ? AppPadding.p46_6.w
                                                  : AppPadding.p13_3.h,
                                              top: AppPadding.p13_3.h,
                                              bottom: AppPadding.p13_3.h),
                                          child:
                                              _createTextMessage(context, size),
                                        ),
                                        if (widget.message.userUid ==
                                            widget.user.uid)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: AppSize.w20.w),
                                            child: Icon(
                                              widget.message.isRead == true ||
                                                      widget.message
                                                              .isReceived ==
                                                          true
                                                  ? Icons.done_all
                                                  : Icons.done,
                                              size: AppSize.w18_6.r,
                                              color:
                                                  widget.message.isRead == true
                                                      ? AppColors.blue
                                                      : AppColors.white1,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: AppSize.h5_3.h),
                                    widget.message.messageTimeUtc != null
                                        ? Row(
                                            mainAxisAlignment:
                                                widget.message.userUid ==
                                                        widget.user.uid
                                                    ? MainAxisAlignment.start
                                                    : MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                // DateTime.parse(message.messageTimeUtc).toLocal().toString(),
                                                '${new DateFormat(' hh:mm ${'a' == "AM" ? getTranslated(context, "am") : getTranslated(context, "pm")}').format(DateTime.parse(widget.message.messageTimeUtc!).toLocal())}',
                                                textAlign: TextAlign.end,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, "Ithralight"),
                                                  fontSize: AppFontsSizeManager
                                                      .s16.sp,
                                                  color: AppColors.grey,
                                                  // fontWeight:
                                                  //     AppFontsWeightManager
                                                  //         .bold300,
                                                  fontStyle: FontStyle.normal,
                                                ),
                                              ),
                                              // if (widget.message.userUid ==
                                              //     widget.user.uid)
                                              //   Padding(
                                              //     padding: EdgeInsets.symmetric(horizontal: AppSize.w4.w),
                                              //     child: Icon(
                                              //       widget.message.isRead == true ||
                                              //           widget.message.isReceived ==
                                              //               true
                                              //           ? Icons.done_all
                                              //           : Icons.done,
                                              //       size: AppSize.w25.r,
                                              //       color: widget.message.isRead == true
                                              //           ? AppColors.blue
                                              //           : Color.fromRGBO(
                                              //           167, 165, 165, 1),
                                              //     ),
                                              //   ),
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                ),
            ),
          ),
          SizedBox(
            height: AppSize.h5,
          ),
        ],
      ),
    );
  }

  void showSnack(String text, BuildContext context,
      {Color color = AppColors.red}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: color,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  download(url) {
    html.AnchorElement anchorElement = html.AnchorElement(href: url);
    anchorElement.download = "resume";
    anchorElement.click();
    print('download path = ${url.toString()}');
    //OpenFile.open(url.toString());
  }

  Future<void> downloadpdf(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Reference storageRef = FirebaseStorage.instance.refFromURL(url);
      final metadata = await storageRef.getMetadata();
      final String? contentType = metadata.contentType;
      final String fileExtension = contentType!.split('/').last;

      FileStorage.writeCounter(
              response.bodyBytes, "${storageRef.name}.$fileExtension")
          .then((value) {
        if (value == null) {
          showSnack(getTranslated(context, 'fileIsExists'), context);
        } else {
          showSnack(
              getTranslated(context, 'fileDownloadedSuccessfully'), context,
              color: AppColors.green);
        }
      });
    } else {
      showSnack(getTranslated(context, 'errorWhenDownloadFile'), context);
    }

    // var client = new HttpClient();
    // try {
    //   var request = await client.getUrl(Uri.parse(url));
    //   var response = await request.close();
    //   var byte = await consolidateHttpClientResponseBytes(response);
    //   final dir = await getExternalStorageDirectory();
    //   final File file2 = File(url);
    //   final filename = p.basename(file2.path);
    //   print('noww');
    //   print(file2.path);
    //   final Reference storageRef = FirebaseStorage.instance.refFromURL(url);
    //   final metadata = await storageRef.getMetadata();
    //   final String? contentType = metadata.contentType;
    //   final String fileExtension = contentType!.split('/').last;
    //   String docid = Uuid().v4();
    //   String name = docid.toString() + '.' + fileExtension.toString();
    //
    //   print(name.toString());
    //   if (fileExtension.toString() ==
    //       'vnd.openxmlformats-officedocument.wordprocessingml.document') {
    //     File file = new File('${dir!.path}/${docid.toString()}.docx');
    //     await file.writeAsBytes(byte);
    //     print('download path = ${file.path}');
    //     //OpenFile.open(file.path.toString());
    //     return file;
    //   }
    //   File file = new File('${dir!.path}/${name.toString()}');
    //   await file.writeAsBytes(byte);
    //   print('download path = ${file.path}');
    //   //OpenFile.open(file.path.toString());
    //   return file;
    // } catch (error) {
    //   return File('');
    // }
  }

  launchURL(String url) async {
    if (!url.contains('http')) url = 'https://$url';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // showSnakbar('Could not launch $url', false);

      throw 'Could not launch $url';
    }
  }

  Widget _createTextMessage(context, Size size) {
    return (widget.message.message != null &&
            widget.message.message!.contains('https://'))
        ? InkWell(
            splashColor: Colors.white.withOpacity(0.5),
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: widget.message.message.toString()));
              showSnack(getTranslated(context, "textCopy"), context);
            },
            child: widget.message.message != null
                ? LinkWell(
                    widget.message.message! != null
                        ? widget.message.message!
                        : "...",
                    linkStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.blue,
                      fontSize: (kIsWeb || size.width >= 500)
                          ? AppFontsSizeManager.s21.sp
                          : AppFontsSizeManager.s18_6.sp,
                    ),
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: widget.message.userUid == widget.user.uid
                          ? Colors.black
                          : AppColors.white,
                      fontSize: (kIsWeb || size.width >= 500)
                          ? AppFontsSizeManager.s24.sp
                          : AppFontsSizeManager.s18_6.sp,
                    ),
                  )
                : SizedBox(),
          )
        : InkWell(
            splashColor: Colors.white.withOpacity(0.5),
            onTap: () {
              if (widget.message.type == "closing" &&
                  widget.user.userType != "SUPPORT") {
                rateDialog(size);
              } else {
                Clipboard.setData(
                    ClipboardData(text: widget.message.message.toString()));
                showSnack(getTranslated(context, "textCopy"), context);
              }
            },
            child: widget.message.message != null
                ? Text.rich(
                    TextSpan(
                      text: widget.message.message != null
                          ? widget.message.message
                          : "...",
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: widget.message.userUid == widget.user.uid
                            ? AppColors.white
                            : Colors.black,
                        fontSize: (kIsWeb || size.width >= 500)
                            ? AppFontsSizeManager.s21.sp
                            : AppFontsSizeManager.s17.sp,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: " ",
                        ),
                        widget.message.type == "closing"
                            ? TextSpan(
                                text: getTranslated(context, "pressHere"),
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 3,
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.lightBlueAccent,
                                    fontSize: (kIsWeb || size.width >= 500)
                                        ? 21.sp
                                        : 17.0.sp,
                                    fontWeight: FontWeight.bold),
                              )
                            : TextSpan(
                                text: ' ',
                              ),
                      ],
                    ),
                    softWrap: true,
                    maxLines: 10,
                    //p
                    textAlign: TextAlign.center,
                  )
                : SizedBox(),
          );
  }

  rateDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r20),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16,
              right: AppPadding.p16,
              top: AppPadding.p20,
              bottom: AppPadding.p10),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "supportRating"),
                      style: GoogleFonts.cairo(
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: AppFontsWeightManager.semiBold,
                        letterSpacing: AppConstants.letterSpacing0_3,
                        color: AppColors.black87,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          addReview("good");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              AssetsManager.happyEmo,
                              width: AppSize.w15,
                              height: AppSize.h15,
                              color: Colors.lightBlue,
                            ),
                            SizedBox(
                              width: AppSize.w5,
                            ),
                            Text(
                              getTranslated(context, "good"),
                              style: GoogleFonts.cairo(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.semiBold,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          addReview("bad");
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              AssetsManager.badEmo,
                              width: AppSize.w15,
                              height: AppSize.h15,
                              color: Colors.lightBlue,
                            ),
                            SizedBox(
                              width: AppSize.w5,
                            ),
                            Text(
                              getTranslated(context, "bad"),
                              style: GoogleFonts.cairo(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.semiBold,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p5,
                      right: AppPadding.p5,
                      top: AppPadding.p5,
                      bottom: AppPadding.p10),
                  child: Container(
                    width: size.width,
                    height: 0.5,
                    color: AppColors.lightGrey1,
                  ),
                ),
                /* Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        //Navigator.pop(context);
                      },
                      child: Text(
                        "Thank You",
                        //getTranslated(context, "discard"),
                        style: GoogleFonts.cairo(
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.semiBold,
                          letterSpacing: AppConstants.letterSpacing0_3,
                          color: Colors.lightBlue,
                        ),
                      ),
                    )
                  ],
                ),*/
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }

  Future<bool?> addReview(String review) async {
    setState(() {
      adding = true;
    });
    try {
      /*QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .where('uid', isEqualTo: widget.message.userUid)
          .limit(1)
          .get();
      var support = GroceryUser.fromMap(querySnapshot.docs[0]);*/

      String reviewId = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.supportReviewPath)
          .doc(reviewId)
          .set({
        'rating': review == 'good' ? 5 : 0,
        'review': review == "good" ? "good" : "bad",
        'reviewTime': Timestamp.now(),
        'userName': widget.user.name,
        'supportListId': widget.user.supportListId,
        'supportUid': widget.message.userUid,
        'supportName': widget.message.ownerName,
      });
      //update user review
      List<SupportReview> reviews;
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection(Paths.supportReviewPath)
            .where('supportUid', isEqualTo: widget.message.userUid)
            .get();

        reviews = List<SupportReview>.from(
          (snap.docs).map(
            (e) => SupportReview.fromMap(e.data() as Map),
          ),
        );

        if (reviews.length > 0) {
          double _rating = 0;
          for (var rev in reviews) {
            _rating = _rating + double.parse(rev.rating.toString());
          }

          _rating = _rating / reviews.length;
          _rating = double.parse((_rating.toStringAsFixed(1)));

          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(widget.message.userUid)
              .set({
            'rating': _rating,
            'reviewsCount': reviews.length,
          }, SetOptions(merge: true));
        }
        setState(() {
          adding = false;
        });

        Navigator.pop(context);
        Navigator.pop(context);
      } catch (e) {
        return null;
      }
      return true;
    } catch (e) {}
    return null;
  }
}
