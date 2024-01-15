import 'package:flutter/material.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../localization/localization_methods.dart';
import '../widget/playVideoWidget.dart';

// Construct Dots Indicator

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  // declare and initizlize the page controller
  final PageController _pageController = PageController(initialPage: 0);

  // the index of the current page
  int _activePage = 0;

  // this list holds all the pages
  // all of them are constructed in the very end of this file for readability
  final List<Widget> _pages = [
    const PageOne(),
    const PageTwo(),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _activePage = page;
              });
            },
            itemCount: _pages.length,
            itemBuilder: (BuildContext context, int index) {
              return _pages[index % _pages.length];
            },
          ),
          // Display the prevButton
          Visibility(
            visible: _activePage == 1,
            child: getTranslated(context, "lang") == "ar"
                ? Positioned(top: AppPadding.p50, right: AppPadding.p30, child: prevButton())
                : Positioned(top: AppPadding.p50, left: AppPadding.p30, child: prevButton()),
          ),
          // Display the nextButton
          Visibility(
            visible: _activePage == 0,
            child: getTranslated(context, "lang") == "ar"
                ? Positioned(top: AppPadding.p50, left: AppPadding.p30, child: nextButton())
                : Positioned(top: AppPadding.p50, right: AppPadding.p30, child: nextButton()),
          ),
          // Display the top login
          // Visibility(visible: _activePage==1,child:Positioned(
          //     top: 40,
          //     left: 20,
          //     child: loginAsGuestButton()
          // ),),
          // Display the bottomImage
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: AppSize.h120.h,
            child: Container(
              color: AppColors.primaryColor,
              child: Image.asset(
                AssetsManager.tail,
                fit: BoxFit.fitWidth,
                width: size.width.w,
                height: AppSize.h100.h,
              ),
            ),
          ),
          // Display the dots indicator
          Positioned(
            bottom: AppPadding.p170,
            left: 0,
            right: 0,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                    _pages.length,
                    (index) => Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p3.w),
                          child: InkWell(
                            onTap: () {
                              _pageController.animateToPage(index,
                                  duration: const Duration(
                                      milliseconds:
                                          AppConstants.milliseconds300),
                                  curve: Curves.easeIn);
                            },
                            child: _activePage == index
                                ? Container(
                                    width: AppSize.w22.w,
                                    height: AppSize.h8.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius:
                                          BorderRadius.circular(AppRadius.r7.r),
                                    ),
                                  )
                                : CircleAvatar(
                                    radius: AppRadius.r5,
                                    backgroundColor:
                                        AppColors.linear6),
                          ),
                        )),
              ),
            ),
          ),
          Visibility(
            visible: _activePage == 1,
            child: Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppPadding.p70.w),
                    child: loginButton())),
          ),
          // Display the top login
          Visibility(
            visible: _activePage == 1,
            child: Positioned(
                bottom: 60,
                right: 0,
                left: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "ــ",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.white,
                        fontSize: (MediaQuery.of(context).size.width >= 500)
                            ? AppFontsSizeManager.s26_6.sp
                            : AppFontsSizeManager.s21.sp,
                        fontWeight: AppFontsWeightManager.semiBold,
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w5.w,
                    ),
                    loginAsGuestButton(),
                    SizedBox(
                      width: AppSize.w5.w,
                    ),
                    Text(
                      "ــ",
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'fontFamily'),
                        color: AppColors.white,
                        fontSize: (MediaQuery.of(context).size.width >= 500)
                            ? AppFontsSizeManager.s26_6.sp
                            : AppFontsSizeManager.s21.sp,
                        fontWeight: AppFontsWeightManager.semiBold,
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  prevButton() {
    return InkWell(
      onTap: () {
        //Navigator.pop(context);
        _pageController.animateToPage(0,
            duration: Duration(milliseconds: AppConstants.milliseconds400),
            curve: Curves.easeIn);
      },
      child: getTranslated(context, "lang") == "ar"
          ? Row(
              children: [
                Image.asset(
                  AssetsManager.whiteArrowRight,
                  width: AppSize.w20.w,
                  height: AppSize.h15.h,
                ),
                SizedBox(
                  width: AppSize.w5.w,
                ),
                Text(
                  getTranslated(context, "prev"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.white,
                    fontSize: (MediaQuery.of(context).size.width >= 500)
                        ? AppFontsSizeManager.s26.sp
                        : AppFontsSizeManager.s21.sp,
                    fontWeight: AppFontsWeightManager.semiBold,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Image.asset(
                  AssetsManager.whiteArrowLeft,
                  width: AppSize.w20.w,
                  height: AppSize.h15.h,
                ),
                SizedBox(
                  width: AppSize.w5.w,
                ),
                Text(
                  getTranslated(context, "prev"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'fontFamily'),
                    color: AppColors.white,
                    fontSize: (MediaQuery.of(context).size.width >= 500)
                        ? AppFontsSizeManager.s26.sp
                        : AppFontsSizeManager.s21.sp,
                    fontWeight: AppFontsWeightManager.semiBold,
                  ),
                ),
              ],
            ),
    );
  }

  nextButton() {
    return InkWell(
      onTap: () {
        //Navigator.popAndPushNamed(context, '/home');
        _pageController.animateToPage(1,
            duration: Duration(milliseconds: AppConstants.milliseconds400),
            curve: Curves.easeIn);
      },
      child: getTranslated(context, "lang") == "ar"
          ? Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "next"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.white,
                    fontSize: (MediaQuery.of(context).size.width >= 500)
                        ? AppFontsSizeManager.s26_6.sp
                        : AppFontsSizeManager.s21.sp,
                    fontWeight: AppFontsWeightManager.semiBold,
                  ),
                ),
                SizedBox(
                  width: AppSize.w5.w,
                ),
                Image.asset(
                  AssetsManager.whiteArrowLeft,
                  width: (MediaQuery.of(context).size.width >= 500)
                      ? AppSize.w35.w
                      : AppSize.w28.w,
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "next"),
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, 'fontFamily'),
                    color: AppColors.white,
                    fontSize: (MediaQuery.of(context).size.width >= 500)
                        ? AppFontsSizeManager.s26_6.sp
                        : AppFontsSizeManager.s21.sp,
                    fontWeight: AppFontsWeightManager.semiBold,
                  ),
                ),
                SizedBox(
                  width: AppSize.w5.w,
                ),
                Image.asset(
                  AssetsManager.whiteArrowRight,
                  width: AppSize.w20.w,
                  height: AppSize.h15.h,
                ),
              ],
            ),
    );
  }

  loginAsGuestButton() {
    return InkWell(
      onTap: () {
        //Navigator.popAndPushNamed(context, '/Register_Type');
        Navigator.popAndPushNamed(context, '/home');
      },
      child: Text(
        getTranslated(context, "loginAsGuest"),
        textAlign: TextAlign.start,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        maxLines: 1,
        style: TextStyle(
          fontFamily: getTranslated(context, 'fontFamily'),
          color: AppColors.white,
          fontSize: (MediaQuery.of(context).size.width >= 500)
              ? AppFontsSizeManager.s26_6.sp
              : AppFontsSizeManager.s21.sp,
          fontWeight: AppFontsWeightManager.semiBold,
        ),
      ),
    );
  }

  loginButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          padding: EdgeInsets.symmetric(vertical: AppPadding.p10.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r7.r), // <-- Radius
          )),

      onPressed: (){Navigator.popAndPushNamed(context, '/Register_Type');},child: Text(getTranslated(context, "login"),style: TextStyle(fontFamily: getTranslated(context, "Ithra"),color:Color.fromRGBO(123 ,108 ,150,1)),),);
    // InkWell(onTap: (){
    //   Navigator.popAndPushNamed(context, '/Register_Type');
    // },
    //   child:  Text(
    //     getTranslated(context, "login"),
    //     textAlign: TextAlign.start,
    //     overflow: TextOverflow.ellipsis,
    //     softWrap: false,
    //     maxLines: 1,
    //     style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
    //       color: Colors.white,
    //       fontSize: AppFontsSizeManager.s15,
    //       fontWeight: AppFontsWeightManager.semiBold,
    //     ),
    //   ),
    //
    // );
  }
}

