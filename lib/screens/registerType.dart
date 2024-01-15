import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/config/paths.dart';
import 'package:jeras/controller/blocs/account_bloc/account_bloc.dart';
import 'package:jeras/main.dart';
import 'package:jeras/models/user.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/responsive_layout.dart';

import '../../config/colors_file.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../app/authentication/view/screens/sign_up_screen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../widget/custom_back_button.dart';

class RegisterTypeScreen extends StatefulWidget {
  @override
  _RegisterTypeScreenState createState() => _RegisterTypeScreenState();
}

class _RegisterTypeScreenState extends State<RegisterTypeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String theme = "light";
  String selectedLang = " ";
  GroceryUser user = GroceryUser();
  late AccountBloc accountBloc;
  bool changeLang = false;

  static LinearGradient get gradiant => LinearGradient(
        begin: Alignment(-0.026087120175361633, 0.5),
        end: Alignment(1.0575249195098877, 0.5),
        colors: [
          AppColors.linear1,
          AppColors.linear2,
        ],
      );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  void ShowToastMessage(String s) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
  }

  void _scrollListener() {
    // Perform actions based on scroll position
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Reached the bottom of the scrollable widget
    }
  }

  List<KeyValueModel> _datas = [
    KeyValueModel(key: 0, value: "العربية"),
    KeyValueModel(key: 1, value: "English"),
    // KeyValueModel(key: 2, value: "Español"),
    // KeyValueModel(key: 3, value: "Deusch"),
    KeyValueModel(key: 4, value: "Fraçais"),
    // KeyValueModel(key: 5, value: "Italino"),
    // KeyValueModel(key: 6, value: "日本語"),
  ];

  late String lang = getTranslated(context, 'lang'),
      langValue = getTranslated(context, 'lang'),
      registerAsClient = getTranslated(context, "registerAsClient"),
      registerAsConsultant = getTranslated(context, 'registerAsConsultant'),
      constRegistration = getTranslated(context, 'constRegistration');

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: ResponsiveLayout(
        desktop: SingleChildScrollView(
          child: Container(
            height: size.height,
            width: size.width,
            child: Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: AppPadding.p48.h,
                        left: AppPadding.p140.w,
                        right: AppPadding.p140.w),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //back
                          Container(
                              width: AppSize.w80.w,
                              height: AppSize.h80.h,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r16.r),
                              ),
                              child: CustomBackButton()),
                          SizedBox(width: AppSize.w10.w),
                          // DropdownButton2(
                          //   underline: Container(),
                          //   alignment: Alignment.center,
                          //   isExpanded: true,
                          //   // value: dropdownValue,
                          //   dropdownOverButton: false,
                          //   offset: Offset(-(size.width * .3), 100),
                          //   dropdownDirection: DropdownDirection.right,
                          //   dropdownWidth: size.width * .8,
                          //   dropdownElevation: 16,
                          //   dropdownDecoration: BoxDecoration(
                          //     borderRadius: BorderRadius.all(Radius.circular(27.r)),
                          //     boxShadow: [
                          //       BoxShadow(
                          //         color: const Color(0x30937dbc),
                          //         offset: Offset(0, 9),
                          //         blurRadius: 28,
                          //         spreadRadius: 0,
                          //       ),
                          //     ],
                          //     color: AppColors.white,
                          //   ),
                          //   style: TextStyle(
                          //     fontFamily: getTranslated(context, "Ithra"),
                          //     color: AppColors.blue,
                          //     fontSize: AppFontsSizeManager.s13.sp,
                          //     letterSpacing: AppConstants.letterSpacing0_5,
                          //   ),
                          //   itemHeight: 30,
                          //   dropdownPadding: EdgeInsets.only(
                          //       left: AppPadding.p20,
                          //       right: AppPadding.p10,
                          //       top: AppPadding.p25,
                          //       bottom: AppPadding.p15),
                          //   items: _datas
                          //       .map((data) => DropdownMenuItem<String>(
                          //           alignment: Alignment.center,
                          //           child: Row(
                          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               Text(
                          //                 data.value.toString(),
                          //                 style: TextStyle(
                          //                   fontFamily: getTranslated(context, "Ithra"),
                          //                   color: AppColors.black,
                          //                   fontWeight: FontWeight.bold,
                          //                   fontSize: AppFontsSizeManager.s15.sp,
                          //                   letterSpacing:
                          //                       AppConstants.letterSpacing0_5,
                          //                 ),
                          //               ),
                          //               data.value == lang
                          //                   ? Icon(
                          //                       Icons.check,
                          //                       color: Theme.of(context).primaryColor,
                          //                       size: AppSize.w15,
                          //                     )
                          //                   : SizedBox(),
                          //             ],
                          //           ),
                          //           value: data.key.toString() //data.key,
                          //           ))
                          //       .toList(),
                          //   onChanged: (String? value) {
                          //     switch (value) {
                          //       case "0":
                          //         lang = "العربية";
                          //         langValue = "ar";
                          //         registerAsClient = "التسجيل كطالب";
                          //         registerAsConsultant = "التسجيل كمعلم";
                          //         constRegistration =
                          //             "يرجى التسجيل في حالة التقديم على وظيفة المعلم";
                          //         break;
                          //       case "1":
                          //         lang = "English";
                          //         langValue = "en";
                          //         registerAsClient = "Register as a student";
                          //         registerAsConsultant = "Register as a teacher";
                          //         constRegistration =
                          //             "Please register if you are looking for consultant job";
                          //         break;
                          //       case "2":
                          //         lang = "Español";
                          //         //TODO:: get Español translations
                          //         break;
                          //       case "3":
                          //         lang = "Deusch";
                          //         //TODO:: get Deusch translations
                          //         break;
                          //       case "4":
                          //         lang = "Fraçais";
                          //         langValue = "fr";
                          //         registerAsClient = "S'inscrire en tant qu'étudiant";
                          //         registerAsConsultant =
                          //             "S'inscrire en tant qu'enseignant";
                          //         constRegistration =
                          //             "Veuillez vous inscrire si vous êtes à la recherche d'un emploi d'enseignant";
                          //         break;
                          //       case "5":
                          //         lang = "Italino";
                          //         //TODO:: get Italino translations
                          //         break;
                          //       case "6":
                          //         lang = "日本語";
                          //         //TODO:: get 日本語 translations
                          //         break;
                          //       default:
                          //         lang = "العربية";
                          //         break;
                          //     }
                          //     setState(() {});
                          //     _changeLanguage(langValue);
                          //   },
                          //   customButton: Row(
                          //     children: [
                          //       Text(
                          //         getTranslated(context, "languagh"),
                          //         style: TextStyle(
                          //             color: AppColors.grey2,
                          //             fontWeight: AppFontsWeightManager.normal,
                          //             fontFamily: getTranslated(context, "Ithra"),
                          //             fontStyle: FontStyle.normal,
                          //             fontSize: AppFontsSizeManager.s31.sp),
                          //       ),
                          //       SizedBox(width: AppSize.w13.w),
                          //       Image.asset(
                          //         AssetsManager.globalSearch,
                          //         width: AppSize.w44.w,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          Container(
                            height: AppSize.h77.h,
                            width: AppSize.w205.w,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r8.r),
                                color: AppColors.white,
                                border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: AppSize.w2.w)),
                            child: InkWell(
                              onTap: () {
                                showLangDialog(size);
                              },
                              child: Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    getTranslated(context, "languagh"),
                                    style: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight:
                                            AppFontsWeightManager.normal,
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        fontStyle: FontStyle.normal,
                                        fontSize: AppFontsSizeManager.s32.sp),
                                  ),
                                  SizedBox(width: AppSize.w20.w),
                                  Image.asset(
                                    AssetsManager.globalSearch,
                                    width: AppSize.w40.w,
                                    height: AppSize.h40.h,
                                  ),
                                  Spacer()
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
                  SizedBox(
                    height: AppSize.h88.h,
                  ),
                  Center(
                    child: Image.asset(
                      AssetsManager.whiteJerasLogoIconPath,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w160.w
                          : AppSize.w50.w,
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h119_7.h
                          : AppSize.h65.h,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h112.h,
                  ),
                  PrimaryButton(
                    width: AppSize.w947.w,
                    height: AppSize.h100.h,
                    save: true,
                    // color: AppColors.primaryColor,
                    buttonRadius: AppRadius.r16.r,
                    textSize: AppFontsSizeManager.s32.sp,
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          //CONSULTANT
                          builder: (context) => SignUpScreen(userType: "USER"),
                        ),
                      );
                    },
                    text: getTranslated(context, "registerAsClient"),
                  ),
                  SizedBox(
                    height: AppSize.h88.h,
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        //CONSULTANT
                        builder: (context) =>
                            SignUpScreen(userType: "CONSULTANT"),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: AppSize.h120.h,
                              width: AppSize.w120.w,
                              padding: EdgeInsets.all(AppPadding.p15),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0x47ae9cce),
                                    offset: Offset(0, 8),
                                    blurRadius: 15,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                AssetsManager.teacher,
                                width: AppSize.w52.w,
                                height: AppSize.h66_1.h,
                              ),
                            ),
                            SizedBox(width: AppSize.h48.h),
                            Text(
                              getTranslated(context, "registerAsConsultant"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pink,
                                fontStyle: FontStyle.normal,
                                fontSize: AppFontsSizeManager.s21.sp,
                                fontWeight: AppFontsWeightManager.bold300,
                              ),
                            ),
                          ],
                        ),

                        // SizedBox(height: AppSize.h10.h),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSize.h56.h),
                  SizedBox(
                    child: Text(
                      getTranslated(context, "constRegistration"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Ithra',
                        color: AppColors.textLightGrey,
                        fontWeight: AppFontsWeightManager.normal,
                        fontStyle: FontStyle.normal,
                        fontSize: AppFontsSizeManager.s21.sp,
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ),
        mobile: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p32.w,
          ),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: AppSize.h42_6.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                            width: AppSize.w50_6.r,
                            height: AppSize.h50_6.r,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r13.r),
                            ),
                            child: CustomBackButton()),
                        SizedBox(width: AppSize.w10.w),
                        // DropdownButton2(
                        //   underline: Container(),
                        //   alignment: Alignment.center,
                        //   isExpanded: true,
                        //   // value: dropdownValue,
                        //   dropdownOverButton: false,
                        //   offset: Offset(-(size.width * .3), 100),
                        //   dropdownDirection: DropdownDirection.right,
                        //   dropdownWidth: size.width * .8,
                        //   dropdownElevation: 16,
                        //   dropdownDecoration: BoxDecoration(
                        //     borderRadius:
                        //         BorderRadius.all(Radius.circular(27.r)),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: const Color(0x30937dbc),
                        //         offset: Offset(0, 9),
                        //         blurRadius: 28,
                        //         spreadRadius: 0,
                        //       ),
                        //     ],
                        //     color: AppColors.white,
                        //   ),
                        //   style: TextStyle(
                        //     fontFamily: getTranslated(context, "Ithra"),
                        //     color: AppColors.blue,
                        //     fontSize: AppFontsSizeManager.s13.sp,
                        //     letterSpacing: AppConstants.letterSpacing0_5,
                        //   ),
                        //   itemHeight: AppSize.h30,
                        //   dropdownPadding: EdgeInsets.only(
                        //       left: AppPadding.p20,
                        //       right: AppPadding.p10,
                        //       top: AppPadding.p25,
                        //       bottom: AppPadding.p15),
                        //   items: _datas
                        //       .map((data) => DropdownMenuItem<String>(
                        //           alignment: Alignment.center,
                        //           child: Row(
                        //             mainAxisAlignment:
                        //                 MainAxisAlignment.spaceBetween,
                        //             children: [
                        //               Text(
                        //                 data.value.toString(),
                        //                 style: TextStyle(
                        //                   fontFamily:
                        //                       getTranslated(context, "Ithra"),
                        //                   color: Colors.black,
                        //                   fontWeight: FontWeight.bold,
                        //                   fontSize: AppFontsSizeManager.s15.sp,
                        //                   letterSpacing:
                        //                       AppConstants.letterSpacing0_5,
                        //                 ),
                        //               ),
                        //               data.value == lang
                        //                   ? Icon(
                        //                       Icons.check,
                        //                       color: Theme.of(context)
                        //                           .primaryColor,
                        //                       size: AppSize.w15,
                        //                     )
                        //                   : SizedBox(),
                        //             ],
                        //           ),
                        //           value: data.key.toString() //data.key,
                        //           ))
                        //       .toList(),
                        //   onChanged: (String? value) {
                        //     switch (value) {
                        //       case "0":
                        //         lang = "العربية";
                        //         langValue = "ar";
                        //         registerAsClient = "التسجيل كطالب";
                        //         registerAsConsultant = "التسجيل كمعلم";
                        //         constRegistration =
                        //             "يرجى التسجيل في حالة التقديم على وظيفة المعلم";
                        //         break;
                        //       case "1":
                        //         lang = "English";
                        //         langValue = "en";
                        //         registerAsClient = "Register as a student";
                        //         registerAsConsultant = "Register as a teacher";
                        //         constRegistration =
                        //             "Please register if you are looking for consultant job";
                        //         break;
                        //       case "2":
                        //         lang = "Español";
                        //         //TODO:: get Español translations
                        //         break;
                        //       case "3":
                        //         lang = "Deusch";
                        //         //TODO:: get Deusch translations
                        //         break;
                        //       case "4":
                        //         lang = "Fraçais";
                        //         langValue = "fr";
                        //         registerAsClient =
                        //             "S'inscrire en tant qu'étudiant";
                        //         registerAsConsultant =
                        //             "S'inscrire en tant qu'enseignant";
                        //         constRegistration =
                        //             "Veuillez vous inscrire si vous êtes à la recherche d'un emploi d'enseignant";
                        //         break;
                        //       case "5":
                        //         lang = "Italino";
                        //         //TODO:: get Italino translations
                        //         break;
                        //       case "6":
                        //         lang = "日本語";
                        //         //TODO:: get 日本語 translations
                        //         break;
                        //       default:
                        //         lang = "العربية";
                        //         break;
                        //     }
                        //     setState(() {
                        //       _changeLanguage(langValue);
                        //     });
                        //   },
                        //   customButton: Row(
                        //     children: [
                        //       Text(
                        //         lang,
                        //         style: TextStyle(
                        //             color: AppColors.grey,
                        //             fontWeight: AppFontsWeightManager.bold300,
                        //             fontFamily: getTranslated(context, "Ithra"),
                        //             fontStyle: FontStyle.normal,
                        //             fontSize: AppFontsSizeManager.s22.sp),
                        //       ),
                        //       SizedBox(width: AppSize.w5.w),
                        //       Image.asset(
                        //         AssetsManager.globalSearch,
                        //         width: AppSize.w32.w,
                        //         height: AppSize.h32.h,
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container(
                          height: AppSize.h50_6.r,
                          padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p10_6.w,
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r5_3.r),
                              border: Border.all(
                                  color: AppColors.primaryColor,
                                  width: AppSize.w1.w)),
                          child: InkWell(
                            onTap: () async {
                              showLangDialog(size);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  getTranslated(context, "languagh"),
                                  style: TextStyle(
                                      height: AppSize.h0_5.h,
                                      fontWeight: AppFontsWeightManager.bold100,
                                      color: AppColors.primaryColor,
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s28.sp
                                          : AppFontsSizeManager.s21_3.sp,
                                      fontFamily: lang == "ar"
                                          ? getTranslated(context, "Ithra")
                                          : getTranslated(
                                              context, "Montserratbold")),
                                ),
                                SizedBox(width: AppSize.w16.w),
                                InkWell(
                                  enableFeedback: false,
                                  onTap: () async {},
                                  child: SvgPicture.asset(
                                    lang == "ar"
                                        ? AssetsManager.worldSearch
                                        : AssetsManager.worldSearch,
                                    width: AppSize.w32.r,
                                    height: AppSize.h32.r,
                                  ),
                                ),
                                //Spacer()
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h214_6.h,
                ),
                Center(
                  child: Image.asset(
                    AssetsManager.whiteJerasLogoIconPath,
                    width: AppSize.w99_3.w,
                    height: AppSize.h132_9.h,
                  ),
                ),
                SizedBox(
                  height: AppSize.h114_6.h,
                ),
                PrimaryButton(
                  width: AppSize.w390_6.r,
                  height: AppSize.h66_6.r,
                  buttonRadius: AppRadius.r16.r,
                  textSize: AppFontsSizeManager.s21_3.sp,
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        //CONSULTANT
                        builder: (context) => SignUpScreen(userType: "USER"),
                      ),
                    );
                  },
                  text: getTranslated(context, "registerAsClient"),
                ),
                SizedBox(height: AppSize.h250_6.h),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      //CONSULTANT
                      builder: (context) =>
                          SignUpScreen(userType: "CONSULTANT"),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: AppSize.w77_3.r,
                            height: AppSize.h77_3.r,
                            padding: EdgeInsets.all(AppPadding.p15),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.grey2,
                                  offset: Offset(0, 4),
                                  blurRadius: 12,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              AssetsManager.teacher2,
                              width: AppSize.w33_3.r,
                              height: AppSize.h42_6.r,
                            ),
                          ),
                          SizedBox(width: AppSize.w21_3.w),
                          Text(
                            getTranslated(context, "registerAsConsultant"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.primaryColor,
                              fontStyle: FontStyle.normal,
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              //fontWeight: AppFontsWeightManager.bold300,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSize.h32.h),
                      SizedBox(
                        width: AppSize.w312.w,
                        child: Text(
                          getTranslated(context, "constRegistration"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithralight"),
                            color: AppColors.grey3,
                            // fontWeight: AppFontsWeightManager.bold600,
                            fontStyle: FontStyle.normal,
                            fontSize: AppFontsSizeManager.s21_3.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeLanguage(String lang) async {
    final _temp = await setLocale(lang);
    MyApp.setLocale(context, _temp);
  }

  showLangDialog(Size size) {
    GroupController controller =
        GroupController(initSelectedItem: [getTranslated(context, "lang")]);
    return showDialog(
      builder: (context) => Container(
        child: JerasDialogWidget(
          radius: AppRadius.r32.r,
          padButtom:
              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? null : 0,
          padLeft:
              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? null : 0,
          padReight:
              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? null : 0,
          padTop: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? null : 0,
          dialogContent: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h89_5.h
                    : AppSize.h30.h,
              ),
              Container(
                padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? EdgeInsets.symmetric(horizontal: AppSize.w45.w)
                    : lang == "ar"
                        ? EdgeInsets.only(right: AppPadding.p10.w)
                        : EdgeInsets.only(left: AppPadding.p10.w),
                height: AppSize.h200.h,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w478.w
                    : AppSize.w466_6.w,
                child: SimpleGroupedCheckbox<String>(
                  ///
                  controller: controller,
                  onItemSelected: (data) {
                    setState(() {
                      selectedLang = data;
                    });
                  },
                  itemsTitle: [
                    getTranslated(context, 'ar'),
                    getTranslated(context, 'en'),
                    getTranslated(context, 'fr'),
                  ],
                  values: ["ar", "en", "fr"],
                  groupStyle: GroupStyle(
                      activeColor: AppColors.linear2,
                      itemTitleStyle: TextStyle(
                        fontSize: AppFontsSizeManager.s26_6.sp,
                        fontFamily: getTranslated(context, 'Ithra'),
                      )),
                  //checkFirstElement: false,
                ),
              ),
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h69_5.h
                    : AppSize.h32.h,
              ),
              Center(
                child: Container(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h90.h
                      : AppSize.h66_6.r,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w401.w
                      : AppSize.w390_6.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      end: Alignment.topCenter,
                      begin: Alignment.bottomCenter,
                      colors: [
                        AppColors.gradiant1,
                        AppColors.gradiant2,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.all(Radius.circular(AppRadius.r16.r)),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (selectedLang == 'ar')
                        changelanguage("ar", "AR");
                      else if (selectedLang == 'en')
                        changelanguage("en", "US");
                      else if (selectedLang == 'fr')
                        changelanguage("fr", "FR");
                      else
                        Navigator.pop(context);
                    },
                    // color: AppColors.linear2,

                    child: Center(
                      child: Text(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? getTranslated(context, "change")
                            : getTranslated(context, "save"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: AppColors.white,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s36.sp
                                  : AppFontsSizeManager.s21_3.sp,
                          fontWeight: AppFontsWeightManager.bold400,
                          fontStyle: FontStyle.normal,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h56.h
                    : AppSize.h48.h,
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  changelanguage(String lang, String code) async {
    setState(() {
      changeLang = true;
    });
    await setLocale(lang);
    Locale _temp = Locale(lang, code);
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user.uid)
          .set({
        'userLang': lang,
        'languages':
            user.userType == AppConstants.consultant ? user.languages : [lang],
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .doc(user.supportListId)
          .set({
        'userLang': lang,
      }, SetOptions(merge: true));
      accountBloc.add(GetLoggedUserEvent());
    }
    MyApp.setLocale(context, _temp);
    setState(() {
      changeLang = false;
    });
    Navigator.pop(context);
  }
}
