import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/FireStorePagnation/paginate_firestore.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/models/courses.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';

import '../../Utils/helper.dart';
import '../../Utils/styles.dart';
import '../../config/app_constat.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../controller/courseController.dart';
import '../../models/interests.dart';
import '../../models/user.dart';
import '../../widget/button_widget.dart';
import '../../widget/customTextField.dart';
import '../../widget/custom_back_button.dart';
import '../../widget/default_text_widget.dart';
import '../../widget/userListItem.dart';

class EditCourseScreen extends StatefulWidget {
  final Courses course;

  const EditCourseScreen({required this.course}) : super();

  @override
  _EditCourseScreenState createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController phoneController = new TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool delete = false;
  bool isAdding = false;
  bool load = false,
      saving = false,
      showText = false,
      loadInterests = true,
      activeCourse = false;
  var image;

  //String?  link;
  String lang = "ar";
  var selectedImage;

  String? selectedType;
  bool active = true, uploadVideo = false;

  late TextEditingController nameController,
      ageController,
      summaryController,
      ratingController,
      descController,
      sectionController,
      notesController,
      lessonNumController;
  List<Interests> interestList = [], selectedInterestList = [];
  List<dynamic>? selectedInterestListIds = [];

  CourseController courseController = CourseController();

  @override
  void initState() {
    super.initState();
    //link = widget.course.image;
    isAdding = false;
    activeCourse = widget.course.active!;
    nameController = TextEditingController(text: widget.course.name);
    ageController = TextEditingController(text: widget.course.age);
    summaryController = TextEditingController(text: widget.course.summary);
    ratingController =
        TextEditingController(text: widget.course.rating.toString());
    descController = TextEditingController(text: widget.course.desc);
    sectionController = TextEditingController(text: widget.course.sections);
    notesController = TextEditingController(text: widget.course.notes);
    lessonNumController =
        TextEditingController(text: widget.course.lessonNum.toString());
    lang = widget.course.lang!;
    selectedInterestListIds = widget.course.interestListIds!;
  }

  @override
  void didChangeDependencies() {
    getInterests(widget.course.lang!);
    super.didChangeDependencies();
  }

