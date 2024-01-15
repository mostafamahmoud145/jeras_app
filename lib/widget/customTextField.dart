import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_fonts.dart';

// ignore: must_be_immutable
class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final bool? obscure;
  final bool? readOnly;
  final String? hint, initialValue;
  final Color? backGroundColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final int? maxLine;
  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final bool? enable, isDense;
  bool iscenter = false;
  final Color? borderColor;
  final double? borderRadiusValue, width, height;
  final EdgeInsets? insidePadding;
  final Widget? prefixIcon, suffixIcon;
  final void Function(String)? onchange;
  final void Function(String?)? onsave;
  final Function()? onSuffixTap;
  final void Function()? onTap;
  final List<TextInputFormatter>? formatter;
  final TextInputAction? textInputAction;

  CustomTextFieldWidget({
    Key? key,
    this.isDense,
    this.style,
    this.onchange,
    this.insidePadding,
    this.validator,
    this.maxLine,
    this.hint,
    this.backGroundColor,
    this.controller,
    this.initialValue,
    this.obscure = false,
    this.enable = true,
    this.readOnly = false,
    this.iscenter = false,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.borderColor,
    this.borderRadiusValue,
    this.prefixIcon,
    this.width,
    this.hintStyle,
    this.suffixIcon,
    this.onSuffixTap,
    this.height,
    this.onTap,
    this.formatter,
    this.onsave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: width ?? double.infinity,
       height: height ?? 52.h,
      child: TextFormField(
        // cursorHeight: 20.h,
        readOnly: readOnly ?? false,
        textAlignVertical: TextAlignVertical.center,
        validator: validator,
        textAlign: iscenter ? TextAlign.center : TextAlign.start,
        onTap: () => onTap,
        enabled: enable,
        inputFormatters: formatter ?? [],
        obscureText: obscure ?? false,
        obscuringCharacter: obscure != null ? "*" : '',
        textInputAction: textInputAction,
        controller: controller,
        onSaved: onsave,
        decoration: InputDecoration(
          errorStyle: const TextStyle(height: 0),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 10),
              borderSide:
              BorderSide(color: borderColor ?? AppColors.black1, width: .5)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 10),
              borderSide:
              BorderSide(color: borderColor ?? const Color(0xff555555),  width: .5)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 10),
              borderSide:
              BorderSide(color: borderColor ?? AppColors.black1, width: .5)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 10),
              borderSide:
              BorderSide(color: borderColor ?? const Color(0xFF555555),  width: .5)),
          isDense: isDense ?? false,
          prefixIconConstraints: BoxConstraints(
              minWidth: prefixIcon == null ? 0 : 35, maxHeight: 20),
          suffixIconConstraints: BoxConstraints(
              minWidth: suffixIcon == null ? 0 : 45, maxHeight: 40),
          contentPadding: insidePadding ?? EdgeInsets.symmetric(vertical: 6),
          fillColor: backGroundColor,
          filled: backGroundColor != null,
          hintText: hint,
          prefixIcon: prefixIcon == null
              ? SizedBox(
            width: 10,
          )
              : SizedBox(width: 30, child: prefixIcon),
          suffixIcon: suffixIcon == null
              ? SizedBox(width: 5)
              : InkWell(
            onTap: onSuffixTap,
            child: SizedBox(width: 30, child: suffixIcon),
          ),
          hintStyle: hintStyle ??
              TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFA5A5A5),
                  fontWeight: FontWeight.w400),
        ),
        onChanged: onchange,
        initialValue: initialValue,
        textCapitalization: TextCapitalization.words,
        maxLines: maxLine ?? 1,
        keyboardType: textInputType,
        style: style ??
            TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.black1,
            ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CustomTextFieldWidgetHome extends StatelessWidget {
  final TextEditingController? controller;
  final bool? obscure;
  final bool? readOnly;
  final String? hint;
  final Color? backGroundColor;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final int? maxLine;
  final String? Function(String?)? validator;
  final TextInputType? textInputType;
  final bool? enable, isDense;
  final Color? borderColor;
  final double? borderRadiusValue, width, height;
  final EdgeInsets? insidePadding;
  final Widget? prefixIcon, suffixIcon;
  final void Function(String)? onchange;
  final void Function(String)? onFieldSubmitted;
  final Function()? onSuffixTap;
  final void Function()? onTap;
  final List<TextInputFormatter>? formatter;
  final TextInputAction? textInputAction;

  const CustomTextFieldWidgetHome({
    Key? key,
    this.isDense,
    this.style,
    this.onchange,
    this.insidePadding,
    this.validator,
    this.maxLine,
    this.hint,
    this.backGroundColor,
    this.controller,
    this.obscure = false,
    this.enable = true,
    this.readOnly = false,
    this.textInputType = TextInputType.text,
    this.textInputAction,
    this.borderColor,
    this.borderRadiusValue,
    this.prefixIcon,
    this.width,
    this.hintStyle,
    this.suffixIcon,
    this.onSuffixTap,
    this.height,
    this.onTap,
    this.formatter,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 350,
      height: height ?? 52,
      child: TextFormField(
        textDirection: TextDirection.rtl,
        // cursorHeight: 20.h,
        readOnly: readOnly ?? false,
        textAlignVertical: TextAlignVertical.center,
        validator: validator,
        onTap: () => onTap,
        enabled: enable,
        inputFormatters: formatter ?? [],
        obscureText: obscure ?? false,
        obscuringCharacter: obscure != null ? "*" : '',
        textInputAction: textInputAction,
        controller: controller,
        onFieldSubmitted: onFieldSubmitted,
        // autofocus: true,
        decoration: InputDecoration(
          errorStyle: const TextStyle(height: 0),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30),
              borderSide:
              BorderSide(color: borderColor ?? AppColors.black1)),
          disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30),
              borderSide:
              BorderSide(color: borderColor ?? const Color(0xff555555))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30),
              borderSide:
              BorderSide(color: borderColor ?? AppColors.black1)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadiusValue ?? 30),
              borderSide:
              BorderSide(color: borderColor ?? const Color(0xFF555555))),
          isDense: isDense ?? false,
          prefixIconConstraints: BoxConstraints(
              minWidth: prefixIcon == null ? 0 : 35, maxHeight: 20),
          suffixIconConstraints: BoxConstraints(
              minWidth: suffixIcon == null ? 0 : 45, maxHeight: 40),
          //contentPadding: insidePadding ?? EdgeInsets.symmetric(vertical: 6),
          fillColor: backGroundColor,
          filled: backGroundColor != null,
          hintText: hint,
          prefixIcon: prefixIcon == null
              ? SizedBox(width: 10)
              : SizedBox(width: 30, child: prefixIcon),
          suffixIcon: suffixIcon == null
              ? SizedBox(width: 5)
              : InkWell(
            onTap: onSuffixTap,
            child: SizedBox(width: 30, child: suffixIcon),
          ),
          hintStyle: hintStyle ??
              TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8A8B8D),
                  fontWeight: FontWeight.w400),
        ),
        onChanged: onchange,
        textCapitalization: TextCapitalization.words,
        maxLines: maxLine ?? 1,
        keyboardType: textInputType,
        style: style ??
            TextStyle(
              fontSize: AppFontsSizeManager.s14,
              fontWeight: AppFontsWeightManager.semiBold,
              color: AppColors.black1,
            ),
      ),
    );
  }
}
