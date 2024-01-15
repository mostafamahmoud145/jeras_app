import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../screens/question/editQuestionScreen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../models/questions.dart';

class QuestionListItem extends StatefulWidget {
  final Questions question;
  final GroceryUser user;

  QuestionListItem({required this.question, required this.user});

  @override
  _QuestionListItemState createState() => _QuestionListItemState();
}

class _QuestionListItemState extends State<QuestionListItem>
    with SingleTickerProviderStateMixin {
  bool open = false;
  String lang = "ar";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w16.w
                        : 7,
                    decoration: BoxDecoration(
                      color: AppColors.pink,
                      borderRadius: BorderRadius.circular(AppRadius.r7),
                    ),
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h16.h
                        : AppSize.h7,
                  ),
                  SizedBox(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w15.w
                        : AppSize.w16.w,
                  ),
                  Container(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_4
                        : size.width * AppSize.w0_75,
                    child: InkWell(
                      onTap: () {
                        (widget.user.userType == "SUPPORT")
                            ? Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditQuestionScreen(
                                      questions: widget.question),
                                ),
                              )
                            : SizedBox();
                      },
                      child: Text(
                        lang == "ar"
                            ? widget.question.arQuestion
                            : widget.question.enQuestion,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black2,
                            fontWeight: AppFontsWeightManager.semiBold,
                            //fontFamily: getTranslated(context, "Montserrat"),
                            fontStyle: FontStyle.normal,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s36.sp
                                : AppFontsSizeManager.s21_3.sp),
                      ),
                    ),
                  ),
                ],
              ),
              InkWell(
                splashColor: Colors.white.withOpacity(0.5),
                onTap: () {
                  setState(() {
                    open = !open;
                  });
                },
                child: Icon(
                  open
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_left_rounded,
                  color: Colors.black.withOpacity(0.5),
                  size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w36.r
                      : AppSize.w20,
                ),
              ),
            ],
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h23.h
                : AppSize.h22_6.h,
          ),
          open
              ? Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            color: AppColors.pink,
                            width: 3,
                          ),
                          SizedBox(
                            width: 12.w,
                          ),
                          Expanded(
                            child: Text(
                              lang == "ar"
                                  ? widget.question.arAnswer
                                  : widget.question.enAnswer,
                              textAlign: TextAlign.start,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                              style: TextStyle(
                                color: AppColors.grey5,
                                fontWeight: AppFontsWeightManager.bold300,
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                fontStyle: FontStyle.normal,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s28.sp
                                    : AppFontsSizeManager.s16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    (widget.question.link == "")
                        ? SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: AppSize.h30,
                                width: AppSize.w30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.lightPink,
                                      blurRadius: 4.0,
                                      spreadRadius: 0.0,
                                      offset: Offset(0.0,
                                          1.0), // shadow direction: bottom right
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: InkWell(
                                    onTap: () async {
                                      var url = widget.question.link;
                                      if (!url.contains('http')) {
                                        url = 'https://$url';
                                      }
                                      await launch(url);
                                    },
                                    child: Icon(
                                      Icons.play_circle_outline,
                                      color: Theme.of(context).primaryColor,
                                      size: AppSize.w20,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: AppSize.w5,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    getTranslated(context, "watch"),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: AppColors.pink,
                                      fontSize: AppFontsSizeManager.s10,
                                      fontWeight: AppFontsWeightManager.bold300,
                                    ),
                                  ),
                                  Text(
                                    getTranslated(context, "explain"),
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: AppColors.pink,
                                      fontSize: AppFontsSizeManager.s10,
                                      fontWeight: AppFontsWeightManager.bold300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ],
                )
              : SizedBox(),
          SizedBox(
            height: AppSize.h10,
          ),
        ],
      ),
    );
  }
}
