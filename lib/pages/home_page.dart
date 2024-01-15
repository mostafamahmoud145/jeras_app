import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as firebaseDatabase;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_customPaint.dart';
import 'package:jeras/config/app_shadow.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/methods/change_user_call_state.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/models/user.dart';
import 'package:jeras/screens/courseDetailsScreen.dart';
import 'package:jeras/screens/nameSearchScreen.dart';
import 'package:jeras/screens/allCourses.dart';
import 'package:jeras/screens/allTeachersScreen.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_outlined_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/searchWidget.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/setting.dart';
import '../../screens/job/addJobScreen.dart';
import '../../widget/appointmentWidget.dart';
import '../../widget/consultantListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../Utils/helper.dart';
import '../api/http_helper.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../controller/blocs/replace_video_bloc/cubit.dart';
import '../models/banner.dart';
import '../models/courses.dart';
import '../models/interests.dart';
import '../services/firebase_service.dart';
import '../widget/component/textWidget.dart';
import '../widget/courseItem.dart';
import '../widget/dialogs/custom_text_dialog.dart';
import '../widget/responsive_layout.dart';

// class ToolTipBuilder extends StatelessWidget {
//   const ToolTipBuilder({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         body: ShowCaseWidget(
//             builder: Builder(builder: (context) => HomePage())));
//   }
// }

class HomePage extends StatefulWidget {
  final userType;

