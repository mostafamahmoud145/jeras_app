import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_constat.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/interests.dart';
import '../../models/user.dart';
import '../../widget/custom_back_button.dart';
import '../../widget/processing_dialog.dart';

class SendNotificationScreen extends StatefulWidget {
  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> notificationMap = Map();
  TextEditingController controller = TextEditingController();
  var image;
  int ageValue = -1;
  var selectedImage;
  String url = "noImage";
  String link = "noLink";
  late bool isSending,
      sendReq = false,
      langReq = false,
      isAdding = false,
      loadInterests = true;
  String? selectedType, selectedCountry = "00", selectedLang, theme = "light";
  String? title,
      body,
      type,
      age,
      countryName = "00",
      langValue = "",
      done = "Save",
      dropdownTypeValue,
      dropdownLangValue,
      ageDropDownValue;
  List<KeyValueModel> _typeArray = [];
  List<KeyValueModel> _ageArray = [
    KeyValueModel(key: 0, value: "اقل من ١٠ سنوات"),
    KeyValueModel(key: 1, value: "يتراوح من ١٠ الي ١٥ سنة"),
    KeyValueModel(key: 2, value: "اكبر من ١٥ سنة"),
  ];
  List<Interests> interestList = [], selectedInterestList = [];

  @override
  void initState() {
    super.initState();
    getInterests();
    isSending = false;
  }

