import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/assets_manager.dart';

import '../../localization/localization_methods.dart';
import '../../models/UnorderedList.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import 'account_screen.dart';

class consultRuleScreen extends StatefulWidget {
  final GroceryUser user;
  final Video video;

  const consultRuleScreen({Key? key, required this.user, required this.video})
      : super(key: key);

  @override
  _consultRuleScreenState createState() => _consultRuleScreenState();
}

class _consultRuleScreenState extends State<consultRuleScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true, accept = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              // height: 80,
              // color: Colors.white,
              child: SafeArea(
                  child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p10,
                    right: AppPadding.p10,
                    top: 0.0,
                    bottom: AppPadding.p6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: AppSize.h35,
                      width: AppSize.w35,
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: SvgPicture.asset(
                            AssetsManager.rightArrowIconPath,
                            width: AppSize.w30,
                            height: AppSize.h30,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      getTranslated(context, "terms"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.grey,
                        fontSize: AppFontsSizeManager.s20,
                        fontWeight: AppFontsWeightManager.semiBold,
                      ),
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1,
                  width: size.width * AppSize.w0_9)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppRadius.r20),
              child: ListView(
                children: [
                  UnorderedList([
                    getTranslated(context, "rule1"),
                    getTranslated(context, "rule2"),
                    getTranslated(context, "rule3"),
                    getTranslated(context, "rule4"),
                    getTranslated(context, "rule5"),
                    getTranslated(context, "rule6")
                  ]),
                  SizedBox(
                    height: AppSize.h10,
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: accept,
                        onChanged: (value) {
                          setState(() {
                            accept = !accept;
                          });
                        },
                      ),
                      Text(
                        getTranslated(context, "agree"),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s18,
                          fontWeight: AppFontsWeightManager.bold500,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: AppSize.h20,
                  ),
                  accept == true
                      ? Center(
                          child: InkWell(
                            onTap: () {
                              confirmDialog(size);
                            },
                            child: Container(
                              width: size.width * AppSize.w0_6,
                              height: AppSize.h45,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r10),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.linear1,
                                      AppColors.linear2,
                                      AppColors.linear2,
                                    ],
                                  )),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "saveAndContinue"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.white,
                                    fontSize: AppFontsSizeManager.s18,
                                    letterSpacing:
                                        AppConstants.letterSpacing0_5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  confirmDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            top: AppPadding.p20,
            bottom: AppPadding.p10),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              getTranslated(context, "guarantee"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s15,
                fontWeight: FontWeight.bold,
                color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: AppSize.h15,
            ),
            Text(
              getTranslated(context, "guaranteeText"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s12,
                fontWeight: AppFontsWeightManager.bold500,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: AppSize.h5,
            ),
            Center(
              child: Container(
                width: size.width * AppSize.w0_6,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r10),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AccountScreen(
                          user: widget.user,
                          consultVideo: widget.video,
                        ),
                      ),
                    );
                  },
                  child: Text(
                    getTranslated(context, 'acceptIt'),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.white,
                      fontSize: AppFontsSizeManager.s13_5,
                      fontWeight: AppFontsWeightManager.bold500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
