import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../screens/techUserDetails/userDetailsScreen.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../widget/custom_outlined_button.dart';

class NameSearchScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const NameSearchScreen({Key? key, required this.loggedUser})
      : super(key: key);

  @override
  _NameSearchScreenState createState() => _NameSearchScreenState();
}

class _NameSearchScreenState extends State<NameSearchScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController searchController = new TextEditingController();
  bool load = false;
  String theme = "light";
  String name = "";
  late Query filterQuery;
  late Size size;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          SafeArea(
            child: Container(
                width: size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: size.width * AppPadding.p0_06,
                    right: size.width * AppPadding.p0_06,
                    top: size.height * AppPadding.p0_05,
                    bottom: size.height * AppPadding.p0_05,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton1(
                        onPress: Navigator.of(context).pop,
                        Width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w97.w
                                : AppSize.w50_6.w,
                        Height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w97.h
                                : AppSize.w50_6.h,
                        ButtonRadius:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r24.r
                                : AppRadius.r10_6.r,
                        IconWidth: AppSize.w32.r,
                        IconHeight: AppSize.h32.r,
                        IconColor: Theme.of(context).primaryColor,
                        Icon: AssetsManager.blackArrowRightIconPath,
                        ButtonBackground: AppColors.white,
                      ),
                      const SizedBox(width: AppSize.w10),
                      Container(
                        width: size.width * AppSize.w0_6,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppPadding.p1, vertical: 0.0),
                        decoration: decoration(),
                        child: TextField(
                          onChanged: (val) => initiateSearch(val),
                          keyboardType: TextInputType.text,
                          controller: searchController,
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.search,
                          enableInteractiveSelection: true,
                          readOnly: false,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25 : AppFontsSizeManager.s14_5,
                             color: AppColors.black87,
                            letterSpacing: AppConstants.letterSpacing0_5,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal:
                                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppPadding.p10 : AppPadding.p5,
                                vertical:
                                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppPadding.p20 :AppPadding.p8),
                            prefixIcon: IconButton(
                              onPressed: () {},
                              icon: SvgPicture.asset(
                                AssetsManager.searchIconPath,
                                width:
                                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w30.w : AppSize.w17.w,
                                height:
                                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h30.h : AppSize.h17.h,
                              ),
                            ),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "nameSearch"),
                            hintStyle: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize:
                                  (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25 : AppFontsSizeManager.s14_5,
                              color: AppColors.grey,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSize.w10),
                    ],
                  ),
                )),
          ),
          SizedBox(
            height: 15,
          ),
          name == ""
              ? Expanded(
                  child: Center(child: SizedBox()),
                )
              : Expanded(
                  child: PaginateFirestore(
                    key: ValueKey(filterQuery),
                    itemBuilderType: PaginateBuilderType.listView,
                    padding: EdgeInsets.symmetric(
                      horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppPadding.p0_25
                          : AppPadding.p16,
                      vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.height * AppPadding.p0_06
                          : AppPadding.p16,
                    ),
                    itemBuilder: (context, documentSnapshot, index) {
                      return NameWidget(
                          GroceryUser.fromMap(
                              documentSnapshot[index].data() as Map),
                          size);
                    },
                    separator: Center(
                        child: Container(
                            color: AppColors.lightGrey,
                            height: 1,
                            width: size.width * .9)),
                    query: filterQuery,
                    isLive: true,
                  ),
                )
        ],
      ),
    );
  }

  BoxDecoration decoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(8.0),
      border: CustomOulinedButton.outlineBorder(),
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase(); //.trim();
      filterQuery = getTranslated(context, "lang") == "ar"
          ? FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .where('searchIndex', arrayContains: name)
              .orderBy('name', descending: true)
          : FirebaseFirestore.instance
              .collection(Paths.usersPath)
              .where('searchIndexEn', arrayContains: name)
              .orderBy('name', descending: true);
    });
  }

  Widget NameWidget(GroceryUser user, size) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserDetailsScreen(
              user: user,
              loggedUser: widget.loggedUser,
            ),
          ),
        );
      },
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only(
            left: AppPadding.p5, right: AppPadding.p5, bottom: AppPadding.p10, top: AppPadding.p10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: AppSize.h50,
              width: AppSize.w50,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: 0),
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: user.photoUrl!.isEmpty
                  ? Image.asset(
                      AssetsManager.whiteJerasLogoIconPath,
                      width: AppSize.w50,
                      height: AppSize.h50,
                      fit: BoxFit.fill,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r100),
                      child: FadeInImage.assetNetwork(
                        placeholder: AssetsManager.lodeGif,
                        placeholderScale: 0.5,
                        imageErrorBuilder: (context, error, stackTrace) =>
                            Image.asset(AssetsManager.whiteJerasLogoIconPath,
                                width: AppSize.w50, height: AppSize.h50, fit: BoxFit.fill),
                        image: user.photoUrl!,
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
              child: Text(
                user.name!.isEmpty ? "." : user.name!,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontWeight: FontWeight.w100,
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 12,
                  color: AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
