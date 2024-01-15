import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_picker/country_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/models/courses.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import '../config/app_values.dart';
import '../config/paths.dart';
import '../models/interests.dart';
import '../models/user.dart';
import '../screens/searchResultScreen.dart';
import 'component/textWidget.dart';

// ignore: must_be_immutable
class SearchWidget extends StatefulWidget {
  GroceryUser? loggedUser;

  SearchWidget({Key? key, this.loggedUser}) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late Size size;
  String countryText = "..", selectedCountry = "-1";
  RangeValues _priceValuess = RangeValues(1, 500.0);
  SfRangeValues _ageValues = SfRangeValues(1, 100.0);
  late String _genderValue = "all";
  String dependabilityValue = "";
  late List<String> _genderList, _dependabilityList;
  int minPrice = 1, maxPrice = 500, minAge = 1, maxAge = 100;
  bool loadInterests = true, searching = false, loadCourses = true;
  List<Interests> interestList = [];
  String selectedInterestID = "";
  String selectedCourseID = "";
  List<Courses> coursesList = [];
  List<Widget> interestWidgets = [];
  List<Widget> coursestWidgets = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    getInterests();
    getcourses();
    _genderList = [
      getTranslated(context, "all"),
      getTranslated(context, "male"),
      getTranslated(context, "female"),
    ];
    _dependabilityList = [
      getTranslated(context, "teacher"),
      getTranslated(context, "supervisor"),
      getTranslated(context, "follow"),
      getTranslated(context, "planning"),
    ];
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? size.width * AppPadding.p0_010
            : AppPadding.p32.h,
        right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? size.width * AppPadding.p0_010
            : AppPadding.p32.w,
        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? size.width * AppPadding.p0_010
            : AppPadding.p32.w,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 0,
              ),
              Container(
                width: AppSize.w48.w,
                height: AppSize.h6_6.h,
                decoration: BoxDecoration(
                  color: AppColors.grey62,
                  borderRadius: BorderRadius.circular(AppRadius.r3_3.r),
                ),
              ),
              InkWell(
                onTap: Navigator.of(context).pop,
                child: Container(
                  height: AppSize.h32.h,
                  width: AppSize.w32.w,
                  child: Icon(
                    Icons.close_outlined,
                    // size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    //     ? AppFontsSizeManager.s25
                    //     : AppFontsSizeManager.s15,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: AppSize.h28.h,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextWidget(
                        text: getTranslated(context, "filter"),
                        color: AppColors.black1,
                        size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s45_3.sp
                            : AppFontsSizeManager.s26.sp,
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                      ),
                      InkWell(
                        onTap: () {
                          search();
                        },
                        child: Container(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h46.h
                                  : AppSize.h45_3.h,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w445.w
                                  : AppSize.w137_3.w,
                          padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p10.w),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r5_3.r),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color.fromRGBO(174, 156, 206, 1.0),
                                Theme.of(context).primaryColor,
                              ],
                              stops: [0.0, 1.0],
                            ),
                          ),
                          child: Center(
                            child: searching
                                ? CircularProgressIndicator(
                                    color: AppColors.white,
                                  )
                                : Text(
                                    getTranslated(context, "filter"),
                                    style: TextStyle(
                                      fontFamily: 'NotoKufiArabic-SemiBold',
                                      color: AppColors.white,
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s25.sp
                                          : AppFontsSizeManager.s21_3.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h40.h
                        : AppSize.h28.h,
                  ),
                  countrySearchWidget(size),
                  SizedBox(
                    height: AppSize.h21_3.h,
                  ),
                  priceWidget(size),
                  //SizedBox(height: AppSize.h20,),
                  //ageWidget(size),
                  SizedBox(
                    height: AppSize.h21_3.h,
                  ),
                  genderWidget(size),
                  SizedBox(
                    height: AppSize.h21_3.h,
                  ),
                  dependabilityWidget(size),
                  SizedBox(
                    height: AppSize.h21_3.h,
                  ),
                  coursesFilterWiget(size),
                  SizedBox(
                    height: AppSize.h20.h,
                  ),
                  interestWiget(size),
                  SizedBox(
                    height: AppSize.h20.h,
                  ),
                  //search button
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  search() async {
    setState(() {
      searching = true;
    });
    Query courseQuery = FirebaseFirestore.instance
        .collection('Courses')
        .where('lang', isEqualTo: getTranslated(context, "lang"))
        .where('active', isEqualTo: true);
    Query query = FirebaseFirestore.instance
        .collection('Users')
        .where('accountStatus', isEqualTo: "Active")
        .where('isEnglish',
            isEqualTo: getTranslated(context, "lang") == "en" ? true : false);
    //filter country
    if (selectedCountry != "-1") {
      query = query.where('countryISOCode', isEqualTo: selectedCountry);
    }
    //filter gender
    if (_genderValue != "all" &&
        _genderValue != getTranslated(context, 'all')) {
      if (_genderValue == getTranslated(context, "male"))
        query = query.where('gender', isEqualTo: "male");
      else
        query = query.where('gender', isEqualTo: "female");
    }
    //filter title
    if (dependabilityValue != "teacher" &&
        dependabilityValue != getTranslated(context, 'teacher')) {
      if (dependabilityValue == "") {
        query = query.where('userType', isEqualTo: 'CONSULTANT');
      } else if (dependabilityValue == getTranslated(context, "supervisor"))
        query = query.where('userType', isEqualTo: "supervisor");
      else if (dependabilityValue == getTranslated(context, "follow"))
        query = query.where('userType', isEqualTo: "follow");
      else
        query = query.where('userType', isEqualTo: "planning");
    } else {
      query = query.where('userType', isEqualTo: 'CONSULTANT');
    }
    //filter interest
    //key for all interest "9aec45f2-384f-4f77-9a31-d320619d57d7"
    if (selectedInterestID != "" &&
        selectedInterestID != "9aec45f2-384f-4f77-9a31-d320619d57d7") {
      List<String> selected = [selectedInterestID];

      query = query.where("interestListIds", arrayContainsAny: selected);
      courseQuery =
          courseQuery.where("interestListIds", arrayContainsAny: selected);
    }

    // Filter Courses
    if (selectedCourseID != "") {
      List<String> courseIds = [selectedCourseID];
      courseQuery = courseQuery.where("courseId", whereIn: courseIds);
      print("=========================/");
    }
    //filter price
    QuerySnapshot querySnapshot = await query.get();
    List<GroceryUser> list = List<GroceryUser>.from(
      querySnapshot.docs.map(
        (snapshot) => GroceryUser.fromMap(snapshot.data() as Map),
      ),
    );

    List<GroceryUser> consultsPriseFillter = [];
    for (int x = 0; x < list.length; x++) {
      if (minPrice <= int.parse(list[x].price!) &&
          int.parse(list[x].price!) <= maxPrice) {
        consultsPriseFillter.add(list[x]);
      }
    }
    // Filter Courses
    if (selectedCourseID != "") {
      for (var i = 0; i < consultsPriseFillter.length; i++) {
        var coursesListIds = consultsPriseFillter[i].courses;
        if (coursesListIds != null && coursesListIds.isNotEmpty) {
          var foundIndex = coursesListIds.indexOf(selectedCourseID);
          if (foundIndex == -1) {
            consultsPriseFillter.removeAt(i);
            i--;
          }
        } else {
          consultsPriseFillter.removeAt(i);
          i--;
        }
      }
    }

    List<String> consultsIds =
        consultsPriseFillter.map((user) => user.uid!).toList();
    List<String> allconsultsIds = [];
    allconsultsIds.addAll(consultsIds);

    if (allconsultsIds.isNotEmpty) {
      query = query.where('uid', isEqualTo: allconsultsIds[0]);
    } else {
      query = query.where('uid', isEqualTo: []);
    }

    setState(() {
      searching = false;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultScreen(
          consultsFillter: consultsPriseFillter,
          loggedUser: widget.loggedUser,
          consultsQuery: query,
          coursesQuery: courseQuery,
        ),
      ),
    );
  }

  countrySearchWidget(Size size) {
    return InkWell(
      onTap: () {
        showCountryPicker(
          showPhoneCode: true,
          showWorldWide: false,
          context: context,
          onSelect: (Country country) {
            setState(() {
              countryText = country.displayName;
              selectedCountry = country.countryCode;
            });
          },
          countryListTheme: CountryListThemeData(
            searchTextFaildPadding: EdgeInsets.only(
              top: AppPadding.p25_3.h,
              bottom: AppPadding.p38.h,
              right: AppPadding.p30_5.w,
              left: AppPadding.p30_5.w,
            ),
            textStylenum: TextStyle(
              fontFamily: 'NotoKufiArabic-SemiBold',
              fontWeight: FontWeight.bold,
              fontSize: AppFontsSizeManager.s21_3.sp,
              color: Color.fromRGBO(147, 147, 147, 1.0),
            ),
            dividerWidget: Padding(
              padding: EdgeInsets.symmetric(vertical: AppPadding.p26_5.h),
              child: Container(
                width: AppSize.w513.w,
                height: 1.0,
                color: AppColors.grey2,
              ),
            ),
            bottomSheetTopWidget: Padding(
              padding: EdgeInsets.only(
                  top: AppPadding.p16.h, bottom: AppPadding.p10_6.h),
              child: Container(
                width: AppSize.w48.w,
                height: AppSize.h6_6.h,
                decoration: BoxDecoration(
                  color: AppColors.grey62,
                  borderRadius: BorderRadius.circular(AppRadius.r3_3.r),
                ),
              ),
            ),
            bottomSheetHeight: size.height * .75,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.r32.r),
              topRight: Radius.circular(AppRadius.r32.r),
            ),
            inputDecoration: InputDecoration(
              fillColor: AppColors.grey4,
              filled: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                  horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppPadding.p10
                      : AppPadding.p5,
                  vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppPadding.p20
                      : AppPadding.p20.h),
              prefixIcon: IconButton(
                padding: EdgeInsets.only(
                    right: AppPadding.p21_3.w, left: AppPadding.p16.w),
                onPressed: () {},
                icon: SvgPicture.asset(
                  AssetsManager.searchIconPath,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w30.w
                      : AppSize.w26_6.w,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h30.h
                      : AppSize.h26_6.h,
                ),
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
              ),
              hintText: getTranslated(context, "chooseCountry"),
              hintStyle: TextStyle(
                fontFamily: "NotoKufiArabic-Regular",
                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppFontsSizeManager.s25
                    : AppFontsSizeManager.s18_6.sp,
                color: AppColors.grey_dark,
                fontWeight: FontWeight.w400,
              ),
            ),

            textStyle: TextStyle(
              fontFamily: "NotoKufiArabic-SemiBold",
              color: AppColors.grey_dark,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s24.sp
                  : AppFontsSizeManager.s21_3.sp,
              fontWeight: FontWeight.w600,
            ),
            // Optional. Styles the text in the search field
            searchTextStyle: TextStyle(
              fontFamily: "NotoKufiArabic-Regular",
              color: AppColors.grey_dark,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s25
                  : AppFontsSizeManager.s18_6.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
      child: Container(
        decoration: decoration(),
        padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p21_3.w, vertical: AppPadding.p20.h),
        height: AppSize.h58_6.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getTranslated(context, "chooseCountry"),
              style: TextStyle(
                fontFamily: "NotoKufiArabic-Regular",
                color: AppColors.grey_dark,
                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppFontsSizeManager.s24.sp
                    : AppFontsSizeManager.s16.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppSize.w16,
              color: AppColors.primaryColor,
            )
          ],
        ),
      ),
    );
  }

  priceWidget(Size size) {
    return Container(
        // height: AppSize.h120.h,
        decoration: decoration(),
        padding: EdgeInsets.symmetric(
          horizontal: AppPadding.p16.w,
        ),
        child: Column(
          children: [
            SizedBox(height: AppSize.h21_3.h),
            SliderTheme(
              data: SliderTheme.of(context)
                  .copyWith(overlayShape: SliderComponentShape.noThumb),
              child: RangeSlider(
                activeColor: AppColors.linear4,
                min: 1.0,
                max: 500.0,
                values: _priceValuess,
                onChanged: (newRange) {
                  setState(() {
                    _priceValuess = newRange;
                    minPrice = _priceValuess.start.toInt();
                    maxPrice = _priceValuess.end.toInt();
                  });
                },
              ),
            ),
            SizedBox(height: AppSize.h10_6.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text(
                      'Minimum',
                      style: TextStyle(
                        fontFamily: 'Montserrat-Medium',
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s20.sp
                                : AppFontsSizeManager.s13_3.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey_dark,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h5_3.h,
                    ),
                    Text(
                      minPrice.toString() + " \$",
                      style: TextStyle(
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.normal,
                        color: AppColors.grey3,
                        letterSpacing: 0.07,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s20.sp
                                : AppFontsSizeManager.s13_3.sp,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Maximum",
                      style: TextStyle(
                        fontFamily: 'Montserrat-Medium',
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s20.sp
                                : AppFontsSizeManager.s13_3.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey_dark,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h5_3.h,
                    ),
                    Text(
                      maxPrice.toString() + " \$",
                      style: TextStyle(
                        fontFamily: 'Montserrat-Regular',
                        fontWeight: FontWeight.normal,
                        color: AppColors.grey3,
                        letterSpacing: 0.07,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s20.sp
                                : AppFontsSizeManager.s13_3.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: AppSize.h21_3.h)
          ],
        ));
  }

  ageWidget(Size size) {
    return Container(
        decoration: decoration(),
        padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p10.w, vertical: AppPadding.p20.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextWidget(
                  text: getTranslated(context, "ageCat"),
                  color: AppColors.linear7,
                  size: AppFontsSizeManager.s12.sp,
                  weight: FontWeight.w600,
                  align: TextAlign.center,
                ),
              ],
            ),
            SfRangeSlider(
              min: 1.0,
              max: 100.0,
              values: _ageValues,
              interval: 5,
              onChanged: (SfRangeValues newValues) {
                setState(() {
                  _ageValues = newValues;
                  minAge = _ageValues.start.toInt();
                  maxAge = _ageValues.end.toInt();
                });
              },
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      TextWidget(
                        text: "Min",
                        color: AppColors.linear7,
                        size: AppFontsSizeManager.s12.sp,
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                      ),
                      TextWidget(
                        text: minAge.toString(),
                        color: AppColors.linear7,
                        size: AppFontsSizeManager.s12.sp,
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      TextWidget(
                        text: "Max",
                        color: AppColors.linear7,
                        size: AppFontsSizeManager.s12.sp,
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                      ),
                      TextWidget(
                        text: maxAge.toString(),
                        color: AppColors.linear7,
                        size: AppFontsSizeManager.s12.sp,
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  Widget genderWidget(Size size) {
    return Container(
      decoration: decoration(),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.p16.w,
      ),
      height: AppSize.h77_3.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _buildRadioGender(_genderList[0]),
              _buildRadioGender(_genderList[1]),
              _buildRadioGender(_genderList[2]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGender(String option) {
    return Row(
      children: [
        Radio<String>(
          visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: option,
          autofocus: false,
          groupValue: _genderValue,
          onChanged: (value) {
            setState(() {
              _genderValue = value!;
            });
          },
          fillColor: MaterialStatePropertyAll(_genderValue == option
              ? AppColors.primaryColor
              : AppColors.greyColor),
        ),
        SizedBox(width: AppSize.w21_3.w),
        Text(
          option,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontFamily: "NotoKufiArabic-Regular",
            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppFontsSizeManager.s20.sp
                : AppFontsSizeManager.s18_6.sp,
            fontWeight: FontWeight.w400,
            color: _genderValue == option
                ? AppColors.primaryColor
                : Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  dependabilityWidget(Size) {
    return Container(
      decoration: decoration(),
      padding: EdgeInsets.symmetric(
        horizontal: AppPadding.p16.w,
      ),
      // height: AppSize.h245_3.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: AppSize.h26_6.h),
          Column(
            children: <Widget>[
              _buildRadiodependability(_dependabilityList[0]),
              SizedBox(height: AppSize.h21_3.h),
              _buildRadiodependability(_dependabilityList[1]),
              SizedBox(height: AppSize.h21_3.h),
              _buildRadiodependability(_dependabilityList[2]),
              SizedBox(height: AppSize.h21_3.h),
              _buildRadiodependability(_dependabilityList[3]),
            ],
          ),
          SizedBox(height: AppSize.h26_6.h),
        ],
      ),
    );
  }

  Widget _buildRadiodependability(String option) {
    return Row(
      children: [
        Radio<String>(
          visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          value: option,
          autofocus: false,
          groupValue: dependabilityValue,
          onChanged: (value) {
            setState(() {
              dependabilityValue = value!;
            });
          },
          fillColor: MaterialStatePropertyAll(dependabilityValue == option
              ? AppColors.primaryColor
              : AppColors.greyColor),
        ),
        SizedBox(
          width: AppSize.w10_6.w,
        ),
        Text(
          option,
          style: TextStyle(
            overflow: TextOverflow.ellipsis,
            fontFamily: "NotoKufiArabic-Regular",
            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppFontsSizeManager.s20.sp
                : AppFontsSizeManager.s18_6.sp,
            fontWeight: FontWeight.w400,
            color: dependabilityValue == option
                ? AppColors.primaryColor
                : Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  coursesFilterWiget(size) {
    return Container(
        decoration: decoration(),
        padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p16.w, vertical: AppPadding.p20.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "courses"),
                  style: TextStyle(
                    fontFamily: "NotoKufiArabic-SemiBold",
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s24.sp
                        : AppFontsSizeManager.s21_3.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppPadding.p21_3.h,
            ),
            loadCourses
                ? Center(
                    child: CircularProgressIndicator(
                    color: AppColors.pink,
                  ))
                : Container(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppPadding.p30_5.w),
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: AppPadding.p21_3.h,
                          crossAxisSpacing: AppPadding.p21_3.w,
                          childAspectRatio: 3.7027,
                          children: coursesList
                              .map(
                                (Item) => coursesItemList(Item),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
          ],
        ));
  }

  Widget coursesItemList(Courses item) {
    return InkWell(
      onTap: () {
        setState(() {
          if (selectedCourseID == item.courseId) {
            selectedCourseID = "";
          } else {
            selectedCourseID = item.courseId;
            print(selectedCourseID);
          }
        });
      },
      child: Container(
        width: AppSize.w212.w,
        height: AppSize.h49_3.h,
        decoration: selectedCourseID == item.courseId
            ? BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(5.0),
              )
            : BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.r6_5.r),
                border: Border.all(color: AppColors.primaryColor, width: 1.0),
              ),
        child: Center(
          child: Text(
            item.name,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoKufiArabic-SemiBold',
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s20.sp
                  : AppFontsSizeManager.s18_6.sp,
              color: selectedCourseID == item.courseId
                  ? Colors.white
                  : AppColors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }

  interestWiget(size) {
    return Container(
        decoration: decoration(),
        padding: EdgeInsets.symmetric(
            horizontal: AppPadding.p21_3.w, vertical: AppPadding.p20.h),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "specialties"),
                  style: TextStyle(
                    fontFamily: "NotoKufiArabic-SemiBold",
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s24.sp
                        : AppFontsSizeManager.s21_3.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            loadInterests
                ? Center(
                    child: CircularProgressIndicator(
                    color: AppColors.pink,
                  ))
                : Container(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: AppPadding.p21_3.h,
                        crossAxisSpacing: AppPadding.p21_3.w,
                        childAspectRatio: 106.0 / 36.0,
                        children: interestList
                            .map(
                              (Item) => ItemList(Item),
                            )
                            .toList(),
                      ),
                    ),
                  ),
          ],
        ));
  }

  Widget ItemList(Interests item) {
    return InkWell(
      onTap: () {
        setState(() {
          if (selectedInterestID == item.interestId) {
            selectedInterestID = "";
          } else {
            selectedInterestID = item.interestId;
            print(selectedInterestID);
          }
        });
      },
      child: Container(
        width: AppSize.w212.w,
        height: AppSize.h49_3.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        ),
        child: Center(
          child: Text(
            item.arName,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'NotoKufiArabic-SemiBold',
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s20.sp
                  : AppFontsSizeManager.s16.sp,
              color: selectedInterestID == item.interestId
                  ? AppColors.primaryColor
                  : AppColors.grey_dark,
            ),
          ),
        ),
      ),
    );
  }

  decoration() {
    return BoxDecoration(
      color: Color.fromRGBO(245, 243, 247, 1.0),
      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
    );
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
      for (int x = 0; x < list.length; x++) {
        interestWidgets.add(ItemList(list[x]));
      }
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

  getcourses() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Courses')
          .where('lang', isEqualTo: getTranslated(context, "lang"))
          .where('active', isEqualTo: true)
          .get();
      List<Courses> list = List<Courses>.from(
        querySnapshot.docs.map(
          (snapshot) => Courses.fromMap(snapshot.data() as Map),
        ),
      );
      for (int x = 0; x < list.length; x++) {
        coursestWidgets.add(coursesItemList(list[x]));
      }
      setState(() {
        coursesList = list;
        loadCourses = false;
      });
    } catch (e) {
      setState(() {
        loadCourses = false;
      });
    }
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
