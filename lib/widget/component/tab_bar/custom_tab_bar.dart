

import 'package:flutter/material.dart';

class CustomTabBar extends StatelessWidget {
  const CustomTabBar({Key? key,
    this.width= double.infinity,  this.height,  this.radius, required this.backgroundColor, required this.buttons, this.margin, this.padding,
  }) : super(key: key);

  final double? width;
  final double? height;
  final double? radius;
  final Color backgroundColor;
  final List<Widget> buttons;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;



  @override
  Widget build(BuildContext context) {
    return Container(
      width: width??0,
      height: height??0,
      alignment: Alignment.center,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(radius??0)),
        color: backgroundColor.withOpacity(0.05),
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: buttons
      ),
    );
  }
}




//
// class TabBarButton extends StatelessWidget {
//   const TabBarButton({
//     Key? key,
//     required this.isSelected,
//     required this.function,
//     this.activeColor= const AppColors.linear3,
//     this.notActiveColor= const Color.fromRGBO(250, 245, 249, 1),
//     this.radius= 10.5,
//     this.height= 41,
//     this.width= 153,
//     required this.text,
//     this.activeTextColor= AppColors.white,
//     this.notActiveTextColor= AppColors.pink,
//     this.textSize= 21,
//     this.textFont,
//   }) : super(key: key);
//
//   final bool isSelected;
//   final Function function;
//   final Color? activeColor;
//   final Color? notActiveColor;
//   final Color? activeTextColor;
//   final Color? notActiveTextColor;
//   final String text;
//   final double width;
//   final double height;
//   final double radius;
//   final double textSize;
//   final String? textFont;
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return textButton(
//         onPress: (){
//           function();
//         },
//         text: text,
//         width: width.w,
//         height: height.h,
//         buttonRadius: radius.r,
//         textSize: textSize.sp,
//         textfont: textFont,
//         textcolor: isSelected ? activeColor : notActiveColor,
//         icon: null,
//         Gradient_Color: isSelected ? activeColor : notActiveColor,
//         Gradient_Color2: isSelected ? activeColor : notActiveColor,
//     );
//   }
// }
