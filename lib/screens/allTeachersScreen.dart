import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/textWidget.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../widget/consultantListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../models/interests.dart';
import '../services/app_flyer_service.dart';
import '../widget/component/IconButton.dart';
import '../widget/searchWidget.dart';

class AllTeachersScreen extends StatefulWidget {
  final GroceryUser? loggedUser;

  const AllTeachersScreen({Key? key, this.loggedUser}) : super(key: key);

  @override
  _AllTeachersScreenState createState() => _AllTeachersScreenState();
}

class _AllTeachersScreenState extends State<AllTeachersScreen> {
  Query query = FirebaseFirestore.instance.collection('Users');
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Size size;
  GroceryUser? user;
  final TextEditingController searchController = new TextEditingController();
  late AccountBloc accountBloc;
  bool load = false, loadInterests = true;
  late int selectedCard = -1;
  late String lang, userImage, theme = "light";
  String type = "";
  List<Interests> interestList = [];
  late Query filterQuery;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    lang = getTranslated((context), "lang");
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppPadding.p0_06
                          : AppPadding.p32.w,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppPadding.p0_06
                          : AppPadding.p32.w,
                      top: AppPadding.p10,
                      bottom: AppPadding.p21_3.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(),
                      SizedBox(
                        width: AppSize.w21_3.w,
                      ),
                      Text(
                        getTranslated(context, "consultNum"),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s25.sp
                                  : AppFontsSizeManager.s21_3.sp,
                          color: AppColors.black,
                          letterSpacing: AppConstants.letterSpacing0_5,
                          // fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w120.w
                        : double.infinity)),
            //search part

            Container(
                width: size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_06
                        : AppSize.w32.w,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_06
                        : AppSize.w32.w,
                    top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p25.h
                        : AppSize.h21_3.h,
                    bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.height * AppPadding.p0_05
                        : 0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //search part
                          Container(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w408.w
                                : AppSize.w422_6.w,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h62.h
                                : AppSize.h60.h,
                            padding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p1.w, vertical: 0.0.h),
                            decoration: decoration(),
                            child: Center(
                              child: TextField(
                                onChanged: (val) => initiateSearch(val, "0"),
                                keyboardType: TextInputType.text,
                                controller: searchController,
                                textAlignVertical: TextAlignVertical.center,
                                textInputAction: TextInputAction.search,
                                enableInteractiveSelection: true,
                                readOnly: false,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.black,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s25.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  fontWeight: AppFontsWeightManager.bold500,
                                  /* fontFamily:(kIsWeb||size.width >= 500)
                              ?getTranslated(context, "Montserrat"):getTranslated(context, "Ithra"),align: TextAlign.start,
                                    fontSize: (kIsWeb||size.width >= 500)
                              ?25:14.5,
                                     color: AppColors.black87,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                    fontWeight: FontWeight.w400,*/
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppPadding.p10.w
                                          : AppPadding.p20.w,
                                      vertical: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppPadding.p20.h
                                          : AppPadding.p8.h),
                                  suffixIcon: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? IconButton(
                                          onPressed: () {
                                            _modalBottomSheetMenu(size);
                                          },
                                          //filter
                                          icon: SvgPicture.asset(
                                            AssetsManager
                                                .slidersHorizontalIconPath,
                                            width: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.w26.w
                                                : AppSize.w26.w,
                                            height: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.h26.h
                                                : AppSize.h26.h,
                                          ),
                                        )
                                      : null,
                                  prefixIcon: IconButton(
                                    onPressed: () {},
                                    //search
                                    icon: SvgPicture.asset(
                                      AssetsManager.searchIconPath,
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w30.w
                                          : AppSize.w32.r,
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h30.h
                                          : AppSize.h32.r,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  hintText:
                                      getTranslated(context, "nameTeacher"),
                                  hintStyle: TextStyle(
                                    fontFamily:
                                        getTranslated(context, "Ithralight"),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25.sp
                                        : AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.grey,
                                    letterSpacing:
                                        AppConstants.letterSpacing0_5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSize.w26_6.w),
                          IconButton1(
                            onPress: () {
                              _modalBottomSheetMenu(size);
                            },
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w97.w
                                : AppSize.w60.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h97.h
                                : AppSize.h60.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r25.r
                                : AppRadius.r10_6.r,
                            IconWidth: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w46.w
                                : AppSize.w32.w,
                            IconHeight: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h54.h
                                : AppSize.h32.h,
                            IconColor: Colors.white,
                            Icon: AssetsManager.whiteSlidersHorizontalIconPath,
                            GradientColor: AppColors.linear8,
                            GradientColor2: AppColors.linear4,
                          ),
                        ],
                      ),
                      type == ""
                          ? SingleChildScrollView(
                              child: Column(
                                children: [
                                  Align(
                                    alignment: lang == "ar"
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppPadding.p25.h
                                            : AppPadding.p21_3.h,
                                        bottom: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? size.height * AppPadding.p0_05
                                            : AppSize.h32.h,
                                      ),
                                      child: Text(
                                        getTranslated(context, "allTeachers"),
                                        style: TextStyle(
                                            fontFamily:
                                                getTranslated(context, "Ithra"),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: AppSize.h850.h,
                                    child: PaginateFirestore(
                                      key: ValueKey(query),
                                      itemBuilderType:
                                          PaginateBuilderType.gridView,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? 4
                                                  : 2,
                                              crossAxisSpacing: AppSize.w32.w,
                                              mainAxisSpacing: AppSize.h32.h,
                                              //mainAxisExtent: 175,
                                              childAspectRatio: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? 1.6
                                                  : .83),
                                      padding: EdgeInsets.only(
                                        left: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? size.width * AppSize.w0_06
                                            : 0,
                                        right: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? size.width * AppSize.w0_06
                                            : 0,
                                        bottom: 0,
                                      ),
                                      itemBuilder:
                                          (context, documentSnapshot, index) {
                                        final data = documentSnapshot[index]
                                            .data() as Map;
                                        return ConsultantListItem(
                                          consult: GroceryUser.fromMap(data),
                                          loggedUser: widget.loggedUser,
                                          theme: theme,
                                          lang: lang,
                                        );
                                      },
                                      query: query.orderBy('order',
                                          descending: true),
                                      isLive: true,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Align(
                                    alignment: lang == "ar"
                                        ? Alignment.topRight
                                        : Alignment.topLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        top: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppPadding.p25.h
                                            : AppPadding.p21_3.h,
                                        bottom: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? size.height * AppPadding.p0_05
                                            : AppSize.h32.h,
                                      ),
                                      child: Text(
                                        getTranslated(context, "resultSearch"),
                                        style: TextStyle(
                                            fontFamily:
                                                getTranslated(context, "Ithra"),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: AppSize.h850.h,
                                    child: PaginateFirestore(
                                      key: ValueKey(filterQuery),
                                      itemBuilderType:
                                          PaginateBuilderType.gridView,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? 4
                                                  : 2,
                                              crossAxisSpacing: AppSize.w32.w,
                                              mainAxisSpacing: AppSize.h32.h,
                                              //mainAxisExtent: 175,
                                              childAspectRatio: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? 1.6
                                                  : .83),
                                      padding: EdgeInsets.only(
                                        left: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? size.width * AppSize.w0_06
                                            : 0,
                                        right: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? size.width * AppSize.w0_06
                                            : 0,
                                        bottom: 0,
                                      ),
                                      itemBuilder:
                                          (context, documentSnapshot, index) {
                                        final data = documentSnapshot[index]
                                            .data() as Map;
                                        return ConsultantListItem(
                                          consult: GroceryUser.fromMap(data),
                                          loggedUser: widget.loggedUser,
                                          theme: theme,
                                          lang: lang,
                                        );
                                      },
                                      query: filterQuery.orderBy('order',
                                          descending: true),
                                      isLive: true,
                                    ),
                                  ),
                                ],
                              ),
                            )
                    ],
                  ),
                )),

            // loadInterests ? SizedBox() : interestWidget(),
          ],
        ),
      ),
    );
  }

  Widget interestWidget() {
    return Container(
      height: AppSize.h50.h,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(
          top: AppPadding.p10,
          bottom: AppPadding.p10,
          left: AppPadding.p5,
          right: AppPadding.p5),
      child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: ScrollPhysics(),
          //physics: const AlwaysScrollableScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 15.w);
          },
          itemCount: interestList.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                setState(() {
                  selectedCard = index;
                });
                initiateSearch(interestList[index].interestId, "1");
              },
              child: Container(
                padding: EdgeInsets.all(AppPadding.p5),
                // height: 27,
                decoration: BoxDecoration(
                  color: selectedCard == index
                      ? AppColors.pink
                      : AppColors.lightGrey,
                  borderRadius: BorderRadius.circular(AppRadius.r10.r),
                ),
                child: Center(
                  child: Text(
                    lang == "ar"
                        ? interestList[index].arName
                        : interestList[index].enName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color:
                          selectedCard == index ? Colors.white : AppColors.grey,
                      fontSize: AppFontsSizeManager.s12.sp,
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  void showNoNotifSnack(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
  }

  @override
  void didChangeDependencies() {
    getInterests();
    super.didChangeDependencies();
  }

  void initiateSearch(String name, typeSearch) {
    String eventName = "af_search";
    Map eventValues = {
      "af_search_string": name,
      "af_content_list": [name],
    };
    AppFlyerService().logEvent(eventName, eventValues);
    setState(() {
      type = typeSearch;
      if (typeSearch == "0")
        filterQuery = getTranslated(context, "lang") == "ar"
            ? FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .where('userType', isEqualTo: "CONSULTANT")
                .where('accountStatus', isEqualTo: "Active")
                .where('searchIndex', arrayContainsAny: [name]).orderBy('order',
                    descending: true)
            : FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .where('userType', isEqualTo: "CONSULTANT")
                .where('accountStatus', isEqualTo: "Active")
                .where('searchIndexEn', arrayContainsAny: [name]).orderBy(
                    'order',
                    descending: true);
      else
        filterQuery = FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .where('userType', isEqualTo: "CONSULTANT")
            .where('accountStatus', isEqualTo: "Active")
            .where('interestListIds', arrayContainsAny: [name]).orderBy('order',
                descending: true);
    });
  }

  getInterests() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.interestsPath)
          .where('lang', isEqualTo: getTranslated(context, "lang"))
          .where('active', isEqualTo: true)
          .orderBy('order', descending: false)
          .get();
      var list = List<Interests>.from(
        querySnapshot.docs.map(
          (snapshot) => Interests.fromMap(snapshot.data() as Map),
        ),
      );
      if (mounted)
        setState(() {
          interestList = list;
          loadInterests = false;
        });
    } catch (e) {
      if (mounted)
        setState(() {
          loadInterests = false;
        });
    }
  }

  BoxDecoration decoration() {
    return BoxDecoration(
        color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? Color.fromRGBO(247, 247, 247, 1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? 8.0.r
                : AppRadius.r10_6.r),
        border: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? null
            : Border.all(color: AppColors.lightGrey, width: AppSize.w2.w));
  }

  void _modalBottomSheetMenu(Size size) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return new Container(
            height: size.height * .9.h,
            //color: Colors.transparent,
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(30.0.r),
                    topRight: Radius.circular(30.0.r))),
            //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: SearchWidget(
              loggedUser: widget.loggedUser,
            ),
          );
        });
  }
}
