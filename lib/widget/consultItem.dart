import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/blocs/jitsi_meet/start_call_screen.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/screens/ConsultantDetailsScreen.dart';
import 'package:jeras/widget/component/textWidget.dart';
import 'package:jeras/widget/responsive.dart';

import '../Utils/styles.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../localization/localization_methods.dart';
import '../models/courses.dart';
import '../models/user.dart';
import 'component/TextButton.dart';

class ConsultItem extends StatefulWidget {
  Courses course;
  GroceryUser? user;
  GroceryUser consultant;

  ConsultItem({
    Key? key,
    required this.course,
    required this.user,
    required this.consultant,
  }) : super(key: key);

  @override
  State<ConsultItem> createState() => _ConsultItemState();
}

class _ConsultItemState extends State<ConsultItem> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double price =
        (double.parse(widget.consultant.price!) * widget.course.lessonNum);
    double discountPercentage = widget.course.discount! / 100;
    double discountAmount = discountPercentage * price;
    double finalPrice = price - discountAmount;

    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(
          horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppPadding.p139.w
              : AppPadding.p25.w,
          vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppPadding.p48.h
              : AppPadding.p20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.consultant.photoUrl == ""
              ? Container(
                  decoration: BoxDecoration(
                      color: AppColors.moveColor2,
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r50.w
                              : 30.r)),
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w91.w
                      : AppSize.w60.w,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h91.h
                      : AppSize.h50.h,
                  child: Icon(
                    Icons.person_outlined,
                    color: AppColors.pink,
                    size: AppSize.w30,
                  ),
                )
              : CircleAvatar(
                  radius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppRadius.r45.r
                      : AppRadius.r25.r,
                  backgroundColor: AppColors.moveColor2,
                  backgroundImage: NetworkImage(widget.consultant.photoUrl == ""
                      ? "https://icons.veryicon.com/png/o/internet--web/prejudice/user-128.png"
                      : "${widget.consultant.photoUrl}"),
                ),
          SizedBox(
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w22.w
                  : AppSize.w75.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Spacer(),
              SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h15.h
                      : 0),
              Container(
                width: size.width * AppSize.w0_3, //(kIsWeb||size.width >= 500)

                child: Text(
                  "${widget.consultant.name}",
                  style: Styles.getTextStyle(
                      color: AppColors.black,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s30.sp
                              : AppFontsSizeManager.s17.sp),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    color: AppColors.yellow,
                    size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w17
                        : AppSize.w16,
                  ),
                  SizedBox(
                    width: AppSize.w5.w,
                  ),
                  Text(
                    "${widget.consultant.rating}",
                    style: Styles.getTextStyle(
                        color:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppColors.grey2
                                : AppColors.black,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s20.sp
                                : AppFontsSizeManager.s16.sp),
                  ),
                ],
              ),
              // Spacer(),
              SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h15.h
                      : 0),
            ],
          ),
          Spacer(
            flex: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 2 : 1,
          ),
          Container(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h70.h
                : AppSize.h40.h,
            // color: Colors.red,
            child: Column(
              children: [
                Spacer(),
                widget.course.priceDisplay!
                    ? Text("${(finalPrice).toString()} \$",
                        style: Styles.getTextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s36.sp
                                : AppFontsSizeManager.s18_6.sp),
                        textAlign: TextAlign.center)
                    : SizedBox(),
                Spacer(),
              ],
            ),
          ),
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? SizedBox(
                  width: AppSize.w59.w,
                )
              : Spacer(),
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ConsultantDetailsScreen(
                          consoltantId: widget.consultant.uid!);
                    }));
                  },
                  child: Container(
                      height: AppSize.h82.h,
                      width: AppSize.w253.w,
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(123, 108, 150, 1),
                          borderRadius: BorderRadius.circular(AppRadius.r25.r)),
                      child: Center(
                        child: TextWidget(
                          text: getTranslated(context, "bookNow"),
                          color: AppColors.white,
                          size:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s21_3.sp,
                          family: getTranslated(context, "Ithra"),
                          weight: AppFontsWeightManager.bold300,
                          align: TextAlign.center,
                        ),
                      )),
                )
              : TextButton1(
                  onPress: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return ConsultantDetailsScreen(
                          consoltantId: widget.consultant.uid!);
                    }));
                  },
                  Padding: (kIsWeb || size.width >= 500) ? 10 : 7,
                  Padding2: (kIsWeb || size.width >= 500) ? 10 : 7,
                  ButtonBackground: Color.fromRGBO(123, 108, 150, 1),
                  Width: (kIsWeb || size.width >= 500) ? 253.w : 101.w,
                  Height: (kIsWeb || size.width >= 500) ? 82.h : 40.h,
                  Title: getTranslated(context, "bookNow"),
                  ButtonRadius: (kIsWeb || size.width >= 500) ? 19.r : 5.r,
                  TextSize: (kIsWeb || size.width >= 500) ? 34.sp : 18.6.sp,
                  TextFont: getTranslated(context, "Ithra"),
                  TextColor: AppColors.white,
                ),
//             InkWell(
//               onTap: () {
//                 // add here code of promocode
//                 if(widget.user != null && widget.user?.profileCompleted==true)
//                 {
//                   showDialog(
//                     barrierDismissible: false,
//                     context: context,
//                     builder: (context) {
//                       return promoCodeDialog(
//                         course: widget.course,
//                         user: widget.user!,
//                         consultant: widget.consultant,
//                       );
//                     },
//                   );
//
//                 }
//                 else
//                 {
//                   if (widget.user == null)
//                     Navigator.pushNamed(context, '/Register_Type');
//                   else  if (widget.user?.profileCompleted==false)
//                     {
//                       showDialog(context: context, builder: (context)=>
//                           DialogWidget(title: getTranslated(context, "confirmChangeType"), cancelPress: () {
//                             Navigator.pop(context);
//                           }, confirmPress: () {
//                             Navigator.pop(context);
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => UserAccountScreen(
//                                     user: widget.user!, firstLogged: false),
//                               ),
//                             );
//                           }, dialogType: 'confirm', conformText: getTranslated(context, 'yes'), cancelText: getTranslated(context, 'no'),));
//                     }
//                 }
//               },
//               child: Container(
//                 height: (kIsWeb||size.width >= 500)
//                     ?82.h:32.h,
//                 width: (kIsWeb||size.width >= 500)
//                     ?217.w:92.w,
//                 //padding: EdgeInsets.symmetric(horizontal: 20.w), p
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular((kIsWeb||size.width >= 500)
// ?41.r:5.r),
//                   color: AppColors.darkGreen2,
//                 ),
//                 child: Text(
//                   "${getTranslated(context, "book_now")}",
//                   style: Styles.getTextStyle(color: AppColors.white, fontSize: (kIsWeb||size.width >= 500)
// ?22.sp:16.sp),
//                 ),
//               ),
//             ),
          // CustomButton(width:70, height:26, title: getTranslated(context, "book_now"),style: Styles.getTextStyle(color: AppColors.white, fontSize: 9),
          // backgroundColor: AppColors.darkGreen, textColor: AppColors.white,onTap: () { })
        ],
      ),
    );
  }
}
