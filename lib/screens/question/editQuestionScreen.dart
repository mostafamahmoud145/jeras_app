import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/app_constat.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/questions.dart';


class EditQuestionScreen extends StatefulWidget {
  final Questions questions;

  const EditQuestionScreen({Key? key, required this.questions}) : super(key: key);

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
   String? arQuestion,  arAnswer, enQuestion, enAnswer, link, id,theme="light";
  late int order;
  late bool status;

  bool isAdding = false;

  @override
  void initState() {
    super.initState();
    isAdding = false;
    arQuestion = widget.questions.arQuestion;
    arAnswer = widget.questions.arAnswer;
    enQuestion = widget.questions.enQuestion;
    enAnswer = widget.questions.enAnswer;
    order = widget.questions.order;
    id = widget.questions.id;
    status = widget.questions.status;
    link = widget.questions.link;
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

  addCategory() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding = true;
      });
      List<String>indexListAr=[],indexListEn=[];
      for(int y=1;y<=arQuestion!.trimLeft().trimRight().length;y++)
      {
        indexListAr.add(arQuestion!.trimLeft().trimRight().substring(0,y).toLowerCase());
      }
      for(int y=1;y<=enQuestion!.trimLeft().trimRight().length;y++)
      {
        indexListEn.add(enQuestion!.trimLeft().trimRight().substring(0,y).toLowerCase());
      }
      await FirebaseFirestore.instance
          .collection(Paths.questionPath)
          .doc(id)
          .set({
        'arQuestion': arQuestion,
        'arAnswer': arAnswer,
        'enQuestion': enQuestion,
        'enAnswer': enAnswer,
        'id': id,
        'order': order,
        'status': status,
        'link': link,
        'searchIndexAr': indexListAr,
        'searchIndexEn': indexListEn,
      }, SetOptions(merge: true));

      setState(() {
        isAdding = false;
      });
      Navigator.pop(context);
    } else {
      showSnack('Please fill all the details!', context);
    }
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
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, top: 0.0, bottom: AppPadding.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r50),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.6),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: AppSize.w38.w,
                            height: AppSize.h35.h,
                            child: Icon(
                              Icons.arrow_back,
                              color: theme == "light"
                                  ? Colors.white
                                  : Colors.black,
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width:AppSize.w8,
                    ),
                    Text(
                      getTranslated(context, "editQuestion"),
                      style: GoogleFonts.poppins(
                        color: theme == "light" ? Colors.white : Colors.black,
                        fontSize: AppFontsSizeManager.s19,
                        fontWeight: AppFontsWeightManager.semiBold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppPadding.p16, vertical: AppPadding.p16),
              children: <Widget>[
                SizedBox(
                  height: AppSize.h20,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        // initialValue: getRandomString(5),
                        initialValue: arQuestion,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          arQuestion = val!;
                        },
                        maxLines: 2,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( AppPadding.p15),
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
                          labelText: getTranslated(context, "arQuestion"),
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
                        initialValue: arAnswer,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          arAnswer = val!;
                        },
                        maxLines: 6,
                        keyboardType: TextInputType.text,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( 15.0),
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
                          labelText: getTranslated(context, "arAnswer"),
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
                         initialValue: enQuestion,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          enQuestion = val!;
                        },
                        maxLines: 2,
                        keyboardType: TextInputType.text,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( AppPadding.p15),
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
                          labelText: getTranslated(context, "enQuestion"),
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
                        initialValue: enAnswer,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          enAnswer = val!;
                        },
                        maxLines:6,
                        keyboardType: TextInputType.text,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all( 15.0),
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
                          labelText: getTranslated(context, "enAnswer"),
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
                        initialValue: order.toString(),
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          order = int.parse(val!);
                        },
                        keyboardType: TextInputType.number,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.words,
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
                          labelText: getTranslated(context, "order"),
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
                        initialValue: link,
                        /*validator: (String val) {
                          if (val.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },*/
                        onSaved: (val) {
                          link = val!;
                        },
                        maxLines: 3,
                        enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: AppColors.black,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.words,
                        decoration: inputDecoration("link"),
                      ),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "status"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: Theme.of(context).primaryColor,
                                fontSize: AppFontsSizeManager.s15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: AppConstants.letterSpacing0_3,
                              ),
                            ),
                            Switch(
                              value: status,
                              onChanged: (value) {
                                setState(() {
                                  status = value;
                                });
                              },
                              activeTrackColor: AppColors.purple,
                              activeColor: AppColors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h15,
                      ),
                      isAdding
                          ? Center(child: CircularProgressIndicator())
                          : Center(
                              child: Container(
                                height: AppSize.h45,
                                width: double.infinity,
                                child: MaterialButton(
                                  onPressed: () {
                                    addCategory();
                                  },
                                  color: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppRadius.r15.r),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      FaIcon(
                                        FontAwesomeIcons.atom,
                                        color: theme == "light"
                                            ?AppColors.white
                                            : AppColors.black,
                                        size: AppSize.w20,
                                      ),
                                      SizedBox(
                                        width: AppSize.w10,
                                      ),
                                      Text(
                                        getTranslated(context, "save"),
                                        style: GoogleFonts.poppins(
                                          color: theme == "light"
                                              ?AppColors.white
                                              : AppColors.black,
                                          fontSize: AppFontsSizeManager.s15,
                                          fontWeight: AppFontsWeightManager.semiBold,
                                          letterSpacing: AppConstants.letterSpacing0_3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: AppSize.h15,
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

  InputDecoration inputDecoration(String value) {
    return InputDecoration(
      hintText: (value == "link"
          ? "https://www.youtuyoutubebe.com/watch?v=xxxxxxx"
          : ""),
      contentPadding: EdgeInsets.all( AppRadius.r15),
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
      labelText: getTranslated(context, "bio"),
      labelStyle: GoogleFonts.poppins(
        fontSize: AppFontsSizeManager.s14_5,
        fontWeight: AppFontsWeightManager.bold500,
        letterSpacing: AppConstants.letterSpacing0_5,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
    );
  }
}
