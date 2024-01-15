import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/localization/localization_methods.dart';

import '../../models/Objections.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../screens/ObjectionDetailScreen.dart';

class ObjectionWidget extends StatelessWidget {
  final Size size;
  final Objections item;

  const ObjectionWidget({
    required this.size,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    String photoUrl = item.user.image!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ObjectionDetailsScreen(
              item: item,
            ),
          ),
        );
      },
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only(
            left: AppPadding.p5,
            right: AppPadding.p5,
            bottom: AppPadding.p10,
            top: AppPadding.p10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: AppSize.h50,
              width: AppSize.w50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 0),
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: photoUrl.isEmpty
                  ? Image.asset(
                      AssetsManager.whiteJerasLogoIconPath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.fill,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r100),
                      child: FadeInImage.assetNetwork(
                        placeholder: AssetsManager.lodeGif,
                        placeholderScale: 0.5,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset(AssetsManager.whiteJerasLogoIconPath,
                                width: AppSize.w50,
                                height: AppSize.h50,
                                fit: BoxFit.fill),
                        image: photoUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(
                            milliseconds: AppConstants.milliseconds250),
                        fadeInCurve: Curves.easeInOut,
                        fadeOutDuration: Duration(
                            milliseconds: AppConstants.milliseconds150),
                        fadeOutCurve: Curves.easeInOut,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: AppPadding.p5, right: AppPadding.p5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppSize.w0_3
                            : size.width * AppSize.w0_5,
                        child: Text(
                          item.user.name!,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontWeight: FontWeight.w100,
                            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s22 : AppFontsSizeManager.s12,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                      Text(
                        // date,
                        item.timestamp != null
                            ? '${dateFormat.format(item.timestamp.toDate())}'
                            : '..',
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s20 : AppFontsSizeManager.s10,
                          color: AppColors.grey,
                          fontWeight: FontWeight.normal,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_3
                        : size.width * AppSize.w0_5,
                    child: Text(
                      item.objection,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s20 : AppFontsSizeManager.s10,
                          color: AppColors.grey,
                          fontWeight: FontWeight.normal),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
