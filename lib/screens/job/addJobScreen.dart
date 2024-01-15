import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/responsive_layout.dart';
import 'package:uuid/uuid.dart';

import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/interests.dart';
import '../../models/user.dart';

class AddJobScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const AddJobScreen({Key? key, required this.loggedUser}) : super(key: key);

  @override
  _AddJobScreenState createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false, loadInterests = true;
  String? title, des;
  late Size size;
  List<Interests> interestList = [], selectedInterestList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      addingDialog(MediaQuery.of(context).size, "add-job-icon.png",
          getTranslated(context, "job"), " ", false);
    });
  }

  @override
  void didChangeDependencies() {
    getInterests();
    super.didChangeDependencies();
  }

  getInterests() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.interestsPath)
          .where('lang', isEqualTo: getTranslated(context, "lang"))
          .where('active', isEqualTo: true)
          .orderBy('order', descending: false)
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

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: ResponsiveLayout(
        desktop: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p140.w
                          : AppPadding.p20,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p140.w
                          : AppPadding.p20,
                      top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p65.h
                          : AppPadding.p10,
                      bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton1(
                        onPress: Navigator.of(context).pop,
                        Width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w75.w
                                : AppSize.w50_6.w,
                        Height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h75.h
                                : 50.6.h,
                        ButtonRadius:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r25.r
                                : 10.6.r,
                        IconWidth:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w27_4.w
                                : AppSize.w32.w,
                        IconHeight:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h27_4.w
                                : AppSize.h32.h,
                        IconColor: Theme.of(context).primaryColor,
                        Icon: AssetsManager.blackArrowRightIconPath,
                        ButtonBackground: AppColors.white,
                      ),
                    ],
                  ),
                ))),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? SizedBox()
                : Center(
                    child: Container(
                        color: AppColors.lightGrey,
                        height: AppSize.h1.h,
                        width: size.width)),
            Expanded(
              child: ListView(
                  padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p156.w,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p156.w,
                  ),
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: AppSize.h63.h, bottom: 15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s58.sp
                                          : 20.0.sp,
                                      fontWeight: AppFontsWeightManager.normal,
                                      color: AppColors.primaryColor),
                                  cursorColor: AppColors.primaryColor,
                                  keyboardType: TextInputType.text,
                                  validator: (String? val) {
                                    if (val!.trim().isEmpty) {
                                      return getTranslated(context, 'required');
                                    }
                                    return null;
                                  },
                                  onSaved: (val) {
                                    title = val!;
                                  },
                                  onChanged: (val) {
                                    title = val;
                                  },
                                  enableInteractiveSelection: true,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      hintText:
                                          getTranslated(context, "jobTitle"),
                                      hintStyle: TextStyle(
                                          color:
                                              Color.fromRGBO(184, 180, 180, 1),
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppFontsSizeManager.s58.sp
                                              : 20.0.sp,
                                          fontWeight:
                                              AppFontsWeightManager.bold100,
                                          fontFamily:
                                              getTranslated(context, "Ithra")),
                                      focusColor: AppColors.greyShade300),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h13.sp
                                  : 20.sp,
                            ),
                            Stack(
                              children: <Widget>[
                                Text(
                                  getTranslated(context, "jobDesc"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s35.sp
                                        : 18.0.sp,
                                    fontWeight: AppFontsWeightManager.bold300,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 0.3
                                      ..color = AppColors.black4,
                                  ),
                                ),
                                // Solid text as fill.
                                Text(
                                  getTranslated(context, "jobDesc"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.black4,
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s35.sp
                                        : 18.sp,
                                    fontWeight: AppFontsWeightManager.bold300,
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.top,
                              maxLines: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 3
                                  : 4,
                              scrollPadding: EdgeInsets.all(0),
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s24.sp
                                      : 15.0.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey6),
                              cursorColor: Colors.black,
                              initialValue: des,
                              keyboardType: TextInputType.multiline,
                              onChanged: (val) {
                                des = val;
                              },
                              onSaved: (val) {
                                des = val!;
                              },
                              decoration: new InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0.w, vertical: 0.h),
                                hintStyle: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s24.sp
                                        : 15.0.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey2),
                                hintText: getTranslated(context, 'jobDetails'),
                                focusedErrorBorder: InputBorder.none,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,

                                //  hintText: sLabel
                              ),
                            ),
                            SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h38.h
                                  : AppSize.h66_6.h,
                            ),
                            Stack(
                              children: <Widget>[
                                Text(
                                  getTranslated(context, "jobInterests"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s35.sp
                                        : 18.sp,
                                    fontWeight: AppFontsWeightManager.bold300,
                                    foreground: Paint()
                                      ..style = PaintingStyle.stroke
                                      ..strokeWidth = 0.3
                                      ..color = AppColors.black4,
                                  ),
                                ),
                                // Solid text as fill.
                                Text(
                                  getTranslated(context, "jobInterests"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.black4,
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s35.sp
                                        : 18.sp,
                                    fontWeight: AppFontsWeightManager.bold300,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: AppSize.h30.h,
                            ),
                            loadInterests
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: AppColors.pink,
                                  ))
                                : Container(
                                    //p
                                    height: AppSize.h543.h,
                                    width: AppSize.w1250.w,
                                    // color: Colors.red,
                                    child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: GridView.count(
                                        padding: EdgeInsets.only(
                                          left:
                                              getTranslated(context, "lang") ==
                                                      "ar"
                                                  ? (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.w10.w
                                                      : 0
                                                  : 0,
                                          right:
                                              getTranslated(context, "lang") ==
                                                      "ar"
                                                  ? 0
                                                  : (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.w10.w
                                                      : 0,
                                        ),
                                        crossAxisCount: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? 6
                                            : 3,
                                        mainAxisSpacing: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.w36.w
                                            : 10,
                                        crossAxisSpacing: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h43.h
                                            : 10,
                                        childAspectRatio: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? 1.7
                                            : 1,
                                        children: interestList
                                            .map(
                                              (Item) => ItemList(Item),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h112.h
                                  : 30.h,
                            ),
                            InkWell(
                              onTap: () {
                                if (selectedInterestList.length != 0 &&
                                    title != null &&
                                    des != null)
                                  save();
                                else {
                                  Fluttertoast.showToast(
                                      msg: getTranslated(context, "enterAll"),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: AppColors.red,
                                      textColor: AppColors.white,
                                      fontSize: AppFontsSizeManager.s16.sp);
                                }
                              },
                              child: Center(
                                child: Container(
                                  height: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.h115.h
                                      : 66.0.h,
                                  width: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.w1214.w
                                      : 421.w,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppRadius.r20.r
                                            : 12.r),
                                    gradient:
                                        (selectedInterestList.length != 0 &&
                                                title != null &&
                                                des != null)
                                            ? PrimaryButton.gradiant
                                            : null,
                                    color: (selectedInterestList.length != 0 &&
                                            title != null &&
                                            des != null)
                                        ? null
                                        : Color(0xfff7f7f7),
                                  ),
                                  child: saving
                                      ? Center(
                                          child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ))
                                      : Center(
                                          child: Text(
                                            getTranslated(context, "publish"),
                                            style: TextStyle(
                                                fontFamily: getTranslated(
                                                    context, "Ithra"),
                                                color: (selectedInterestList
                                                                .length !=
                                                            0 &&
                                                        title != null &&
                                                        des != null)
                                                    ? Colors.white
                                                    : AppColors.black2,
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppFontsSizeManager.s34.sp
                                                    : 20.sp,
                                                letterSpacing: AppConstants
                                                    .letterSpacing0_5,
                                                fontWeight: FontWeight.w300),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h73.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
        mobile: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_06
                          : 20,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_06
                          : 20,
                      top: 10.0,
                      bottom: AppPadding.p21_3.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(),
                      SizedBox(
                        width: AppSize.w21_3.w,
                      ),
                      Text(
                        getTranslated(context, "addAdvertisement"),
                        style: TextStyle(
                          fontFamily: 'NotoKufiArabic-SemiBold',
                          fontSize: AppFontsSizeManager.s21_3.sp,
                          color: AppColors.grey_dark,
                          fontWeight:
                              FontWeight.w600, // FontWeight for semi-bold
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: size.width)),
            Expanded(
              child: ListView(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20, right: AppPadding.p20),
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: EdgeInsets.only(
                            left: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppSize.w0_06
                                : AppPadding.p20,
                            right: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppSize.w0_06
                                : AppPadding.p20,
                            bottom: AppPadding.p15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: AppSize.h21_3.h,
                                ),
                                Center(
                                  child: Image.asset(
                                    AssetsManager.editOrder,
                                    height: AppSize.h64.h,
                                    width: AppSize.w56.w,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h21_3.h,
                                ),
                                Text(
                                  'أعـلن عن حاجتـك لمعلـم واختـر من بيـن المـتقدمين للإعـلان',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'NotoKufiArabic-SemiBold',
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.grey_dark,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h40.h,
                                ),
                                Text(
                                  getTranslated(context, "Adtitle"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'NotoKufiArabic-SemiBold',
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h21_3.h,
                                ),
                                TextFormField(
                                  style: TextStyle(
                                      fontFamily: 'NotoKufiArabic-Regular',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                      fontWeight: AppFontsWeightManager.regular,
                                      color: AppColors.primaryColor),
                                  cursorColor: AppColors.primaryColor,
                                  keyboardType: TextInputType.text,
                                  validator: (String? val) {
                                    if (val!.trim().isEmpty) {
                                      return getTranslated(context, 'required');
                                    }
                                    return null;
                                  },
                                  onSaved: (val) {
                                    title = val!;
                                  },
                                  onChanged: (val) {
                                    title = val;
                                  },
                                  enableInteractiveSelection: true,
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppSize.h6_6.r),
                                      borderSide: BorderSide(
                                        color: AppColors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 16.0),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppSize.h6_6.r),
                                      borderSide: BorderSide(
                                        color: AppColors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(AppSize.h6_6.r),
                                      borderSide: BorderSide(
                                        color: AppColors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                    hintText: getTranslated(context,
                                        "EnterTheTitleOfTheAdvertisement"),
                                    hintStyle: TextStyle(
                                      fontFamily: 'NotoKufiArabic-Regular',
                                      fontSize: AppFontsSizeManager.s21_3.sp,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h26_6.h,
                                ),
                              ],
                            ),
                            Text(
                              getTranslated(context, "jobDesc"),
                              style: TextStyle(
                                fontFamily: 'NotoKufiArabic-SemiBold',
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h21_3.h,
                            ),
                            TextFormField(
                              textAlignVertical: TextAlignVertical.top,
                              maxLines: 4,
                              scrollPadding: EdgeInsets.all(0),
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s24.sp
                                      : 18.0.sp,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.grey6),
                              cursorColor: Colors.black,
                              initialValue: des,
                              keyboardType: TextInputType.multiline,
                              onChanged: (val) {
                                des = val;
                              },
                              onSaved: (val) {
                                des = val!;
                              },
                              enableInteractiveSelection: true,
                              decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.h6_6.r),
                                  borderSide: BorderSide(
                                    color: AppColors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 16.0),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.h6_6.r),
                                  borderSide: BorderSide(
                                    color: AppColors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppSize.h6_6.r),
                                  borderSide: BorderSide(
                                    color: AppColors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                hintText: getTranslated(context, 'jobDetails'),
                                hintStyle: TextStyle(
                                  fontFamily: 'NotoKufiArabic-Regular',
                                  fontSize: AppFontsSizeManager.s21_3.sp,
                                  color: AppColors.grey,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h26_6.h,
                            ),
                            Center(
                              child: Text(
                                getTranslated(context, "jobInterests"),
                                style: TextStyle(
                                  fontFamily: 'NotoKufiArabic-SemiBold',
                                  fontSize: AppFontsSizeManager.s21_3.sp,
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h26_6.h,
                            ),
                            loadInterests
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.pink,
                                    ),
                                  )
                                : Container(
                                    height: size.height * .4,
                                    child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: GridView.count(
                                        padding: EdgeInsets.only(
                                          left:
                                              getTranslated(context, "lang") ==
                                                      "ar"
                                                  ? (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? size.width * .2
                                                      : 0
                                                  : 0,
                                          right:
                                              getTranslated(context, "lang") ==
                                                      "ar"
                                                  ? 0
                                                  : (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? size.width * .2
                                                      : 0,
                                        ),
                                        crossAxisCount: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? 5
                                            : 3,
                                        mainAxisSpacing: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? 40
                                            : AppSize.h21_3.h,
                                        crossAxisSpacing: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? 40
                                            : AppSize.w21_3.w,
                                        childAspectRatio: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? 1.7
                                            : 1,
                                        children: interestList
                                            .map(
                                              (Item) => ItemList(Item),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),
                            SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 60.h
                                  : AppSize.h37_3.h,
                            ),
                            InkWell(
                              onTap: () {
                                if (selectedInterestList.length != 0 &&
                                    title != null &&
                                    des != null)
                                  save();
                                else {
                                  Fluttertoast.showToast(
                                      msg: getTranslated(context, "enterAll"),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: AppColors.red,
                                      textColor: AppColors.white,
                                      fontSize: AppFontsSizeManager.s16.sp);
                                }
                              },
                              child: Center(
                                child: Container(
                                  height: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 115.h
                                      : 66.0.h,
                                  decoration: (selectedInterestList.length !=
                                              0 &&
                                          title != null &&
                                          des != null)
                                      ? BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? 17.r
                                                  : 12.r),
                                          gradient: LinearGradient(
                                            colors: [
                                              Color.fromRGBO(
                                                  174, 156, 206, 1.0),
                                              AppColors.primaryColor,
                                            ],
                                            stops: [0.0, 1.0],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          color: (selectedInterestList.length !=
                                                      0 &&
                                                  title != null &&
                                                  des != null)
                                              ? null
                                              : Color(0xfff7f7f7),
                                        )
                                      : BoxDecoration(
                                          color: Color.fromRGBO(
                                              123, 108, 150, 0.05),
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        ),
                                  child: saving
                                      ? Center(
                                          child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ))
                                      : Center(
                                          child: Text(
                                            getTranslated(context, "publish"),
                                            style: TextStyle(
                                                fontFamily: getTranslated(
                                                    context, "Ithra"),
                                                color: (selectedInterestList
                                                                .length !=
                                                            0 &&
                                                        title != null &&
                                                        des != null)
                                                    ? AppColors.white
                                                    : AppColors.primaryColor,
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? 34.sp
                                                    : AppFontsSizeManager
                                                        .s21_3.sp,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25.0.h,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget ItemList(Interests item) {
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
        height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppSize.h210.h
            : AppSize.h133.h,
        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppSize.w212.h
            : AppSize.w156.w,
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(123, 108, 150, 0.08),
              offset: Offset(0, 8),
              blurRadius: 19,
              spreadRadius: 0,
            ),
          ],
          borderRadius: BorderRadius.circular(
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppRadius.r30.r
                  : AppRadius.r21_3.r),
          border: selectedInterestList.contains(item)
              ? Border.all(
                  color: AppColors.primaryColor,
                  width: 1,
                )
              : Border.all(color: AppColors.transparent),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Spacer()
                : SizedBox(),
            Container(
              color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? null
                  // ? selectedInterestList.contains(item)
                  //     ? AppColors.grey4
                  //     : Colors.white
                  : null,
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h35.h
                  : AppSize.h33.h,
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w35.w
                  : AppSize.w33.w,
              child: FadeInImage.assetNetwork(
                placeholder: AssetsManager.lodeGif,
                placeholderScale: 0.5,
                imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                  AssetsManager.whiteJerasLogoIconPath,
                  color: AppColors.white,
                ),
                image: item.icon!,
                fadeInDuration:
                    Duration(milliseconds: AppConstants.milliseconds250),
                fadeInCurve: Curves.easeInOut,
                fadeOutDuration:
                    Duration(milliseconds: AppConstants.milliseconds150),
                fadeOutCurve: Curves.easeInOut,
              ),
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h18.sp
                  : AppSize.h12.h,
            ),
            SizedBox(
              width: AppSize.w105.h,
              child: Text(
                item.arName,
                style: TextStyle(
                  fontFamily: 'NotoKufiArabic-SemiBold',
                  fontSize: AppFontsSizeManager.s16.sp,
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
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

  InputDecoration inputDecoration() {
    return InputDecoration(
        fillColor: Colors.white,
        hintText: getTranslated(context, 'title'),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r15.r),
          borderSide: BorderSide(
            color: AppColors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r15.r),
          borderSide: BorderSide(
            color: AppColors.grey,
            width: AppSize.w1.w,
          ),
        ));
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        List<Map> interestsMap = [];
        List<String> ids = [];
        for (var add in selectedInterestList) {
          Map tempAdd = Map();
          tempAdd.putIfAbsent('icon', () => add.icon);
          tempAdd.putIfAbsent('activeIcon', () => add.activeIcon);
          tempAdd.putIfAbsent('enName', () => add.enName);
          tempAdd.putIfAbsent('arName', () => add.arName);
          tempAdd.putIfAbsent('interestId', () => add.interestId);
          interestsMap.add(tempAdd);
          ids.add(add.interestId);
        }

        String jobId = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.jobsPath)
            .doc(jobId)
            .set({
          'approved': false,
          "jobId": jobId,
          'status': "new",
          'utcTime': DateTime.now().toUtc().toString(),
          'date': {
            'day': DateTime.now().toUtc().day,
            'month': DateTime.now().toUtc().month,
            'year': DateTime.now().toUtc().year,
          },
          'title': title,
          'desc': des,
          'interests': interestsMap,
          'interestsIds': ids,
          'owner': {
            'uid': widget.loggedUser.uid,
            'name': widget.loggedUser.name,
            'image': widget.loggedUser.photoUrl,
            'phone': widget.loggedUser.phoneNumber,
          },
          'consultList': []
        });
        setState(() {
          saving = false;
        });
        showPublishJobsDialog(
          MediaQuery.of(context).size,
          AssetsManager.refreshIconPath,
          getTranslated(context, "publishSuccessfully"),
          getTranslated(context, "receiveTeacherRequests"),
        );
      } catch (e) {}
    }
  }

  showPublishJobsDialog(Size size, String icon, String title, String msg) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        radius: AppRadius.r50.r,
        dialogContent: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.w74.w
                : 0,
            vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h53.h
                : 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context)
                        ..pop()
                        ..pop();
                    },
                    child: SvgPicture.asset(
                      AssetsManager.moveCloseIconPath,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w68.w
                          : AppSize.w32.w,
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h61.h
                          : AppSize.h32.h,
                    ),
                  ),
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? Spacer()
                      : SizedBox(width: AppSize.w140.w),
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? Spacer()
                      : Padding(
                          padding: EdgeInsets.only(top: AppSize.h10_6.h),
                          child: Center(
                            child: SvgPicture.asset(
                              icon,
                              width: AppSize.w53_5.r,
                              height: AppSize.h53_5.r,
                            ),
                          ),
                        ),
                ],
              ),
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? Center(
                      child: SvgPicture.asset(
                        icon,
                        width: AppSize.w81_8.r,
                        height: AppSize.h81_8.r,
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h39_9.h
                      : AppSize.h31_3.h),
              Padding(
                padding: EdgeInsets.only(
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 0
                        : AppPadding.p10_6.w),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s34.sp
                                : AppFontsSizeManager.s26_6.sp,
                        // fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 32.sp : 15.0.sp,
                        color: AppColors.black4,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 0
                                : AppSize.h50.h),
                    Text(
                      msg,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithralight"),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s30.sp
                                : AppFontsSizeManager.s21_3.sp,
                        // fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s32.sp : AppFontsSizeManager.s21_3.sp,
                        color:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppColors.grey2
                                : AppColors.linear2,
                        fontWeight:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsWeightManager.normal
                                : AppFontsWeightManager.bold300,
                        fontStyle: FontStyle.normal,
                      ),
                    ),
                    SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h42.h
                                : AppSize.h36.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  addingDialog(Size size, String icon, String text, String details, bool back) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular((kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppRadius.r90.r
                : 50.r),
          ),
        ),
        elevation: 5.0,
        content: Container(
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h478.h
              : null,
          width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.w718.w
              : null,
          // color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          //     ? AppColors.white
          //     : AppColors.grey2,
          child: Padding(
            padding: EdgeInsets.only(
                top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h54.h
                    : 0,
                left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w75.w
                    : 10,
                right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w75.w
                    : 0,
                bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h54.h
                    : 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: Navigator.of(context).pop,
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColor,
                      size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h66.h
                          : AppSize.w35,
                    ),
                  ),
                ),
                Image.asset(
                  AssetsManager.jobIcon,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h97.h
                      : AppSize.w40.w,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h98.h
                      : AppSize.h30.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h44.h
                        : AppSize.h15.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p70.w
                              : AppPadding.p15.w),
                  child: Stack(
                    children: <Widget>[
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                          fontWeight:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? null
                                  : AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : AppFontsSizeManager.s15.sp,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 0.3
                            ..color = Color(0xff202020),
                        ),
                      ),
                      // Solid text as fill.
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                            color: Color(0xff202020),
                            fontWeight: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? null
                                : AppFontsWeightManager.bold300,
                            fontFamily: getTranslated(context, "Ithra"),
                            fontStyle: FontStyle.normal,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : AppFontsSizeManager.s15.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                details != " "
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p15.w
                                : AppPadding.p0.w),
                        child: Stack(
                          children: <Widget>[
                            Text(
                              details,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s15.sp,
                                fontWeight: AppFontsWeightManager.bold300,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.3
                                  ..color = Color.fromRGBO(184, 180, 180, 1),
                              ),
                            ),
                            // Solid text as fill.
                            Text(
                              details,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.grey6,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s15.sp,
                                fontWeight: AppFontsWeightManager.bold300,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: AppSize.h10.h,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<Interests> reportList;
  final List<dynamic> initList;
  final bool init;
  final Function(List<Interests>) onSelectionChanged; // +added
  MultiSelectChip(this.reportList,
      {required this.onSelectionChanged,
      required this.initList,
      required this.init} // +added
      );

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<Interests> selectedChoices = [];

  _buildChoiceList() {
    List<Widget> choices = [];
    widget.reportList.forEach((item) {
      choices.add(Container(
        child: ChoiceChip(
          label: Padding(
            padding: const EdgeInsets.only(left: 2, right: 2),
            child: Text(
              item.arName,
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                color: ((widget.init &&
                            widget.initList.contains(item.interestId)) ||
                        selectedChoices.contains(item))
                    ? Color.fromRGBO(123, 108, 150, 1)
                    : Color.fromRGBO(184, 180, 180, 1),
                fontSize: AppFontsSizeManager.s13,
                fontWeight: AppFontsWeightManager.bold300,
              ),
            ),
          ),
          shape: StadiumBorder(
              side: BorderSide(
            width: .7.w,
            color:
                ((widget.init && widget.initList.contains(item.interestId)) ||
                        selectedChoices.contains(item))
                    ? Colors.white
                    : Color.fromRGBO(184, 180, 180, 1),
          )),
          selectedColor: Color.fromRGBO(245, 243, 247, 1),
          backgroundColor: AppColors.white,
          // elevation:1,
          selected:
              ((widget.init && widget.initList.contains(item.interestId)) ||
                  selectedChoices.contains(item)),
          onSelected: (selected) {
            setState(() {
              ((widget.init && widget.initList.contains(item.interestId)) ||
                      selectedChoices.contains(item))
                  ? selectedChoices.remove(item)
                  : selectedChoices.add(item);
              widget.onSelectionChanged(selectedChoices);
            });
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0,
      children: _buildChoiceList(),
    );
  }
}
