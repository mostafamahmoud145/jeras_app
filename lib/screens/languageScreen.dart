import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../main.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String lang = "اللغة",
      langValue = "",
      done = "حفظ",
      title = "من فضلك قم بتحديد لغة التطبيق",
      dropdownValue;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool changeLang = false;
  List<KeyValueModel> _datas = [
    KeyValueModel(key: 0, value: "العربية"),
    KeyValueModel(key: 1, value: "English"),
    KeyValueModel(key: 2, value: "Fraçais"),
    // KeyValueModel(key: 2, value: "Español"),
    // KeyValueModel(key: 3, value: "Deusch"),
    // KeyValueModel(key: 4, value: "Fraçais"),
    // KeyValueModel(key: 5, value: "Italino"),
    // KeyValueModel(key: 6, value: "日本語"),
  ];
  static LinearGradient get gradiant => LinearGradient(
        begin: Alignment(-0.026087120175361633, 0.5),
        end: Alignment(1.0575249195098877, 0.5),
        colors: [
          AppColors.linear1,
          AppColors.linear2,
        ],
      );
  String selectedLang = " ";

  @override
  void initState() {
    super.initState();
    storeDeviceToken();
    lang = "العربية";
    dropdownValue = "0";
    title = "من فضلك قم باختيار اللغة المفضلة";
    langValue = "ar";
  }

  /// When the user enter to the app at first time, store his device token.
  ///
  storeDeviceToken()async{
    String uId= Uuid().v4();
    FirebaseMessaging.instance.getToken().then((token) async{
      await FirebaseFirestore.instance.collection('NotRegisteredUsers').doc(uId).set({
        'token': token,
        'userId': uId,
      });
    });
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Spacer(
                    flex: 6,
                  )
                : SizedBox(
                    height: size.height * .4,
                  ),
            Center(
              child: InkWell(
                onTap: () async {
                  showLangDialog(size);
                },
                child: Container(
                  padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? EdgeInsets.all(0)
                      : EdgeInsets.symmetric(vertical: AppPadding.p16.w),
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w150.w
                      : AppSize.w90_6.w,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h150.w
                      : null,
                  decoration: BoxDecoration(
                    borderRadius: (kIsWeb ||
                            size.width >= AppConstants.kIsWebValue)
                        ? BorderRadius.all(Radius.circular(AppRadius.r40.r))
                        : BorderRadius.all(Radius.circular(AppRadius.r21_3.r)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x30937dbc),
                        offset: Offset(0, 9),
                        blurRadius: 28,
                        spreadRadius: 0,
                      ),
                    ],
                    color: AppColors.white,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AssetsManager.worldSearch,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w78.r
                          : AppSize.w58_6.r,
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h78.r
                          : AppSize.h58_6.r,
                    ),
                  ),
                ),
              ),
            ),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? SizedBox(height: AppSize.h78.h)
                : SizedBox(height: AppSize.h74_6.h),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Text(
                    getTranslated(context, "chooseLang2"),
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s36.sp
                              : AppFontsSizeManager.s18_6.sp,
                      fontFamily: getTranslated(context, "Ithra"),
                    ),
                  )
                : Text(
                    getTranslated(context, "chooseLang2"),
                    style: TextStyle(
                      color: AppColors.grey10,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s36.sp
                              : AppFontsSizeManager.s26_6.sp,
                      fontFamily: getTranslated(context, "Ithra"),
                    ),
                  ),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Spacer(
                    flex: 6,
                  )
                : SizedBox(
                    height: AppSize.h136.h,
                  ),
            PrimaryButton(
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w947.w
                  : AppSize.w390_6.w,
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h100.h
                  : AppSize.h64.r,
              buttonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppRadius.r20.r
                  : AppRadius.r16.r,
              normal: true,
              textSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s36.sp
                  : AppFontsSizeManager.s21_3.sp,
              onPress: () async {
                if (selectedLang == " ") {
                  selectedLang = getTranslated(context, "lang");
                  if (selectedLang == 'ar')
                    changelanguage3("ar", "AR");
                  else if (selectedLang == 'en')
                    changelanguage3("en", "US");
                  else if (selectedLang == 'fr') changelanguage3("fr", "FR");

                  Navigator.pushNamed(context, '/home');
                } else {
                  Navigator.pushNamed(context, '/home');
                }
                // else {
                //   // _changeLanguage(langValue);
                //   //await setFirstLanch();
                //   Navigator.pushNamed(context, '/home');
                //   // Navigator.pushNamed(context, '/OnBoardingScreen');
                // }
              },
              text: getTranslated(
                context,
                "save",
              ),
            ),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Spacer()
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  void _changeLanguage(String lang) async {
    final _temp = await setLocale(lang);
    MyApp.setLocale(context, _temp);
  }

  changelanguage(String lang, String code) async {
    setState(() {
      changeLang = true;
    });
    await setLocale(lang);
    Locale _temp = Locale(lang, code);
    // if (FirebaseAuth.instance.currentUser != null) {
    //   await FirebaseFirestore.instance
    //       .collection(Paths.usersPath)
    //       .doc(user.uid)
    //       .set({
    //     'userLang': lang,
    //     'languages':
    //         user.userType == AppConstants.consultant ? user.languages : [lang],
    //   }, SetOptions(merge: true));
    //   await FirebaseFirestore.instance
    //       .collection(Paths.supportListPath)
    //       .doc(user.supportListId)
    //       .set({
    //     'userLang': lang,
    //   }, SetOptions(merge: true));
    //   accountBloc.add(GetLoggedUserEvent());
    // }
    MyApp.setLocale(context, _temp);
    setState(() {
      changeLang = false;
    });
    Navigator.pop(context);
  }

  changelanguage3(String lang, String code) async {
    setState(() {
      changeLang = true;
    });
    await setLocale(lang);
    Locale _temp = Locale(lang, code);
    // if (FirebaseAuth.instance.currentUser != null) {
    //   await FirebaseFirestore.instance
    //       .collection(Paths.usersPath)
    //       .doc(user.uid)
    //       .set({
    //     'userLang': lang,
    //     'languages':
    //         user.userType == AppConstants.consultant ? user.languages : [lang],
    //   }, SetOptions(merge: true));
    //   await FirebaseFirestore.instance
    //       .collection(Paths.supportListPath)
    //       .doc(user.supportListId)
    //       .set({
    //     'userLang': lang,
    //   }, SetOptions(merge: true));
    //   accountBloc.add(GetLoggedUserEvent());
    // }
    MyApp.setLocale(context, _temp);
    setState(() {
      changeLang = false;
    });
  }

  showLangDialog(Size size) {
    String lang = getTranslated(context, "lang");
    GroupController controller =
        GroupController(initSelectedItem: [getTranslated(context, "lang")]);
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => Container(
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w478.w
                  : AppSize.w466_6.w,
              // height: 314.6.h,
              child: JerasDialogWidget(
                padButtom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? null
                    : 0,
                padLeft: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? null
                    : 0,
                padReight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? null
                    : 0,
                padTop: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? null
                    : 0,
                radius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? null
                    : AppRadius.r32.r,
                dialogContent: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: SvgPicture.asset(
                                  AssetsManager.moveCloseIconPath,
                                  width: AppSize.w32.w,
                                  height: AppSize.h32.h,
                                ),
                              ),
                              Spacer()
                            ],
                          )
                        : SizedBox(),
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? SizedBox(
                            height: AppSize.h30.h,
                          )
                        : SizedBox(
                            height: AppSize.h30.h,
                          ),
                    Container(
                      padding: lang == "ar"
                          ? EdgeInsets.only(right: AppPadding.p10.w)
                          : EdgeInsets.only(left: AppPadding.p10.w),
                      height: AppSize.h200.h,
                      width: size.width * .9,
                      child: SimpleGroupedCheckbox<String>(
                        ///
                        controller: controller,
                        onItemSelected: (data) {
                          setState(() {
                            selectedLang = data;

                            if (selectedLang == 'ar') {
                              changelanguage("ar", "AR");
                            } else if (selectedLang == 'en')
                              changelanguage("en", "US");
                            else if (selectedLang == 'fr')
                              changelanguage("fr", "FR");
                            else
                              Navigator.pop(context);
                          });
                        },
                        groupTitleAlignment: Alignment.center,
                        itemsTitle: [
                          getTranslated(context, 'ar'),
                          getTranslated(context, 'en'),
                          getTranslated(context, 'fr'),
                        ],
                        values: ["ar", "en", "fr"],
                        groupStyle: GroupStyle(
                            activeColor: AppColors.linear2,
                            itemTitleStyle: TextStyle(
                                fontWeight: AppFontsWeightManager.bold,
                                fontSize: AppFontsSizeManager.s26_6.sp,
                                fontFamily:
                                    // lang == "ar"
                                    getTranslated(context, 'Ithra')
                                //: getTranslated(context, 'Ithra')
                                )),
                        //checkFirstElement: false,
                      ),
                    ),
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? SizedBox(
                            height: AppSize.h30.h,
                          )
                        : SizedBox(
                            height: AppSize.h30.h,
                          ),
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? SizedBox(
                            height: AppSize.h10.h,
                          )
                        : SizedBox()
                  ],
                ),
              ),
            ));
  }
}
