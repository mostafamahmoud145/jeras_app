import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/app_constat.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/interests.dart';
import '../../models/job.dart';
import '../../models/jobOffers.dart';
import '../../models/user.dart';
import '../../widget/component/IconButton.dart';
import '../ConsultantDetailsScreen.dart';

class JobDetailsScreen extends StatefulWidget {
  final Job job;
  final GroceryUser loggedUser;

  const JobDetailsScreen(
      {Key? key, required this.job, required this.loggedUser})
      : super(key: key);

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false, loadInterests = true, dealting = false, init = true;
  String? title, des;
  bool show = false;
  List<Interests> interestList = [];
  late Size size;
  String lang = "";

  @override
  void initState() {
    if (widget.loggedUser.userType != "CONSULTANT") getInterests();
    title = widget.job.title;
    des = widget.job.desc;
    super.initState();
  }

  getInterests() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.interestsPath)
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
    lang = getTranslated(context, "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          //header
          Container(
            width: size.width,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p139.w
                        : AppPadding.p20,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p139.w
                        : AppPadding.p20,
                    top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p58.w
                        : AppPadding.p10,
                    bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p76_5.w
                        : AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomBackButton(),
                    SizedBox(width: AppSize.w21_3.w,),
                    (widget.loggedUser.userType == "CONSULTANT")
                        ? Text(
                            getTranslated(context,"jobAvaliable"),
                            style: TextStyle(
                              fontFamily: 'NotoKufiArabic-SemiBold',
                              fontSize: AppFontsSizeManager.s21_3.sp,
                              color: AppColors.black,
                            ),
                          )
                        : SizedBox(
                            width: 0,
                          ),
                          Spacer(),
                    (widget.loggedUser.userType != "CONSULTANT" &&
                            show == false)
                        ? (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? SizedBox()
                            : IconButton(
                                onPressed: () {
                                  setState(() {
                                    show = true;
                                  });
                                },
                                icon: Image.asset(
                                  AssetsManager.greyMore,
                                  width: AppSize.w30.w,
                                  height: AppSize.h30.h,
                                ),
                              )
                        : (widget.loggedUser.userType != "CONSULTANT" && show)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    height: AppSize.h37.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.r20.r),
                                      border: Border.all(
                                        color: AppColors.borderLightGrey,
                                        width: AppSize.w0_5.w,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            save("new");
                                          },
                                          icon: SvgPicture.asset(
                                            AssetsManager.refreshIconPath,
                                            width: AppSize.w15.w,
                                            height: AppSize.h15.h,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            save("closed");
                                          },
                                          icon: SizedBox(
                                            child: Icon(
                                              widget.job.status == "closed"
                                                  ? Icons.lock
                                                  : Icons.lock_open,
                                                  color: AppColors.primaryColor,
                                                  size: AppSize.h17.h,
                                              // width: AppSize.w15.w,
                                              // height: AppSize.h15.h,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            deleteCourseDialoge(size);
                                          },
                                          icon: SvgPicture.asset(
                                            AssetsManager.smallDelete1IconPath,
                                            width: AppSize.w15.w,
                                            height: AppSize.h15.h,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSize.w10.w,
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        show = false;
                                      });
                                    },
                                    icon: Image.asset(
                                      AssetsManager.greyClose,
                                      width: AppSize.w15.w,
                                      height: AppSize.h15.h,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? SizedBox()
              : Center(
                  child: Container(
                      color: Color.fromRGBO(236, 236, 236, 0.65),
                      height: AppSize.h1.h,
                      width: size.width),
                ),
          Expanded(
            child: ListView(
                padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? EdgeInsets.symmetric(vertical: 0)
                    : EdgeInsets.only(
                        left: AppPadding.p20, right: AppPadding.p20),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppPadding.p140.w
                            : AppPadding.p10,
                        right:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p140.w
                                : AppPadding.p10,
                        top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? 0
                            : AppPadding.p10,
                        bottom:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 0
                                : AppPadding.p15,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            width: AppSize.w2.w,
                          ),
                          if (widget.loggedUser.userType != "CONSULTANT")
                            saving
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.pink,
                                    ),
                                  )
                                : SizedBox(),
                          SizedBox(
                            height: AppSize.h22.h,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              //title
                              Expanded(
                                child: TextFormField(
                                  maxLines: 2,
                                  minLines: 1,
                                  scrollPadding: EdgeInsets.all(AppPadding.p0),
                                  textAlignVertical: TextAlignVertical.top,
                                  style: TextStyle(
                                      fontFamily: "NotoKufiArabic-SemiBold",
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s58.sp
                                          : AppFontsSizeManager.s24.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryColor),
                                  cursorColor: AppColors.primaryColor,
                                  keyboardType: TextInputType.text,
                                  readOnly: widget.loggedUser.userType ==
                                      "CONSULTANT",
                                  initialValue: widget.job.title,
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
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 0.w, vertical: 0.h),
                                      hintStyle: TextStyle(
                                          color: AppColors.grey6,
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppFontsSizeManager.s58.sp
                                              : AppFontsSizeManager.s17.sp,
                                          fontWeight:
                                              AppFontsWeightManager.semiBold,
                                          fontFamily:
                                              getTranslated(context, "Ithra")),
                                      focusColor: AppColors.greyShade300),
                                ),
                              ),
                              // if (widget.loggedUser.userType == "CONSULTANT")
                              //time
                              Padding(
                                padding: EdgeInsets.only(
                                    // top:  AppPadding.p25_3.h,
                                    right: AppPadding.p20.w,
                                    left: AppPadding.p20.w),
                                child: Row(
                                  children: [
                                    Text(
                                      DateTime.parse(widget.job.utcTime)
                                              .toUtc()
                                              .hour
                                              .toString() +
                                          ":" +
                                          DateTime.parse(widget.job.utcTime)
                                              .toUtc()
                                              .minute
                                              .toString(), // DateFormat.jm("ar").format(
                                      //     DateTime.parse(widget.job.utcTime)),
                                      textAlign: TextAlign.start,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        color: AppColors.grey,
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s39.sp
                                            : AppFontsSizeManager.s21.sp,
                                        fontWeight:
                                            AppFontsWeightManager.bold300,
                                      ),
                                    ),
                                    Text(
                                      " ${DateTime.parse(widget.job.utcTime).toUtc().hour > 12 ? getTranslated(context, "pm") : getTranslated(context, "am")} ",
                                      textAlign: TextAlign.start,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                        fontFamily: "NotoKufiArabic-Regular",
                                        color: AppColors.grey,
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s39.sp
                                            : AppFontsSizeManager.s21.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (widget.loggedUser.userType == "CONSULTANT")
                            SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppPadding.p6_5.w
                                  : AppSize.h32.h,
                            ),
                            (widget.loggedUser.userType != "CONSULTANT")?
                          Divider(
                            height: AppSize.h43.h,
                            color: Color.fromRGBO(236, 236, 236, 0.65),
                          ):SizedBox(),
                          Text(
                            getTranslated(context, "jobDesc"),
                            style: TextStyle(
                              fontFamily: "NotoKufiArabic-SemiBold",
                              color: AppColors.black4,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s35.sp
                                  : AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h21_3.h,
                          ),
                          Container(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w1135.w
                                : size.width,
                            child: TextFormField(
                              maxLines: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 3
                                  : 2,
                              minLines: 1,
                              readOnly:
                                  widget.loggedUser.userType != "CONSULTANT"
                                      ? false
                                      : true,
                              style: TextStyle(
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s24.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  fontFamily: (widget.loggedUser.userType == "CONSULTANT")?"NotoKufiArabic-Regular": "NotoKufiArabic-SemiBold",
                                  fontWeight: (widget.loggedUser.userType == "CONSULTANT")? FontWeight.w400: FontWeight.w600,
                                  color: AppColors.grey6),
                              cursorColor: AppColors.black,
                              initialValue: widget.job.desc,
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
                                        : AppFontsSizeManager.s20.sp,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.grey6),
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
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h24.h
                                : AppSize.h37.h,
                          ),
                          //continu
                          Text(
                            getTranslated(context, "jobInterests"),
                            style: TextStyle(
                              fontFamily: "NotoKufiArabic-SemiBold",
                              color: AppColors.black4,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s35.sp
                                  : AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h24.h
                                : AppSize.h10.h,
                          ),
                          if (widget.loggedUser.userType != "CONSULTANT")
                            loadInterests
                                ? Center(
                                    child: CircularProgressIndicator(
                                    color: AppColors.pink,
                                  ))
                                : Container(
                                    height: size.height * AppSize.h0_45,
                                    child: MediaQuery.removePadding(
                                      context: context,
                                      removeTop: true,
                                      child: GridView.count(
                                        padding: EdgeInsets.only(
                                          left: getTranslated(
                                                      context, "lang") ==
                                                  "ar"
                                              ? (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? size.width * AppSize.w0_2
                                                  : 0
                                              : 0,
                                          right: getTranslated(
                                                      context, "lang") ==
                                                  "ar"
                                              ? 0
                                              : (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? size.width * AppSize.w0_2
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
                                            : AppSize.h26_6.h,
                                        crossAxisSpacing: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.w49.w
                                            : AppSize.w21_3.w,
                                        childAspectRatio: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? 1.9
                                            : 1,
                                        children: interestList
                                            .map(
                                              (Item) => ItemList(Item),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                  ),

                          if (widget.loggedUser.userType == "CONSULTANT")
                            buildInterests(),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h45_3.h
                                : AppSize.h54.h,
                          ),
                          if (widget.loggedUser.userType != "CONSULTANT")
                            Text(
                              getTranslated(context, "jobOffers"),
                              style: TextStyle(
                                fontFamily: "NotoKufiArabic-SemiBold",
                                color: AppColors.black4,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s35.sp
                                    : AppFontsSizeManager.s21_3.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          if (widget.loggedUser.userType != "CONSULTANT")
                            Container(
                              height: size.height * AppSize.h0_5,
                              child: PaginateFirestore(
                                separator: Center(
                                    child: Container(
                                        color: AppColors.grey7,
                                        height: AppSize.h1.h,
                                        width: size.width * AppSize.w0_75)),
                                itemBuilderType: PaginateBuilderType.listView,
                                itemBuilder:
                                    (context, documentSnapshot, index) {
                                  return offerWidget(
                                      JobOffer.fromMap(documentSnapshot[index]
                                          .data() as Map),
                                      size);
                                },
                                query: FirebaseFirestore.instance
                                    .collection(Paths.jobOffersPath)
                                    .where('jobId', isEqualTo: widget.job.jobId)
                                    .orderBy('utcTime', descending: true),
                                // to fetch real-time data
                                isLive: true,
                              ),
                            ),
                          if (widget.loggedUser.userType == "CONSULTANT")
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "JobAdvertiser"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: "NotoKufiArabic-SemiBold",
                                      color: AppColors.primaryColor,
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s20.sp
                                          : AppFontsSizeManager.s24.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(
                                    height: AppSize.h21_3.h,
                                  ),
                                  //image icon
                                  Container(
                                    height: AppSize.h66_6.h,
                                    width: AppSize.w66_6.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey4,
                                      border: Border.all(
                                          color: AppColors.white,
                                          width: AppSize.w3.w),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.linear3,
                                          blurRadius: 9.0,
                                          spreadRadius: 0.0,
                                          offset: Offset(0.0, 2.0),
                                        )
                                      ],
                                    ),
                                    child: widget.job.owner.image!.isEmpty
                                        ? Icon(
                                            Icons.person,
                                            color: AppColors.white,
                                            size: 30.0,
                                          )
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r100.r),
                                            child: FadeInImage.assetNetwork(
                                              placeholder: AssetsManager
                                                  .iconPersonIconPath,
                                              placeholderScale: 0.5,
                                              imageErrorBuilder: (context,
                                                      error, stackTrace) =>
                                                  Icon(
                                                Icons.person,
                                                color: AppColors.white,
                                                size: AppSize.w30,
                                              ),
                                              image: widget.job.owner.image!,
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
                                  SizedBox(height: AppSize.h10_6.h),
                                  Text(
                                    widget.job.owner.name!,
                                    maxLines: 2,
                                    style: TextStyle(
                                      fontFamily: "NotoKufiArabic-SemiBold",
                                      color: AppColors.black4,
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s23.sp
                                          : AppFontsSizeManager.s21_3.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            height: AppSize.h57.h,
                          ),
                          if (widget.loggedUser.userType == "CONSULTANT")
                            InkWell(
                              onTap: () {
                                sendProfile();
                              },
                              child: Center(
                                child: Column(
                                  children: [
                                    widget.job.cosultIds
                                            .contains(widget.loggedUser.uid)
                                        ? Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons
                                                    .check_circle_outline_rounded,
                                                color: Color(0xff12E95F),  
                                              ),
                                              SizedBox(
                                                width: AppSize.w10_6.w,
                                              ),
                                              Text(
                                                getTranslated(
                                                    context, "sendDone"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily:
                                                      'NotoKufiArabic-SemiBold',
                                                  fontSize: AppFontsSizeManager
                                                      .s24.sp,
                                                  color: AppColors.black,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container(
                                            height: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.h80.h
                                                : AppSize.h66_6.h,
                                            width: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? size.width * AppSize.w0_3
                                                : AppSize.w390.w,
                                            padding: EdgeInsets.all(1),
                                            decoration: BoxDecoration(
                                              gradient: PrimaryButton.gradiant,
                                              borderRadius: BorderRadius
                                                  .circular((kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppRadius.r12.r
                                                      : AppRadius.r16.r),
                                            ),
                                            child: saving
                                                ? Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                    color: AppColors.white,
                                                  ))
                                                : Center(
                                                    child: Text(
                                                      getTranslated(context,
                                                          "sendProfile"),
                                                      style: TextStyle(
                                                        fontFamily:
                                                            "NotoKufiArabic-SemiBold",
                                                        color: AppColors.white,
                                                        fontSize: (kIsWeb ||
                                                                size.width >=
                                                                    AppConstants
                                                                        .kIsWebValue)
                                                            ? AppFontsSizeManager
                                                                .s26_6.sp
                                                            : AppFontsSizeManager
                                                                .s22.sp,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                  ],
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
          // SizedBox(height: size.height *  .2,),
        ],
      ),
    );
  }

  interestWidget(Size size) {
    return Container(
      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.h167.h
          : size.height * AppSize.h0_4,
      child: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? ListView.separated(
              itemCount: interestList.length,
              //shrinkWrap: true,

              scrollDirection: Axis.horizontal,
              //physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              itemBuilder: (context, index) {
                return ItemList(interestList[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: AppSize.w20.w,
                );
              },
            )
          : MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
                children: interestList
                    .map(
                      (Item) => ItemList(Item),
                    )
                    .toList(),
              ),
            ),
    );
  }

  save(String status) async {
    if (status == "new") {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();
        try {
          setState(() {
            saving = true;
          });
          List<Map> interestsMap = [];
          List<String> ids = [];
          for (var add in interestList) {
            if (widget.job.interestsIds.contains(add.interestId)) {
              Map tempAdd = Map();
              tempAdd.putIfAbsent('icon', () => add.icon);
              tempAdd.putIfAbsent('enName', () => add.enName);
              tempAdd.putIfAbsent('arName', () => add.arName);
              tempAdd.putIfAbsent('interestId', () => add.interestId);
              tempAdd.putIfAbsent('activeIcon', () => add.activeIcon);
              interestsMap.add(tempAdd);
              ids.add(add.interestId);
            }
          }

          await FirebaseFirestore.instance
              .collection(Paths.jobsPath)
              .doc(widget.job.jobId)
              .set({
            'status': status,
            'title': title,
            'desc': des,
            'interests': interestsMap,
            'interestsIds': ids,
          }, SetOptions(merge: true));
          setState(() {
            saving = false;
          });
          showRepublishJobsDialog(
              MediaQuery.of(context).size,
              AssetsManager.refreshIconPath,
              getTranslated(context, "republishSuccessfully"),
              getTranslated(context, "receiveTeacherRequests"));
        } catch (e) {}
      }
    } else {
      setState(() {
        saving = true;
      });
      await FirebaseFirestore.instance
          .collection(Paths.jobsPath)
          .doc(widget.job.jobId)
          .set({
        'status': status,
      }, SetOptions(merge: true));
      setState(() {
        saving = false;
      });
      showRepublishJobsDialog(
          MediaQuery.of(context).size,
          AssetsManager.moveLockIconPath,
          getTranslated(context, "jobClosed"),
          getTranslated(context, "canRepublishAgain"));
    }
  }

  sendProfile() async {
    if (widget.job.cosultIds.contains(widget.loggedUser.uid)) {
      Fluttertoast.showToast(
          msg: getTranslated(context, "sendDone"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.red,
          textColor: AppColors.white,
          fontSize: AppFontsSizeManager.s16.sp);
    } else {
      try {
        setState(() {
          saving = true;
        });
        String jobOfferId = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.jobOffersPath)
            .doc(jobOfferId)
            .set({
          'jobOfferId': jobOfferId,
          "jobId": widget.job.jobId,
          "jobOwnerUid": widget.job.owner.uid,
          'status': "new",
          'rate': widget.loggedUser.rating.toString(),
          'utcTime': DateTime.now().toUtc().toString(),
          'date': {
            'day': DateTime.now().toUtc().day,
            'month': DateTime.now().toUtc().month,
            'year': DateTime.now().toUtc().year,
          },
          'owner': {
            'uid': widget.loggedUser.uid,
            'name': widget.loggedUser.name,
            'image': widget.loggedUser.photoUrl,
            'phone': widget.loggedUser.phoneNumber,
          },
        });
        widget.job.cosultIds.add(widget.loggedUser.uid);
        await FirebaseFirestore.instance
            .collection(Paths.jobsPath)
            .doc(widget.job.jobId)
            .set({
          'cosultIds': widget.job.cosultIds,
        }, SetOptions(merge: true));
        setState(() {
          saving = false;
        });
        Fluttertoast.showToast(
            msg: getTranslated(context, "sendDone"),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            backgroundColor: Colors.lightGreen,
            textColor: AppColors.white,
            fontSize: AppFontsSizeManager.s16.sp);
      } catch (e) {}
    }
  }

  showRepublishJobsDialog(Size size, String icon, String title, String msg) {
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
                    Navigator.of(context)
                      ..pop()
                      ..pop();
                  },
                  child: SvgPicture.asset(
                    AssetsManager.moveCloseIconPath,
                    width: AppSize.w32.w,
                    height: AppSize.h32.h,
                  ),
                ),
                SizedBox(width: AppSize.w140.w),
                Padding(
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
            SizedBox(height: AppSize.h22.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s26_6.sp,
                      color: AppColors.black4,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSize.h31_3.h),
                  Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.linear2,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(height: AppSize.h18_6.h),
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

  /* addingDialog(Size size, String icon, String text, String details) {
    //Size size=MediaQuery.of(context).size;
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(47.r),
          ),
        ),
        elevation: 5.0,
        content: Padding(
          padding:
              const EdgeInsets.only(top: 15, left: AppPadding.p10, right: AppPadding.p10, bottom: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.of(context)
                    ..pop()
                    ..pop(),
                  icon: Icon(
                    Icons.close,
                    color: Theme.of(context).primaryColor,
                    size: 35,
                  ),
                ),
              ),
              Image.asset(
                'assets/applicationIcons/' + icon,
                width: 40.w,
                height:AppSize.h40.h,
                fit: BoxFit.cover,
              ),
              SizedBox(
                height: AppSize.h10.h,
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  color: Color(0xff202020),
                  fontSize: AppFontsSizeManager.s18.sp,
                  fontWeight:AppFontsWeightManager.bold300,
                ),
              ),
              // Stack(
              //   children: <Widget>[
              //     Text(
              //       text,
              //       textAlign: TextAlign.center,
              //       style: TextStyle(
              //         fontFamily: getTranslated(context, "Ithra"),
              //         fontSize: 18.0,
              //         fontWeight:AppFontsWeightManager.bold300,
              //         foreground: Paint()
              //           ..style = PaintingStyle.stroke
              //           ..strokeWidth = 0.3
              //           ..color = Color(0xff202020),
              //       ),
              //     ),
              //     // Solid text as fill.
              //     Text(
              //       text,
              //       textAlign: TextAlign.center,
              //       style: TextStyle(
              //         fontFamily: getTranslated(context, "Ithra"),
              //         color: Color(0xff202020),
              //         fontSize: 18.0,
              //         fontWeight:AppFontsWeightManager.bold300,
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(
                height: AppSize.h10.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: details != " "
                    ? Text(
                        details,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: AppColors.grey6,
                          fontSize: 15.0.sp,
                          fontWeight:AppFontsWeightManager.bold300,
                        ),
                      )
                    : SizedBox(),
              ),
              SizedBox(
                height: AppSize.h10.h,
              ),
              // Center(
              //   child: Container(
              //     width: size.width * .5,
              //     child: MaterialButton(
              //       color: Theme.of(context).primaryColor,
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(5.0),
              //       ),
              //       padding: const EdgeInsets.all(0.0),
              //       onPressed: () {
              //         Navigator.pop(context);
              //         Navigator.pop(context);
              //       },
              //       child: Text(
              //         getTranslated(context, 'Ok'),
              //         style: TextStyle(
              //           fontFamily: getTranslated(context, "Ithra"),
              //           color: Colors.white,
              //           fontSize: 13.5,
              //           fontWeight: FontWeight.wAppConstants.kIsWebValue,
              //           letterSpacing: AppConstants.letterSpacing0_3,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }*/

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

  deleteCourseDialoge(Size size) {
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
              ],
            ),
            SizedBox(height: AppSize.h26.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "deleteJob"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.grey_dark,
                      fontWeight: FontWeight.w300,
                      // fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h32.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      SizedBox(
                        width: AppSize.w160.w,
                        height: AppSize.h56.h,
                        child: InkWell(
                          onTap: () async {
                            setState(() {
                              dealting = true;
                            });
                            var querySnapshot = await FirebaseFirestore.instance
                                .collection("JobOffer")
                                .where('jobId', isEqualTo: widget.job.jobId)
                                .get();
                            for (var doc in querySnapshot.docs) {
                              await FirebaseFirestore.instance
                                  .collection("JobOffer")
                                  .doc(doc.id)
                                  .delete();
                            }
                            FirebaseFirestore.instance
                                .collection(Paths.jobsPath)
                                .doc(widget.job.jobId)
                                .delete();
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Container(
                            //   alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.linear2,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r),
                            ),
                            child: Center(
                              child: Text(
                                getTranslated(context, "delete"),
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
                      ),
                      SizedBox(width: AppSize.w57_3.w),
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
                              getTranslated(context, "cancel"),
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

  Widget buildInterests() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: Wrap(
        children: [
          ...widget.job.interests.map((Item) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p7_5.w,
                  vertical: AppPadding.p10_6.h,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(123, 108, 150, 0.08),
                    borderRadius: BorderRadius.circular(AppSize.h8.r),
                  ),
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h50.h
                      : AppSize.h53.h,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? 0
                      : AppSize.w160.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Spacer(),
                      Text(
                        Item.arName,
                        textAlign: TextAlign.right,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontFamily: 'NotoKufiArabic-SemiBold',
                            color: AppColors.primaryColor,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s29.sp
                                : AppFontsSizeManager.s18_6.sp),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget buildInterests2() {
    List<Widget> choices = [];
    for (int x = 0; x < widget.job.interests.length; x++) {
      choices.add(Container(
        padding: EdgeInsets.only(
            left: AppPadding.p10,
            right: AppPadding.p10,
            top: AppPadding.p5,
            bottom: AppPadding.p5),
        decoration: BoxDecoration(
          color: Color.fromRGBO(174, 156, 206, 0.19),
          borderRadius: BorderRadius.circular(16.0.r),
        ),
        child: Text(
          widget.job.interests[x].arName,
          style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
            color: AppColors.primaryColor,
            fontSize: AppFontsSizeManager.s13.sp,
            fontWeight: AppFontsWeightManager.bold300,
          ),
        ),
      ));
    }
    return Wrap(spacing: 5.0, runSpacing: 5, children: choices);
  }

  Widget offerWidget(JobOffer offer, size) {
    bool display = false;
    return Padding(
      padding:
          const EdgeInsets.only(top: AppPadding.p15, bottom: AppPadding.p15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h75.h
                    : AppSize.h46_6.h,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h75.h
                    : AppSize.w46_6.w,
                padding: EdgeInsets.all(AppPadding.p4),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(199, 198, 198, 1),
                  shape: BoxShape.circle,
                ),
                child: offer.owner.image!.isEmpty
                    ? Icon(
                        Icons.person,
                        color: AppColors.white,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r100.r),
                        child: FadeInImage.assetNetwork(
                          placeholder: AssetsManager.iconPersonIconPath,
                          placeholderScale: 0.5,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Icon(
                            Icons.person,
                            color: AppColors.white,
                          ),
                          image: offer.owner.image!,
                          fit: BoxFit.cover,
                          fadeInDuration: Duration(
                              milliseconds: AppConstants.milliseconds250),
                          fadeInCurve: Curves.easeInOut,
                          fadeOutDuration: Duration(
                              milliseconds: AppConstants.milliseconds150),
                          fadeOutCurve: Curves.easeInOut,
                        ),
                      ),
              ),
              SizedBox(
                width: AppSize.w6_5.w,
              ),
              Padding(
                padding: EdgeInsets.only(top: AppPadding.p5.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_5
                          : size.width * AppSize.w0_4,
                      child: Text(
                        offer.owner.name!,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.grey_dark,
                          fontFamily: "NotoKufiArabic-SemiBold",
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s28.sp
                                  : AppFontsSizeManager.s18_6.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p2.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            offer.rate,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              color: AppColors.primaryColor,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s18.sp
                                  : AppFontsSizeManager.s16.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Icon(
                            Icons.star,
                            size: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w24
                                : AppSize.w14.r,
                            color: AppColors.yellow,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () async {
              setState(() {
                display = true;
              });
              DocumentReference docRef = FirebaseFirestore.instance
                  .collection(Paths.usersPath)
                  .doc(offer.owner.uid);
              final DocumentSnapshot documentSnapshot = await docRef.get();
              var consult = GroceryUser.fromMap(documentSnapshot.data() as Map);
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings:
                      RouteSettings(arguments: {"consultant_id": consult.uid}),
                  builder: (context) => ConsultantDetailsScreen(
                    consoltantId: '${consult.uid}',
                  ),
                ),
              );
            },
            child: Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h60.h
                  : AppSize.h40.h,
              // width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              //     ? AppSize.h60.h
              //     : AppSize.w102.h,
              padding: EdgeInsets.all(
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p10.w
                    : AppPadding.p13_3.w,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppRadius.r25.r
                        : AppRadius.r5_3.r),
                color: widget.job.status == "closed"
                    ? Color.fromRGBO(184, 180, 180, 1)
                    : Color.fromRGBO(123, 108, 150, 1),
              ),
              child: display
                  ? Center(
                      child: CircularProgressIndicator(
                      color: Colors.white,
                    ))
                  : Center(
                      child: Text(
                        getTranslated(context, "profile"),
                        style: TextStyle(
                            fontFamily: "NotoKufiArabic-SemiBold",
                            color: Colors.white,
                            // letterSpacing: AppSize.w0_20.w,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s21.sp
                                : AppFontsSizeManager.s16.sp,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget ItemList(Interests item) {
    return InkWell(
      onTap: () {
        if (widget.loggedUser.userType != "CONSULTANT") {
          if (widget.job.interestsIds.contains(item.interestId))
            setState(() {
              widget.job.interests.remove(item);
              widget.job.interestsIds.remove(item.interestId);
            });
          else
            setState(() {
              widget.job.interests.add(item);
              widget.job.interestsIds.add(item.interestId);
            });
        }
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
          border: widget.job.interestsIds.contains(item.interestId)
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
}
