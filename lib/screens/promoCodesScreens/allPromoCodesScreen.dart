import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/promoCode.dart';
import '../../models/user.dart';
import '../../widget/promoListItem.dart';
import 'addPromoCodeScreen.dart';

class AllPromoCodeScreen extends StatefulWidget {
  @override
  _AllPromoCodeScreenState createState() => _AllPromoCodeScreenState();
}

class _AllPromoCodeScreenState extends State<AllPromoCodeScreen>
    with SingleTickerProviderStateMixin {
  late List<GroceryUser> activeList;
  final TextEditingController searchController = new TextEditingController();
  bool load = false;
  String name = "";
  late Query filterQuery;

  @override
  void initState() {
    super.initState();

    activeList = [];
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton1(
                            onPress: Navigator.of(context).pop,
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w97.w
                                : AppSize.w50_6.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 97.0.h
                                : 50.6.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 24.r
                                : 10.6.r,
                            IconWidth: 32.w,
                            IconHeight: 32.h,
                            IconColor: Theme.of(context).primaryColor,
                            Icon:
                                AssetsManager.blackArrowRightIconPath,
                            ButtonBackground: AppColors.white,
                          ),
                          SizedBox(width: AppSize.w10.w),
                          Text(
                            getTranslated(context, "proCodes"),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: AppFontsWeightManager.bold300,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s31.sp
                                  : AppFontsSizeManager.s15.sp,
                              color: AppColors.black2,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.6),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddPromoCodeScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: AppSize.w38.w,
                              height: AppSize.h35.h,
                              child: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.black,
                                size: AppSize.w24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          SizedBox(
            height: AppSize.h30.h,
          ),
          Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              separator: SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h40.h : AppSize.h20.h,
              ),
              padding: EdgeInsets.only(
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p16,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p16,
                  bottom: AppPadding.p16,
                  top: AppPadding.p16),
              itemBuilder: (context, documentSnapshot, index) {
                return PromoListItem(
                  code:
                      PromoCode.fromMap(documentSnapshot[index].data() as Map),
                );
              },
              query: FirebaseFirestore.instance
                  .collection(Paths.promoPath)
                  // .where('promoCodeStatus', isEqualTo: true)
                  .orderBy('promoCodeTimestamp', descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          )
        ],
      ),
    );
  }
}
