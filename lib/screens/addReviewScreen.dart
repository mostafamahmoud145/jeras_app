import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/screens/addObjectionScreen.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/consultReview.dart';
import '../../models/user.dart';
import '../models/course.dart';

class AddReviewScreen extends StatefulWidget {
  final String consultId;
  String? courseId;
  final String userId;
  final String appointmentId;
  final bool isCourse;

  AddReviewScreen(
      {Key? key,
      required this.consultId,
      this.courseId,
      required this.userId,
      required this.appointmentId,
      required this.isCourse})
      : super(key: key);

  @override
  _AddReviewScreenState createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final TextEditingController controller = TextEditingController();
  String theme = "light";
  bool load = true, adding = false;
  late GroceryUser consult, user;
  late Course course;
  late double rating = 0
  // widget.isCourse
  //         ? double.parse(courseRating.toString())
  //         : double.parse(consultRating.toString())
          ,
      consultRating = 0.0,
      courseRating = 0.0;
  String name = "....", image = "";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getConsultDetails();
    getCourseDetails();
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

  Future<void> getConsultDetails() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.consultId);
    final DocumentSnapshot documentSnapshot = await docRef.get();

    DocumentReference docRef2 = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.userId);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    setState(() {
      consult = GroceryUser.fromMap(documentSnapshot.data() as Map);
      name = consult.name!;
      image = consult.photoUrl!;
consultRating = (consult.rating == null) ? 0.0 : consult.rating.toDouble();
      user = GroceryUser.fromMap(documentSnapshot2.data() as Map);
      load = false;
    });
  }

  Future<void> getCourseDetails() async {
    if (widget.isCourse) {
      DocumentReference docRef =
        FirebaseFirestore.instance.collection("Courses").doc(widget.courseId);
    final DocumentSnapshot documentSnapshot = await docRef.get();

    setState(() {
      course = Course.fromMap(documentSnapshot.data() as Map);
      courseRating = course.rate;
      load = false;
    });
    }
    
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
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
                      const SizedBox(width: AppSize.w10),
                      Text(
                        getTranslated(context, "Reviews"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s31 : AppFontsSizeManager.s16,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey, height: 1, width: size.width)),
            SizedBox(height: 50),
            Center(
              child: load
                  ? CircularProgressIndicator()
                  : Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? size.width * .3
                                  : 20,
                          vertical: 20),
                      child: Column(
                        children: [
                          !widget.isCourse
                              ? Center(
                                  child: Container(
                                    height: AppSize.h71,
                                    width: AppSize.w71,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.white, width: AppSize.w1),
                                      boxShadow: [
                                        BoxShadow(
                                            color: const Color(0x1a7b6c96),
                                            offset: Offset(0, 5),
                                            blurRadius: 17,
                                            spreadRadius: 0)
                                      ],
                                      shape: BoxShape.circle,
                                      color: AppColors.white,
                                    ),
                                    child: Container(
                                      height: AppSize.h70,
                                      width: AppSize.w70,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.white, width: AppSize.w5),
                                        shape: BoxShape.circle,
                                        color: AppColors.white,
                                      ),
                                      child: consult.photoUrl!.isEmpty
                                          ? Image.asset(
                                              AssetsManager.whiteJerasLogoIconPath,
                                              width: AppSize.w70,
                                              height: AppSize.h70,
                                              fit: BoxFit.fill,
                                            )
                                          : ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(AppRadius.r100),
                                              child: FadeInImage.assetNetwork(
                                                placeholder:
                                                    AssetsManager.lodeGif,
                                                placeholderScale: 0.5,
                                                imageErrorBuilder: (context,
                                                        error, stackTrace) =>
                                                    Image.asset(
                                                        AssetsManager.whiteJerasLogoIconPath,
                                                        width: AppSize.w70,
                                                        height: AppSize.h70,
                                                        fit: BoxFit.fill),
                                                image: consult.photoUrl!,
                                                fit: BoxFit.cover,
                                                fadeInDuration: Duration(
                                                    milliseconds: AppConstants
                                                        .milliseconds250),
                                                fadeInCurve: Curves.easeInOut,
                                                fadeOutDuration: Duration(
                                                    milliseconds: AppConstants
                                                        .milliseconds150),
                                                fadeOutCurve: Curves.easeInOut,
                                              ),
                                            ),
                                    ),
                                  ),
                                )
                              : SizedBox(),
                          Text(
                            widget.isCourse ? course.name : name,
                            style: TextStyle(
                              color: AppColors.pink,
                              fontWeight: FontWeight.w400,
                              fontFamily: getTranslated(context, "Montserrat"),
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s31
                                  : AppFontsSizeManager.s14,
                            ),
                          ),
                          SizedBox(height: AppSize.h10),
                          widget.isCourse
                              ? SizedBox()
                              : Text(
                                  consult.location!,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s24
                                        : AppFontsSizeManager.s11,
                                    color: AppColors.lightGrey1,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                          SizedBox(height: AppSize.h10),
                          SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 5,
                            rating: rating,
                            size: AppSize.w35,
                            onRatingChanged: (v) {
                              setState(() {
                                rating = v;
                                // widget.isCourse
                                //     ? double.parse(courseRating.toString())
                                //     : double.parse(consultRating.toString());
                              });
                            },
                            color: AppColors.darkYellow,
                            borderColor: AppColors.darkYellow,
                            spacing: 1.0,
                          ),
                          SizedBox(height: AppSize.h25),
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.grey4,
                              borderRadius: BorderRadius.circular(AppRadius.r25),
                            ),
                            child: TextFormField(
                              textAlignVertical: TextAlignVertical.center,
                              maxLines: 5,
                              controller: controller,
                              enableInteractiveSelection: true,
                              style: GoogleFonts.poppins(
                                color: AppColors.black,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s20
                                    : AppFontsSizeManager.s11,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              textInputAction: TextInputAction.newline,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                /* filled: true,
                                fillColor: Colors.grey[100],*/
                                border: InputBorder.none,
                                /*enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(AppRadius.r10),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade100,
                                    width: 0.0,
                                  ),
                                ),*/
                                /* border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(AppRadius.r10),
                                        borderSide:  BorderSide(color: Colors.white ),
                                    ),*/
                                contentPadding: EdgeInsets.all((kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppPadding.p30
                                    : AppPadding.p10),
                                helperStyle: GoogleFonts.poppins(
                                  color: Colors.black.withOpacity(0.65),
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                ),
                                errorStyle: GoogleFonts.poppins(
                                  fontSize: AppFontsSizeManager.s11,
                                ),
                                hintStyle: GoogleFonts.poppins(
                                  color:AppColors.grey,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s20
                                      : AppFontsSizeManager.s11,
                                ),
                                hintText: widget.isCourse
                                    ? getTranslated(context, 'rateCourse')
                                    : getTranslated(context, 'rateConsult'),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSize.h25),
                          Center(
                            child: adding
                                ? CircularProgressIndicator()
                                : PrimaryButton(
                                    onPress: () {
                                      //rate event
                                      if (rating > 0.0) {
                                        //proceed
                                        widget.isCourse
                                            ? addCourseReview()
                                            : addConsultReview();
                                      }
                                    },
                                    text: getTranslated(context, "rate"),
                                    height: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.h60
                                        : AppSize.h40,
                                    textSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s26_6
                                        : AppFontsSizeManager.s11,
                                    buttonRadius: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppRadius.r30
                                        : AppRadius.r25,
                                    width: size.width * AppSize.w0_7,
                                  ),
                          ),
                          const SizedBox(height: AppSize.h25),
                          Center(
                            child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (_) => AddObjectionScreen(
                                          consultId: widget.consultId,
                                          userId: widget.userId,
                                          appointmentId:
                                              widget.appointmentId)));
                                },
                                child: Text(
                                  getTranslated(context, 'addObjection'),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontWeight: AppFontsWeightManager.bold500,
                                    fontStyle: FontStyle.normal,
                                    color: AppColors.red,
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25
                                        : AppFontsSizeManager.s11,
                                    letterSpacing:
                                        AppConstants.letterSpacing0_5,
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addConsultReview() async {
    setState(() {
      adding = true;
    });
    String reviewId = Uuid().v4();
    try {
      log(rating.toString());
      await FirebaseFirestore.instance
          .collection(Paths.consultReviewsPath)
          .doc(reviewId)
          .set({
        // 'rating': double.parse((rating.toString())),
        'rating': rating,
        'review': controller.text,
        'uid': user.uid,
        'name': user.name,
        'image': user.photoUrl,
        'consultUid': consult.uid,
        'appointmentId': widget.appointmentId,
        'reviewTime': Timestamp.now(),
        'consultName': consult.name,
        'consultImage': consult.photoUrl,
      });
      //update user review
      List<ConsultReview> reviews;
      try {
        QuerySnapshot snap = await FirebaseFirestore.instance
            .collection(Paths.consultReviewsPath)
            .where('consultUid', isEqualTo: consult.uid)
            .get();

        reviews = List<ConsultReview>.from(
          (snap.docs).map(
            (e) => ConsultReview.fromMap(e.data() as Map),
          ),
        );
        double _rating = 0;
        if (reviews.length > 0) {
          for (var review in reviews) {
            _rating = _rating + double.parse(review.rating.toString());
          }
          _rating = _rating / reviews.length;
          _rating = double.parse((_rating.toStringAsFixed(1)));
          await FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .doc(consult.uid)
              .set({
            'rating': _rating,
            'reviewsCount': reviews.length,
          }, SetOptions(merge: true));
        }
        setState(() {
          adding = false;
        });
        showAddingReviewDialog(MediaQuery.of(context).size);
      } catch (e) {}
    } catch (e) {}
  }

  Future<void> addCourseReview() async {
    setState(() {
      adding = true;
    });
    String reviewCourseId = Uuid().v4();
    try {
      await FirebaseFirestore.instance
          .collection("CourseReviews")
          .doc(reviewCourseId)
          .set({
        // 'rating': double.parse((rating.toString())),
        'rating': rating,
        'desc': controller.text,
        'uid': user.uid,
        'name': user.name,
        'appointmentId': widget.appointmentId,
        'reviewTime': Timestamp.now(),
        'courseName': course.name,
        'courseId': course.id,
      }, SetOptions(merge: true)).then((value) {});
      //update user review
      try {
        // QuerySnapshot snap = await FirebaseFirestore.instance
        //     .collection(Paths.consultReviewsPath)
        //     .where('consultUid', isEqualTo: consult.uid)
        //     .get();
        //
        // reviews = List<ConsultReview>.from(
        //   (snap.docs).map(
        //         (e) => ConsultReview.fromMap(e.data() as Map),
        //   ),
        // );
        // double _rating=0;
        // if (reviews.length > 0) {
        //   for (var review in reviews) {
        //     _rating = _rating + double.parse(review.rating.toString());
        //   }
        //   _rating = _rating / reviews.length;
        //   _rating=double.parse((_rating.toStringAsFixed(1)));
        //   await FirebaseFirestore.instance.collection(Paths.usersPath).doc(consult.uid).set({
        //     'rating': _rating,
        //     'reviewsCount':reviews.length,
        //
        //   }, SetOptions(merge: true));
        // }
        setState(() {
          adding = false;
        });
        showAddingReviewDialog(MediaQuery.of(context).size);
      } catch (e) {}
    } catch (e) {}
  }

  showAddingReviewDialog(Size size) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Center(
              child: Padding(
                padding: EdgeInsets.only(top: AppSize.h4.h),
                child: SvgPicture.asset(
                  AssetsManager.yellowStarIconPath,
                  width: AppSize.h56.r,
                  height: AppSize.w56.r,
                ),
              ),
            ),
            SizedBox(height: AppSize.h36.h),
            Column(
              children: [
                Text(
                  getTranslated(context, "ratingAddedSuccessfully"),
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithralight"),
                    fontSize: AppFontsSizeManager.s26_6.sp,
                    color: AppColors.black4,
                  ),
                ),
                SizedBox(
                  height: AppSize.h42_6.h,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
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
      barrierDismissible: false,
      context: context,
    );
  }
}