  HomePage({
    Key? key,
    this.userType,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage>, WidgetsBindingObserver {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController searchController = new TextEditingController();

  //late HomeController homeController = HomeController(context: context);

  late AccountBloc accountBloc;
  GroceryUser? user;
  Courses? courses;
  Setting? setting;
  bool? first;
  bool loadInterests = true, wait = true, fixed = false;
  bool load = true, male = false, female = false, loadPageWidget = true;
  bool active = false;
  int _selectedIndex = -1;
  String selectedInteresrId = "-1";
  Query query = FirebaseFirestore.instance.collection('Users');
  Query courseQuery = FirebaseFirestore.instance.collection('Courses');
  Query consultQuery = FirebaseFirestore.instance.collection('Users');
  String lang = "ar";
  bool avaliable = false;
  late String userId;
  var registered = false;
  var hasPushedToCall = false;
  late Size size;

  List<Interests> _Interests = [];

  bool loadData = false, loadBanner = true;
  List<banner> bannerList = [];

  // late toolTipBloc tipBloc;
  //GroceryUser currentUser =GroceryUser();

  User? currentUser = FirebaseAuth.instance.currentUser;
  bool stateIsCalling = false;

  @override
  initState() {
    super.initState();

    first = true;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());

    if (FirebaseAuth.instance.currentUser != null) {
      firebaseDatabase.FirebaseDatabase.instance
          .ref('userCallState')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('callState')
          .onValue
          .listen((event) {
        if (event.snapshot.value == 'oncall' ||
            event.snapshot.value == 'calling') {
          setState(() {
            stateIsCalling = true;
          });
        } else {
          setState(() {
            stateIsCalling = false;
          });
        }
      });
    }
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

      setState(() {
        _Interests = list;
        loadInterests = false;
      });
    } catch (e) {
      setState(() {
        loadInterests = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    getImageSlider();
    getInterests();
    super.didChangeDependencies();
  }

  getImageSlider() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.bannerPath)
          .where('lang', isEqualTo: getTranslated(context, "lang"))
          .where('status', isEqualTo: true)
          .get();
      var _bannerList = List<banner>.from(
        querySnapshot.docs.map(
          (snapshot) => banner.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        bannerList = _bannerList;
        loadBanner = false;
      });
    } catch (e) {
      setState(() {
        loadBanner = false;
      });
    }
  }

  @override
  void dispose() {
    first = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        floatingActionButton: stateIsCalling
            ? FloatingActionButton(
                onPressed: () async {
                  customTextDialog(
                    context: context,
                    text: getTranslated(context, 'resetUserInformation'),
                    buttonText: getTranslated(context, 'close'),
                    okFunction: () async {
                      await updateFirebaseToken(
                          FirebaseAuth.instance.currentUser!);
                      await changeUserState(
                          userId: FirebaseAuth.instance.currentUser!.uid,
                          state: 'closed');
                      Navigator.pop(context);
                    },
                  );
                },
                backgroundColor: AppColors.red,
                child: Padding(
                  padding: EdgeInsets.all(AppSize.h12.r),
                  child: Image.asset(
                    AssetsManager.endCall,
                  ),
                ),
              )
            : null,
        backgroundColor: AppColors.white,
        key: _scaffoldKey,
        body: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            if (state is GetLoggedUserInProgressState) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GetLoggedUserCompletedState) {
              user = state.user;
              if (user!.userType == "CONSULTANT") {
                query = FirebaseFirestore.instance
                    .collection(Paths.appAppointments)
                    .where('consult.uid', isEqualTo: user!.uid)
                    .where('appointmentStatus', isEqualTo: "open")
                    .orderBy('timestamp', descending: true);
                avaliable = Helper.checkAvaliable(user!);
                return consultHome(size);
              } else {
                return userHome(size);
              }
            } else {
              return userHome(size);
            }
          },
        ),
      ),
    );
  }

  Widget imageSlider(Size size) {
    return Center(
      child: bannerList.length > 0
          ? ImageSlideshow(
              //old
              /*width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
?size.width*.90:size.width*.95,*/
              //new
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 1282.w
                  : 484.w,

              //old
              /*height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
?size.height*0.17:size.height*.10,*/
              //new
//         height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
// ?size.height*0.17.h:size.height*.10.h,
              initialPage: 0,
              indicatorColor: AppColors.white,
              indicatorBackgroundColor: AppColors.linear1,
              autoPlayInterval: 3000,
              isLoop: true,
              children: [
                for (var item in bannerList)
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(
                              name: 'courses?course_id=${item.itemId}',
                              arguments: {"course_id": item.itemId}),
                          builder: (context) => CourseDetailScreen(
                            courseId: '${item.itemId}',
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.only(
                          left:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 100
                                  : 0),
                      child: CachedNetworkImage(
                        imageUrl: kIsWeb ||
                                (MediaQuery.of(context).size.width >=
                                    AppConstants.kIsWebValue)
                            ? item.webImage!
                            : item.image!,
                        imageBuilder: (context, imageProvider) => Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.contain,
                              colorFilter: const ColorFilter.mode(
                                AppColors.white,
                                BlendMode.colorBurn,
                              ),
                            ),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(),
                        ),
                        errorWidget: (context, url, error) => Image.asset(
                          'assets/applicationIcons/GroupLogo.png',
                          width: AppSize.w80.w,
                          height: AppSize.h80.h,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : SizedBox(),
    );
  }

  Widget imageSlider2(Size size) {
    return Center(
      child: bannerList.length > 0
          ? ImageSlideshow(
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w1282.w
                  : AppSize.w484.w,
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h173.h
                  : AppSize.h121.h,
              initialPage: 0,
              indicatorColor: AppColors.white,
              indicatorBackgroundColor: AppColors.linear1,
              autoPlayInterval: 3000,
              isLoop: true,
              children: [
                for (var item in bannerList)
                  InkWell(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: RouteSettings(
                              name: 'courses?course_id=${item.itemId}',
                              arguments: {"course_id": item.itemId}),
                          builder: (context) => CourseDetailScreen(
                            courseId: '${item.itemId}',
                          ),
                        ),
                      );
                    },
                    child: CachedNetworkImage(
                      imageUrl: kIsWeb ||
                              (MediaQuery.of(context).size.width >=
                                  AppConstants.kIsWebValue)
                          ? item.webImage!
                          : item.image!,
                      imageBuilder: (context, imageProvider) => Container(
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              AppColors.white,
                              BlendMode.colorBurn,
                            ),
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/applicationIcons/GroupLogo.png',
                        width: AppSize.w80.w,
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
              ],
            )
          : SizedBox(),
    );
  }

  Widget userHome(Size size) {
    return ResponsiveLayout(
      desktop: Stack(children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p24.w),
          child: SizedBox(
            height: size.height,
            child: ListView(
              children: <Widget>[
                SizedBox(
                  height: AppSize.h46.h,
                ),
                imageSlider2(size),
                /*imageSlider(size),*/
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h49.h
                      : AppSize.h21_3.h,
                ),

                Expanded(
                  child: Row(
                    children: [
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w140.w
                                  : 0),
                      Expanded(
                        child: Container(child: interstsWidget(size)),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h28_7.h
                      : AppSize.h16.h,
                ),
                //new
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? Divider(
                        height: AppSize.h1.h,
                        color: AppColors.grey2,
                      )
                    : SizedBox(),
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? SizedBox(height: AppSize.h42_6.h)
                    : SizedBox(),

                Container(
                  child: Row(
                    children: [
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w140.w
                                  : 0),
                      TextWidget(
                        text: getTranslated(context, "_teachers"),
                        color: AppColors.black4,
                        size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s27.sp
                            : AppFontsSizeManager.s21_3.sp,
                        family: getTranslated(context, "Montserrat"),
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                //teacher data
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h50.h
                      : .120.h,
                ),
                Expanded(
                  child: Container(
                    child: Row(
                      children: [
                        SizedBox(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w140.w
                                : 0),
                        Expanded(
                            child: Container(child: consultListWidget(size))),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h70.h
                        : null),
                Container(
                  child: Row(
                    children: [
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w140.w
                                  : 0),
                      TextWidget(
                        text: getTranslated(context, "_courses"),
                        color: AppColors.black4,
                        size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s34.sp
                            : AppFontsSizeManager.s21_3.sp,
                        weight: FontWeight.w600,
                        family:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Montserrat")
                                : getTranslated(context, "Ithra"),
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h50.h
                      : .120.h,
                ),
                //Courses data
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: (getTranslated(context, "lang")) == "ar" ? 0 : 0,
                      right: (getTranslated(context, "lang")) == "ar"
                          ? size.width * AppPadding.p0_06.r
                          : 0,
                      top: 0,
                    ),
                    child: PaginateFirestore(
                      key: ValueKey(courseQuery),
                      shrinkWrap: true,
                      padding: EdgeInsets.only(
                        left: (getTranslated(context, "lang")) == "ar"
                            ? (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p50.r
                                : 0
                            : 0.r,
                        right: (getTranslated(context, "lang")) == "ar"
                            ? (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p50.r
                                : 0
                            : size.width * AppPadding.p0_06.r.r,
                      ),
                      initialLoader: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * AppSize.h0_1.h,
                          ),
                          CircularProgressIndicator()
                        ],
                      ),
                      onEmpty: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height * AppSize.h0_1.h,
                          ),
                          TextWidget(
                            text: getTranslated(context, "noCoursesAvaliable"),
                            color: Color.fromRGBO(192, 192, 192, 1),
                            size: AppFontsSizeManager.s17.sp,
                            weight: FontWeight.w500,
                            family: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Montserrat")
                                : getTranslated(context, "Ithra"),
                            align: TextAlign.center,
                          ),
                        ],
                      ),
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilderType: PaginateBuilderType.gridView,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 2
                                  : 2,
                          crossAxisSpacing:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 74
                                  : 0,
                          mainAxisSpacing:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 74
                                  : 20,

                          // mainAxisExtent: size.height*.25,
                          //old
                          //childAspectRatio: (kIsWeb || size.width >= AppConstants.kIsWebValue)

                          childAspectRatio:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 1.6
                                  : 1.8),
                      itemBuilder: (context, documentSnapshot, index) {
                        return CourseItem(
                          course: Courses.fromMap(
                              documentSnapshot[index].data() as Map),
                          loggedUser: user,
                        );
                      },
                      query: courseQuery
                          .where("lang",
                              isEqualTo: getTranslated(context, "lang"))
                          .where('active', isEqualTo: true),
                      isLive: true,
                    ),
                  ),
                ),
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h50.h
                      : null,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: AppPadding.p15.h,
          bottom: AppPadding.p50.h,
          child: InkWell(
            onTap: () {
              if (user == null)
                Navigator.pushNamed(context, '/Register_Type');
              else
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddJobScreen(
                            loggedUser: user!,
                          )),
                );
            },
            child: Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h156.h
                  : AppSize.h8_3.h,
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w156.w
                  : AppSize.w803.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.linear8,
                    AppColors.linear4,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                      offset: Offset(0, 14.0),
                      blurRadius: 20.0,
                      spreadRadius: 1.0,
                      color: Color.fromRGBO(123, 108, 150, 0.2)),
                ],
              ),
              child: Center(
                child: SvgPicture.asset(AssetsManager.whiteNoteIconPath,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w64.w
                        : AppSize.w35.w),
              ),
            ),
          ),
        ),
        Positioned(
          right: male ? 160 : 25, bottom: 150.h, //240
          child: InkWell(
            onTap: () {
              setState(() {
                male = !male;
                female = !female;
                query = FirebaseFirestore.instance.collection('Users');
                if (selectedInteresrId != "-1")
                  query = query.where("interestListIds",
                      arrayContainsAny: [selectedInteresrId]);
              });
            },
            child: Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h105.h
                  : AppSize.h56.h,
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w105.w
                  : AppSize.w56.w,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppColors.redLight,
                      AppColors.blueLight,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )),
              child: Center(
                child: SvgPicture.asset(
                  AssetsManager.whiteGenderIconPath,
                  // fit: BoxFit.fill,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w36.w
                      : AppSize.w18.w,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: male,
          child: Positioned(
            right: AppPadding.p30,
            bottom: AppPadding.p150.h,
            child: InkWell(
              onTap: () {
                setState(() {
                  query = FirebaseFirestore.instance
                      .collection('Users')
                      .where("gender", isEqualTo: "male");
                  if (selectedInteresrId != "-1")
                    query = query.where("interestListIds",
                        arrayContainsAny: [selectedInteresrId]);
                });
              },
              child: Container(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? 90.h
                    : 45.h,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? 90.w
                    : 45.w,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.blueLight),
                child: Center(
                  child: Image.asset(AssetsManager.whiteMaleIconPath,
                      // fit: BoxFit.fill,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w36.w
                          : AppSize.w18.w),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: female,
          child: Positioned(
            right: female ? 95 : 0,
            bottom: AppPadding.p150.h,
            child: InkWell(
              onTap: () {
                setState(() {
                  query = FirebaseFirestore.instance
                      .collection('Users')
                      .where("gender", isEqualTo: "female");
                  if (selectedInteresrId != "-1")
                    query = query.where("interestListIds",
                        arrayContainsAny: [selectedInteresrId]);
                });
              },
              child: Container(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h90.h
                    : AppSize.h45.h,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w90.w
                    : AppSize.w45.w,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.redLight),
                child: Center(
                  child: Image.asset(AssetsManager.whiteFemaleIconPath,
                      // fit: BoxFit.fill,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w36.w
                          : AppSize.w18.w),
                ),
              ),
            ),
          ),
        ),
      ]),
      mobile: Stack(children: <Widget>[
        ListView(
          padding: EdgeInsets.only(top: AppPadding.p0.h),
          children: [
            // put polygon here
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p31.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: AppSize.h10.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomPaint(
                        size: Size(80, 60),
                        painter: lang == "ar" ? MyPainter1() : MyPainter4(),
                        child: customPaintTitle("1 A label A label A label"),
                      ),
                      CustomPaint(
                        size: Size(80, 60),
                        painter: lang == "ar" ? MyPainter2() : MyPainter5(),
                        child: customPaintTitle("2 label B label C label"),
                      ),
                      CustomPaint(
                        size: Size(80, 60),
                        painter: lang == "ar" ? MyPainter2() : MyPainter5(),
                        child: customPaintTitle('3 label B label C label'),
                      ),
                      CustomPaint(
                        size: Size(80, 60),
                        painter: lang == "ar" ? MyPainter3() : MyPainter6(),
                        child: customPaintTitle('4 label C label C label'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: AppSize.h14_6.h,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    clipBehavior: Clip.antiAlias,
                    child: Container(
                      color: AppColors.grey2,
                      child: StepProgressIndicator(
                        totalSteps: 100,
                        currentStep: 9,
                        size: AppRadius.r5_5.r,
                        padding: 0,
                        selectedColor: AppColors.linear8,
                        unselectedColor: AppColors.grey2,
                        roundedEdges: Radius.circular(10),
                        progressDirection: TextDirection.ltr,
                        /*selectedGradientColor: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.yellowAccent, Colors.deepOrange],
                        ),
                        unselectedGradientColor: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.black, Colors.blue],
                        ),*/
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h5_3.h,
                  ),
                  Text(
                    "9" + " " + "\%",
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontWeight:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsWeightManager.normal
                              : AppFontsWeightManager.bold400,
                      fontFamily: getTranslated(context, "Montserratbold"),
                      fontStyle: FontStyle.normal,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s27.sp
                              : AppFontsSizeManager.s18_6.sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h10_6.h,
            ),
            imageSlider2(size),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h20.h
                  : AppSize.h21_3.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p31_3.w),
              child: interstsWidget(size),
            ),
            // highestRatedCourses
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppPadding.p32.w,
                vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h32.h
                    : AppSize.h21_3.h,
              ),
              child: Row(
                children: [
                  TextWidget(
                    text: getTranslated(context, "highestRatedCourses"),
                    color: AppColors.black4,
                    size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s34.sp
                        : AppFontsSizeManager.s21_3.sp,
                    weight: FontWeight.w700,
                    family: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? getTranslated(context, "Montserrat")
                        : getTranslated(context, "Ithra"),
                    align: TextAlign.center,
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AllCourseScreen(loggedUser: user),
                        ),
                      );
                      // view all courses
                    },
                    child: Row(
                      children: [
                        TextWidget(
                          text: getTranslated(context, "viewAll"),
                          color: AppColors.linear8,
                          size:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s18_6.sp,
                          weight: FontWeight.w700,
                          family:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                          align: TextAlign.center,
                        ),
                        SizedBox(width: AppSize.w18_6.w),
                        SvgPicture.asset(
                          (getTranslated(context, "lang")) == "ar"
                              ? AssetsManager.blackIosLeftArrowIconPath
                              : AssetsManager.BlackIosRightArrowIconPath,
                          color: AppColors.linear8,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w48.w
                                  : AppSize.w7_5.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h29.h
                                  : AppSize.h12_2.h,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //Courses data
            Container(
              height: AppSize.h228.h,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.only(
                  left: (getTranslated(context, "lang")) == "ar"
                      ? AppSize.w32.w
                      : AppSize.w32.w,
                  right: (getTranslated(context, "lang")) == "ar"
                      ? AppSize.w32.w
                      : AppSize.w32.w,
                ),
                children: <Widget>[
                  PaginateFirestore(
                    key: ValueKey(courseQuery),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    separator: SizedBox(
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w45.w
                          : AppSize.w21_3.w,
                    ),
                    initialLoader: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height * .1.h,
                        ),
                        CircularProgressIndicator()
                      ],
                    ),
                    onEmpty: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height * .1.h,
                        ),
                        TextWidget(
                          text: getTranslated(context, "noCoursesAvaliable"),
                          color: Color.fromRGBO(192, 192, 192, 1),
                          size: AppFontsSizeManager.s17.sp,
                          weight: FontWeight.w500,
                          family:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                    itemBuilderType: PaginateBuilderType.listView,
                    itemBuilder: (context, documentSnapshot, index) {
                      return CourseItem(
                        course: Courses.fromMap(
                            documentSnapshot[index].data() as Map),
                        loggedUser: user,
                      );
                    },
                    query: courseQuery
                        .where("lang",
                            isEqualTo: getTranslated(context, "lang"))
                        .where('active', isEqualTo: true),
                    isLive: true,
                  ),
                ],
              ),
            ),
            // TopRatedTeachers
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h32.w
                    : AppSize.h32.w,
                vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h21_3.h
                    : AppSize.h21_3.h,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      _modalBottomSheetMenu(size);
                    },
                    child: Container(
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w97.w
                          : AppSize.w32.r,
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h97.h
                          : AppSize.h32.r,
                      decoration: decoration(radius: AppRadius.r5_3.r),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r50),
                          child: SvgPicture.asset(
                            AssetsManager.whiteSlidersHorizontalIconPath,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w41_1.w
                                : AppSize.w17.w,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h36.h
                                : AppSize.h13.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSize.w10_6.w),
                  TextWidget(
                    text: getTranslated(context, "topRatedTeachers"),
                    color: AppColors.black4,
                    size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s34.sp
                        : AppFontsSizeManager.s21_3.sp,
                    family: getTranslated(context, "Ithra"),
                    weight: FontWeight.w700,
                    align: TextAlign.center,
                  ),
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AllTeachersScreen(loggedUser: user),
                        ),
                      );
                      // view all teachers
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text: getTranslated(context, "viewAll"),
                          color: AppColors.linear8,
                          size:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s18_6.sp,
                          weight: FontWeight.w700,
                          family:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                          align: TextAlign.center,
                        ),
                        SizedBox(width: AppSize.w18_6.w),
                        SvgPicture.asset(
                          (getTranslated(context, "lang")) == "ar"
                              ? AssetsManager.blackIosLeftArrowIconPath
                              : AssetsManager.BlackIosRightArrowIconPath,
                          color: AppColors.linear8,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w48.w
                                  : AppSize.w7_5.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h29.h
                                  : AppSize.h12_2.h,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //teacher data
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
              child: consultListWidget(size),
            ),
          ],
        ),
        //pb
        /*IconButton1(
            onPress:(){  if (user == null)
              Navigator.pushNamed(context, '/Register_Type');
            else
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddJobScreen(loggedUser: user!,)),
              );}, Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)?163.w:84.w, Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)?163.h:84.h,ButtonColor:AppColors.pink, BoxShape1: BoxShape.circle,IconWidth: (kIsWeb || size.width >= AppConstants.kIsWebValue)?64.w:35.w,Icon: 'assets/applicationIcons/edit.png'),*/
        Positioned(
          left: AppPadding.p33_3.w,
          bottom: AppPadding.p18_6.h,
          child: InkWell(
            onTap: () {
              if (user == null)
                Navigator.pushNamed(context, '/Register_Type');
              else
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddJobScreen(
                            loggedUser: user!,
                          )),
                );
            },
            child: Stack(
              children: [
                Container(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h163.h
                      : AppSize.h84.h,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w163.w
                      : AppSize.w84.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.linear8,
                        AppColors.linear4,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    boxShadow: [AppShadow.fabshadow],
                  ),
                  child: SvgPicture.asset(
                    AssetsManager.whiteAdd,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w48.w
                        : AppSize.w90.w,
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h29.h
                        : AppSize.h50.h,
                  ),
                  // child: Showcase.withWidget(
                  //
                  //   height: AppSize.h173.h,
                  //   width:AppSize.w272.w ,
                  //
                  //   key: ToolTipController.toolTip,
                  //   container: Container(
                  //     height: AppSize.h173.h,
                  //     width:AppSize.w272.w ,
                  //     decoration: BoxDecoration(
                  //       color: AppColors.white,
                  //       borderRadius: BorderRadius.circular(AppRadius.r16.r)
                  //     ),
                  //     child: Column(
                  //       children: [
                  //         Row(
                  //           mainAxisAlignment: MainAxisAlignment.start,
                  //           children: [
                  //             IconButton(onPressed: (){
                  //
                  //             }, icon:Icon(Icons.close,color: AppColors.linear2,))
                  //           ],
                  //         ),
                  //         Padding(
                  //           padding:  EdgeInsets.only(right: AppPadding.p10.w),
                  //           child: Text(
                  //             getTranslated(context, "adsToolTipText"),
                  //           style: TextStyle(
                  //             color: AppColors.linear2,
                  //             fontFamily: getTranslated(context, "Ithra"),
                  //             fontSize: AppFontsSizeManager.s16.sp,
                  //
                  //           ),
                  //           ),
                  //         ),
                  //         Expanded(
                  //           child: Padding(
                  //             padding:  EdgeInsets.only(left: AppPadding.p16.w,bottom: AppPadding.p10.h),
                  //             child: Row(
                  //               mainAxisAlignment: MainAxisAlignment.end,
                  //               children: [
                  //                 Row(
                  //                   children: [
                  //                     Container(
                  //                       width: AppSize.w10.w,
                  //                       height: AppSize.h9.h,
                  //                       decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.circular(AppRadius.r100),
                  //                         color: AppColors.grey,
                  //                       ),
                  //                     ),
                  //                     SizedBox(width: AppSize.w5.w,),
                  //                     Container(
                  //                       width: AppSize.w10.w,
                  //                       height: AppSize.h9.h,
                  //                       decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.circular(AppRadius.r100),
                  //                         color: AppColors.grey,
                  //                       ),
                  //                     ),
                  //                     SizedBox(width: AppSize.w5.w,),
                  //
                  //                     Container(
                  //                       width: AppSize.w10.w,
                  //                       height: AppSize.h9.h,
                  //                       decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.circular(AppRadius.r100),
                  //                         color: AppColors.linear2,
                  //                       ),
                  //                     ),
                  //                     SizedBox(width: AppSize.w5.w,),
                  //
                  //                     Container(
                  //                       width: AppSize.w10.w,
                  //                       height: AppSize.h9.h,
                  //                       decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.circular(AppRadius.r100),
                  //                         color: AppColors.grey,
                  //                       ),
                  //                     ),
                  //                     SizedBox(width: AppSize.w5.w,),
                  //
                  //                     Container(
                  //                       width: AppSize.w10.w,
                  //                       height: AppSize.h9.h,
                  //                       decoration: BoxDecoration(
                  //                         borderRadius: BorderRadius.circular(AppRadius.r100),
                  //                         color: AppColors.grey,
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 ),
                  //                 SizedBox(width: AppSize.w16.w,),
                  //                 GestureDetector(
                  //                   onTap: (){
                  //                     ShowCaseWidget.of(context).next();
                  //                   },
                  //                   child: Container(
                  //                     width: AppSize.w80.w,
                  //                     height: AppSize.h40.h,
                  //                     decoration: BoxDecoration(
                  //                         color: AppColors.linear2,
                  //                       borderRadius: BorderRadius.circular(AppRadius.r10.r),
                  //                       gradient: LinearGradient(
                  //                         begin: Alignment(0.5, 0),
                  //                         end: Alignment(0.5, 1),
                  //                         colors: [
                  //                           AppColors.linear8,
                  //                           AppColors.linear4,
                  //                         ],
                  //                       ),
                  //                     ),
                  //                     child: Center(
                  //                       child: Text(
                  //                         getTranslated(context, "goNext"),
                  //
                  //                         style: TextStyle(
                  //                             color: AppColors.white,
                  //                           fontFamily: getTranslated(context, "Ithra"),
                  //                           fontSize: AppFontsSizeManager.s13_5.sp,
                  //                         ),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ),
                  //
                  //               ],
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  //
                  //   child: Center(
                  //     child: SvgPicture.asset(AssetsManager.whiteNoteIconPath,
                  //         width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  //             ? AppSize.w64.w
                  //             : AppSize.w35.w),
                  //   ),
                  // ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: male ? AppPadding.p213_3.w : AppPadding.p25.w,
          bottom: AppPadding.p120.h,
          child: IconButton1(
              onPress: () {
                setState(() {
                  male = !male;
                  female = !female;
                  query = FirebaseFirestore.instance.collection('Users');
                  if (selectedInteresrId != "-1")
                    query = query.where("interestListIds",
                        arrayContainsAny: [selectedInteresrId]);
                });
              },
              Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w105.w
                  : AppSize.w50.w,
              Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h105.h
                  : AppSize.h50.h,
              GradientColor: AppColors.redLight,
              GradientColor2: AppColors.blueLight,
              BoxShape1: BoxShape.circle,
              IconWidth: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w46.w
                  : AppSize.w24.w,
              IconHeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h54.h
                  : AppSize.h28.h,
              Icon: AssetsManager.whiteGender2IconPath),
        ),
        Visibility(
          visible: male,
          child: Positioned(
            left: AppPadding.p40.w,
            bottom: AppPadding.p120.h,
            child: InkWell(
              onTap: () {
                setState(() {
                  male = !male;
                  female = !female;
                  query = FirebaseFirestore.instance
                      .collection('Users')
                      .where("gender", isEqualTo: "male");
                  if (selectedInteresrId != "-1")
                    query = query.where("interestListIds",
                        arrayContainsAny: [selectedInteresrId]);
                });
              },
              child: Container(
                height: AppSize.h45.h,
                width: AppSize.w45.w,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.blueLight),
                child: Center(
                  child: Image.asset(
                    AssetsManager.whiteMaleIconPath,
                    // fit: BoxFit.fill,
                    width: AppSize.w20.w,
                    height: AppSize.h20.h,
                  ),
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: female,
          child: Positioned(
            left: female ? AppPadding.p126.w : 0,
            bottom: AppPadding.p120.h,
            child: InkWell(
              onTap: () {
                setState(() {
                  male = !male;
                  female = !female;
                  query = FirebaseFirestore.instance
                      .collection('Users')
                      .where("gender", isEqualTo: "female");
                  if (selectedInteresrId != "-1")
                    query = query.where("interestListIds",
                        arrayContainsAny: [selectedInteresrId]);
                });
              },
              child: Container(
                height: AppSize.h45.h,
                width: AppSize.w45.w,
                decoration: BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.redLight),
                child: Center(
                  child: Image.asset(
                    AssetsManager.whiteFemaleIconPath,
                    // fit: BoxFit.fill,
                    width: AppSize.w20.w,
                    height: AppSize.h20.h,
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  customPaintTitle(String title) {
    return Container(
      width: 80,
      height: 60,
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p25.w),
          child: TextWidget(
            text: title,
            lines: 2,
            color: AppColors.linear8,
            size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppFontsSizeManager.s22.sp
                : AppFontsSizeManager.s13_3.sp,
            family: getTranslated(context, "Ithra"),
            weight: FontWeight.w700,
            align: TextAlign.center,
          ),
        ),
      ),
    );
  }

  ///teacher home
  Widget search(Size size) {
    return Column(
      children: [
        kIsWeb || size.width >= AppConstants.kIsWebValue
            ? SizedBox()
            : Padding(
                padding: EdgeInsets.only(
                  top: AppPadding.p20.h,
                  bottom: AppPadding.p21_3.h,
                ),
                child: Container(
                  height: AppSize.h0_15.h,
                  color: AppColors.grey2,
                )),
        // normal search && search with filteration
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                if (user != null && user?.userType == "SUPPORT")
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NameSearchScreen(
                        loggedUser: user!,
                      ),
                    ),
                  );
                else
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllTeachersScreen(loggedUser: user),
                    ),
                  );
              },
              child: Container(
                width: kIsWeb || size.width >= AppConstants.kIsWebValue
                    ? AppSize.w1187.w
                    : AppSize.w437.w,
                height: kIsWeb || size.width >= AppConstants.kIsWebValue
                    ? AppSize.h97.h
                    : AppSize.h50.h,
                padding: EdgeInsets.all(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p15
                        : AppPadding.p8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppRadius.r25.r
                          : AppRadius.r10.r),
                  border: CustomOulinedButton.outlineBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        //filter section
                        SvgPicture.asset(
                          AssetsManager.searchIconPath,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w48.w
                                  : AppSize.w25.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h29.h
                                  : AppSize.h25.h,
                        ),
                        SizedBox(
                          width: AppSize.w5.w,
                        ),
                        TextWidget(
                          text: getTranslated(context, "search"),
                          color: Color.fromRGBO(147, 147, 147, 1),
                          size:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s25.sp
                                  : AppFontsSizeManager.s16.sp,
                          weight: FontWeight.w500,
                          family:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                          align: TextAlign.start,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            //extra
            SizedBox(
              width: 1.w,
            ),
            IconButton1(
              onPress: () {
                _modalBottomSheetMenu(size);
              },
              Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w97.w
                  : AppSize.w50_6.w,
              Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h97.h
                  : AppSize.h50_6.h,
              ButtonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppRadius.r25.r
                  : AppRadius.r10_6.r,
              IconWidth: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w46.w
                  : AppSize.w24.w,
              IconHeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h54.h
                  : AppSize.h24.h,
              IconColor: Colors.white,
              Icon: AssetsManager.whiteSlidersHorizontalIconPath,
              GradientColor: AppColors.linear8,
              GradientColor2: AppColors.linear4,
            ),
          ],
        ),
      ],
    );
  }

  closeAll() async {
    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .where('openingStatus', isEqualTo: true)
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.supportListPath)
            .doc(doc.id)
            .update({
          'openingStatus': false,
        });
      }
    } catch (e) {
      print("jjjjjjjkkkk" + e.toString());
    }
  }

  void _modalBottomSheetMenu(Size size) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return new Container(
            height: size.height * .75,
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.r32.r),
                    topRight: Radius.circular(AppRadius.r32.r))),
            //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: SearchWidget(
              loggedUser: user,
            ),
          );
        });
  }

  Widget consultHome(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: AppSize.h20.h),
        AvaliableWidget(),
        Expanded(
          child: PaginateFirestore(
            key: ValueKey(query),
            itemBuilderType: PaginateBuilderType.gridView,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: (kIsWeb || size.width >= 500) ? 2 : 1,
              crossAxisSpacing: (kIsWeb || size.width >= 500) ? 50 : 30,
              mainAxisSpacing: (kIsWeb || size.width >= 500) ? 50 : 20,
              mainAxisExtent: (kIsWeb || size.width >= 500) ? 361.h : 250.h,
            ),
            padding: EdgeInsets.only(
                left: (kIsWeb || size.width >= 500)
                    ? size.width * .17
                    : size.width * .1,
                right: (kIsWeb || size.width >= 500)
                    ? size.width * .17
                    : size.width * .1,
                bottom: 16.0,
                top: 16.0),
            //Change types accordingly
            itemBuilder: (context, documentSnapshot, index) {
              return AppointmentWiget(
                  //
                  appointment: AppAppointments.fromMap(
                      documentSnapshot[index].data() as Map),
                  loggedUser: user!,
                  theme: "light");
            },
            query: query,
            isLive: true,
          ),
        )
      ],
    );
  }

  Widget interstsWidget(Size size) {
    return (loadInterests == false && _Interests.length > 0)
        ? Container(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h100.h
                : AppSize.h73_3.h,
            child: ListView.separated(
              itemCount: _Interests.length,
              //shrinkWrap: true,
              //physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(0),
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    _onSelected(index);
                  },
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FadeInImage.assetNetwork(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w52_8.w
                                  : AppSize.w32.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h52_8.h
                                  : AppSize.h32.h,
                          placeholder: AssetsManager.lodeGif,
                          placeholderScale: 0.7,
                          imageErrorBuilder: (context, error, stackTrace) =>
                              Image.asset(
                            AssetsManager.whiteJerasLogoIconPath,
                            width: AppSize.w32.w,
                            height: AppSize.h32.h,
                          ),
                          image:
                              (_selectedIndex != -1 && _selectedIndex == index)
                                  ? _Interests[index].activeIcon!
                                  : _Interests[index].icon!,
                          //fit: BoxFit.cover,
                          fadeInDuration: Duration(
                              milliseconds: AppConstants.milliseconds250),
                          fadeInCurve: Curves.easeInOut,
                          fadeOutDuration: Duration(
                              milliseconds: AppConstants.milliseconds150),
                          fadeOutCurve: Curves.easeInOut,
                        ),
                        SizedBox(
                          height: AppSize.h9_3.h,
                        ),
                        //old
                        /*TextWidget(text: _Interests[index].arName, color: (_selectedIndex!=-1&&_selectedIndex==index)?
                     Color.fromRGBO(123 ,108 ,150,1):Color.fromRGBO(147, 147 ,147,1),
                     size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                       ?22.sp:12.sp, weight: FontWeight.w600, align: TextAlign.center,),*/
                        //new
                        TextWidget(
                          text: _Interests[index].arName,
                          color:
                              (_selectedIndex != -1 && _selectedIndex == index)
                                  ? AppColors.linear8
                                  : AppColors.grey1,
                          size:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s22.sp
                                  : AppFontsSizeManager.s16.sp,
                          family: getTranslated(context, "Ithra"),
                          weight: FontWeight.w600,
                          align: TextAlign.center,
                        ),
                        Visibility(
                          visible:
                              (_selectedIndex != -1 && _selectedIndex == index),
                          child: Container(
                            color: AppColors.primaryColor,
                            height: AppSize.h2.h,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: AppSize.w21_3.w,
                );
              },
            ),
          )
        : SizedBox();
  }

  _onSelected(int index) {
    setState(() {
      _selectedIndex = index;
      selectedInteresrId = _Interests[index].interestId;
      query = FirebaseFirestore.instance
          .collection('Users')
          .where("interestListIds", arrayContainsAny: [selectedInteresrId]);

      courseQuery = FirebaseFirestore.instance
          .collection('Courses')
          .where("interestListIds", arrayContainsAny: [selectedInteresrId]);
    });
  }

  AvaliableWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppRadius.r16.r
              : convertPtToPx(AppRadius.r8.r),
          backgroundColor: avaliable ? AppColors.darkGreen : AppColors.red,
        ),
        //old
        /*Text(
          avaliable
              ? getTranslated(context, 'available')
              : getTranslated(context, 'notAvailable'),
          style: TextStyle(
            fontWeight:AppFontsWeightManager.bold300,
            fontFamily: "Ithra",
            fontStyle: FontStyle.normal,
            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
?22:10.0,
            color: AppColors.black2,
          ),
        ),*/
        //new available text
        SizedBox(
          width: AppSize.w8.w,
        ),
        Text(
          avaliable
              ? getTranslated(context, 'available')
              : getTranslated(context, 'notAvailable'),
          style: TextStyle(
            fontWeight: AppFontsWeightManager.bold300,
            fontFamily: "Ithra",
            fontStyle: FontStyle.normal,
            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppFontsSizeManager.s34.sp
                : AppFontsSizeManager.s18_6.sp,
            color: AppColors.black1,
          ),
        ),
      ],
    );
  }

  BoxDecoration decoration({double? radius}) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.linear8,
          AppColors.linear4,
        ],
      ),
      borderRadius: BorderRadius.circular(
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppRadius.r25.r
              : radius == null
                  ? AppRadius.r13.r
                  : radius),
      border: CustomOulinedButton.outlineBorder(),
      // boxShadow: [
      //   BoxShadow(
      //     color: Color.fromRGBO(123, 108, 150, 0.18),
      //     blurRadius: 8.0,
      //     spreadRadius: 0.0,
      //     offset: Offset(0.0, 1.0),
      //   )
      // ],
    );
  }

  Widget consultListWidget(Size size) {
    String languageFilter;
    if (getTranslated(context, "lang") == "ar") {
      languageFilter = "العربية";
    } else if (getTranslated(context, "lang") == "en") {
      languageFilter = "English";
    } else {
      languageFilter = "French";
    }

    // تكوين الاستعلام
    var consultantQuery = query
        .where('userType', isEqualTo: 'CONSULTANT')
        //.where('languages', arrayContains: languageFilter)
        .where('accountStatus', isEqualTo: "Active")
        .orderBy('order', descending: true);
    return Container(
      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.h295.h
          : AppSize.h275.h,
      child: PaginateFirestore(
        key: ValueKey(query),
        onEmpty: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * AppSize.h0_1,
            ),
            TextWidget(
              text: getTranslated(context, "noConsultAvaliable"),
              color: Color.fromRGBO(192, 192, 192, 1),
              size: AppFontsSizeManager.s17.sp,
              weight: FontWeight.w500,
              align: TextAlign.center,
            ),
          ],
        ),
        initialLoader: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * AppSize.h0_1.h,
            ),
            CircularProgressIndicator()
          ],
        ),
        itemBuilderType: PaginateBuilderType.listView,
        scrollDirection: Axis.horizontal,
        separator: SizedBox(
          width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.w45.w
              : AppSize.w21_3.w,
        ),
        /* padding: EdgeInsets.only(
            //left: 16.0,
            // right: 16.0,
            bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? 0
                : AppPadding.p20.h,
            top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? 0
                : AppPadding.p20.h),*/
        //Change types accordingly
        itemBuilder: (context, documentSnapshot, index) {
          final data = documentSnapshot[index].data() as Map;
          return ConsultantListItem(
              consult: GroceryUser.fromMap(data),
              loggedUser: user,
              lang: lang,
              theme: "light");
        },
        query: //consultantQuery,

            query
                //         .where('userType', isEqualTo: 'CONSULTANT')
                //     .where('languages', arrayContains: getTranslated(context, "lang"))
                //         // .where('isArabic', isEqualTo: true)
                //         .where('accountStatus', isEqualTo: "Active")
                .where('phoneNumber', isEqualTo: "+966555555555"),
        //.orderBy('order', descending: true),
        //     // : query
        //     //     .where('userType', isEqualTo: 'CONSULTANT')
        //     //     .where('isEnglish', isEqualTo: true)
        //     //     .where('accountStatus', isEqualTo: "Active")
        //     // // .where('phoneNumber', isEqualTo: "+966555555555")
        //     // .orderBy('order', descending: true),
        isLive: true,
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  update00() async {
    try {
      //delete orders
      var querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where('consult.phone', isEqualTo: "+966999999999")
          .get();

      if (querySnapshot.docs.length > 0) {
        for (var doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection(Paths.ordersPath)
              .doc(doc.id)
              .delete();
        }
      }
      //delete appointment
      querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where('consult.phone', isEqualTo: "+966999999999")
          .get();

      if (querySnapshot.docs.length > 0) {
        for (var doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection(Paths.appAppointments)
              .doc(doc.id)
              .delete();
        }
      }
      //delete forever
      querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.forEverAppointmentsPath)
          .where('consult.phone', isEqualTo: "+966999999999")
          .get();

      if (querySnapshot.docs.length > 0) {
        for (var doc in querySnapshot.docs) {
          await FirebaseFirestore.instance
              .collection(Paths.forEverAppointmentsPath)
              .doc(doc.id)
              .delete();
        }
      }
    } catch (e) {}
  }
}