  getInterests() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.interestsPath)
          .get();
      var list = List<Interests>.from(
        querySnapshot.docs.map(
          (snapshot) => Interests.fromMap(snapshot.data() as Map),
        ),
      );

      setState(() {
        interestList = list;
        loadInterests = false;
      });
    } catch (e) {
      setState(() {
        loadInterests = false;
      });
    }
  }

  Future cropImage(context) async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile = File(image.path);

    setState(() {
      selectedImage = croppedFile;
    });
  }

  sendNotification() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (dropdownTypeValue == null) {
        if (selectedType == null)
          setState(() {
            sendReq = true;
          });
      } else {
        setState(() {
          isAdding = true;
        });

        if (selectedImage != null) {
          var uuid = Uuid().v4();
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('pushNotificationImages/$uuid');
          await storageReference.putFile(selectedImage);
          url = await storageReference.getDownloadURL();
        }

        List<String> interestsName = [];
        List<String> ids = [];
        for (var add in selectedInterestList) {
          interestsName.add(add.arName);
          ids.add(add.interestId);
        }

        String id = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.generalNotificationsPath)
            .doc(id)
            .set({
          'id': id,
          'title': title,
          'body': body,
          'notificationLang': "ar",
          'notificationType': dropdownTypeValue,
          'notificationAge': ageDropDownValue,
          'countryCode': selectedCountry,
          'interestIds': ids,
          'interestsName': interestsName,
          'notificationCountry': countryName! + " - " + selectedCountry!,
          'notificationTimestamp': Timestamp.now(),
          'imageUrl': url,
          'link': link,
        });

        //call function

        setState(() {
          isAdding = false;
        });
        Navigator.pop(context);
      }
    }
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: 'Sending notification..\nPlease wait!',
        );
      },
    );
  }

  void showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: getTranslated(context, "enterAll"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    _typeArray = [
      KeyValueModel(
          key: "CONSULTANT", value: getTranslated(context, "consultNum")),
      KeyValueModel(key: "USER", value: getTranslated(context, "userNum")),
      KeyValueModel(
          key: "SUPPORT", value: getTranslated(context, "supportNum")),
    ];

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(color: AppColors.black),
                      const SizedBox(width: 10),
                      Text(
                        getTranslated(context, "sendNotification"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: AppFontsWeightManager.bold300,
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
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p16,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue) ?size.width * AppPadding.p0_3 : AppPadding.p16,
                  bottom:AppPadding.p16,
                  top: AppPadding.p16),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Center(
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppSize.h0_15
                                  : size.width * AppSize.h0_45,
                              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppSize.h0_15
                                  : size.width * AppSize.w0_9,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(AppRadius.r20),
                                color: theme == "light"
                                    ? AppColors.white
                                    : Colors.transparent,
                                boxShadow: [
                                  BoxShadow(
                                    offset: Offset(0, 0.0),
                                    blurRadius: 15.0,
                                    spreadRadius: 2.0,
                                    color: AppColors.black.withOpacity(0.05),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.r20),
                                child: selectedImage == null
                                    ? Icon(
                                        Icons.image,
                                        size:AppSize.w50
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.r20),
                                        child: Image.file(
                                          selectedImage,
                                        ),
                                      ),
                              ),
                            ),
                            selectedImage != null
                                ? Positioned(
                                    top: AppPadding.p10,
                                    right: AppPadding.p10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.r10),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                              AppColors.white.withOpacity(0.6),
                                          onTap: () {
                                            cropImage(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: AppSize.w30,
                                            height: AppSize.h30,
                                            child: Icon(
                                              Icons.edit,
                                              color: theme == "light"
                                                  ? AppColors.white
                                                  : Colors.black,
                                              size: AppSize.w16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Positioned(
                                    top: AppPadding.p10,
                                    right: AppPadding.p10,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.r10),
                                      child: Material(
                                        color: Theme.of(context).primaryColor,
                                        child: InkWell(
                                          splashColor:
                                              AppColors.white.withOpacity(0.6),
                                          onTap: () {
                                            cropImage(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(),
                                            width: AppSize.w30,
                                            height:AppSize.h30,
                                            child: Icon(
                                              Icons.add,
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
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }
                          return null;
                        },
                        onSaved: (val) {
                          title = val!.trim();
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
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: AppColors.black.withOpacity(0.65),
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            //color: AppColors.black54,
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          //prefixIcon: Icon(Icons.title),
                          labelText: getTranslated(context, "title"),
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
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }

                          return null;
                        },
                        onSaved: (val) {
                          body = val!.trim();
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        minLines: 1,
                        maxLines: 6,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p15, vertical: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: AppColors.black.withOpacity(0.65),
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            //color: AppColors.black54,
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          // prefixIcon: Icon(Icons.mail),
                          labelText: getTranslated(context, "description"),
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
                      Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                              color: theme == "light"
                                  ? AppColors.white
                                  : Colors.transparent,
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10))),
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: AppPadding.p10, right: AppPadding.p10),
                            child: DropdownButton<String>(
                              hint: Text(
                                getTranslated(context, "sendTo"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  //color: AppColors.black,
                                  fontSize: AppFontsSizeManager.s15,
                                  letterSpacing: AppConstants.letterSpacing0_5,
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
                                color: AppColors.blue,
                                fontSize: AppFontsSizeManager.s13,
                                letterSpacing: AppConstants.letterSpacing0_5,
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
                                          letterSpacing:
                                              AppConstants.letterSpacing0_5,
                                        ),
                                      ),
                                      value: data.key.toString() //data.key,
                                      ))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownTypeValue = value;
                                });
                              },
                            ),
                          )),
                      sendReq
                          ? Text(
                              getTranslated(context, "required"),
                              style: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                color: AppColors.red,
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              border: Border.all(
                                color: AppColors.grey,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: AppPadding.p10, right: AppPadding.p10),
                            child: DropdownButton<String>(
                              hint: Text(
                                getTranslated(context, "ageCat"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  //color: AppColors.black,
                                  fontSize: AppFontsSizeManager.s15,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                              ),
                              underline: Container(),
                              isExpanded: true,
                              value: ageDropDownValue,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: AppColors.black),
                              iconSize: AppSize.w24,
                              elevation: 16,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.blue,
                                fontSize: AppFontsSizeManager.s13,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              items: _ageArray
                                  .map((data) => DropdownMenuItem<String>(
                                      child: Text(
                                        data.value.toString(),
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: AppColors.black,
                                          fontSize: AppFontsSizeManager.s15,
                                          letterSpacing:
                                              AppConstants.letterSpacing0_5,
                                        ),
                                      ),
                                      value: data.key.toString() //data.key,
                                      ))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  ageDropDownValue = value;
                                  ageValue = _ageArray[int.parse(value!)].key;
                                  notificationMap.putIfAbsent('notificationAge',
                                      () => ageValue.toString());
                                });
                              },
                            ),
                          )),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        readOnly: true,
                        controller: controller,
                        onSaved: (val) {
                          countryName = controller.text;
                        },
                        onTap: () {
                          showCountryPicker(
                            context: context,
                            showPhoneCode: true,
                            onSelect: (Country country) {
                              setState(() {
                                selectedCountry = "+" + country.phoneCode;
                                controller.text = country.name;
                              });
                            },
                            // Optional. Sets the theme for the country list picker.
                            countryListTheme: CountryListThemeData(
                              // Optional. Sets the border radius for the bottomsheet.
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(40.0),
                                topRight: Radius.circular(40.0),
                              ),
                              // Optional. Styles the search field.
                              inputDecoration: InputDecoration(
                                labelText: 'Search',
                                hintText: 'Start typing to search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color:AppColors.darkGrey
                                        .withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        minLines: 1,
                        maxLines: 6,
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p15, vertical: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: AppColors.black.withOpacity(0.65),
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            //color: AppColors.black54,
                            fontSize: AppFontsSizeManager.s14_5,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          // prefixIcon: Icon(Icons.mail),
                          labelText: getTranslated(context, "selectCountry"),
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
                      Center(
                        child: Text(
                          getTranslated(context, "interests"),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize:
                                  (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s20 : AppFontsSizeManager.s13,
                              color: AppColors.pink,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      SizedBox(
                        height:AppSize.h20,
                      ),
                      loadInterests
                          ? Center(
                              child: CircularProgressIndicator(
                              color: AppColors.pink,
                            ))
                          : Container(
                              height: size.height * AppSize.h0_4,
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio:
                                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 1.7 : 1,
                                  //8.0 / 9.0,
                                  children: interestList
                                      .map(
                                        (Item) => ItemList(size, Item),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: AppSize.h30,
                      ),
                      SizedBox(
                        height: AppSize.h25,
                      ),
                      isAdding
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Container(
                                height: AppSize.h45,
                                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? size.width * AppSize.h0_15
                                    : double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 0.0),
                                child: MaterialButton(
                                  onPressed: () {
                                    //add notificationMap
                                    sendNotification();
                                  },
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.r15.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.send,
                                        color: theme == "light"
                                            ? AppColors.white
                                            : AppColors.black,
                                        size: AppSize.w20,
                                      ),
                                      SizedBox(
                                        width: AppSize.w10,
                                      ),
                                      Text(
                                        getTranslated(
                                            context, "sendNotification"),
                                        style: GoogleFonts.poppins(
                                          color: theme == "light"
                                              ? AppColors.white
                                              : AppColors.black,
                                          fontSize: AppFontsSizeManager.s15,
                                          fontWeight: AppFontsWeightManager.semiBold,
                                          letterSpacing:
                                              AppConstants.letterSpacing0_3,
                                        ),
                                      ),
                                    ],
                                  ),
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

  Widget ItemList(Size size, Interests item) {
    return InkWell(
      onTap: () {
        setState(() {
          if (selectedInterestList.contains(item)) {
            selectedInterestList.remove(item);
          } else {
            selectedInterestList.add(item);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.lightGrey5,
            borderRadius: BorderRadius.circular(AppRadius.r15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: AppPadding.p8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selectedInterestList.contains(item)
                          ? AppColors.shadoColor
                          : AppColors.lightGrey5,
                    ),
                    width: AppSize.w14,
                    height:AppSize.h13,
                    child: Icon(
                      Icons.check,
                      size: AppSize.w10,
                      color: selectedInterestList.contains(item)
                          ? AppColors.white
                          : AppColors.lightGrey5,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 5, bottom: 5),
              child: Container(
                height: AppSize.h25,
                width: AppSize.w20,
                child: item.icon!.isEmpty
                    ? Image.asset(AssetsManager.whiteJerasLogoIconPath)
                    : FadeInImage.assetNetwork(
                        placeholder: AssetsManager.lodeGif,
                        placeholderScale: 0.5,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                              AssetsManager.whiteJerasLogoIconPath,
                        ),
                        image: item.icon!,
                        //fit: BoxFit.cover,
                        fadeInDuration: Duration(milliseconds: AppConstants.milliseconds250),
                        fadeInCurve: Curves.easeInOut,
                        fadeOutDuration: Duration(milliseconds: AppConstants.milliseconds150),
                        fadeOutCurve: Curves.easeInOut,
                      ),
              ),
            ),
            Stack(
              children: <Widget>[
                Text(
                  item.arName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s15 : AppFontsSizeManager.s10,
                    fontWeight: AppFontsWeightManager.bold300,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 0.2
                      ..color = Color(0xff202020),
                  ),
                ),
                // Solid text as fill.
                Text(
                  item.arName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: Color(0xff202020),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s15 : AppFontsSizeManager.s10,
                    fontWeight: AppFontsWeightManager.bold300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
