import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/app_constat.dart';

enum InputFormatType { textOnly, numbersOnly, textAndNumbers }

class TextFormFieldWidget extends StatelessWidget {
  TextFormFieldWidget(
      {required this.name,
      required this.controller,
      this.obscureText,
      this.hintText,
      this.icon,
      this.numbers,
      this.lines,
      this.TextSpace,
      this.keyboardType,
      this.maxLength,
      this.Width,
      this.Height,
      this.radius,
      this.padding,
      this.font,
      this.validator,
      //this.Height,
      this.labelFont});

  final TextEditingController controller;
  String? hintText;
  final String name;
  String? font, labelFont;
  final bool? obscureText;
  final String? icon;
  final int? lines;
  bool? numbers = false;
  final double? TextSpace, Width, Height, radius, padding;
  //final double? TextSpace, Width, Height;
  final String? Function(String?)? validator;
  final int? maxLength;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return (TextSpace == null)
        ? Container(
            width: Width,
            height: Height,
            child: TextFormField(
              inputFormatters: keyboardType == TextInputType.number
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : (keyboardType == TextInputType.text ||
                          keyboardType == TextInputType.multiline)
                      ? [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))]
                      : null,
              controller: controller,
              obscureText: obscureText == null ? false : obscureText!,
              textAlignVertical: TextAlignVertical.center,
              validator: validator,
              maxLength: this.maxLength,
              enableInteractiveSelection: true,
              style: TextStyle(
                  fontSize: 21.3.sp,
                  color: Colors.grey,
                  fontFamily: font ?? 'Ithralight'),
              maxLines: lines == null ? 1 : lines,
              textInputAction: lines == null
                  ? TextInputAction.done
                  : TextInputAction.newline,
              keyboardType: this.keyboardType,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintText: hintText,
                // contentPadding: EdgeInsets.all(
                //     (kIsWeb || size.width >= AppConstants.kIsWebValue)
                //         ? 20
                //         : 10),
                errorStyle: TextStyle(
                    fontFamily:
                        getTranslated(context, "Ithra"), // 'Montserrat',
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 32
                        : 18.6.sp,
                    color: AppColors.red,
                    fontWeight: FontWeight.normal),
                hintStyle: TextStyle(
                    fontFamily: getTranslated(context, "Ithralight"),
                    fontSize: 21.3.sp,
                    color: Colors.black54),
                prefixIcon: icon == null
                    ? null
                    : Image.asset(
                        'assets/icons/' + icon!,
                        width: 14,
                        height: 12,
                      ),
                prefixIconConstraints: BoxConstraints(
                  minWidth: 50.0,
                ),

                labelText: name,
                labelStyle: TextStyle(
                    fontFamily: labelFont ?? getTranslated(context, "Ithra"),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : AppFontsSizeManager.s21_3.sp,
                    color: AppColors.pink,
                    fontWeight: FontWeight.bold),
                enabledBorder: new OutlineInputBorder(
                  borderSide: BorderSide(
                      width: .5.w, color: Color.fromRGBO(158, 158, 158, 1)),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                focusedBorder: new OutlineInputBorder(
                  borderSide:
                      BorderSide(width: .5.w, color: AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                border: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromRGBO(175, 175, 175, 1)),
                  borderRadius:
                      BorderRadius.circular(radius ?? AppRadius.r10_6.r),
                ),
              ),
            ),
          )
        : Container(
            width: Width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: (kIsWeb || size.width >= 500) ? 25.sp : 21.3.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
                SizedBox(
                  height: TextSpace,
                ),
                TextFormField(
                  keyboardType: this.keyboardType,

                  inputFormatters: keyboardType == TextInputType.number
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : (keyboardType == TextInputType.text ||
                              keyboardType == TextInputType.multiline)
                          ? [
                              FilteringTextInputFormatter.deny(
                                  RegExp(r'[0-9 - ٠ - ٩ ]'))
                            ]
                          : null,
                  controller: controller,
                  obscureText: obscureText == null ? false : obscureText!,
                  textAlignVertical: TextAlignVertical.center,
                  validator: (String? val) {
                    if (val!.trim().isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                  enableInteractiveSelection: true,
                  style: TextStyle(
                      fontSize: 21.sp,
                      color: Colors.grey,
                      fontFamily: 'Ithralight'),
                  maxLines: lines == null ? 1 : lines,
                  textInputAction: lines == null
                      ? TextInputAction.done
                      : TextInputAction.newline,
                  // keyboardType: lines == null
                  //     ? TextInputType.text
                  //     : TextInputType.multiline,
                  decoration: InputDecoration(
                    hintText: hintText,
                    contentPadding: EdgeInsets.all(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? 20
                            : 10),
                    errorStyle: TextStyle(
                        fontFamily:
                            getTranslated(context, "Ithra"), // 'Montserrat',
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 32
                                : 21.3.sp,
                        color: AppColors.red,
                        fontWeight: FontWeight.normal),
                    hintStyle: TextStyle(
                        fontFamily: getTranslated(context, "Ithralight"),
                        fontSize: 21.3.sp,
                        color: Colors.black54),
                    prefixIcon: icon == null
                        ? null
                        : Image.asset(
                            'assets/icons/' + icon!,
                            width: 14,
                            height: 12,
                          ),
                    prefixIconConstraints: BoxConstraints(
                      minWidth: 50.0,
                    ),
                    enabledBorder: new OutlineInputBorder(
                      borderSide: BorderSide(
                          width: .5, color: Color.fromRGBO(158, 158, 158, 1)),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    focusedBorder: new OutlineInputBorder(
                      borderSide:
                          BorderSide(width: .5, color: AppColors.primaryColor),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromRGBO(158, 158, 158, 1)),
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
