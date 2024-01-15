import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/component/textWidget.dart';
import 'package:jeras/widget/custom_outlined_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../../../config/app_constat.dart';
import '../../../config/app_fonts.dart';
import '../../../config/app_values.dart';

class SearchBar1 extends StatelessWidget {
  const SearchBar1(
      {super.key,
      required this.onPress,
      required this.Title,
      this.Width,
      this.Height,
      required this.ButtonRadius,
      required this.TextSize,
      this.ButtonBackground,
      required this.TextFont,
      required this.TextColor,
      this.Icon,
      this.GradientColor,
      this.GradientColor2,
      this.IconSpace,
      this.IconColor,
      this.Direction,
      this.Padding2,
      this.IconWidth,
      this.IconHeight,
      this.Icon2,
      this.onPress2,
      this.suffixButton,
      this.Padding1,
      this.searchController,
      this.onPress3});

  final Function()? onPress, onPress2;
  final Function(String)? onPress3;

  final double? ButtonRadius;
  final Color? ButtonBackground;
  final double? Width;
  final double? Height;
  final String Title;

  final String? suffixButton;
  final String? TextFont;
  final double? TextSize;
  final Color? TextColor;
  final String? Icon, Icon2;

  ////
  final TextEditingController? searchController;

  final Color? GradientColor, GradientColor2;
  final TextDirection? Direction;
  final double? Padding1, Padding2;
  final double? IconSpace;
  final double? IconWidth;
  final double? IconHeight;
  final Color? IconColor;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return (suffixButton==null)?InkWell(
      onTap: onPress,
      child: Container(
          width: Width,
          height: Height,
          padding: EdgeInsets.symmetric(vertical: Padding1!.h??0, horizontal: Padding2!.w??0),
          decoration:
          BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(ButtonRadius??0)),
            border: CustomOulinedButton.outlineBorder(),
            color: ButtonBackground,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  //filter section
                  SvgPicture.asset(
                    Icon!,
                    width:IconWidth,
                    height: IconHeight
                  ),
                  SizedBox(width: IconSpace,),
                  TextWidget(text: Title, color: TextColor!,
                    size: TextSize!, weight: FontWeight.w500,
                    family:TextFont,align: TextAlign.start,),
                ],
              ),
              (Icon2!=null)?InkWell(
                onTap: onPress2,
                child: SvgPicture.asset(
                    Icon2!,
                    width:IconWidth,
                    height: IconHeight
                ),
              ):SizedBox(),



            ],
          ),),
    ): Container(
      width: Width,
      height: Height,
      padding: EdgeInsets.symmetric(vertical: Padding1!.h??0, horizontal: Padding2!.w??0),
      decoration:
      BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(ButtonRadius??0)),
        border: CustomOulinedButton.outlineBorder(),
        color: ButtonBackground,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            child: Center(
              child:  TextField(
                onChanged: (val) => onPress2,
                keyboardType: TextInputType.text,
                controller: searchController,
                textInputAction: TextInputAction.search,
                enableInteractiveSelection: true,
                readOnly: false,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s14_5.sp,
                   color: AppColors.black87,
                  letterSpacing: AppConstants.letterSpacing0_5,
                  fontWeight: FontWeight.w400,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 5.0.w
                      , vertical: 8.0.h),
                  prefixIcon: Container( width: AppSize.w10.w,
                    height: AppSize.h10.h,
                    child: Image.asset(
                      'assets/applicationIcons/searchImage.png',
                      color: AppColors.warmGrey,
                    ),
                  ),
                  border: InputBorder.none,
                  hintText: suffixButton!,// "Ask a question",,
                  hintStyle: TextStyle(
                    color: AppColors.warmGrey,
                    fontWeight: FontWeight.w400,
                    fontFamily: getTranslated(context, "Montserrat"),
                    fontStyle: FontStyle.normal,
                    fontSize: 15.0.sp,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),);
  }
}
