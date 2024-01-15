import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/controller/programController.dart';
import 'package:jeras/widget/button_widget.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../Utils/helper.dart';
import '../../Utils/styles.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../widget/customTextField.dart';
import '../../widget/custom_back_button.dart';
import '../../widget/divider_widget.dart';

class AddProgramScreen extends StatefulWidget {
  @override
  _AddProgramScreenState createState() => _AddProgramScreenState();
}

class _AddProgramScreenState extends State<AddProgramScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? url;

  TextEditingController nameController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController courseNumController = TextEditingController();
  TextEditingController lessonNumController = TextEditingController();

  ProgramController programController = ProgramController();
  String lang = "ar";
  String dropdownTypeValue = "Primary";
  List<String> listType = ['Primary', 'Academy'];
  bool isAdding = false;
  bool active = false;
  late String selectedType, programType = "jeras";
  var image;
  var selectedImage;

  @override
  void initState() {
    super.initState();

    isAdding = false;
  }

  @override
  void didChangeDependencies() {
    selectedType = getTranslated(context, "jeras");
    super.didChangeDependencies();
  }

  addCategory() async {
    if (_formKey.currentState!.validate() &&
        selectedImage != null) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });

      var uuid = Uuid().v4();
      if (selectedImage != null) {
        Reference storageReference =
            FirebaseStorage.instance.ref().child('Program/$uuid');
        await storageReference.putFile(selectedImage);
        url = await storageReference.getDownloadURL();
      }
      await FirebaseFirestore.instance.collection("Program").doc(uuid).set({
        'id': uuid,
        'name': nameController.text,
        'image': url,
        'notes': notesController.text,
        'desc': descController.text,
        'courseNum': int.parse(courseNumController.text),
        'lessonNum': int.parse(lessonNumController.text),
        'consultType': programType,
        'active': active,
        'lang': lang,
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
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  CustomBackButton(),
                  const SizedBox(width: AppSize.w10),
                  //  SizedBox(width: size.width * .3,),
                  TextDefaultWidget(
                      title: getTranslated(context, 'addProgram'),
                      fontSize: AppFontsSizeManager.s17.sp,
                      color: AppColors.black,
                      fontWeight: FontWeight.bold),
                ],
              ),
            ),
            //DividerWidget(height: 2, width: size.width * .8),
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
                          height: AppSize.h50.h,
                        ),
                        CustomTextFieldWidget(
                            backGroundColor: AppColors.grey4,
                            borderColor: AppColors.white,
                            borderRadiusValue: AppRadius.r10,
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
                                  ? 'please enter course name .'
                                  : null;
                            }),
                        SizedBox(
                          height: AppSize.h25.h,
                        ),
                        Container(
                          height: AppSize.h220.h,
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p20.w, vertical: AppPadding.p24.h),
                          decoration: BoxDecoration(
                              color: AppColors.grey4,
                              borderRadius: BorderRadius.circular(AppRadius.r30.r)),
                          child: Stack(
                            children: <Widget>[
                              Column(
                                children: [
                                  TextDefaultWidget(
                                    title: getTranslated(context, 'addBanner'),
                                    color: AppColors.black,
                                    fontSize: AppFontsSizeManager.s14.sp,
                                  ),
                                  SizedBox(
                                    height: AppSize.h18_6.h,
                                  ),
                                  Container(
                                      width: AppSize.w294.w,
                                      height: AppSize.h130.h,
                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.r30.r)),
                                      child: selectedImage == null
                                          ? SizedBox()
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(AppRadius.r10.r),
                                              child: Image.file(
                                                selectedImage,
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                ],
                              ),
                              if (selectedImage == null &&
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
                            textInputType: TextInputType.multiline,
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
                            textInputType: TextInputType.multiline,
                            maxLine: 4,
                            height: AppSize.h110.h,
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
                                horizontal: AppPadding.p34.w, vertical: AppFontsSizeManager.s20.h)),

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
                                      fontSize: 14.sp,
                                    ),
                                    CustomTextFieldWidget(
                                      borderColor: AppColors.white,
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
                                          fontSize: AppFontsSizeManager.s12.sp),
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
                                    borderRadius: BorderRadius.circular(AppRadius.r16.r)),
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
                                        child: TextDefaultWidget(
                                          title: value,
                                          color: AppColors.black1,
                                          fontSize: AppFontsSizeManager.s10,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        selectedType = value!;
                                        if (selectedType ==
                                            getTranslated(context, "jeras"))
                                          programType = "jeras";
                                        else if (selectedType ==
                                            getTranslated(context, "perfect"))
                                          programType = "perfect";
                                        else
                                          programType = "vocal";
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
                              fontSize: AppFontsSizeManager.s18.sp,
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
                              activeTrackColor: AppColors.pink,
                              activeColor: AppColors.lightGrey,
                            ),
                          ],
                        ),

                        SizedBox(
                          height: AppSize.h50.h,
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
                        // consultType
                        // Row(
                        //   children: [
                        //     TextDefaultWidget(title:"programType", color: AppColors.pink, fontSize: 18.0, fontWeight: FontWeight.bold,),
                        //     Spacer(),
                        //     Container(
                        //       width: 10,
                        //       height: 40,
                        //       padding: const EdgeInsets.symmetric(
                        //           horizontal: 10.0, vertical: 10.0),
                        //       decoration: BoxDecoration(
                        //         color: Colors.black.withOpacity(0.03),
                        //         borderRadius: BorderRadius.circular(AppRadius.r15.r),
                        //       ),
                        //       child: DropdownButtonHideUnderline(
                        //         child: DropdownButton<String>(
                        //           value: selectedType,
                        //           items: <String>['perfect', 'jeras','vocal']
                        //               .map((String value) {
                        //             return DropdownMenuItem<String>(
                        //               value: value,
                        //               child: new Text(value),
                        //             );
                        //           }).toList(),
                        //           onChanged: (value) {
                        //             setState(() {
                        //               selectedType = value!;
                        //             });
                        //             /*
                        //             if (value == "focal")
                        //               _changeType("focal");
                        //             else if (value == "jeras")
                        //               _changeType("jeras");
                        //             else if (value == "perfect")
                        //               _changeType("perfect");
                        //             else
                        //               _changeType("focal");*/
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        //
                        // // lang
                        // Row(
                        //   children: [
                        //     TextDefaultWidget(title: getTranslated(context, "lang"), color: AppColors.pink, fontSize: 18.0, fontWeight: FontWeight.bold,),
                        //     Spacer(),
                        //     Container(
                        //       width: 10,
                        //       height: 40,
                        //       padding: const EdgeInsets.symmetric(
                        //           horizontal: 10.0, vertical: 10.0),
                        //       decoration: BoxDecoration(
                        //         color: Colors.black.withOpacity(0.03),
                        //         borderRadius: BorderRadius.circular(AppRadius.r15.r),
                        //       ),
                        //       child: DropdownButtonHideUnderline(
                        //         child: DropdownButton<String>(
                        //           value: lang,
                        //           items: <String>['ar', 'en']
                        //               .map((String value) {
                        //             return DropdownMenuItem<String>(
                        //               value: value,
                        //               child: new Text(value),
                        //             );
                        //           }).toList(),
                        //           onChanged: (value) {
                        //             setState(() {
                        //               lang = value!;
                        //             });
                        //           },
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(height: 20),
                        // //status
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     TextDefaultWidget(title:getTranslated(context, "status"), color: AppColors.pink, fontSize: AppFontsSizeManager.s15, fontWeight: FontWeight.bold,),
                        //     Spacer(),
                        //     Switch(
                        //       value: active,
                        //       onChanged: (value) {
                        //         setState(() {
                        //           active = value;
                        //         });
                        //       },
                        //       activeTrackColor: AppColors.lightGrey.withOpacity(.1),
                        //       activeColor: AppColors.pink,
                        //     ),
                        //   ],
                        // ),
                        //
                        // SizedBox(
                        //   height: 60.0,
                        // ),
                        // SizedBox(
                        //   height: AppSize.h15,
                        // ),
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
