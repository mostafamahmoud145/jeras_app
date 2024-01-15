import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';

class VideoDetailsScreen extends StatefulWidget {
  final Video video;
  final String consultUid;

  const VideoDetailsScreen(
      {Key? key, required this.video, required this.consultUid})
      : super(key: key);

  @override
  _VideoDetailsScreenState createState() => _VideoDetailsScreenState();
}

class _VideoDetailsScreenState extends State<VideoDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late bool isAdding, activeCode = false;

  @override
  void initState() {
    super.initState();
    isAdding = false;
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });
      String? id = Uuid().v4();
      if (widget.video.id != null) id = widget.video.id;
      await FirebaseFirestore.instance.collection(Paths.videoPath).doc(id).set({
        'id': id,
        'consultUid': widget.consultUid,
        'desc': widget.video.desc,
        'link': widget.video.link,
      }, SetOptions(merge: true));
      setState(() {
        isAdding = false;
      });
      Navigator.pop(context);
    } else {
      showSnack('Please fill all the details!', context);
    }
  }

  void showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p10,
                    right: AppPadding.p10,
                    top: 0.0,
                    bottom: AppPadding.p6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: AppSize.h35,
                      width: AppSize.w35,
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: SvgPicture.asset(
                            AssetsManager.rightArrowIconPath,
                            width: AppSize.w30,
                            height: AppSize.h30,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      getTranslated(context, "video"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s16,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                    widget.video.id != null
                        ? isAdding
                            ? CircularProgressIndicator()
                            : InkWell(
                                splashColor: Colors.white.withOpacity(0.6),
                                onTap: () {
                                  deleteVideo();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                  ),
                                  width: AppSize.w38.w,
                                  height: AppSize.h35.h,
                                  child: Icon(
                                    Icons.delete,
                                    color: AppColors.red,
                                    size: AppSize.w24,
                                  ),
                                ),
                              )
                        : SizedBox(),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h2,
                  width: size.width * AppSize.w0_9)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.p16, vertical: AppPadding.p16),
              children: <Widget>[
                SizedBox(
                  height: AppSize.h20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: widget.video.link,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          widget.video.link = val;
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
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
                           color: AppColors.black54,
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: getTranslated(context, "link"),
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
                        initialValue: widget.video.desc,
                        maxLines: 5,
                        /* validator: (String val) {
                          if (val.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },*/
                        onSaved: (val) {
                          widget.video.desc = val;
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 15),
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
                           color: AppColors.black54,
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: getTranslated(context, "desc"),
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
                      isAdding
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: InkWell(
                                onTap: () {
                                  save();
                                },
                                child: Container(
                                  width: size.width * AppSize.w0_6,
                                  height: AppSize.h45,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r10),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          AppColors.linear1,
                                          AppColors.linear2,
                                          AppColors.linear2,
                                        ],
                                      )),
                                  child: Center(
                                    child: Text(
                                      getTranslated(context, "save"),
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        color: AppColors.white,
                                        fontSize: AppFontsSizeManager.s18,
                                        letterSpacing:
                                            AppConstants.letterSpacing0_5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  deleteVideo() {
    setState(() {
      isAdding = true;
    });
    FirebaseFirestore.instance
        .collection(Paths.videoPath)
        .doc(widget.video.id)
        .delete();
    setState(() {
      isAdding = false;
    });
    Navigator.pop(context);
  }
}
