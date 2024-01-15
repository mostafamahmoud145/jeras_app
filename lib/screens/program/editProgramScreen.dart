import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_credit_card/extension.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../../config/colors_file.dart';
import '../../Utils/helper.dart';
import '../../Utils/styles.dart';
import '../../controller/blocs/program_bloc/program_bloc.dart';
import '../../controller/programController.dart';
import '../../localization/localization_methods.dart';
import '../../models/program.dart';
import '../../widget/button_widget.dart';
import '../../widget/customTextField.dart';
import '../../widget/custom_back_button.dart';
import '../../widget/default_text_widget.dart';
import '../../widget/divider_widget.dart';

class EditProgramScreen extends StatefulWidget {
  final Program program;

  const EditProgramScreen({required this.program}) : super();

  @override
  _EditProgramScreenState createState() => _EditProgramScreenState();
}

class _EditProgramScreenState extends State<EditProgramScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool delete = false;
  bool isAdding = false;

  var image;
  int? courseNum;

  int? lessonNum;

  String? title, type;
  String dropdownTypeValue = "primary";

  late TextEditingController nameController,
      descController,
      notesController,
      courseNumController,
      lessonNumController;

  ProgramController programController = ProgramController();
  late ProgramBloc programBloc;
  List<String> listType = ['Primary', 'Academy'];
  var selectedImage;
  late bool active;

  late String selectedType;
  late String lang;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.program.name);
    descController = TextEditingController(text: widget.program.desc);
    notesController = TextEditingController(text: widget.program.notes);
    courseNumController =
        TextEditingController(text: widget.program.courseNum.toString());
    lessonNumController =
        TextEditingController(text: widget.program.lessonNum.toString());
    active = widget.program.active;
    //selectedType= widget.program.consultType;
    lang = widget.program.lang;
  }

  @override
  void didChangeDependencies() {
    selectedType = getTranslated(context, widget.program.consultType);
    super.didChangeDependencies();
  }

  addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });

      String url = widget.program.image;

      if (selectedImage != null) {
        var uuid = Uuid().v4();
        Reference storageReference =
            FirebaseStorage.instance.ref().child('Program/$uuid');
        await storageReference.putFile(selectedImage);
        url = await storageReference.getDownloadURL();
        widget.program.image = url;
      }

      await FirebaseFirestore.instance
          .collection("Program")
          .doc(widget.program.id)
          .set({
        'name': nameController.text,
        'image': url,
        'notes': notesController.text,
        'desc': descController.text,
        'courseNum': int.parse(courseNumController.text),
        'lessonNum': int.parse(lessonNumController.text),
        'consultType': widget.program.consultType, //selectedType,
        'active': active,
        'lang': lang,
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
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p16.w, vertical: AppPadding.p16.h),
        child: Column(
          children: <Widget>[
            SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CustomBackButton(),
                  SizedBox(width: AppSize.w10),
                  TextDefaultWidget(
                      title: getTranslated(context, 'editProgram'),
                      fontSize: AppFontsSizeManager.s17.sp,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold),
                  Spacer(),
                  IconButton(
                      onPressed: () {
                        programController.deleteProgram(
                            widget.program, context);
                      },
                      icon: SvgPicture.asset(
                          AssetsManager.delete1IconPath))
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p16, vertical: AppPadding.p16),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: AppSize.h30.h,
                        ),
                        InkWell(
                          onTap: () {
                            /*Navigator.push(context, MaterialPageRoute(builder: (contex){
                              return CourseIsProgramScreen(program: widget.program,);
                            }));*/
                          },
                          child: Center(
                            child: Container(
                              width: AppSize.w50.w,
                              height: AppSize.h50.h,
                              decoration: BoxDecoration(
                                  color: AppColors.chatButton,
                                  borderRadius: BorderRadius.circular(AppRadius.r30.r)),
                              child: SvgPicture.asset(
                                  AssetsManager.add,
                                  height: AppSize.h20,
                                  width: AppSize.w20,
                                  fit: BoxFit.scaleDown),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h32.h,
                        ),
                        CustomTextFieldWidget(
                            iscenter: true,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            borderRadiusValue: 10,
                            controller: nameController,
                            hint: getTranslated(context, "program_name"),
                            insidePadding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h),
                            style: Styles.getTextStyle(
                                fontSize: AppFontsSizeManager.s14.sp, color: AppColors.black),
                            hintStyle: Styles.getTextStyle(
                                fontSize: AppFontsSizeManager.s14.sp, color: AppColors.black),
                            validator: (val) {
                              return (val!.trim().isEmpty)
                                  ? 'please enter program name .'
                                  : null;
                            }),
                        SizedBox(
                          height: AppSize.h25.h,
                        ),
                        Container(
                          height: AppSize.h230.h,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p20.w, vertical: AppPadding.p20.h),
                          decoration: BoxDecoration(
                              color: AppColors.grey4,
                              borderRadius: BorderRadius.circular(AppRadius.r30.r)),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextDefaultWidget(
                                        title: getTranslated(
                                            context, 'addProgram'),
                                        color: AppColors.black,
                                        fontSize: AppFontsSizeManager.s14.sp,
                                      ),
                                      widget.program.image.isNotEmpty
                                          ? InkWell(
                                              onTap: () async {
                                                await programController
                                                    .onPickImage(context);
                                                setState(() {
                                                  selectedImage =
                                                      programController
                                                          .pickedImage;
                                                });
                                              },
                                              child: Icon(
                                                Icons.edit,
                                                color: AppColors.pink,
                                                size: AppSize.w15,
                                              ))
                                          : SizedBox(),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Container(
                                      width: AppSize.w294.w,
                                      height: AppSize.h130.h,
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.r30.r)),
                                      child: selectedImage != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(AppRadius.r10.r),
                                              child: Image.file(
                                                selectedImage,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : widget.program.image.isEmpty
                                              ? SizedBox()
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppRadius.r10.r),
                                                  child: Image.network(
                                                    widget.program.image,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )),
                                ],
                              ),
                              if (widget.program.image.isEmpty &&
                                  programController.pickedImage == null)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  left: 0,
                                  top: 0,
                                  child: IconButton(
                                    onPressed: () async {
                                      await programController
                                          .onPickImage(context);
                                      setState(() {
                                        selectedImage =
                                            programController.pickedImage;
                                      });
                                    },
                                    icon: SvgPicture.asset(
                                      AssetsManager.greyAddImage,
                                      width: AppSize.w30.w,
                                      height: AppSize.h30.h,
                                    ),
                                  ),
                                )
                              else
                                SizedBox(),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h25.h,
                        ),
                        //  notes
                        CustomTextFieldWidget(
                            iscenter: true,
                            height: AppSize.h110.h,
                            maxLine: 4,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            controller: descController,
                            hint: getTranslated(context, "program_desc"),
                            validator: (String? val) {
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, "program_desc");
                              } else {
                                return null;
                              }
                            },
                            style: Styles.getTextStyle(
                                fontSize: AppFontsSizeManager.s14.sp, color: AppColors.black),
                            hintStyle: Styles.getTextStyle(
                                fontSize: AppFontsSizeManager.s14.sp, color: AppColors.black),
                            insidePadding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h)),

                        SizedBox(
                          height: AppSize.h25.h,
                        ),

                        CustomTextFieldWidget(
                            iscenter: true,
                            height: AppSize.h110.h,
                            maxLine: 4,
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            controller: notesController,
                            hint: getTranslated(context, "program_notes"),
                            validator: (String? val) {
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, "program_notes");
                              } else {
                                return null;
                              }
                            },
                            style: Styles.getTextStyle(
                                fontSize: AppFontsSizeManager.s14.sp, color: AppColors.black),
                            hintStyle: Styles.getTextStyle(
                                fontSize: AppFontsSizeManager.s14.sp, color: AppColors.black),
                            insidePadding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p34.w, vertical: AppPadding.p20.h)),

                        SizedBox(height: AppSize.h25.h),
                        //courseNum
                        Container(
                          color: AppColors.grey4,
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p25.w, vertical: AppPadding.p14.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextDefaultWidget(
                                      title:
                                          getTranslated(context, "course_num"),
                                      color: AppColors.black,
                                      fontSize: AppFontsSizeManager.s14.sp,
                                    ),
                                    CustomTextFieldWidget(
                                      borderColor: AppColors.white,
                                      iscenter: true,
                                      textInputType: TextInputType.number,
                                      backGroundColor: AppColors.white,
                                      borderRadiusValue: AppRadius.r14.r,
                                      width: AppSize.w65.w,
                                      height: AppSize.h30.h,
                                      controller: courseNumController,
                                      validator: (String? val) {
                                        if (val!.trim().isEmpty) {
                                          return getTranslated(
                                              context, "course_num");
                                        } else {
                                          return null;
                                        }
                                      },
                                      style: Styles.getTextStyle(
                                          color: AppColors.black,
                                          fontSize: 12.sp),
                                    ),
                                  ],
                                ),
                              ),
                              DividerWidget(height: AppSize.h0_5.h, width: AppSize.w335.w),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p25.w, vertical: AppPadding.p14.h),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TextDefaultWidget(
                                      title:
                                          getTranslated(context, "lesson_num"),
                                      color: AppColors.black,
                                      fontSize: AppFontsSizeManager.s14.sp,
                                    ),
                                    CustomTextFieldWidget(
                                      borderColor: AppColors.white,
                                      textInputType: TextInputType.number,
                                      iscenter: true,
                                      backGroundColor: AppColors.white,
                                      borderRadiusValue: AppRadius.r14.r,
                                      width: AppSize.w65.w,
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
                              horizontal: AppPadding.p25.w, vertical: AppPadding.p14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextDefaultWidget(
                                title: getTranslated(context, "consultType"),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s14.sp,
                              ),
                              Container(
                                width: AppSize.w150.w,
                                height: AppSize.h34.h,
                                decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.r17.r)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedType,
                                    iconEnabledColor: AppColors.chatButton,
                                    iconDisabledColor: AppColors.chatButton,
                                    items: <String>
                                        //['vocal','jeras','perfect']
                                        [
                                      getTranslated(context, "vocal"),
                                      getTranslated(context, "jeras"),
                                      getTranslated(context, "perfect")
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Center(
                                            child: TextDefaultWidget(
                                                title: value,
                                                color: AppColors.black1,
                                                fontSize: AppFontsSizeManager.s10)),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedType = value!;
                                        if (selectedType ==
                                            getTranslated(context, "jeras"))
                                          widget.program.consultType = "jeras";
                                        else if (selectedType ==
                                            getTranslated(context, "perfect"))
                                          widget.program.consultType =
                                              "perfect";
                                        else
                                          widget.program.consultType = "vocal";
                                      });
                                    },
                                  ),
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
                              horizontal: AppPadding.p25.w, vertical: AppPadding.p14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextDefaultWidget(
                                title: getTranslated(context, "selectLanguage"),
                                color: AppColors.black,
                                fontSize: AppFontsSizeManager.s14.sp,
                              ),
                              Container(
                                width: AppSize.w102.w,
                                height: AppSize.h34.h,
                                decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(AppRadius.r17.r)),
                                child: Center(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: lang,
                                      iconEnabledColor: AppColors.chatButton,
                                      iconDisabledColor: AppColors.chatButton,
                                      items: <String>[
                                        "ar", "en",
                                        // getTranslated(context, "arabic"),
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
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: AppSize.h36.h,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextDefaultWidget(
                              title: getTranslated(context, "status"),
                              color: AppColors.black,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                            Spacer(),
                            Switch(
                              value: active,
                              onChanged: (value) {
                                setState(() {
                                  active = value;
                                });
                              },
                              activeTrackColor: AppColors.chatButton,
                              activeColor: AppColors.lightGrey,
                            ),
                          ],
                        ),

                        SizedBox(
                          height: 50.h,
                        ),

                        isAdding
                            ? Center(child: CircularProgressIndicator())
                            : Center(
                                child: CustomButton(
                                  radius: AppRadius.r28.r,
                                  title: getTranslated(context, "save"),
                                  backgroundColor: AppColors.chatButton,
                                  onTap: () {
                                    addCategory();
                                  },
                                  verticalPadding: AppPadding.p18.h,
                                  margin: const EdgeInsets.all(0),
                                ),
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
}
