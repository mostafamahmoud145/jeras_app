import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/FireStorePagnation/paginate_firestore.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/paths.dart';
import 'package:jeras/controller/courseController.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/button_widget.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../Utils/helper.dart';
import '../../Utils/styles.dart';
import '../../config/app_constat.dart';
import '../../config/colors_file.dart';
import '../../models/interests.dart';
import '../../models/user.dart';
import '../../widget/component/IconButton.dart';
import '../../widget/customTextField.dart';
import '../../widget/default_text_widget.dart';
import '../../widget/userListItem.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen() : super();

  @override
  _AddCourseScreenState createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final TextEditingController phoneController = new TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GroceryUser? user;
  String? url, link;
  String lang = "ar";
  bool isAdding = false,
      load = false,
      saving = false,
      showText = false,
      showStatus = false,
      activeCourse = false,
      showUserType = false,
      loadInterests = true;
  List<Interests> interestList = [], selectedInterestList = [];
  var image;
  File? selectedImage;
  String uuid = Uuid().v4();
 late Size size;

  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController summaryController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController lessonNumController = TextEditingController();

  CourseController courseController = CourseController();

  @override
  void initState() {
    super.initState();
    isAdding = false;
  }

  @override
  void didChangeDependencies() {
    getInterests(getTranslated(context, "lang"));
    super.didChangeDependencies();
  }

  getInterests(String _lang) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.interestsPath)
          .where('lang', isEqualTo: lang)
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
            color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.r21.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: <Widget>[
                Text(
                  item.arName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s20.sp : AppFontsSizeManager.s10.sp,
                    fontWeight:AppFontsWeightManager.bold300,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 0.5
                      ..color = selectedInterestList.contains(item)
                          ? AppColors.pink
                          : AppColors.black2,
                  ),
                ),
                // Solid text as fill.
                Text(
                  item.arName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: selectedInterestList.contains(item)
                        ? AppColors.pink
                        : AppColors.black2,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s20.sp : AppFontsSizeManager.s10.sp,
                    fontWeight:AppFontsWeightManager.bold300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
     size = MediaQuery.of(context).size;
     lang = getTranslated(context, "lang");

     return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_06 : AppPadding.p20,
                          right:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_06 : AppPadding.p20,
                          top: AppPadding.p10,
                          bottom: AppPadding.p10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w75.r : AppSize.w45.r,
                            height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h75.r : AppSize.h45.r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r25.r : AppRadius.r13.r),
                            ),
                            child: IconButton1(
                              onPress: Navigator.of(context).pop,
                              Width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w97.w
                                  : AppSize.w50.w,
                              Height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h97.h
                                  : AppSize.h50.h,
                              ButtonRadius: AppRadius.r10_6.r,
                              IconWidth: AppSize.w22.w,
                              IconHeight: AppSize.h20.h,
                              IconColor: Theme.of(context).primaryColor,
                              Icon:lang=="ar"? AssetsManager.whiteArrowRight:AssetsManager.whiteArrowLeft,
                              ButtonBackground: AppColors.white,
                            ),
                          ),                           SizedBox(width: AppSize.w10.w),
                          Text(
                            getTranslated(context, "addCourse"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s34.sp : AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black1,
                            ),
                          ),
                        ],
                      ),
                    ))),
            SizedBox(height: AppSize.h6,),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: size.width)),
            // SizedBox(
            //   height: 16.h,
            // ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_25
                        : AppSize.w16.w,
                    vertical: .0.h),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppPadding.p16,right: AppPadding.p16,),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: AppSize.h50.h,
                          ),
                          Text(getTranslated(context, "course_name",),
                          style: TextStyle(
                            color: AppColors.pink,
                            fontFamily: getTranslated(context, "Ithralight"),
                          ),
                          ),
                          SizedBox(height: AppSize.h4,),
                          Container(
                            height:kIsWeb?AppSize.h95: AppSize.h53_3,
                            width:kIsWeb?AppSize.w1085: AppSize.w509,
                            child: CustomTextFieldWidget(
                                textInputType: TextInputType.multiline,
                                height: AppSize.h110.h,
                                maxLine: 4,
                                backGroundColor: AppColors.white,
                                borderColor: AppColors.grey,
                                borderRadiusValue: AppRadius.r10.r,
                                controller: nameController,
                                //hint: getTranslated(context, "course_name"),
                                insidePadding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h),
                                style: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                hintStyle: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                validator: (val) {
                                  return (val!.trim().isEmpty)
                                      ? 'please enter course name .'
                                      : null;
                                }),
                          ),
                          SizedBox(
                            height: AppSize.h16.h,
                          ),
                          Text(getTranslated(context, "age"),

                            style: TextStyle(
                              color: AppColors.pink,
                              fontFamily: getTranslated(context, "Ithralight"),

                            ),
                          ),
                          SizedBox(height: AppSize.h4,),

                          Container(
                            height:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.h95: AppSize.h53_3,
                            width:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.w1085: AppSize.w509,
                            child: CustomTextFieldWidget(
                                textInputType: TextInputType.multiline,
                                height: AppSize.h110.h,
                                maxLine: 4,
                                backGroundColor: AppColors.white,
                                borderColor: AppColors.grey,
                                borderRadiusValue: AppRadius.r10.r,
                                controller: ageController,
                                //hint: getTranslated(context, "age"),
                                insidePadding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h),
                                style: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                hintStyle: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                validator: (val) {
                                  return (val!.trim().isEmpty)
                                      ? 'please enter age .'
                                      : null;
                                }),
                          ),

                          SizedBox(
                            height: AppSize.h16.h,
                          ),
                      Text(getTranslated(context, "summary"),

                        style: TextStyle(
                          color: AppColors.pink,
                          fontFamily: getTranslated(context, "Ithralight"),

                        ),
                      ),
                      SizedBox(height: AppSize.h4,),

                          Container(
                            height:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.h95: AppSize.h53_3,
                            width:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.w1085: AppSize.w509,
                            child: CustomTextFieldWidget(
                                textInputType: TextInputType.multiline,
                                height: AppSize.h110.h,
                                maxLine: AppConstants.maxLines4,
                                backGroundColor: AppColors.white,
                                borderColor: AppColors.grey,
                                controller: summaryController,
                                //hint: getTranslated(context, "summary"),
                                validator: (String? val) {
                                  if (val!.trim().isEmpty) {
                                    return getTranslated(context, "summary");
                                  } else {
                                    return null;
                                  }
                                },
                                style: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                hintStyle: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                insidePadding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h)),
                          ),

                          SizedBox(
                            height: AppSize.h16.h,
                          ),
                          Text(getTranslated(context, "rating"),
                            style: TextStyle(
                              color: AppColors.pink,
                              fontFamily: getTranslated(context, "Ithralight"),

                            ),
                          ),
                          SizedBox(height: AppSize.h4,),


                          Container(
                            height:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.h95: AppSize.h53_3,
                            width:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.w1085: AppSize.w509,
                            color: AppColors.white,
                            child: CustomTextFieldWidget(
                              borderColor: AppColors.grey,
                              backGroundColor: AppColors.white,
                              borderRadiusValue: AppRadius.r14.r,
                              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w30.w
                                  : AppSize.w65.w,
                              height: AppSize.h30.h,
                              textInputType: TextInputType.number,
                              controller: ratingController,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(
                                      context, "price");
                                } else {
                                  return null;
                                }
                              },
                              style: Styles.getTextStyle(
                                  color: AppColors.black,
                                  fontSize: AppFontsSizeManager.s12.sp),
                            ),
                          ),

                          SizedBox(
                            height: AppSize.h16.h,
                          ),
                          Text(getTranslated(context, "course_desc"),
                            style: TextStyle(
                              color: AppColors.pink,
                              fontFamily: getTranslated(context, "Ithralight"),

                            ),
                          ),
                          SizedBox(height: AppSize.h4,),

                          Container(
                            height:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.h95: AppSize.h53_3,
                            width:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.w1085: AppSize.w509,
                            child: CustomTextFieldWidget(
                                textInputType: TextInputType.multiline,
                                height: AppSize.h110.h,
                                maxLine: 4,
                                backGroundColor: AppColors.white,
                                borderColor: AppColors.grey,
                                controller: descController,
                                //hint: getTranslated(context, "course_desc"),
                                validator: (String? val) {
                                  if (val!.trim().isEmpty) {
                                    return getTranslated(context, "course_desc");
                                  } else {
                                    return null;
                                  }
                                },
                                style: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                hintStyle: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                insidePadding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h)),
                          ),

                          SizedBox(
                            height: AppSize.h16.h,
                          ),
                          Text(getTranslated(context, "course_sections"),
                            style: TextStyle(
                              color: AppColors.pink,
                              fontFamily: getTranslated(context, "Ithralight"),

                            ),
                          ),
                          SizedBox(height: AppSize.h4,),


                          Container(
                            height:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.h95: AppSize.h53_3,
                            width:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.w1085: AppSize.w509,
                            child: CustomTextFieldWidget(
                                textInputType: TextInputType.multiline,
                                height: AppSize.h110.h,
                                maxLine: AppConstants.maxLines4,
                                backGroundColor: AppColors.white,
                                borderColor: AppColors.grey,
                                controller: sectionController,
                                //hint: getTranslated(context, "course_sections"),
                                validator: (String? val) {
                                  if (val!.trim().isEmpty) {
                                    return getTranslated(
                                        context, "course_sections");
                                  } else {
                                    return null;
                                  }
                                },
                                style: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                hintStyle: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                insidePadding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h)),
                          ),

                          SizedBox(
                            height: AppSize.h16.h,
                          ),
                          Text(getTranslated(context, "course_notes"),
                            style: TextStyle(
                              color: AppColors.pink,
                              fontFamily: getTranslated(context, "Ithralight"),

                            ),
                          ),
                          SizedBox(height: AppSize.h4,),
                          Container(
                            height:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.h95: AppSize.h53_3,
                            width:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.w1085: AppSize.w509,
                            child: CustomTextFieldWidget(
                                textInputType: TextInputType.multiline,
                                height: AppSize.h110.h,
                                maxLine: 4,
                                backGroundColor: AppColors.white,
                                borderColor: AppColors.grey,
                                controller: notesController,
                                //hint: getTranslated(context, "course_notes"),
                                validator: (String? val) {
                                  if (val!.trim().isEmpty) {
                                    return getTranslated(context, "course_notes");
                                  } else {
                                    return null;
                                  }
                                },
                                style: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                hintStyle: Styles.getTextStyle(
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s14.sp,
                                    color: AppColors.black),
                                insidePadding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h)),
                          ),

                          SizedBox(height: AppSize.h25.h),
                          //courseNum
                          Text(getTranslated(context, "lesson_num"),
                            style: TextStyle(
                              color: AppColors.pink,
                              fontFamily: getTranslated(context, "Ithralight"),

                            ),
                          ),
                          SizedBox(height: AppSize.h4,),
                          Container(
                            height:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.h95: AppSize.h53_3,
                            width:(kIsWeb || size.width >= AppConstants.kIsWebValue)?AppSize.w1085: AppSize.w509,
                            color: AppColors.white,
                            child: CustomTextFieldWidget(
                              borderColor: AppColors.grey,
                              textInputType: TextInputType.number,
                              backGroundColor: AppColors.white,
                              borderRadiusValue: AppRadius.r14.r,
                              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w30.w
                                  : AppSize.w65.w,
                              height: AppSize.h30.h,
                              controller: lessonNumController,
                              validator: (String? val) {
                                if (val!.trim().isEmpty) {
                                  return getTranslated(
                                      context, "lesson_num");
                                } else {
                                  return null;
                                }
                              },
                              style: Styles.getTextStyle(
                                  color: AppColors.black,
                                  fontSize: AppFontsSizeManager.s12.sp),
                            ),
                          ),
                          SizedBox(height: AppSize.h16.h),
                          Text(getTranslated(context, "selectLanguage"),
                            style: TextStyle(
                              color: AppColors.pink,
                              fontFamily: getTranslated(context, "Ithralight"),

                            ),
                          ),
                          SizedBox(height: AppSize.h4,),
                          Container(
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color: AppColors.grey),
                                borderRadius: BorderRadius.circular(AppRadius.r10.r)),
                            padding: EdgeInsets.symmetric(
                                horizontal:
                                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppPadding.p5.w : AppPadding.p25.w,
                                vertical: AppPadding.p14.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextDefaultWidget(
                                  title: getTranslated(context, "selectLanguage",),
                                  color: AppColors.white,
                                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s25.sp
                                      : AppFontsSizeManager.s14.sp,
                                ),
                                Container(
                                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                      ? AppSize.w65.w
                                      : AppSize.w102.w,
                                  height: AppSize.h34.h,
                                  decoration: BoxDecoration(
                                      color: AppColors.pink,
                                      borderRadius: BorderRadius.circular(AppRadius.r10.r)),
                                  child: Center(
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: lang,
                                        iconEnabledColor: AppColors.white,
                                        iconDisabledColor: AppColors.chatButton,
                                        items: <String>[
                                          "ar", "en"
                                          //getTranslated(context, "arabic"),
                                          // getTranslated(context, "english")
                                        ].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: TextDefaultWidget(
                                              title: value,
                                              color: AppColors.white,
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            lang = value!;
                                          });
                                          getInterests(lang);
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppSize.h16.h),
                          interestWidget(size),
                          SizedBox(
                            height: AppSize.h25.h,
                          ),
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextDefaultWidget(
                                title: getTranslated(
                                    context, 'addConsult'),
                                color: AppColors.black,
                                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s25.sp
                                    : AppFontsSizeManager.s14.sp,
                              ),
                              SizedBox(width: AppSize.w6,),
                              InkWell(
                                onTap: () {
                                  addConsultDialoge(size);
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.shadoColor,
                                  size: AppSize.w20,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppSize.h4,),
                          Container(
                            //height: 185.h,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p20.w, vertical: AppPadding.p24.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.grey),
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(AppRadius.r10_6.r)),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: AppSize.h16.h,
                                ),
                                Container(
                                  height: size.height * AppSize.h0_25.h,
                                  child: PaginateFirestore(
                                    itemBuilderType:
                                        PaginateBuilderType.listView,
                                    // shrinkWrap: true,
                                    separator: SizedBox(
                                      height: AppSize.h20.h,
                                    ),
                                    onEmpty: Container(
                                      width: AppSize.w90.w,
                                      height: AppSize.h90.h,
                                      decoration: BoxDecoration(
                                          color: AppColors.textLightGrey,
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.r90.r)),
                                      child: IconButton(
                                        onPressed: () async {
                                          addConsultDialoge(size);
                                        },
                                        icon: SvgPicture.asset(
                                          AssetsManager.whiteAddPersonIconPath,
                                          width: AppSize.w32.w,
                                          height: AppSize.h32.h,
                                        ),
                                      ),
                                    ),
                                    //physics: NeverScrollableScrollPhysics(),
                                    padding: const EdgeInsets.only(
                                        left: AppPadding.p16,
                                        right: AppPadding.p16,
                                        bottom:AppPadding.p16,
                                        top: AppPadding.p16),
                                    //Change types accordingly
                                    itemBuilder:
                                        (context, documentSnapshot, index) {
                                      return UserListItem(
                                        groceryUser: GroceryUser.fromMap(
                                            documentSnapshot[index].data()
                                                as Map),
                                        uidCourse: uuid,
                                      );
                                    },
                                    query: FirebaseFirestore.instance
                                        .collection('Users')
                                        .where('userType',
                                            isEqualTo: "CONSULTANT")
                                        .where('accountStatus',
                                            isEqualTo: "Active")
                                        .where('courses', arrayContains: uuid)
                                        .orderBy('order', descending: true),
                                    // to fetch real-time data
                                    isLive: true,
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h30.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: activeCourse,
                                onChanged: (value) {
                                  setState(() {
                                    activeCourse = !activeCourse;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "active"),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: AppFontsSizeManager.s15,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: AppSize.h25.h,
                          ),

                          isAdding
                              ? Center(child: CircularProgressIndicator())
                              : Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16.0),
                                    child: Container(
                                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                          ? size.width * .2.w
                                          : size.width * 1.3.w,
                                      child: CustomButton(
                                        radius: 28.r,
                                        title: getTranslated(context, "save"),
                                        backgroundColor: AppColors.chatButton,
                                        onTap: () {
                                          showAddCourseDialog(size);
                                        },
                                        verticalPadding: AppPadding.p18.h,
                                        margin: const EdgeInsets.all(0),
                                      ),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  save() async {
    if (_formKey.currentState!.validate() && selectedInterestList.length > 0) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });

      /* if (selectedImage != null) {
          Reference storageReference =
          FirebaseStorage.instance.ref().child('Courses/$uuid');
          await storageReference.putFile(selectedImage!);
          url = await storageReference.getDownloadURL();
        }*/
      List<String> _list = [];
      for (int x = 0; x < selectedInterestList.length; x++) {
        _list.add(selectedInterestList[x].interestId);
      }
      await FirebaseFirestore.instance.collection("Courses").doc(uuid).set({
        'courseId': uuid,
        'name': nameController.text,
        'age': ageController.text,
        'summary': summaryController.text,
        'rating': double.parse(ratingController.text),
        'desc': descController.text,
        "sections": sectionController.text,
        'notes': notesController.text,
        // 'image': url,
        'lang': lang,
        'interestListIds': _list,
        'active': activeCourse,
        'lessonNum': int.parse(lessonNumController.text),
      }, SetOptions(merge: true));
      setState(() {
        isAdding = false;
         Navigator.pop(context);
      });
    } else {
      setState(() {
        isAdding = false;
      });
      Helper.showSnack('Please fill all the details!', context);
    }
  }

  showAddCourseDialog(Size size) {
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
                  child: SvgPicture.asset(
                    AssetsManager.moveCloseIconPath,
                    width: AppSize.w32.w,
                    height: AppSize.h32.h,
                  ),
                ),
                SizedBox(width: AppSize.w140.w),
                Padding(
                  padding: EdgeInsets.only(top:AppSize.h10_6.h),
                  child: Center(
                    child: SvgPicture.asset(
                      AssetsManager.addChartIconPath,
                      width: AppSize.w53_5.r,
                      height: AppSize.h53_5.r,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h52_6.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "DoYouWantAddCourse"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight:AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h38.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          save();
                          },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.linear2,
                            borderRadius:
                            BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'yes'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.white,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      //SizedBox(width: AppSize.w57_3.w),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10_6.r)),
                              border: Border.all(
                                color: AppColors.linear2,
                                width: 1.5.w,
                              )),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'no'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.linear2,
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
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  addConsultDialoge( Size size) {
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
                  child: SvgPicture.asset(
                    AssetsManager.moveCloseIconPath,
                    width: AppSize.w32.w,
                    height: AppSize.h32.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h21_3.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "addConsult"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s26_6.sp,
                      color: AppColors.linear2,
                      fontWeight:AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h42.h,
                  ),
                  CustomTextFieldWidget(
                    width:AppSize.w337_3 ,
                    height: AppSize.h60.h,
                    controller: phoneController,
                    hint: getTranslated(context, "phoneNum"),
                    borderColor:AppColors.grey2 ,
                    borderRadiusValue:AppRadius.r5_3.r,
                    hintStyle: Styles.getTextStyle(
                        color: AppColors.grey1, fontSize:AppFontsSizeManager.s21_3.sp,
                        fontfamily: getTranslated(context, "Ithralight"),
                      fontWeight:AppFontsWeightManager.bold300,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h36_6.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          setState(() {
                            saving = true;
                          });
                          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                              .collection(Paths.usersPath)
                              .where(
                            "phoneNumber",
                            isEqualTo: phoneController.text,
                          )
                              .get();
                          if (querySnapshot.docs.length > 0) {
                            setState(() {
                              showText = false;
                            });
                            var userType =
                                GroceryUser.fromMap(querySnapshot.docs[0].data() as Map)
                                    .userType;
                            var status =
                                GroceryUser.fromMap(querySnapshot.docs[0].data() as Map)
                                    .accountStatus;
                            var uid =
                                GroceryUser.fromMap(querySnapshot.docs[0].data() as Map)
                                    .uid;
                            var courses =
                                GroceryUser.fromMap(querySnapshot.docs[0].data() as Map)
                                    .courses;

                            if (courses!.contains(uuid)) {
                              Fluttertoast.showToast(
                                  msg: getTranslated(context, 'found'),
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: AppColors.red,
                                  textColor: AppColors.white);
                            } else {
                              if (userType == "CONSULTANT") {
                                if (status == "Active") {
                                  courses.add(uuid);
                                  await FirebaseFirestore.instance
                                      .collection("Users")
                                      .doc(uid)
                                      .set({
                                    'courses': courses,
                                  }, SetOptions(merge: true));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: getTranslated(context, 'consultIsNotActive'),
                                      toastLength: Toast.LENGTH_SHORT,
                                      backgroundColor: AppColors.red,
                                      textColor: AppColors.white);
                                }
                              } else {
                                Fluttertoast.showToast(
                                    msg: getTranslated(context, 'NotConsultIs'),
                                    toastLength: Toast.LENGTH_SHORT,
                                    backgroundColor: AppColors.red,
                                    textColor: AppColors.white);
                              }
                            }
                            setState(() {
                              saving = false;
                            });
                            Navigator.pop(context);
                          } else {
                            setState(() {
                              showText = true;
                              saving = false;
                            });
                          }
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.linear2,
                            borderRadius:
                            BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'save'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.white,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      //SizedBox(width: AppSize.w57_3.w),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10_6.r)),
                              border: Border.all(
                                color: AppColors.linear2,
                                width: 1.5.w,
                              )),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'cancel'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.linear2,
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
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  interestWidget(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color:Theme.of(context).primaryColor,
              blurRadius: 8.0,
              spreadRadius: 0.0,
              offset: Offset(
                  0.0, 0.50), // shadow direction: bottom right
            )
          ],
          color: AppColors.grey4, borderRadius: BorderRadius.circular(30.r)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextDefaultWidget(
                title: getTranslated(context, "categories"),
                color: AppColors.black,
                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25.sp : 21.sp,
              ),
            ],
          ),
          SizedBox(
            height: AppSize.h10.h,
          ),
          loadInterests
              ? Center(
                  child: CircularProgressIndicator(
                  color: AppColors.pink,
                ))
              : Container(
                  height: size.height * .4.h,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: GridView.count(
                      // shrinkWrap:false,
                      //physics:const NeverScrollableScrollPhysics() ,
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.5,
                      //8.0 / 9.0,
                      children: interestList
                          .map(
                            (Item) => ItemList(size, Item),
                          )
                          .toList(),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
