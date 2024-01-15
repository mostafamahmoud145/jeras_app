// import 'package:flutter/material.dart';
// import 'package:jeras/config/colors_file.dart';
// import 'package:jeras/methods/convert_pt_to_px.dart';
// import 'package:jeras/widget/component/IconButton.dart';
// import 'package:jeras/widget/responsive.dart';
// import '../config/app_values.dart';
// import '../config/assets_manager.dart';
// import '../localization/localization_methods.dart';

// class CustomBackButton extends StatelessWidget {
//   const CustomBackButton({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return IconButton1(
//       ButtonRadius: AppRadius.r10_6.r,
//       ButtonColor: AppColors.white,
//       IconWidth: 30,
//       Icon: getTranslated(context, "lang") == "ar"
//           ? AssetsManager.rightArrowIconPath
//           : AssetsManager.leftArrowIconPath,
//       IconColor: AppColors.linear2,
//       onPress: () {
//         Navigator.pop(context);
//       },
//       Width: convertPtToPx(AppSize.w38).w,
//       Height: convertPtToPx(AppSize.w38).w,
//     );
//   }
// }
