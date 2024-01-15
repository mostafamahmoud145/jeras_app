import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';

class SuggestionScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const SuggestionScreen({Key? key, required this.loggedUser})
      : super(key: key);

  @override
  _SuggestionScreenState createState() => _SuggestionScreenState();
}

class _SuggestionScreenState extends State<SuggestionScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false;
  late GroceryUser user;
  List<GroceryUser> users = [];
  String? title, des, theme;
  String lang = "";

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
        body: Stack(children: <Widget>[
      Column(
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
                    CustomBackButton(),
                    SizedBox(width: AppSize.w10.w),
                    Text(
                      getTranslated(context, "suggestions"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: size.width >= 500
                              ? getTranslated(context, "Ithralight")
                              : getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s31.sp
                                  : AppFontsSizeManager.s20.sp,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1.h,
                  width: size.width)),
          Expanded(
            child: ListView(
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppPadding.p0_35
                        : AppPadding.p20,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppPadding.p0_35
                        : AppPadding.p20),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(AppPadding.p10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Center(
                            child: Container(
                                padding: EdgeInsets.only(
                                    top: AppPadding.p20,
                                    bottom: AppPadding.p20),
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w198.w
                                    : AppSize.w162_3.w,
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h233_3.h
                                    : AppSize.h192.h,
                                child: Image.asset(
                                  AssetsManager.suggestionImage,
                                )),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h16.h
                                : AppSize.h25.h,
                          ),
                          //title
                          Text(
                            getTranslated(context, "suggestionText"),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: 6,
                            style: TextStyle(
                                fontFamily: size.width >= 500
                                    ? getTranslated(context, "Ithralight")
                                    : getTranslated(context, "Ithralight"),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s25.sp
                                    : AppFontsSizeManager.s21_3.sp,
                                color: AppColors.grey),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h30.h
                                : AppSize.h40.h,
                          ),
                          Text(
                            getTranslated(context, "theName"),
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: lang == "ar"
                                  ? getTranslated(context, "Ithra")
                                  : getTranslated(context, "Montserrat"),
                            ),
                          ),
 Container(
                            // height: (kIsWeb ||
                            //         size.width >= AppConstants.kIsWebValue)
                            //     ? AppSize.h95.h
                            //     : AppSize.h85.h,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: AppPadding.p20.h,
                                  bottom: AppPadding.p10),
                              child: SizedBox(
                                // height: AppSize.h50.h,
                                child: Theme(
                                  data: new ThemeData(
                                    primaryColor: Colors.redAccent,
                                    primaryColorDark: Colors.red,
                                  ),
                                  child: TextFormField(
                                      scrollPadding: EdgeInsets.symmetric(
                                          horizontal: AppPadding.p20.w),
                                      style: TextStyle(
                                        fontFamily: size.width >= 500
                                            ? getTranslated(
                                                context, "Ithralight")
                                            : getTranslated(
                                                context, "Ithralight"),
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s18.sp
                                            : AppFontsSizeManager.s21_3.sp,
                                        fontWeight: AppFontsWeightManager.bold,
                                        color: AppColors.grey,
                                      ),
                                      cursorColor: AppColors.pink,
                                      keyboardType: TextInputType.text,
                                      validator: (String? val) {
                                        if (val!.trim().isEmpty) {
                                          return getTranslated(
                                              context, 'required');
                                        }
                                        return null;
                                      },
                                      onSaved: (val) {
                                        title = val!;
                                      },
                                      
                                      enableInteractiveSelection: true,
                                      decoration: inputDecoration(size)),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h35.h
                                : AppSize.h20.h,
                          ),
                          Text(
                            getTranslated(context, "Suggestions"),
                            style: TextStyle(
                              color: AppColors.primaryColor,
                              fontFamily: lang == "ar"
                                  ? getTranslated(context, "Ithra")
                                  : getTranslated(context, "Montserrat"),
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h35.h
                                : AppSize.h20.h,
                          ),
                          Container(
                            height: AppSize.h200.h,
                            padding: EdgeInsets.all((kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p20
                                : AppPadding.p5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular((kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r12.r
                                  : AppRadius.r16.r),
                              border: Border.all(
                                  color: AppColors.grey, width: AppSize.w1.w),
                            ),
                            child: Center(
                              child: Container(
                                //width: size.width * .7,
                                child: TextFormField(
                                  maxLines: 7,
                                  maxLength: 300,
                                  style: TextStyle(
                                    fontFamily: size.width >= 500
                                        ? getTranslated(context, "Ithralight")
                                        : getTranslated(context, "Ithralight"),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s18.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.grey,
                                  ),
                                  cursorColor: Colors.black,
                                  initialValue: des,
                                  keyboardType: TextInputType.multiline,
                                  onSaved: (val) {
                                    des = val!;
                                  },
                                  decoration: new InputDecoration(
                                    counterStyle: TextStyle(
                                      color: Colors.grey,
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s18.sp
                                          : AppFontsSizeManager.s14.sp,
                                    ),
                                    hintStyle: TextStyle(
                                      fontFamily: size.width >= 500
                                          ? getTranslated(context, "Ithralight")
                                          : getTranslated(
                                              context, "Ithralight"),
                                      color: Colors.grey,
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s18.sp
                                          : AppFontsSizeManager.s14.sp,
                                      fontWeight:
                                          AppFontsWeightManager.semiBold,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                    hintText: '     .................',
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,

                                    //  hintText: sLabel
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h62.h
                                : lang == "ar"
                                    ? AppSize.h100.h
                                    : AppSize.h100.h,
                          ),
                          //d
                          Center(
                            child: InkWell(
                              onTap: () {
                                save();
                              },
                              child: Container(
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h80.h
                                    : AppSize.h66.r,
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w439.w
                                    : AppSize.w365.r,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppRadius.r22.r
                                            : AppRadius.r16.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.linear1,
                                        AppColors.linear2,
                                        AppColors.linear2,
                                      ],
                                    )),
                                child: saving
                                    ? Center(child: CircularProgressIndicator())
                                    : Center(
                                        child: Text(
                                          getTranslated(context, "save"),
                                          style: TextStyle(
                                            fontFamily: lang == "ar"
                                                ? getTranslated(
                                                    context, "Ithra")
                                                : getTranslated(
                                                    context, "Montserrat"),
                                            color: Colors.white,
                                            fontSize: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppFontsSizeManager.s26_6.sp
                                                : AppFontsSizeManager.s21_3.sp,
                                            letterSpacing:
                                                AppConstants.letterSpacing0_5,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h25.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    ]));
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        String suggestionId = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.suggestionsPath)
            .doc(suggestionId)
            .set({
          "userUid": widget.loggedUser.uid,
          'suggestionId': suggestionId,
          'status': false,
          'sendTime': Timestamp.now(),
          'title': title,
          'desc': des,
          'userData': {
            'uid': widget.loggedUser.uid,
            'name': widget.loggedUser.name,
            'image': widget.loggedUser.photoUrl,
            'phone': widget.loggedUser.phoneNumber,
          },
        });
        setState(() {
          saving = false;
        });
        showAddingSuggestionDialog(MediaQuery.of(context).size);
      } catch (e) {}
    }
  }

  showAddingSuggestionDialog(Size size) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Padding(
          padding: EdgeInsets.only(right: AppSize.w10_6.w),
          child: Column(
            children: <Widget>[
              SizedBox(height: AppSize.h10_6.h),
              Center(
                child: SvgPicture.asset(
                  AssetsManager.moveHandHeartLinearIconPath,
                  width: AppSize.w53_5.r,
                  height: AppSize.h53_5.r,
                ),
              ),
              SizedBox(height: AppSize.h26.h),
              Column(
                children: [
                  Text(
                    getTranslated(context, "suggestions"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s26_6.sp,
                      color: AppColors.linear2,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSize.h26.h),
                  Text(
                    getTranslated(context, "thanks"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h32.h,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    child: Container(
                      width: AppSize.w377_3.w,
                      height: AppSize.h56.h,
                      //   alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.linear2,
                        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, 'continue'),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s18_6.sp,
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
  }

  InputDecoration inputDecoration(Size size) {
    return InputDecoration(
      
      isDense: true,
      fillColor: Colors.white,
      hintText: getTranslated(context, 'enterUrName'),
      hintStyle: TextStyle(
        color: AppColors.grey,
        fontWeight: FontWeight.w300,
        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s18.sp
                                            : AppFontsSizeManager.s21_3.sp,
        fontFamily: lang == "ar"
            ? getTranslated(context, "Ithralight")
            : getTranslated(context, "Montserrat"),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppPadding.p21_3.w,
        vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppPadding.p20.h
            : AppPadding.p26_5.h,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        borderSide: BorderSide(
          color: AppColors.grey,
          width: AppSize.w1.w,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        borderSide: BorderSide(
          color: AppColors.red,
          width: AppSize.w1.w,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r15.r),
        borderSide: BorderSide(
          color: AppColors.grey,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        borderSide: BorderSide(
          color: AppColors.grey,
          width: AppSize.w1.w,
        ),
      ),
    );
  }
}