// Page One
class PageOne extends StatelessWidget {
  const PageOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              child: PlayVideoWidget(
            url:
                "https://firebasestorage.googleapis.com/v0/b/dream-43bb8.appspot.com/o/files%2F6ac7c88a-6ef0-4a04-8ad9-dd8ec85177b6?alt=media&token=e9cd6c68-1cb5-4101-8a97-23760db14ad1",
          )),
          SizedBox(
            height: 20.h,
          ),
          Text(
            getTranslated(context, "app"),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'bukra',
              color: AppColors.white,
              fontSize:
                  (MediaQuery.of(context).size.width >= 500) ? AppFontsSizeManager.s38.sp : AppFontsSizeManager.s30.sp,
              fontWeight: AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: AppSize.h10.h,
          ),
          Text(
            getTranslated(context, "appText"),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 15,
            style: TextStyle(
              fontFamily: getTranslated(context, 'fontFamily'),
              color: AppColors.white,
              fontSize:
                  (MediaQuery.of(context).size.width >= 500) ? AppFontsSizeManager.s26.sp : AppFontsSizeManager.s21.sp,
              fontWeight: AppFontsWeightManager.bold300,
            ),
          ),
        ],
      ),
    );
  }
}

// Page Two
class PageTwo extends StatelessWidget {
  const PageTwo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p10),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/applicationIcons/boardImage.png',
            height: (MediaQuery.of(context).size.width >= 500) ? AppSize.h500.r : AppSize.h300.r,
            width: (MediaQuery.of(context).size.width >= 500) ? AppSize.w500.r : AppSize.w300.r,
          ),
          SizedBox(
            height: AppSize.h20.h,
          ),
          Text(
            getTranslated(context, "benefits"),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 1,
            style: TextStyle(
              fontFamily: 'bukra',
              color: AppColors.white,
              fontSize:
                  (MediaQuery.of(context).size.width >= 500) ? AppFontsSizeManager.s38.sp : AppFontsSizeManager.s30.sp,
              fontWeight: AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: AppSize.h10.h,
          ),
          Text(
            getTranslated(context, "benefitsText"),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            softWrap: false,
            maxLines: 15,
            style: TextStyle( fontFamily: getTranslated(context, "Ithra"),
              color: Colors.white,
              fontSize:
                  (MediaQuery.of(context).size.width >= 500) ? AppFontsSizeManager.s26_6.sp : AppFontsSizeManager.s21.sp,
              fontWeight: AppFontsWeightManager.bold300,
            ),
          ),
        ],
      ),
    );
  }
}

// Page Three
class PageThree extends StatelessWidget {
  const PageThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        color: Colors.blue,
        child: Text(
          'Blue Page',
          style: TextStyle(fontSize: AppFontsSizeManager.s50.sp, color: Colors.white),
        ));
  }
}