  getInterests(String lang) async {
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
          if (selectedInterestListIds!.contains(item.interestId)) {
            selectedInterestListIds!.remove(item.interestId);
          } else {
            selectedInterestListIds!.add(item.interestId);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(AppRadius.r21)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: <Widget>[
                Text(
                  item.arName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s20 : AppFontsSizeManager.s10,
                    fontWeight:AppFontsWeightManager.bold300,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 0.5
                      ..color =
                          selectedInterestListIds!.contains(item.interestId)
                              ? AppColors.pink
                              : AppColors.black2,
                  ),
                ),
                // Solid text as fill.
                Text(
                  item.arName,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: selectedInterestListIds!.contains(item.interestId)
                        ? AppColors.pink
                        : AppColors.black2,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s20 : AppFontsSizeManager.s10,
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

  save() async {
    if (_formKey.currentState!.validate() &&
        selectedInterestListIds!.length > 0) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });

      /*String url = widget.course.image;

      if (selectedImage != null) {
        var uuid = Uuid().v4();
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('Courses/$uuid');
        await storageReference.putFile(selectedImage);
        url = await storageReference.getDownloadURL();
        widget.course.image = url;
      }
*/
      await FirebaseFirestore.instance
          .collection("Courses")
          .doc(widget.course.courseId)
          .set({
        'name': nameController.text,
        'age': ageController.text,
        'summary': summaryController.text,
        'rating': double.parse(ratingController.text),
        'sections': sectionController.text,
        'desc': descController.text,
        'notes': notesController.text,
        //'image': url,
        'lang': lang,
        'interestListIds': selectedInterestListIds,
        'lessonNum': int.parse(lessonNumController.text),
        'active': activeCourse,
      }, SetOptions(merge: true));

      setState(() {
        isAdding = false;
      });

      Navigator.pop(context);
    } else {
      Helper.showSnack('Please fill all the details!', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        body: Column(
          children: <Widget>[
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p20, right: AppPadding.p20, top: AppPadding.p10, bottom: AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    CustomBackButton(),
                    SizedBox(width: AppSize.w10),
                    Text(
                      getTranslated(context, "editCourse"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s31 : AppFontsSizeManager.s16,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.w300),
                    ),
                    Spacer(),
                    IconButton(
                        onPressed: () {
                          courseController.deleteCourseDialoge(
                              context, size, widget.course);
                        },
                        icon: SvgPicture.asset(
                            AssetsManager.delete2IconPath))
                  ],
                ),
              ),
            ),
            SizedBox(
              height: AppSize.h40.h,
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_25 : AppPadding.p16,
                    vertical: AppPadding.p16),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: AppSize.h50.h,
                        ),
                        CustomTextFieldWidget(
                            textInputType: TextInputType.multiline,
                            height: AppSize.h110.h,
                            maxLine: 2,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            borderRadiusValue: AppRadius.r10,
                            controller: nameController,
                            hint: getTranslated(context, "course_name"),
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
                        SizedBox(
                          height: AppSize.h25.h,
                        ),

                        /*Container(
                            height: 230.h,
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                            decoration: BoxDecoration(color: AppColors.grey4, borderRadius: BorderRadius.circular(30.r)),
                            child: Stack(
                              children: <Widget>[
                                Column(
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextDefaultWidget(title: getTranslated(context, 'addCover'), color: AppColors.black,fontSize:(kIsWeb||size.width >= AppConstants.kIsWebValue)
?AppFontsSizeManager.s25.sp:AppFontsSizeManager.s14.sp,),
                                        widget.course.image.isNotNullAndNotEmpty?
                                        InkWell(onTap:() async {
                                          await courseController.onPickImage(context);
                                          setState(() {
                                            selectedImage = courseController.pickedImage;
                                          });
                                        },child: Icon(Icons.edit, color: AppColors.pink, size: 15.0,))
                                            :SizedBox(),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Container(
                                        width: 294.w, height: 130.h,
                                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(30.r)),
                                        child: selectedImage != null?ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                          child: Image.file(selectedImage, fit: BoxFit.cover,),
                                        ):widget.course.image.isEmpty
                                            ? SizedBox() : ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                          child: Image.network(widget.course.image, fit: BoxFit.cover,),
                                        )
                                    ),
                                  ],
                                ),
                                if(widget.course.image.isEmpty && courseController.pickedImage == null)
                                  Positioned(
                                    bottom: 0, right: 0, left: 0,top: 0,
                                    child: IconButton(
                                      onPressed: ()
                                      async {
                                        await courseController.onPickImage(context);
                                        setState(() {
                                          selectedImage = courseController.pickedImage;
                                        });
                                      },
                                      icon: SvgPicture.asset("assets/applicationIcons/addimage.svg", width: 30.w, height: 30.h,),
                                    ),
                                  ) else SizedBox(),
                              ],
                            ),
                          ),*/

                        /* Container(
                            color: AppColors.grey4,
                            child: Column(children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 14.h),
                                child: Row(
                                  mainAxisAlignment:MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextDefaultWidget(title: getTranslated(context, "age"),color: AppColors.black,fontSize:(kIsWeb||size.width >= AppConstants.kIsWebValue)
?AppFontsSizeManager.s25.sp:AppFontsSizeManager.s14.sp,),
                                    CustomTextFieldWidget(iscenter:true,borderColor:AppColors.white,backGroundColor:AppColors.white,borderRadiusValue:14.r,width:65.w, height:30.h, controller: ageController, validator: (String? val) {
                                      if (val!.trim().isEmpty) {return getTranslated(context, "age");} else {return null;}},
                                      style: Styles.getTextStyle(color: AppColors.black, fontSize:(kIsWeb||size.width >= AppConstants.kIsWebValue)
?18.sp:12.sp,),),
                                  ],),
                              ),
                            ],),
                          ),*/
                        CustomTextFieldWidget(
                            textInputType: TextInputType.multiline,
                            height: AppSize.h110.h,
                            maxLine: 2,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            borderRadiusValue: AppRadius.r10,
                            controller: ageController,
                            hint: getTranslated(context, "age"),
                            insidePadding: EdgeInsets.symmetric(
                                horizontal: AppSize.w34.w, vertical: AppSize.h20.h),
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
                        SizedBox(
                          height: AppSize.h25.h,
                        ),

                        CustomTextFieldWidget(
                            textInputType: TextInputType.multiline,
                            height: AppSize.h110.h,
                            maxLine: 4,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            controller: summaryController,
                            hint: getTranslated(context, "summary"),
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
                                horizontal: AppSize.w34.w, vertical: AppSize.h20.h)),

                        SizedBox(
                          height: AppSize.h25.h,
                        ),

                        Container(
                          color: AppColors.grey4,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppPadding.p5.w
                                        : AppPadding.p25.w,
                                    vertical: AppPadding.p14.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextDefaultWidget(
                                      title: getTranslated(context, "rating"),
                                      color: AppColors.black,
                                      fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s25.sp
                                          : AppFontsSizeManager.s14.sp,
                                    ),
                                    CustomTextFieldWidget(
                                      borderColor: AppColors.white,
                                      backGroundColor: AppColors.white,
                                      borderRadiusValue: 14.r,
                                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                          ? AppSize.w30.w
                                          : AppSize.w65.w,
                                      height: AppSize.h30.h,
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
                                        fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s18.sp
                                            : AppFontsSizeManager.s12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: AppSize.h25.h,
                        ),

                        CustomTextFieldWidget(
                            textInputType: TextInputType.multiline,
                            height: AppSize.h110.h,
                            maxLine: 4,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            controller: descController,
                            hint: getTranslated(context, "course_desc"),
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
                                horizontal: AppSize.w34.w, vertical: AppSize.h20.h)),

                        SizedBox(
                          height: AppSize.h25.h,
                        ),
                        //sections

                        CustomTextFieldWidget(
                            textInputType: TextInputType.multiline,
                            height: AppSize.h110.h,
                            maxLine: 4,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            controller: sectionController,
                            hint: getTranslated(context, "course_sections"),
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
                                horizontal: AppSize.w34.w, vertical: AppSize.h20.h)),
                        SizedBox(
                          height: AppSize.h25.h,
                        ),
                        CustomTextFieldWidget(
                            height: AppSize.h110.h,
                            maxLine: 4,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            controller: notesController,
                            hint: getTranslated(context, "course_notes"),
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
                                horizontal: AppSize.w34.w, vertical: AppSize.h20.h)),

                        SizedBox(height: AppSize.h25.h),
                        //courseNum
                        Container(
                          color: AppColors.grey4,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppPadding.p5.w
                                        : AppPadding.p25.w,
                                    vertical: AppPadding.p14.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextDefaultWidget(
                                      title:
                                          getTranslated(context, "lesson_num"),
                                      color: AppColors.black,
                                      fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s25.sp
                                          : AppFontsSizeManager.s14.sp,
                                    ),
                                    CustomTextFieldWidget(
                                      borderColor: AppColors.white,
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
                                        fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s18.sp
                                            : AppFontsSizeManager.s12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: AppSize.h25.h),

                        Container(
                          decoration: BoxDecoration(
                              color: AppColors.grey4,
                              borderRadius: BorderRadius.circular(AppRadius.r10.r)),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w5.w : AppSize.w25.w,
                              vertical: 14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextDefaultWidget(
                                title: getTranslated(context, "selectLanguage"),
                                color: AppColors.black,
                                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s25.sp
                                    : AppFontsSizeManager.s14.sp,
                              ),
                              Container(
                                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w30.w
                                    : AppSize.w102.w,
                                height: AppSize.h34.h,
                                decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.r18.r)),
                                child: Center(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: lang,
                                      iconEnabledColor: AppColors.chatButton,
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
                                            color: AppColors.black1,
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

                        SizedBox(height: AppSize.h25.h),
                        consultListWidget(size),
                        SizedBox(height: AppSize.h25.h),
                        interestWidget(size),
                        SizedBox(height: AppSize.h30.h),
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
                                fontFamily:
                                    getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s15,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h42.h,
                        ),

                        isAdding
                            ? Center(child: CircularProgressIndicator())
                            : Center(
                                child: Container(
                                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? size.width * AppSize.w0_2
                                        : size.width * AppSize.w0_5,
                                    child: CustomButton(
                                      radius: AppRadius.r28.r,
                                      title: getTranslated(context, "save"),
                                      backgroundColor: AppColors.chatButton,
                                      onTap: () {
                                        save();
                                      },
                                      verticalPadding: AppPadding.p18.h,
                                      margin: const EdgeInsets.all(0),
                                    )),
                              ),
                      ],
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

  interestWidget(Size size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p10, vertical: AppPadding.p20),
      decoration: BoxDecoration(
          color: AppColors.grey4, borderRadius: BorderRadius.circular(AppRadius.r30.r)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextDefaultWidget(
                title: getTranslated(context, "categories"),
                color: AppColors.black,
                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25.sp : AppFontsSizeManager.s14.sp,
              ),
            ],
          ),
          SizedBox(
            height: AppSize.h10,
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

  addConsultDialoge(Size size) {
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
                    width: AppSize.w337_3,
                    height: AppSize.h60.h,
                    controller: phoneController,
                    hint: getTranslated(context, "phoneNum"),
                    borderColor: AppColors.grey2,
                    borderRadiusValue: AppRadius.r5_3.r,
                    hintStyle: Styles.getTextStyle(
                      color: AppColors.grey1,
                      fontSize: AppFontsSizeManager.s21_3.sp,
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
                          QuerySnapshot querySnapshot =
                              await FirebaseFirestore.instance
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
                            var userType = GroceryUser.fromMap(
                                    querySnapshot.docs[0].data() as Map)
                                .userType;
                            var status = GroceryUser.fromMap(
                                    querySnapshot.docs[0].data() as Map)
                                .accountStatus;
                            var uid = GroceryUser.fromMap(
                                    querySnapshot.docs[0].data() as Map)
                                .uid;
                            var courses = GroceryUser.fromMap(
                                    querySnapshot.docs[0].data() as Map)
                                .courses;

                            if (courses!.contains(widget.course.courseId)) {
                              Fluttertoast.showToast(
                                  msg: getTranslated(context, 'found'),
                                  toastLength: Toast.LENGTH_SHORT,
                                  backgroundColor: AppColors.red,
                                  textColor: AppColors.white);
                            } else {
                              if (userType == "CONSULTANT") {
                                if (status == "Active") {
                                  courses.add(widget.course.courseId);
                                  await FirebaseFirestore.instance
                                      .collection("Users")
                                      .doc(uid)
                                      .set({
                                    'courses': courses,
                                  }, SetOptions(merge: true));
                                } else {
                                  Fluttertoast.showToast(
                                      msg: getTranslated(
                                          context, 'consultIsNotActive'),
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
                                fontFamily:
                                    getTranslated(context, "Ithra"),
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
                                fontFamily:
                                    getTranslated(context, "Ithra"),
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



  consultListWidget(Size size) {
    return Container(
      // height: 250.h,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p20.w, vertical: AppPadding.p24.h),
      decoration: BoxDecoration(
          color: AppColors.grey4, borderRadius: BorderRadius.circular(AppRadius.r30.r)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextDefaultWidget(
                title: getTranslated(context, 'addConsult'),
                color: AppColors.black,
                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25.sp : AppFontsSizeManager.s14.sp,
              ),
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
          SizedBox(
            height: 16.h,
          ),
          Container(
            height: size.height * AppSize.h0_25,
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              //shrinkWrap: true,
              // physics: NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppPadding.p5),
              itemBuilder: (context, documentSnapshot, index) {
                if (documentSnapshot.length == 0)
                  return Container(
                    width: 90.w,
                    height: 90.h,
                    decoration: BoxDecoration(
                        color: AppColors.textLightGrey,
                        borderRadius: BorderRadius.circular(AppRadius.r90.r)),
                    child: IconButton(
                      onPressed: () async {
                        addConsultDialoge(size);
                      },
                      icon: SvgPicture.asset(
                        AssetsManager.whiteAddPersonIconPath,
                        width: AppSize.w32.w,
                        height: AppSize.h22.h,
                      ),
                    ),
                  );
                else
                  return UserListItem(
                    groceryUser: GroceryUser.fromMap(
                        documentSnapshot[index].data() as Map),
                    uidCourse: widget.course.courseId,
                  );
              },
              query: FirebaseFirestore.instance
                  .collection('Users')
                  .where('userType', isEqualTo: "CONSULTANT")
                  .where('accountStatus', isEqualTo: "Active")
                  .where('courses', arrayContains: widget.course.courseId)
                  .orderBy('order', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ),
        ],
      ),
    );
  }
}