class _FloatingActionButtons extends StatefulWidget {
  const _FloatingActionButtons({
    required this.user,
  });

  final GroceryUser? user;

  @override
  State<_FloatingActionButtons> createState() => _FloatingActionButtonsState();
}

class _FloatingActionButtonsState extends State<_FloatingActionButtons> {
  bool _showMaleFemaleAction = false;
  late Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p15.w),
          child: Row(
            children: [
              if (_showMaleFemaleAction) ...[
                InkWell(
                  onTap: () {
                    //TODO:: implement the logic when click on male
                  },
                  child: Container(
                    height: 45.h,
                    width: 45.w,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x12000000),
                            offset: Offset(0, 12),
                            blurRadius: 16,
                            spreadRadius: 0)
                      ],
                      gradient: LinearGradient(
                        begin: Alignment(0.5, 0),
                        end: Alignment(0.5, 1),
                        colors: [
                          const Color(0xff6eaad9),
                          const Color(0xff5c9dd0)
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AssetsManager.whiteMaleIconPath,
                        width: AppSize.w20.w,
                        height: AppSize.h25.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w10.w),
                InkWell(
                  onTap: () {
                    //TODO:: implement the logic when click on female
                  },
                  child: Container(
                    height: AppSize.h35.h,
                    width: AppSize.w35.w,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0x12000000),
                            offset: Offset(0, 12),
                            blurRadius: 16,
                            spreadRadius: 0)
                      ],
                      gradient: LinearGradient(
                        begin: Alignment(0.5, 0),
                        end: Alignment(0.5, 1),
                        colors: [
                          const Color(0xfff7c1d1),
                          const Color(0xfff7a4bc)
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/applicationIcons/female-outline.png',
                        width: AppSize.w15.w,
                        height: AppSize.h15.h,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w10.w),
              ],
              InkWell(
                onTap: () {
                  //TODO:: implement the logic when click on gender
                  _showMaleFemaleAction = !_showMaleFemaleAction;
                  setState(() {});
                },
                child: Container(
                  height: AppSize.h35.h,
                  width: AppSize.w35.w,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x12000000),
                        offset: Offset(0, 12),
                        blurRadius: 16,
                        spreadRadius: 0,
                      )
                    ],
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        const Color(0xfff7c1d1),
                        const Color(0xff6eaad9),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      AssetsManager.whiteGender2IconPath,
                      width: AppSize.w15.w,
                      height: AppSize.h15.h,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        InkWell(
          onTap: () {
            if (widget.user == null)
              Navigator.pushNamed(context, '/Register_Type');
            else
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddJobScreen(
                          loggedUser: widget.user!,
                        )),
              );
          },
          child: Container(
            height: 65.h,
            width: 65.w,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.3428587019443512, 0.9015871286392212),
                end: Alignment(0.685713529586792, 0.114285908639431),
                colors: [
                  AppColors.shadoColor,
                  const Color(0xff957dc0),
                ],
              ),
              shape: BoxShape.circle,
              color: AppColors.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x337b6c96),
                  offset: Offset(6, 14),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                AssetsManager.whiteNoteIconPath,
                width: AppSize.w25.w,
                height: AppSize.h25.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
