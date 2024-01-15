import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/models/payInfo.dart';
import 'package:jeras/widget/custom_outlined_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
import '../widget/processing_dialog.dart';

class payInfoScreen extends StatefulWidget {
  final String consultId;

  const payInfoScreen({Key? key, required this.consultId}) : super(key: key);

  @override
  _payInfoScreenState createState() => _payInfoScreenState();
}

class _payInfoScreenState extends State<payInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> adminMap = Map();
  var image;
  var selectedImage;
  var selectedImageFront, selectedImageBack;
  bool isAdding = false, load = true;
  late GroceryUser consult;
  late PayInfo consultPayInfo;

  //String? fullName,bankName,accountNumber,address,personalId;
  @override
  void initState() {
    super.initState();
    getConsultPayInfoDetails();
  }

  Future<void> getConsultPayInfoDetails() async {
    DocumentSnapshot documentSnapshotConsult = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.consultId)
        .get();

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(Paths.payInfoPath)
        .doc(widget.consultId)
        .get();
    if (documentSnapshot.exists)
      setState(() {
        consultPayInfo = PayInfo.fromMap(documentSnapshot.data() as Map);
        consult = GroceryUser.fromMap(documentSnapshotConsult.data() as Map);
        load = false;
      });
    else
      setState(() {
        consultPayInfo = new PayInfo();
        consult = GroceryUser.fromMap(documentSnapshotConsult.data() as Map);
        load = false;
      });
  }
  Future cropImage(context, type) async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);
    setState(() {
      if (type == "front")
        selectedImageFront = croppedFile;
      else
        selectedImageBack = croppedFile;
    });
    //addFile(type);
  }

  /*Future cropImage(context) async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    if (croppedFile != null) {
      setState(() {
        selectedImage = croppedFile;
        adminMap.update(
          'profileImage',
          (value) => selectedImage,
          ifAbsent: () => selectedImage,
        );
      });
    } else {
      //not croppped
    }
  }*/

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Adding new admin..\nPlease wait!',
        );
      },
    );
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
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p10, right: AppPadding.p10, top: 0.0, bottom: AppPadding.p6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Container(
                        height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h75.r : AppSize.h45.r,
                        width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w75.r : AppSize.w45.r,
                        decoration: decoration(size),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back,
                            size: (kIsWeb && size.width > 400) ? AppSize.w75.r : AppSize.w45.r,
                            color: AppColors.black2,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      getTranslated(context, "paymentInfo"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: getTranslated(context, 'fontFamily'),
                          fontSize: AppFontsSizeManager.s16,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1_5,
                  width: size.width * AppSize.w0_9)),
          load
              ? CircularProgressIndicator()
              : Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p16,
                      vertical: AppPadding.p16,
                    ),
                    children: <Widget>[
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: AppSize.h10,
                            ),
                            Center(
                              child: Text(
                                getTranslated(context, "personInformation"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily:
                                    getTranslated(context, 'fontFamily'),
                                    fontSize: AppFontsSizeManager.s16,
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h10,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.title,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.title = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.title),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "title"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
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
                              initialValue: consultPayInfo.fullNameAr,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                if (val.split(" ").length < 3) {
                                  return getTranslated(context, "third");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.fullNameAr = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.person),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "fullNameAr"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
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
                              initialValue: consultPayInfo.fullNameEn,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                if (val.split(" ").length < 3) {
                                  return getTranslated(context, "third");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.fullNameEn = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.person),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "fullNameEn"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
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
                              initialValue: consultPayInfo.email,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.email = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.email_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "email"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
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
                              initialValue: consult.phoneNumber,
                              readOnly: true,
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.phone,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.phone),
                                labelText:
                                getTranslated(context, "phoneNumber"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
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
                            Center(
                              child: Text(
                                getTranslated(context, "NationalId"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily:
                                    getTranslated(context, 'fontFamily'),
                                    fontSize: AppFontsSizeManager.s16,
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h15,
                            ),
                            Row(
                              children: [
                                Text(
                                  getTranslated(context, "personalIdFront"),
                                  style: TextStyle(
                                    fontFamily:
                                    getTranslated(context, 'fontFamily'),
                                    color: AppColors.grey,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: AppFontsWeightManager.semiBold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: AppSize.h10,
                            ),
                            Center(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: size.width * AppSize.h0_35,
                                    width: size.width * AppSize.w0_85,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.lightGrey,
                                        width: AppSize.w1,
                                      ),
                                      borderRadius: BorderRadius.circular(AppRadius.r10),
                                      shape: BoxShape.rectangle,
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 0.0),
                                          blurRadius: 15.0,
                                          spreadRadius: 2.0,
                                          color: Colors.black.withOpacity(0.05),
                                        ),
                                      ],
                                    ),
                                    child: (consultPayInfo.personalFrontUrl ==
                                        null ||
                                        consultPayInfo.personalFrontUrl!
                                            .isEmpty) &&
                                        selectedImageFront == null
                                        ? Icon(
                                      Icons.person_pin_outlined,
                                      size: 25.0,
                                    )
                                        : selectedImageFront != null
                                        ? ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(0.0),
                                      child: Image.file(
                                          selectedImageFront),
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(0.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                        AssetsManager.lodeGif,
                                        placeholderScale: 0.5,
                                        imageErrorBuilder: (context,
                                            error, stackTrace) =>
                                            Icon(
                                              Icons.person,
                                              size: AppSize.w50,
                                            ),
                                        image: consultPayInfo
                                            .personalFrontUrl!,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(
                                            milliseconds: AppConstants.milliseconds250),
                                        fadeInCurve: Curves.easeInOut,
                                        fadeOutDuration: Duration(
                                            milliseconds: AppConstants.milliseconds150),
                                        fadeOutCurve:
                                        Curves.easeInOut,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5.0,
                                    left: 5.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.r50),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                          Colors.white.withOpacity(0.6),
                                          onTap: () {
                                            //TODO: take user to edit
                                            cropImage(context, "front");
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: AppSize.w30,
                                            height: 30.0,
                                            child: Icon(
                                              (consultPayInfo.personalFrontUrl ==
                                                  null ||
                                                  consultPayInfo
                                                      .personalFrontUrl!
                                                      .isEmpty)
                                                  ? Icons.edit
                                                  : Icons.add,
                                              color: AppColors.white,
                                              size: AppSize.w16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /*Center(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: size.width * 0.35,
                                    width: size.width * 0.85,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 0.0),
                                          blurRadius: 15.0,
                                          spreadRadius: 2.0,
                                          color: Colors.black.withOpacity(0.05),
                                        ),
                                      ],
                                    ),
                                    child: (consult.personalIdUrl == null ||
                                                consult
                                                    .personalIdUrl!.isEmpty) &&
                                            selectedImage == null
                                        ? Icon(
                                            Icons.account_box_outlined,
                                            size: AppSize.w50,
                                          )
                                        : selectedImage != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child:
                                                    Image.file(selectedImage),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      AssetsManager.lodeGif,
                                                  placeholderScale: 0.5,
                                                  imageErrorBuilder: (context,
                                                          error, stackTrace) =>
                                                      Icon(
                                                    Icons.person,
                                                    size: AppSize.w50,
                                                  ),
                                                  image: consult.personalIdUrl!,
                                                  fit: BoxFit.cover,
                                                  fadeInDuration: Duration(
                                                      milliseconds: AppConstants.milliseconds250),
                                                  fadeInCurve: Curves.easeInOut,
                                                  fadeOutDuration: Duration(
                                                      milliseconds: AppConstants.milliseconds150),
                                                  fadeOutCurve:
                                                      Curves.easeInOut,
                                                ),
                                              ),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    left: 0.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.r50),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                              Colors.white.withOpacity(0.6),
                                          onTap: () {
                                            //TODO: take user to edit
                                            cropImage(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: AppSize.w30,
                                            height: 30.0,
                                            child: Icon(
                                              (consult.personalIdUrl == null ||
                                                      consult.personalIdUrl!
                                                          .isEmpty)
                                                  ? Icons.edit
                                                  : Icons.add,
                                              color: AppColors.white,
                                              size: AppSize.w16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),*/

                            SizedBox(
                              height: AppSize.h25,
                            ),
                            Row(
                              children: [
                                Text(
                                  getTranslated(context, "personalIdBack"),
                                  style: TextStyle(
                                    fontFamily:
                                    getTranslated(context, 'fontFamily'),
                                    color: AppColors.grey,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: AppFontsWeightManager.semiBold,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height:AppSize.h10,
                            ),
                            Center(
                              child: Stack(
                                children: <Widget>[
                                  Container(
                                    height: size.width * AppSize.h0_35,
                                    width: size.width *AppSize.w0_85,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppColors.lightGrey,
                                        width: AppSize.w1,
                                      ),
                                      borderRadius: BorderRadius.circular(AppRadius.r10),
                                      shape: BoxShape.rectangle,
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          offset: Offset(0, 0.0),
                                          blurRadius: 15.0,
                                          spreadRadius: 2.0,
                                          color: Colors.black.withOpacity(0.05),
                                        ),
                                      ],
                                    ),
                                    child: (consultPayInfo.personalBackUrl ==
                                        null ||
                                        consultPayInfo.personalBackUrl!
                                            .isEmpty) &&
                                        selectedImageBack == null
                                        ? Icon(
                                      Icons.person_pin_outlined,
                                      size: 25.0,
                                    )
                                        : selectedImageBack != null
                                        ? ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(0.0),
                                      child: Image.file(
                                          selectedImageBack),
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(0.0),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                        AssetsManager.lodeGif,
                                        placeholderScale: 0.5,
                                        imageErrorBuilder: (context,
                                            error, stackTrace) =>
                                            Icon(
                                              Icons.person,
                                              size: AppSize.w50,
                                            ),
                                        image: consultPayInfo
                                            .personalBackUrl!,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(
                                            milliseconds: AppConstants.milliseconds250),
                                        fadeInCurve: Curves.easeInOut,
                                        fadeOutDuration: Duration(
                                            milliseconds: AppConstants.milliseconds150),
                                        fadeOutCurve:
                                        Curves.easeInOut,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 5.0,
                                    left: 5.0,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.r50),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                          Colors.white.withOpacity(0.6),
                                          onTap: () {
                                            //TODO: take user to edit
                                            cropImage(context, "back");
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: AppSize.w30,
                                            height: AppSize.h30,
                                            child: Icon(
                                              (consultPayInfo.personalBackUrl ==
                                                  null ||
                                                  consultPayInfo
                                                      .personalBackUrl!
                                                      .isEmpty)
                                                  ? Icons.edit
                                                  : Icons.add,
                                              color: AppColors.white,
                                              size: AppSize.w16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      SizedBox(
                        height: AppSize.h25,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: consultPayInfo.startDate,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consultPayInfo.startDate = val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(
                          fontFamily:
                          getTranslated(context, 'fontFamily'),
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
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
                            fontSize: AppFontsSizeManager.s12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.date_range),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          hintText: "yyyy-mm-dd",
                          labelText: getTranslated(context, "startDate"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s12,
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
                        initialValue: consultPayInfo.endDate,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consultPayInfo.endDate = val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(
                          fontFamily:
                          getTranslated(context, 'fontFamily'),
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
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
                            fontSize: AppFontsSizeManager.s12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.date_range),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          hintText: "yyyy-mm-dd",
                          labelText: getTranslated(context, "endDate"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h25,
                      ),
                            Center(
                              child: Text(
                                getTranslated(context, "bankingInfo"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily:
                                    getTranslated(context, 'fontFamily'),
                                    fontSize: AppFontsSizeManager.s16,
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.bankName,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.bankName = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.home),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "bankName"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
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
                              initialValue: consultPayInfo.bankAccountNumber,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.bankAccountNumber = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon:
                                Icon(Icons.confirmation_num_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText:
                                getTranslated(context, "bankAccountNumber"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.iban,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.iban = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.security_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "iban"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.swift,
                              /*validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },*/
                              onSaved: (val) {
                                consultPayInfo.swift = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.security_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "swift"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            Center(
                              child: Text(
                                getTranslated(context, "addressInfo"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily:
                                    getTranslated(context, 'fontFamily'),
                                    fontSize: AppFontsSizeManager.s16,
                                    color: Colors.black.withOpacity(0.8),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.address1,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.address1 = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "address1"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
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
                              initialValue: consultPayInfo.address2,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.address2 = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "address2"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.district,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.district = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "district"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.city,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.city = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "city"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.zip_code,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.zip_code = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.location_on_outlined),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "zip_code"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consultPayInfo.siteUrl,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consultPayInfo.siteUrl = val;
                              },
                              enableInteractiveSelection: true,
                              style: TextStyle(
                                fontFamily:
                                getTranslated(context, 'fontFamily'),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s12,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                prefixIcon: Icon(Icons.upcoming_rounded),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "siteUrl"),
                                labelStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s12,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r12),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h25,
                            ),

                            /*TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              initialValue: consult.fullName,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consult.fullName = val!;
                              },
                              enableInteractiveSelection: false,
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
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
                                prefixIcon: Icon(Icons.person),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s14_5,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "fullName"),
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
                              initialValue: consult.bankName,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "required");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consult.bankName = val!;
                              },
                              enableInteractiveSelection: true,
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.name,
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
                                prefixIcon: Icon(Icons.account_balance),
                                prefixStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s14_5,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                labelText: getTranslated(context, "bankName"),
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
                              initialValue: consult.bankAccountNumber,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(
                                      context, "accountNumber");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consult.bankAccountNumber = val!;
                              },
                              enableInteractiveSelection: false,
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
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
                                prefixIcon: Icon(Icons.account_balance),
                                labelText:
                                    getTranslated(context, "accountNumber"),
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
                              initialValue: consult.fullAddress,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(context, "address");
                                }
                                return null;
                              },
                              onSaved: (val) {
                                consult.fullAddress = val!;
                              },
                              enableInteractiveSelection: false,
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
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
                                prefixIcon: Icon(Icons.location_on_outlined),
                                labelText: getTranslated(context, "address"),
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
                              height: AppSize.h25,
                            ),*/


                            isAdding
                                ? Center(child: CircularProgressIndicator())
                                : Container(
                              height: 45.0,
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 0.0),
                              child: MaterialButton(
                                onPressed: () {
                                  //add adminMap
                                  save();
                                },
                                color: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(15.0),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      getTranslated(
                                          context, "saveAndContinue"),
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, 'fontFamily'),
                                        color: AppColors.white,
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
                              height: AppSize.h25,
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

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });
      String? urlF = consultPayInfo.personalFrontUrl;
      String? urlB = consultPayInfo.personalFrontUrl;
      if (selectedImageFront != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
        FirebaseStorage.instance.ref().child('profileImages/$uuid');
        await storageReference.putFile(selectedImageFront);
        urlF = await storageReference.getDownloadURL();
        consultPayInfo.personalFrontUrl = urlF;
      }
      if (selectedImageBack != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
        FirebaseStorage.instance.ref().child('profileImages/$uuid');
        await storageReference.putFile(selectedImageBack);
        urlB = await storageReference.getDownloadURL();
        consultPayInfo.personalBackUrl = urlB;
      }
      await FirebaseFirestore.instance
          .collection(Paths.payInfoPath)
          .doc(widget.consultId)
          .set({
        "id": widget.consultId,
        "consultUid": widget.consultId,
        'title': consultPayInfo.title,
        'fullNameEn': consultPayInfo.fullNameEn,
        'fullNameAr': consultPayInfo.fullNameAr,
        'phone':
        consult.phoneNumber!.replaceAll(consult.countryCode!, '').trim(),
        'countryCode': consult.countryCode,
        'countryISOCode': consult.countryISOCode,
        'email': consultPayInfo.email,

        "personalFrontUrl": consultPayInfo.personalFrontUrl,
        "personalBackUrl": consultPayInfo.personalBackUrl,
        "personalFrontUrlId": ".", //consultPayInfo.personalFrontUrlId,
        "personalBackUrlId": ".", //consultPayInfo.personalBackUrlId,
        'startDate': consultPayInfo.startDate,
        'endDate': consultPayInfo.endDate,

        "address1": consultPayInfo.address1,
        "address2": consultPayInfo.address2,
        'district': consultPayInfo.district,
        'city': consultPayInfo.city,
        'zip_code': consultPayInfo.zip_code,

        "iban": consultPayInfo.iban,
        "swift": consultPayInfo.swift,
        'bankName': consultPayInfo.bankName,
        'bankAccountNumber': consultPayInfo.bankAccountNumber,
        'siteUrl': consultPayInfo.siteUrl,
      }, SetOptions(merge: true));
      setState(() {
        isAdding = false;
      });
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/home',
            (route) => false,
      );
      /*  if(consult.marketplace!)
           addBusiness();
      else{
        setState(() {
          isAdding=false;
        });
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
              (route) => false,
        );
      }*/
    } else
      showSnack(getTranslated(context, "allRequired"), context);
  }

  BoxDecoration decoration(Size size) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius:
          BorderRadius.circular((kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 8.0),
      border: CustomOulinedButton.outlineBorder(),
      // boxShadow: [
      //   BoxShadow(
      //     color: Color.fromRGBO(123, 108, 150, 0.18),
      //     blurRadius: 8.0,
      //     spreadRadius: 0.0,
      //     offset: Offset(0.0, 1.0),
      //   )
      // ],
    );
  }
}
