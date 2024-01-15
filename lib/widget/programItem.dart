import 'package:flutter/material.dart';
import 'package:jeras/screens/program/editProgramScreen.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../localization/localization_methods.dart';
import '../models/program.dart';
import '../models/user.dart';

class ProgramItem extends StatefulWidget {
  final Program program;
  final GroceryUser user;

  ProgramItem({required this.program, required this.user});

  @override
  State<ProgramItem> createState() => _ProgramItemState();
}

class _ProgramItemState extends State<ProgramItem> {
  @override
  Widget build(BuildContext context) {
    String lang = getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        if (widget.user.userType == "CONSULTANT")
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EditProgramScreen(
                      program: widget.program,
                    )),
          );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey,
                      spreadRadius: 0.0,
                      blurRadius: 2.0,
                      offset: Offset(0.0, 1.0),
                    )
                  ],
                  borderRadius: BorderRadius.circular(AppRadius.r25),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(AppPadding.p25)),
                  child: FadeInImage.assetNetwork(
                    height: size.height * AppSize.h0_15,
                    width: size.width *AppSize.w0_7,
                    placeholder: AssetsManager.lodeGif,
                    placeholderScale: 0.5,
                    imageErrorBuilder: (context, error, stackTrace) =>
                        Image.asset(AssetsManager.whiteJerasLogoIconPath,
                            width: AppSize.w70, height: AppSize.h70, fit: BoxFit.fill),
                    image: widget.program.image,
                    fit: BoxFit.cover,
                    fadeInDuration:
                        Duration(milliseconds: AppConstants.milliseconds250),
                    fadeInCurve: Curves.easeInOut,
                    fadeOutDuration:
                        Duration(milliseconds: AppConstants.milliseconds150),
                    fadeOutCurve: Curves.easeInOut,
                  ),
                ),
              ),
              PositionedDirectional(
                  top: AppPadding.p24.h,
                  start: 0,
                  child: Image.asset(
                    lang == "ar"
                        ? AssetsManager.arrow2
                        : AssetsManager.arrow1,
                    width: AppSize.w35.w,
                    height: AppSize.h72.h,
                    fit: BoxFit.scaleDown,
                  )),
            ],
          ),
          SizedBox(
            height: AppSize.h35,
          )
        ],
      ),
    );
  }
}
