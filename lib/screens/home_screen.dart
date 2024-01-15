import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart' as db;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:jeras/Utils/helper.dart';
import 'package:jeras/blocs/jitsi_meet/start_call_screen.dart';
import 'package:jeras/blocs/web_rtc_bloc/start_call.dart';
import 'package:jeras/models/SupportList.dart';
import 'package:jeras/models/chat.dart';
import 'package:jeras/screens/PrivacyScreen/privacyscreen.dart';
import 'package:jeras/screens/nameSearchScreen.dart';
import 'package:jeras/screens/allTeachersScreen.dart';
import 'package:jeras/screens/userAccountScreen.dart';
import 'package:jeras/tool_tip/custom_tooltip.dart';
import 'package:jeras/tool_tip/tooltib_model.dart';
import 'package:jeras/tool_tip/tooltip_manager.dart';
import 'package:jeras/tool_tip/tooltip_progress.dart';
import 'package:jeras/screens/supportMessagesScreen.dart';
import 'package:jeras/widget/component/App_Bar/App_Bar.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/component/textWidget.dart';
import 'package:jeras/widget/custom_outlined_button.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/dialogs/calling_dialog.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/searchWidget.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../pages/AppointmentsPage.dart';
import '../../pages/CallHistoryPage.dart';
import '../../pages/TechnicalSupportPage.dart';
import '../../pages/home_page.dart';
import '../blocs/rate_bloc/cuibt/cuibt.dart';
import '../blocs/rate_bloc/cuibt/states.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../controller/blocs/notification_bloc/notification_bloc.dart';
import '../controller/blocs/replace_video_bloc/cubit.dart';
import '../controller/blocs/sign_in_bloc/signin_bloc.dart';
import '../methods/check_if_the_caller_cancel.dart';
import '../methods/parse_duration.dart';
import '../models/user_notification.dart';
import '../repositories/user_data_repository.dart';
import '../services/firebase_service.dart';
import '../shared preferences/shared_preferences.dart';
import '../widget/drawerWidget.dart';
import 'ConsultantDetailsScreen.dart';
import 'courseDetailsScreen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final int? notificationPage;
  final GroceryUser? user2;

  HomeScreen({
    this.user2,
    this.notificationPage,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ToolTipKeysManager _toolTipKeysManager = ToolTipKeysManager();
  final InAppReview inAppReview = InAppReview.instance;
  late int _selectedPage;
  late PageController _pageController;
  late int cartCount;
  late NotificationBloc notificationBloc;
  late UserNotification userNotification;
  final UserDataRepository userDataRepository = UserDataRepository();

  late AccountBloc accountBloc =
      AccountBloc(userDataRepository: userDataRepository);
  late SigninBloc signinBloc;
  User? currentUser = FirebaseAuth.instance.currentUser;
  GroceryUser? user = GroceryUser();
  String userType = "", theme = "light";
  String? userImage, lang, userName;
  late Size size;
  bool load = true, chating = false, first = true;
  late GroceryUser loggedUser;
  String type = "";
  bool cameraGranted = true;
  bool micGranted = true;
  GroceryUser currentUser2 = GroceryUser();

  @override
  void initState() {
    super.initState();
    var controller = VideoCubit.get(context).replaceVidController;
    if (controller != null) {
      print("CONTROLLER");
      VideoCubit.get(context).replaceVidController!.dispose();
    }
    if (kIsWeb && FirebaseAuth.instance.currentUser != null) {
      FirebaseDatabase.instance
          .ref('userCallState')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('callState')
          .onValue
          .listen((event) {
        if (event.snapshot.value == 'calling') {
          /// get the caller data.
          FirebaseDatabase.instance
              .ref('userCallState')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .get()
              .then((callData) {
            Map<dynamic, dynamic> call = callData.value as Map;

            FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(call['callerID'])
                .get()
                .then((value) {
              /// if the caller id == current user id => do not show the dialog.
              if (call['callerID'] != FirebaseAuth.instance.currentUser!.uid) {
                showCallingDialog(
                  context: context,
                  callerId: call['callerID'],
                  receiverId: 'receiverId',
                  callerName: value.data()!['name'],
                );
              }
            });
          });
        }
      });
    }

    if (widget.notificationPage != null)
      _selectedPage = widget.notificationPage!;
    else
      _selectedPage = 0;
    _pageController = PageController(initialPage: _selectedPage);
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
    notificationBloc.stream.listen((state) {});

    if (FirebaseAuth.instance.currentUser != null) {
      // if (kIsWeb) {
      //   trigerCallMethod();
      // }
      /// if the caller cancel the call then the call will canceled in receiver too.
      checkIfTheSenderCanceled(function: () {
        //CallKeep.instance.endAllCalls();
        FlutterCallkitIncoming.endAllCalls();
      });

      // FirebaseFirestore.instance
      //     .collection('Users')
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .get()
      //     .then((value) {
      //   if (value.exists) {
      //     Map<String, dynamic>? data = value.data();
      //     var user = GroceryUser.fromMap(value.data() as Map);
      //
      //     var userbalance = data?['privacy'];
      //     ////
      //     if (userbalance != true) {
      //       Navigator.push(
      //           context,
      //           MaterialPageRoute(
      //               builder: (context) => PrivacyScreen(user: user)));
      //     }
      // }
      //});
    }

    // updateDialog();
    // WidgetsBinding.instance.addPostFrameCallback((_) => getUpdateDialog());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      final Uri link = dynamicLinkData.link;

      if (link.queryParameters['consultant_id'] != null) {
        String? consultantId = link.queryParameters['consultant_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(
                name: 'conslultant?consultant_id=${consultantId}',
                arguments: {"consultant_id": consultantId}),
            builder: (context) => ConsultantDetailsScreen(
              consoltantId: '${consultantId}',
            ),
          ),
        );
        return;
      } else if (link.queryParameters['course_id'] != null) {
        String? course_id = link.queryParameters['course_id'];
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(
                name: 'courses?course_id=${course_id}',
                arguments: {"course_id": course_id}),
            builder: (context) => CourseDetailScreen(
              courseId: '${course_id}',
            ),
          ),
        );
        return;
      }
    }).onError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    if ((CashHelper.getData(key: 'rate') == null)) {
      Future.delayed(Duration(seconds: 1), () {
        Duration twoHours = Duration(hours: 2);
        Duration total = CashHelper.getData(key: 'time') != null
            ? parseDuration(CashHelper.getData(key: 'time'))
            : Duration(hours: 0);
        if ((twoHours <= total) && currentUser != null) {
          showDialog(
              context: context,
              builder: (context) {
                return rateReactionsDialog();
              });
          CashHelper.saveData(
              key: 'time', value: Duration(microseconds: 0).toString());
        }
      });
    }
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: LayoutBuilder(
        builder: (con, cons) => cons.maxWidth >= 500
            ? Scaffold(
                drawer: DrawerWidget(_scaffoldKey),
                //shadow
                //drawerScrimColor: Colors.transparent,
                key: _scaffoldKey,
                body: Stack(children: <Widget>[
                  Container(
                    color: AppColors.black,
                    height: 100,
                    width: 200,
                  ),
                  Column(
                    children: <Widget>[
                      SafeArea(child: headerWidget()),
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: NeverScrollableScrollPhysics(),
                          children: <Widget>[
                            HomePage(
                              userType: userType,
                            ),
                            // rateReactionsDialog(), //0
                            AppointmentsPage(), //1
                            TechnicalSupportPage(), //2
                            CallHistoryPage(), //3
                          ],
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                      bottom: size.height * .05,
                      right: 0,
                      left: 0,
                      child: BlocBuilder(
                        bloc: accountBloc,
                        builder: (context, state) {
                          if (state is GetLoggedUserInProgressState) {
                            return Center(child: userBottomNavigation());
                          } else if (state is GetLoggedUserCompletedState) {
                            user = state.user;
                            if (mounted & first) {
                              FirebaseService.init(
                                  context, currentUser!.uid, currentUser!);
                              notificationBloc.add(
                                  GetAllNotificationsEvent(currentUser!.uid));
                              first = false;
                            }
                            return (user!.userType != "CONSULTANT")
                                ? Center(child: userBottomNavigation())
                                : Center(child: consultBottomNavigation());
                          } else {
                            return Center(child: userBottomNavigation());
                          }
                        },
                      )),
                ]),
              )
            : Scaffold(
                drawer: DrawerWidget(_scaffoldKey),
                //shadow
                //drawerScrimColor: Colors.transparent,
                key: _scaffoldKey,
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white54,
                  ),
                  height: AppSize.h75,
                  width: size.width,
                  child: BlocBuilder(
                    bloc: accountBloc,
                    builder: (context, state) {
                      if (state is GetLoggedUserInProgressState) {
                        return Center(child: userBottomNavigation());
                      } else if (state is GetLoggedUserCompletedState) {
                        user = state.user;
                        if (mounted & first) {
                          FirebaseService.init(
                              context, currentUser!.uid, currentUser!);
                          notificationBloc
                              .add(GetAllNotificationsEvent(currentUser!.uid));
                          first = false;
                        }
                        return size.width >= AppConstants.kIsWebValue
                            ? BottomAppBar(
                                shape: CircularNotchedRectangle(),
                                notchMargin: 6.0,
                                child: (user!.userType != "CONSULTANT")
                                    ? userBottomNavigation()
                                    : consultBottomNavigation(),
                              )
                            : (user!.userType != "CONSULTANT")
                                ? userBottomNavigation()
                                : consultBottomNavigation();
                      } else {
                        return Center(child: userBottomNavigation());
                      }
                    },
                  ),
                ),
                body: Column(
                  children: <Widget>[
                    Stack(children: [
                      Container(
                        height: AppSize.h164.h,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(AssetsManager.islamicPattern),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment(0.5, -0.25),
                            end: Alignment(0.5, 1),
                            colors: [
                              AppColors.linear2,
                              AppColors.linear4,
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(AppPadding.p42_6.r),
                              bottomLeft: Radius.circular(AppPadding.p42_6.r)),
                        ),
                        child: SafeArea(child: headerWidget()),
                      ),
                    ]),
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: NeverScrollableScrollPhysics(),
                        children: <Widget>[
                          HomePage(
                            userType: userType,
                          ), //0
                          AppointmentsPage(), //1
                          TechnicalSupportPage(), //2
                          CallHistoryPage(), //3
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        // floatingActionButton: FloatingActionButton(
        //   child: Icon(Icons.accessibility_outlined),
        //   onPressed: (){
        //     Map<String, Object> featureFlags = {
        //       'add-people.enabled': false,
        //       'audio-focus.disabled': false,
        //       'audio-mute.enabled': true,
        //       'audio-only.enabled': false,
        //       'calendar.enabled': false,
        //       'call-integration.enabled': true,
        //       'car-mode.enabled': false,
        //       'close-captions.enabled': true,
        //       'conference-timer.enabled': true,
        //       'chat.enabled': true,
        //       'invite.enabled': false,
        //       'prejoinpage.enabled': false,
        //       'filmstrip.enabled': true,
        //       'help.enabled': true,
        //       'speakerstats.enabled': true,
        //       'kick-out.enabled': false,
        //       'live-streaming.enabled': false,
        //       'lobby-mode.enabled': false,
        //       'meeting-name.enabled': false,
        //       'meeting-password.enabled': false,
        //       'notifications.enabled': false,
        //       'overflow-menu.enabled': true,
        //       'pip.enabled': true,
        //       'pip-while-screen-sharing.enabled': false,
        //       'prejoinpage.hideDisplayName': false,
        //       'raise-hand.enabled': true,
        //       'reactions.enabled': true,
        //       'recording.enabled': false,
        //       'replace.participant': true,
        //       // 'resolution': 'maximum',
        //       'security-options.enabled': false,
        //       'server-url-change.enabled': false,
        //       'settings.enabled': false,
        //       'tile-view.enabled': false,
        //       'toolbox.alwaysVisible': true,
        //       'toolbox.enabled': true,
        //       'unsaferoomwarning.enabled': false,
        //       'video-mute.enabled': true,
        //       'video-share.enabled': false,
        //       'welcomepage.enabled': false,
        //     };
        //
        //     Map<String, Object> configOverrides = {
        //       "startWithAudioMuted": false,
        //       "startWithVideoMuted": false,
        //       'hideParticipantsStats': false,
        //       'readOnlyName': true,
        //       'giphy': {
        //         'enable': false,
        //       },
        //       'participantsPane': {
        //         'hideModeratorSettingsTab': true,
        //         'hideMoreActionsButton': true,
        //         'hideMuteAllButton': true,
        //       },
        //       'hideAddRoomButton': true,
        //       'breakoutRooms': {
        //         'hideAddRoomButton': true,
        //         'hideAutoAssignButton': true,
        //         'hideJoinRoomButton': true,
        //         'hideModeratorSettingsTab': true,
        //         'hideMoreActionsButton': true,
        //         'hideMuteAllButton': true,
        //       },
        //     };
        //     FirebaseFirestore.instance.collection('servers').doc('featureFlags').set(featureFlags);
        //     FirebaseFirestore.instance.collection('servers').doc('configOverrides').set(configOverrides);
        //   },
      ),
    );

    //);
  }

  void trigerCallMethod() {
    db.FirebaseDatabase.instance
        .ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .onValue
        .listen((event) async {
      var value = Map<String, dynamic>.from(
          event.snapshot.value! as Map<Object?, Object?>);
      if (value['callState'] == 'calling') {
        if (value['roomId'] != null) {
          if (value['callerID'] != null &&
              value['callerID'] != FirebaseAuth.instance.currentUser!.uid) {
            bool acceptcall = false;
            Future(() => StartCall(
                    host: value['roomId'],
                    iscaller: false,
                    acceptNotfi: acceptcall,
                    normalCall: value['isNormal'] ?? true,
                    CallerId: value['callerID'],
                    ReciverId: value['reciverId'],
                    context: context)
                .startCall());
          }
        }
      }

      db.FirebaseDatabase.instance
          .ref('userCallState')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .onDisconnect()
          .set({
        'callState': 'closed',
        'timeStamp': db.ServerValue.timestamp,
        'roomId': value['roomId'],
        'callerID': value['callerID'],
        'reciverId': value['reciverId']
      });
    });
  }

  // void terms_conditions() async {
  //   var collection = FirebaseFirestore.instance.collection('Users');
  //   var documentdata = await collection.doc(widget.user2!.uid).get();
  //
  //   if (documentdata.exists) {
  //     Map<String, dynamic>? data = documentdata.data();
  //     var userbalance = data?['privacy'];
  //
  //     ////
  //     if (userbalance == "false") {
  //       Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => PrivacyScreen(user: widget.user2)));
  //     } else {
  //       /* Navigator.pushNamedAndRemoveUntil(
  //         context,
  //         '/home',
  //             (route) => false,
  //       );*/
  //     }
  //   }
  // }

  Widget headerWidget() {
    return AppBar1(
      widget1: Container(
        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppSize.w97_.r
            : AppSize.w50_6.r,
        height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppSize.h97.r
            : AppSize.h50_6.r,
        child: IconButton1(
            key: _toolTipKeysManager.consultantChatToolTipKey,
            onPress: () {
              if (_scaffoldKey.currentState!.isDrawerOpen) {
                _scaffoldKey.currentState!.openEndDrawer();
              } else {
                _scaffoldKey.currentState!.openDrawer();
              }
            },
            Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.w97_.r
                : AppSize.w50_6.r,
            Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h97.r
                : AppSize.h50_6.r,
            ButtonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppRadius.r16
                : AppRadius.r10_6.r,
            IconWidth: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.w41_1.w
                : AppSize.w32.w,
            IconHeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h36.h
                : AppSize.h32.h,
            IconColor: Theme.of(context).primaryColor,
            Icon:
                lang == "ar" ? AssetsManager.menuRight : AssetsManager.menuLeft,
            ButtonBackground: AppColors.white),
      ),
      widget2: (_selectedPage == 0 && accountBloc.loggeduser.userType == "USER")
          ? Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p21_3.w
                          : AppPadding.p21_3.w),
                  Stack(
                    children: [
                      InkWell(
                        splashColor: Colors.white.withOpacity(0.6),
                        onTap: () {
                          // if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                          //   widget.scaffoldKey.currentState!.openEndDrawer();
                          // } else {
                          //   widget.scaffoldKey.currentState!.openDrawer();
                          // }
                          // if (user!.isDeveloper!)
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) =>
                          //           AllDevelopTechScreen(loggedUser: user!),
                          //     ),
                          //   );
                          // else if (user!.userType != "CONSULTANT")
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => UserAccountScreen(
                          //           user: user!, firstLogged: false),
                          //     ),
                          //   );
                          // else if (user!.userType == "CONSULTANT")
                          //   Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => AccountScreen(
                          //         user: user!,
                          //       ), // firstLogged: false),
                          //     ),
                          //   );
                          // else {
                          //   Navigator.pushNamed(context, '/Register_Type');
                          // }
                        },
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h138.r
                                  : AppSize.h50_6.r,
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w138.r
                                  : AppSize.w50_6.r,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0x33ae9cce),
                                      offset: Offset(0, 6),
                                      blurRadius: 12,
                                      spreadRadius: 0)
                                ],
                                color: Colors.white,
                                border: Border.all(
                                  width: AppSize.w1_5.w,
                                  color: Colors.white,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: accountBloc.loggeduser.photoUrl == null
                                  ? Image.asset(
                                      AssetsManager.whiteJerasLogoIconPath,
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w138.r
                                          : AppSize.w50_6.r,
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h138.r
                                          : AppSize.w50_6.r,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.r56.r),
                                      child: FadeInImage.assetNetwork(
                                        placeholder: AssetsManager
                                            .whiteJerasLogoIconPath,
                                        //placeholderScale: 0.5,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                                Image.asset(
                                          AssetsManager.whiteJerasLogoIconPath,
                                          width: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.w100.r
                                              : AppSize.w50_6.r,
                                          height: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.h100.r
                                              : AppSize.h50_6.r,
                                        ),
                                        image: accountBloc.loggeduser.photoUrl!,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(
                                            milliseconds:
                                                AppConstants.milliseconds250),
                                        fadeInCurve: Curves.easeInOut,
                                        fadeOutDuration: Duration(
                                            milliseconds:
                                                AppConstants.milliseconds150),
                                        fadeOutCurve: Curves.easeInOut,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: 4,
                              left: 0,
                              child: Container(
                                width: AppSize.w10.r,
                                height: AppSize.h10.r,
                                decoration: BoxDecoration(
                                  color: AppColors.darkGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: 1,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w20_5.w
                          : AppSize.w21_3.w),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // لا تنسي ان تحذف ال inkWell
                          TextDefaultWidget(
                            title: getTranslated(context, "hello"),
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s34.sp
                                : AppFontsSizeManager.s21_3.sp,
                            fontFamily: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Ithralight")
                                : getTranslated(context, "Ithra"),
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          SizedBox(
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w20.w
                                  : AppSize.w10.w),
                          (accountBloc.loggeduser.name != null &&
                                  accountBloc.loggeduser.userType ==
                                      "CONSULTANT")
                              ? TextDefaultWidget(
                                  title: getTranslated(context, "lang") == "ar"
                                      ? user!.name!
                                      : getTranslated(context, "lang") == "en"
                                          ? user!.nameEn!
                                          : user!.nameFr!,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s34.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  fontFamily: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? getTranslated(context, "Ithralight")
                                      : getTranslated(context, "Ithra"),
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                )
                              : TextDefaultWidget(
                                  title: accountBloc.loggeduser.name!,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s34.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  fontFamily: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? getTranslated(context, "Ithralight")
                                      : getTranslated(context, "Ithra"),
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                        ],
                      ),
                      TextDefaultWidget(
                        title: getTranslated(context, "welcomeBack"),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s34.sp
                                : AppFontsSizeManager.s21_3.sp,
                        fontFamily:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Ithralight")
                                : getTranslated(context, "Ithralight"),
                        color: AppColors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                  Spacer(),
                ],
              ),
            )
          : SizedBox(),
      widget3: (accountBloc.loggeduser.userType == "USER" && _selectedPage == 2)
          ? InkWell(
              onTap: () {
                Helper.openwhatsapp();
              },
              child: Container(
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w402.w
                    : null,
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h73.h
                    : AppSize.h57_3.h,
                decoration: decoration(radius: AppRadius.r10_6.r),
                child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 0
                          : AppPadding.p10,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 0
                          : AppPadding.p10),
                  child: Row(
                    children: [
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? Spacer()
                          : SizedBox(),
                      SvgPicture.asset(
                        AssetsManager.whatsappIconPath,
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h36.h
                                : AppSize.w26_6.w,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h36.h
                                : AppSize.h26_6.h,
                      ),
                      SizedBox(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w16.w
                                : AppSize.w10,
                      ),
                      Text(
                        getTranslated(context, "CommunicateWithSupervisor"),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s24.sp
                                  : AppFontsSizeManager.s16.sp,
                          fontWeight: AppFontsWeightManager.bold700,
                        ),
                      ),
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? Spacer()
                          : SizedBox(),
                    ],
                  ),
                ),
              ),
            )
          : SizedBox(),
      widget4: (_selectedPage == 0 && accountBloc.loggeduser.userType == "USER")
          ? Row(
              children: [
                Container(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w97_.r
                      : AppSize.w50_6.r,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h97.r
                      : AppSize.h50_6.r,
                  decoration: decoration(radius: AppRadius.r10_6.r),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r50),
                      child: Material(
                        color: AppColors.white,
                        child: InkWell(
                          onTap: () {
                            if (accountBloc.loggeduser != null &&
                                accountBloc.loggeduser.userType == "SUPPORT")
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NameSearchScreen(
                                    loggedUser: user!,
                                  ),
                                ),
                              );
                            /*else
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SearchScreen(loggedUser: user),
                                ),
                              );*/
                          },
                          child: SvgPicture.asset(
                            AssetsManager.search3IconPath,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w41_1.w
                                : AppSize.w3.w,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h36.h
                                : AppSize.h32.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p21_3.w
                        : AppPadding.p21_3.w),
              ],
            )
          : SizedBox(),
      widget5: currentUser == null
          ? noNotificationWidget()
          : BlocBuilder(
              bloc: notificationBloc,
              buildWhen: (previous, current) {
                if (current is GetAllNotificationsInProgressState ||
                    current is GetAllNotificationsFailedState ||
                    current is GetAllNotificationsCompletedState ||
                    current is GetNotificationsUpdateState) {
                  print(user!.userType);
                  return true;
                }
                return false;
              },
              builder: (context, state) {
                if (state is GetAllNotificationsInProgressState) {
                  return noNotificationWidget();
                }
                if (state is GetNotificationsUpdateState) {
                  if (state.userNotification.notifications.length == 0) {
                    return noNotificationWidget();
                  }
                  userNotification = state.userNotification;
                  if (userNotification.notifications.length > 100)
                    Fluttertoast.showToast(
                        msg: getTranslated(context, "removeNotification"),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        backgroundColor: AppColors.red,
                        textColor: AppColors.white,
                        fontSize: AppFontsSizeManager.s16.sp);
                  return Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ///**------------------>>>>>SHOW TOOL TIPS FOR USER<<<<<------------------**///
                      if (user != null && user!.userType == "USER")
                        Stack(
                          children: [
                            // Container(
                            //   height: 650,
                            //   width: 360,
                            //   color: AppColors.black,
                            // ),
                            CustomTooltipManager(
                              tooltips: [
                                TooltipData(
                                  getTranslated(
                                      context, "notificationToolTipText"),
                                  _toolTipKeysManager.notificationTipKey,
                                  Offset(lang == "ar" ? 7.w : 296.w, 15.h),
                                  "save1",
                                ),
                                TooltipData(
                                  getTranslated(context, "searchToolTipText"),
                                  _toolTipKeysManager.searchTipKey,
                                  Offset(55.w, 47.h),
                                  "save2",
                                ),
                                TooltipData(
                                  getTranslated(context, "adsToolTipText"),
                                  _toolTipKeysManager.adsToolTip,
                                  Offset(8.w, lang == "ar" ? 445.h : 410.h),
                                  "save3",
                                ),
                                TooltipData(
                                  getTranslated(
                                      context, "appointmentToolTipText"),
                                  _toolTipKeysManager.appointmentTip,
                                  Offset(152.w, lang == "ar" ? 650.h : 635.h),
                                  "save4",
                                ),
                                TooltipData(
                                  getTranslated(context, "supportToolTipText"),
                                  _toolTipKeysManager.supportCenterTipKey,
                                  Offset(lang == "ar" ? 13.w : 285.w,
                                      lang == "ar" ? 650.h : 635.h),
                                  "save5",
                                ),
                              ],
                              tooltipBuilder: (context, message, showNext,
                                  currentIndex, total, closeToolTip) {
                                return Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Column(
                                      children: [
                                        if (currentIndex == 0 ||
                                            currentIndex == 1)
                                          Stack(
                                            alignment: Alignment.bottomCenter,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: currentIndex == 0
                                                        ? lang == "ar"
                                                            ? 170.w
                                                            : 0
                                                        : 125.w,
                                                    left: currentIndex == 0
                                                        ? lang == "ar"
                                                            ? 0.w
                                                            : 170.w
                                                        : 0),
                                                child: Lottie.asset(
                                                    'assets/lotifile/tool_tip_animation.json',
                                                    width: AppSize.w100.w,
                                                    height: AppSize.h100.h),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    right: currentIndex == 0
                                                        ? lang == "ar"
                                                            ? 170.w
                                                            : 0
                                                        : 125.w,
                                                    left: currentIndex == 0
                                                        ? lang == "ar"
                                                            ? 0.w
                                                            : 170.w
                                                        : 0),
                                                child: ClipPath(
                                                  clipper: TriangleClipper(),
                                                  child: Container(
                                                    key: _toolTipKeysManager
                                                        .searchTipKey,
                                                    width: 21.3.w,
                                                    // Adjust the width as needed
                                                    height: 10.6.h,
                                                    // Adjust the height as needed
                                                    color: AppColors.linear2,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        GestureDetector(
                                          onTap: showNext,
                                          child: Container(
                                            key: _toolTipKeysManager.adsToolTip,
                                            width: AppSize.w272.w,
                                            height: lang == "ar"
                                                ? AppSize.h208.h
                                                : AppSize.h225_7.h,
                                            child: Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme: ColorScheme.light(
                                                    primary: AppColors.white),
                                              ),
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        color: AppColors
                                                            .primaryColor,
                                                        width: AppSize.w1.w),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppRadius.r16.r)),
                                                color: Colors.white,
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        IconButton(
                                                            onPressed:
                                                                closeToolTip,
                                                            icon: Icon(
                                                              Icons.close,
                                                              color: AppColors
                                                                  .linear2,
                                                              size:
                                                                  AppSize.w21.r,
                                                            ))
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              AppPadding.p16.w,
                                                          left:
                                                              AppPadding.p10.w,
                                                          bottom:
                                                              AppPadding.p10.h),
                                                      child: Text(
                                                        message,
                                                        style: TextStyle(
                                                          color:
                                                              AppColors.linear2,
                                                          fontFamily: lang ==
                                                                  "ar"
                                                              ? getTranslated(
                                                                  context,
                                                                  "Ithra")
                                                              : getTranslated(
                                                                  context,
                                                                  "Montserratsemibold"),
                                                          fontSize:
                                                              AppFontsSizeManager
                                                                  .s16.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              AppPadding.p20.w,
                                                          left: lang == "ar"
                                                              ? 0
                                                              : AppPadding
                                                                  .p20.w),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            width: 60,
                                                            height: 7,
                                                            child:
                                                                ToolTipProgressListView(
                                                              select:
                                                                  currentIndex,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                AppSize.w30.w,
                                                          ),
                                                          Container(
                                                            width:
                                                                AppSize.w80.w,
                                                            height:
                                                                AppSize.h40.h,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: AppColors
                                                                  .linear2,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          AppRadius
                                                                              .r10
                                                                              .r),
                                                              gradient:
                                                                  LinearGradient(
                                                                begin:
                                                                    Alignment(
                                                                        0.5, 0),
                                                                end: Alignment(
                                                                    0.5, 1),
                                                                colors: [
                                                                  AppColors
                                                                      .linear8,
                                                                  AppColors
                                                                      .linear4,
                                                                ],
                                                              ),
                                                            ),
                                                            child:
                                                                GestureDetector(
                                                              onTap: showNext,
                                                              child: Center(
                                                                child: Text(
                                                                  getTranslated(
                                                                      context,
                                                                      "goNext"),
                                                                  style:
                                                                      TextStyle(
                                                                    color: AppColors
                                                                        .white,
                                                                    fontFamily: getTranslated(
                                                                        context,
                                                                        "Ithra"),
                                                                    fontSize:
                                                                        AppFontsSizeManager
                                                                            .s13_5
                                                                            .sp,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                new BoxShadow(
                                                  color: Color.fromRGBO(
                                                      123, 108, 150, 0.1),
                                                  blurRadius: 16.r,
                                                  spreadRadius: 0.0,
                                                  offset: Offset(0.0, 1.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        if (currentIndex == 2 ||
                                            currentIndex == 3 ||
                                            currentIndex == 4)
                                          Stack(
                                            alignment: Alignment.topCenter,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: currentIndex == 4
                                                        ? lang == "ar"
                                                            ? 0
                                                            : 110.w
                                                        : 0,
                                                    right: currentIndex == 2
                                                        ? 140.w
                                                        : currentIndex == 4
                                                            ? lang == "ar"
                                                                ? 110.w
                                                                : 0
                                                            : 0),
                                                child: Lottie.asset(
                                                    'assets/lotifile/tool_tip_animation.json',
                                                    width: AppSize.w100.w,
                                                    height: AppSize.h100.h),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: currentIndex == 4
                                                        ? lang == "ar"
                                                            ? 0
                                                            : 110.w
                                                        : 0,
                                                    right: currentIndex == 2
                                                        ? 140.w
                                                        : currentIndex == 4
                                                            ? lang == "ar"
                                                                ? 110.w
                                                                : 0
                                                            : 0),
                                                child: RotationTransition(
                                                  turns:
                                                      new AlwaysStoppedAnimation(
                                                          180 / 360),
                                                  child: ClipPath(
                                                    clipper: TriangleClipper(),
                                                    child: Container(
                                                      width: 16,
                                                      // Adjust the width as needed
                                                      height: 8,
                                                      // Adjust the height as needed
                                                      color: AppColors.linear2,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),

                      ///**------------------>>>>>SHOW TOOL TIPS FOR CONSULTANT<<<<<------------------**///
                      if (user != null && user!.userType == "CONSULTANT")
                        CustomTooltipManager(
                          tooltips: [
                            TooltipData(
                              getTranslated(context, "notificationToolTipText"),
                              _toolTipKeysManager.notificationTipKey,
                              Offset(
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? lang == "ar"
                                          ? 103.w
                                          : 1539.w
                                      : lang == "ar"
                                          ? 8.w
                                          : 295.w,
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? -70.h
                                      : 22.h),
                              "save6",
                            ),
                            TooltipData(
                              getTranslated(context, "consultantChatTipTxt"),
                              _toolTipKeysManager.consultantChatToolTipKey,
                              Offset(
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 500
                                      : 252.w,
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 355.h
                                      : 360.h),
                              "save7",
                            ),
                            TooltipData(
                              getTranslated(
                                  context, "consultantAppointmentTipTxt"),
                              _toolTipKeysManager
                                  .consultantAppointmentToolTipKey,
                              Offset(
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? lang == "ar"
                                          ? 1105.w
                                          : 540.w
                                      : lang == "ar"
                                          ? 285.w
                                          : 17.5.w,
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 550.h
                                      : 670.h),
                              "save8",
                            ),
                            TooltipData(
                              getTranslated(context, "consultantCallHisTipTxt"),
                              _toolTipKeysManager
                                  .consultantCallHistoryToolTipKey,
                              Offset(
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 665
                                      : 155.w,
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 515.h
                                      : 670.h),
                              "save9",
                            ),
                            TooltipData(
                              getTranslated(context, "supportToolTipText"),
                              _toolTipKeysManager.consultantSupportCenterTipKey,
                              Offset(
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? lang == "ar"
                                          ? 435
                                          : 880
                                      : lang == "ar"
                                          ? 17.5.w
                                          : 280.w,
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 550.h
                                      : 670.h),
                              "save10",
                            ),
                          ],
                          tooltipBuilder: (context, message, showNext,
                              currentIndex, total, closeToolTip) {
                            return Column(
                              children: [
                                if (currentIndex == 0 || currentIndex == 1)
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: currentIndex == 0
                                                ? lang == "ar"
                                                    ? 170.w
                                                    : 0
                                                : 0,
                                            left: currentIndex == 0
                                                ? lang == "ar"
                                                    ? 0.w
                                                    : 170.w
                                                : 0),
                                        child: Lottie.asset(
                                            'assets/lotifile/tool_tip_animation.json',
                                            width: AppSize.w100.w,
                                            height: AppSize.h100.h),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            right: currentIndex == 0
                                                ? lang == "ar"
                                                    ? 170.w
                                                    : 0
                                                : 0,
                                            left: currentIndex == 0
                                                ? lang == "ar"
                                                    ? 0.w
                                                    : 170.w
                                                : 0),
                                        child: ClipPath(
                                          clipper: TriangleClipper(),
                                          child: Container(
                                            width: 21.3
                                                .w, // Adjust the width as needed
                                            height: 10.6
                                                .h, // Adjust the height as needed
                                            color: AppColors.linear2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                GestureDetector(
                                  onTap: showNext,
                                  child: Container(
                                    width: AppSize.w272.w,
                                    height: AppSize.h208.h,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: ColorScheme.light(
                                            primary: AppColors.white),
                                      ),
                                      child: Card(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r16.r),
                                          side: BorderSide(
                                              color: AppColors.primaryColor,
                                              width: AppSize.w1.w),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                IconButton(
                                                    onPressed: closeToolTip,
                                                    icon: Icon(
                                                      Icons.close,
                                                      color: AppColors.linear2,
                                                      size: AppSize.w21.r,
                                                    ))
                                              ],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: AppPadding.p16.w,
                                                  left: AppPadding.p10.w,
                                                  bottom: AppPadding.p10.h),
                                              child: Text(
                                                message,
                                                style: TextStyle(
                                                  color: AppColors.linear2,
                                                  fontFamily: lang == "ar"
                                                      ? getTranslated(
                                                          context, "Ithra")
                                                      : getTranslated(context,
                                                          "Montserratsemibold"),
                                                  fontSize: AppFontsSizeManager
                                                      .s16.sp,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  right: AppPadding.p20.w,
                                                  left: lang == "ar"
                                                      ? 0
                                                      : AppPadding.p20.w),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 60,
                                                    height: 7,
                                                    child:
                                                        ToolTipProgressListView(
                                                      select: currentIndex,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: AppSize.w30.w,
                                                  ),
                                                  Container(
                                                    width: AppSize.w80.w,
                                                    height: AppSize.h40.h,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.linear2,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.r10.r),
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment(0.5, 0),
                                                        end: Alignment(0.5, 1),
                                                        colors: [
                                                          AppColors.linear8,
                                                          AppColors.linear4,
                                                        ],
                                                      ),
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: showNext,
                                                      child: Center(
                                                        child: Text(
                                                          getTranslated(context,
                                                              "goNext"),
                                                          style: TextStyle(
                                                            color:
                                                                AppColors.white,
                                                            fontFamily:
                                                                getTranslated(
                                                                    context,
                                                                    "Ithra"),
                                                            fontSize:
                                                                AppFontsSizeManager
                                                                    .s13_5.sp,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        new BoxShadow(
                                          color: Color.fromRGBO(
                                              123, 108, 150, 0.1),
                                          blurRadius: 16.r,
                                          spreadRadius: 0.0,
                                          offset: Offset(0.0, 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (currentIndex == 2 ||
                                    currentIndex == 3 ||
                                    currentIndex == 4)
                                  Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: currentIndex == 2
                                                ? lang == "ar"
                                                    ? 110.w
                                                    : 0
                                                : currentIndex == 4
                                                    ? lang == "ar"
                                                        ? 0
                                                        : 120.w
                                                    : 0,
                                            right: currentIndex == 4
                                                ? lang == "ar"
                                                    ? 120.w
                                                    : 0
                                                : currentIndex == 2
                                                    ? lang == "ar"
                                                        ? 0
                                                        : 120.w
                                                    : 0),
                                        child: Lottie.asset(
                                            'assets/lotifile/tool_tip_animation.json',
                                            width: AppSize.w100.w,
                                            height: AppSize.h100.h),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: currentIndex == 2
                                                ? lang == "ar"
                                                    ? 110.w
                                                    : 0
                                                : currentIndex == 4
                                                    ? lang == "ar"
                                                        ? 0
                                                        : 120.w
                                                    : 0,
                                            right: currentIndex == 4
                                                ? lang == "ar"
                                                    ? 120.w
                                                    : 0
                                                : currentIndex == 2
                                                    ? lang == "ar"
                                                        ? 0
                                                        : 120.w
                                                    : 0),
                                        child: RotationTransition(
                                          turns: new AlwaysStoppedAnimation(
                                              180 / 360),
                                          child: ClipPath(
                                            clipper: TriangleClipper(),
                                            child: Container(
                                              width:
                                                  16, // Adjust the width as needed
                                              height:
                                                  8, // Adjust the height as needed
                                              color: AppColors.linear2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),

                      Container(
                        width: AppSize.w50_6.r,
                        height: AppSize.h50_6.r,
                        child: IconButton1(
                            key: _toolTipKeysManager.notificationTipKey,
                            onPress: () {
                              if (userNotification.unread) {
                                notificationBloc.add(
                                  NotificationMarkReadEvent(currentUser!.uid),
                                );
                              }
                              //notification icon data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NotificationScreen(
                                    userNotification: userNotification,
                                  ),
                                ),
                              );
                            },
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w75.w
                                : AppSize.w50_6.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w75.h
                                : AppSize.h45.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r16
                                : AppRadius.r10_6.r,
                            IconWidth: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w42
                                : AppSize.w22.w,
                            IconHeight: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h48
                                : AppSize.h20.h,
                            IconColor: AppColors.pink,
                            Icon: AssetsManager.blackNotification,
                            ButtonBackground: AppColors.white),
                      ),

                      userNotification.unread
                          ? Positioned(
                              right: AppPadding.p4,
                              top: AppPadding.p4,
                              child: Container(
                                height: AppSize.h7_5.r,
                                width: AppSize.w7_5.r,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      (userNotification.notifications.length >
                                              100)
                                          ? AppColors.red
                                          : AppColors.white,
                                ),
                              ),
                            )
                          : SizedBox(),
                    ],
                  );
                }
                return noNotificationWidget();
              },
            ),
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
    } catch (e) {}
  }

  BoxDecoration decoration({double? radius}) {
    return BoxDecoration(
      color: AppColors.white,
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

  Widget noNotificationWidget() {
    return Container(
      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.w75.w
          : AppSize.w50_6.r,
      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.w75.h
          : AppSize.h50_6.r,
      decoration: decoration(radius: AppRadius.r10_6.r),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.r50),
          child: Material(
            color: AppColors.white,
            child: InkWell(
              splashColor: Colors.white.withOpacity(0.6),
              onTap: () {
                Fluttertoast.showToast(
                    msg: getTranslated(context, "noNotification"),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: AppColors.red,
                    textColor: AppColors.white,
                    fontSize: AppFontsSizeManager.s16);
              },
              child: SvgPicture.asset(
                AssetsManager.notificationIconPath,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w30
                    : AppSize.w23_8.w,
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h30
                    : AppSize.h27_7.h,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget webTapButton(GroceryUser? _user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: AppSize.h35,
          width: AppSize.w35,
          decoration: decoration(),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r50),
              child: Material(
                color: AppColors.white,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.6),
                  onTap: () {
                    Fluttertoast.showToast(
                        msg: getTranslated(context, "noNotification"),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: AppColors.red,
                        textColor: AppColors.white,
                        fontSize: AppFontsSizeManager.s16);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                    ),
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h30
                        : AppSize.h20,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w30
                        : AppSize.w20,
                    child: Image.asset(
                      AssetsManager.blackNotification,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * AppSize.w0_05,
        ),
        Container(
          height: AppSize.h35,
          width: AppSize.w35,
          decoration: decoration(),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r50),
              child: Material(
                color: AppColors.white,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.6),
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, '/Register_Type');
                    } else {
                      _pageController.jumpToPage(
                        2,
                      );
                    }
                    setState(() {
                      _selectedPage = 2;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                    ),
                    width: AppSize.w20,
                    height: AppSize.h20,
                    child: Image.asset(
                      _selectedPage == 2
                          ? AssetsManager.selectSupportCenterIconPath
                          : AssetsManager.unselectSupportCenterIconPath,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * AppSize.w0_05,
        ),
        Container(
          height: AppSize.h35,
          width: AppSize.w35,
          decoration: decoration(),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r50),
              child: Material(
                color: AppColors.white,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.6),
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, '/Register_Type');
                    } else {
                      _pageController.jumpToPage(
                        1,
                      );
                      setState(() {
                        _selectedPage = 1;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                    ),
                    width: AppSize.w20,
                    height: AppSize.h20,
                    child: Image.asset(
                      _selectedPage == 1
                          ? AssetsManager.selectAppointmentIconPath
                          : AssetsManager.unselectAppointmentIconPath,
                      width: kIsWeb || size.width >= AppConstants.kIsWebValue
                          ? AppSize.w40
                          : AppSize.w35,
                      height: kIsWeb || size.width >= AppConstants.kIsWebValue
                          ? AppSize.h40
                          : AppSize.h35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: size.width * AppSize.w0_05,
        ),
        Container(
          height: AppSize.h35,
          width: AppSize.w35,
          decoration: decoration(),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r50),
              child: Material(
                color: AppColors.white,
                child: InkWell(
                  splashColor: Colors.white.withOpacity(0.6),
                  onTap: () {
                    _pageController.jumpToPage(
                      0,
                    );
                    setState(() {
                      _selectedPage = 0;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                    ),
                    width: AppSize.w20,
                    height: AppSize.h20,
                    child: Image.asset(
                      _selectedPage == 0
                          ? AssetsManager.selectHomeIconPath
                          : AssetsManager.unselectHomeIconPath,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget userBottomNavigation() {
    return Container(
      width: kIsWeb || size.width >= AppConstants.kIsWebValue
          ? AppSize.w1015.w
          : AppSize.w574.w,
      height: kIsWeb || size.width >= AppConstants.kIsWebValue
          ? AppSize.h140.h
          : AppSize.h96.h,
      decoration: kIsWeb || size.width >= AppConstants.kIsWebValue
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r50),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 17.0),
                    blurRadius: 45.0,
                    spreadRadius: 0.0,
                    color: Color.fromRGBO(0, 0, 0, 0.08)),
              ],
            )
          : BoxDecoration(
              color: AppColors.white,
            ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _pageController.jumpToPage(
                  0,
                );
                setState(() {
                  _selectedPage = 0;
                });
              },
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _selectedPage == 0
                          ? AssetsManager.selectHomeIconPath
                          : AssetsManager.unselectHomeIconPath,
                      width: kIsWeb || size.width >= AppConstants.kIsWebValue
                          ? AppSize.w66.w
                          : AppSize.w46_6.w,
                      height: kIsWeb || size.width >= AppConstants.kIsWebValue
                          ? AppSize.h63_5.h
                          : AppSize.h46_6.h,
                    ),
                    SizedBox(height: AppSize.h3.h),
                    Text(
                      getTranslated(context, "home"),
                      style: TextStyle(
                        color: _selectedPage == 0
                            ? AppColors.linear8
                            : AppColors.grey2,
                        fontWeight:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? FontWeight.w500
                                : FontWeight.w300,
                        fontFamily:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Montserrat")
                                : getTranslated(context, "Ithra"),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s23.sp
                                : AppFontsSizeManager.s16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  Navigator.pushNamed(context, '/Register_Type');
                } else {
                  _pageController.jumpToPage(
                    1,
                  );
                }
                setState(() {
                  _selectedPage = 1;
                });
              },
              child: Container(
                key: _toolTipKeysManager.appointmentTip,
                width: kIsWeb || size.width >= AppConstants.kIsWebValue
                    ? AppSize.w25
                    : size.width * AppSize.w0_33,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        _selectedPage == 1
                            ? AssetsManager.selectAppointmentIconPath
                            : AssetsManager.unselectAppointmentIconPath,
                        width: kIsWeb || size.width >= AppConstants.kIsWebValue
                            ? AppSize.w66.w
                            : AppSize.w46_6.w,
                        height: kIsWeb || size.width >= AppConstants.kIsWebValue
                            ? AppSize.h63_5.h
                            : AppSize.h46_6.h,
                      ),
                      SizedBox(height: AppSize.h3.h),
                      Text(
                        getTranslated(context, "appointments"),
                        style: TextStyle(
                          color: _selectedPage == 1
                              ? Theme.of(context).primaryColor
                              : AppColors.borderLightGrey,
                          fontWeight:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                          fontFamily:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s23.sp
                                  : AppFontsSizeManager.s16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                if (FirebaseAuth.instance.currentUser == null) {
                  Navigator.pushNamed(context, '/Register_Type');
                } else {
                  _pageController.jumpToPage(
                    2,
                  );
                }
                setState(() {
                  _selectedPage = 2;
                  type = "user";
                });
              },
              child: Row(
                children: [
                  Container(
                    key: _toolTipKeysManager.supportCenterTipKey,
                    width: kIsWeb || size.width >= AppConstants.kIsWebValue
                        ? AppSize.w25
                        : size.width * AppSize.w0_33,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _selectedPage == 2
                                ? AssetsManager.selectSupportCenterIconPath
                                : AssetsManager.unselectSupportCenterIconPath,
                            width:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.w66.w
                                    : AppSize.w46_6.w,
                            height:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.h63_5.h
                                    : AppSize.h46_6.h,
                          ),
                          SizedBox(height: AppSize.h3.h),
                          Text(
                            getTranslated(context, "support"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedPage == 2
                                  ? Theme.of(context).primaryColor
                                  : AppColors.borderLightGrey,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                              fontFamily: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s23.sp
                                  : AppFontsSizeManager.s16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget consultBottomNavigation() {
    return Container(
      width: kIsWeb || size.width >= AppConstants.kIsWebValue
          ? AppSize.w1015.w
          : AppSize.w574.w,
      height: kIsWeb || size.width >= AppConstants.kIsWebValue
          ? AppSize.h140.h
          : AppSize.h96.h,
      decoration: kIsWeb || size.width >= AppConstants.kIsWebValue
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(
                  kIsWeb || size.width >= AppConstants.kIsWebValue
                      ? AppRadius.r70.r
                      : AppRadius.r50.r),
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 17.0),
                    blurRadius: 45.0,
                    spreadRadius: 0.0,
                    color: Color.fromRGBO(0, 0, 0, 0.08)),
              ],
            )
          : BoxDecoration(
              color: AppColors.white,
            ),
      child: Column(
        children: [
          /* kIsWeb || size.width >= AppConstants.kIsWebValue
              ? Container(height: AppSize.h5.h)
              : Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1,
                  width: size.width),*/
          SizedBox(height: AppSize.h5.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, '/Register_Type');
                    } else {
                      _pageController.jumpToPage(
                        0,
                      );
                    }

                    setState(() {
                      _selectedPage = 0;
                    });
                  },
                  child: Container(
                    key: _toolTipKeysManager.consultantAppointmentToolTipKey,
                    width: kIsWeb || size.width >= AppConstants.kIsWebValue
                        ? 25.0
                        : size.width * AppSize.w0_33,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _selectedPage == 0
                                ? AssetsManager.selectAppointmentIconPath
                                : AssetsManager.unselectAppointmentIconPath,
                            width:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.w66.r
                                    : AppSize.w46.r,
                            height:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.h63_5.r
                                    : AppSize.h46.r,
                          ),
                          SizedBox(
                            height: AppSize.h10.h,
                          ),
                          Text(
                            getTranslated(context, "appointments"),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedPage == 0
                                  ? Theme.of(context).primaryColor
                                  : AppColors.borderLightGrey,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                              fontFamily: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s23.sp
                                  : AppFontsSizeManager.s16.sp,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _pageController.jumpToPage(
                      3,
                    );
                    setState(() {
                      _selectedPage = 3;
                    });
                  },
                  child: Container(
                    key: _toolTipKeysManager.consultantCallHistoryToolTipKey,
                    width: kIsWeb || size.width >= AppConstants.kIsWebValue
                        ? AppSize.w25
                        : size.width * AppSize.w0_33,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _selectedPage == 3
                                ? AssetsManager.selectPhoneClock
                                : AssetsManager.unselectPhoneClock,
                            width:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.w66.r
                                    : AppSize.w46.r,
                            height:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.h63_5.r
                                    : AppSize.h46.r,
                          ),
                          SizedBox(
                            height: AppSize.h10.h,
                          ),
                          Text(
                            getTranslated(context, "callHistory"),
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedPage == 3
                                  ? Theme.of(context).primaryColor
                                  : AppColors.borderLightGrey,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                              fontFamily: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s23.sp
                                  : AppFontsSizeManager.s16.sp,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser == null) {
                      Navigator.pushNamed(context, '/Register_Type');
                    } else {
                      _pageController.jumpToPage(
                        2,
                      );
                    }
                    setState(() {
                      _selectedPage = 2;
                    });
                  },
                  child: Container(
                    key: _toolTipKeysManager.consultantSupportCenterTipKey,
                    width: kIsWeb || size.width >= AppConstants.kIsWebValue
                        ? AppSize.w25
                        : size.width * AppSize.w0_33,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            _selectedPage == 2
                                ? AssetsManager.selectSupportCenterIconPath
                                : AssetsManager.unselectSupportCenterIconPath,
                            width:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.w66.r
                                    : AppSize.w46.r,
                            height:
                                kIsWeb || size.width >= AppConstants.kIsWebValue
                                    ? AppSize.h63_5.r
                                    : AppSize.h46.r,
                          ),
                          SizedBox(
                            height: AppSize.h10.h,
                          ),
                          Text(
                            getTranslated(context, "support"),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _selectedPage == 2
                                  ? Theme.of(context).primaryColor
                                  : AppColors.borderLightGrey,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? FontWeight.w500
                                  : FontWeight.w300,
                              fontFamily: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s23.sp
                                  : AppFontsSizeManager.s16.sp,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget rateReactionsDialog() {
    return BlocProvider(
        create: (context) => RateCubit(RateInitialState()),
        child: BlocConsumer<RateCubit, RateStates>(
            listener: (context, state) {},
            builder: (context, state) {
              return Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h612.h
                      : AppSize.h340.h,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w793.w
                      : AppSize.w433_3.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p50.w
                                : 0,
                            vertical: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p32.h
                                : 0),
                        child: Align(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: Image.asset(
                              AssetsManager.closeDialog2,
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h29_9.h
                                  : AppSize.h21_3.h,
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w30_4.w
                                  : AppSize.w21_3.w,
                            ),
                          ),
                          alignment: AlignmentDirectional.topStart,
                        ),
                      ),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h60_1.h
                                : 0,
                      ),
                      AutoSizeText(
                        getTranslated(context, 'rate_qs3'),
                        style: TextStyle(
                          fontFamily: 'Ithra_Bold',
                          color: AppColors.grey_dark,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : AppFontsSizeManager.s24.sp,
                          fontWeight: AppFontsWeightManager.bold,
                        ),
                        minFontSize: 13,
                        // The smallest possible font size to display.
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h69.h
                                : AppSize.h26_6.h,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p55_5.w
                                : 0),
                        alignment: Alignment.center,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h120.h
                                : AppSize.h67_8.h,
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width
                                : AppSize.w383_2.w,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) => InkWell(
                            onTap: () {
                              RateCubit.get(context).changeSelected(
                                  RateCubit.get(context).reactions[index]);
                              print(
                                  RateCubit.get(context).selected!.keys.first);
                            },
                            child: Container(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h120.h
                                  : AppSize.h67_8.h,
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w120.w
                                  : AppSize.w67_8.w,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.transparent,
                                child: Image.asset(
                                  RateCubit.get(context)
                                      .reactions[index]
                                      .keys
                                      .first,
                                  height: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.h82.h
                                      : AppSize.h33_4.h,
                                  width: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.w83_4.w
                                      : AppSize.w34.w,
                                ),
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    end: Alignment.topCenter,
                                    begin: Alignment.bottomCenter,
                                    colors: (RateCubit.get(context).selected ==
                                            RateCubit.get(context)
                                                .reactions[index])
                                        ? [
                                            AppColors.save2,
                                            AppColors.save1,
                                          ]
                                        : [
                                            AppColors.lightGray2,
                                            AppColors.lightGray2
                                          ]),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          separatorBuilder: (context, index) => SizedBox(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w20.w
                                : AppSize.w8_2.w,
                          ),
                          itemCount: RateCubit.get(context).reactions.length,
                        ),
                      ),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h85.h
                                : AppSize.h26_6.h,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          if (RateCubit.get(context).selected != null) {
                            Navigator.pop(context);
                            CashHelper.saveData(key: 'rate', value: 'true');
                            print(
                                RateCubit.get(context).selected!.values.single);
                            user!.rate =
                                RateCubit.get(context).selected!.values.single;
                            accountBloc
                                .add(UpdateAccountDetailsEvent(user: user!));
                            if (await inAppReview.isAvailable()) {
                              inAppReview.requestReview();
                            }
                          } else {
                            showSnakbar(
                                getTranslated(context, 'snakbar_msg'), true);
                          }
                        },
                        child: Container(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h84.h
                                  : AppSize.h56.h,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w464.w
                                  : AppSize.w369_3.w,
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                end: Alignment.topCenter,
                                begin: Alignment.bottomCenter,
                                colors: [
                                  AppColors.save1,
                                  AppColors.save2,
                                ],
                              ),
                              borderRadius: BorderRadius.circular((kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r16.r
                                  : AppRadius.r8.r)),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'send_rating'),
                              style: TextStyle(
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s36.sp
                                    : AppFontsSizeManager.s21_3.sp,
                                color: AppColors.white1,
                                fontFamily: 'Ithra_Bold',
                                fontWeight: AppFontsWeightManager.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h71.h
                                : 0,
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.r18.r),
                    color: AppColors.white,
                  ),
                ),
              );
            }));
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: AppColors.white,
        fontSize: 16.0.sp);
  }

  Widget search(Size size) {
    return Row(
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
            padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? EdgeInsets.symmetric(
                    horizontal: AppPadding.p45.w, vertical: AppPadding.p15.h)
                : EdgeInsets.all(AppPadding.p8),
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
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w36_5.w
                          : AppSize.w25.w,
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h36_5.h
                          : AppSize.h25.h,
                    ),
                    SizedBox(
                      width: AppSize.w19_5.w,
                    ),
                    TextWidget(
                      text: getTranslated(context, "search"),
                      color: Color.fromRGBO(147, 147, 147, 1),
                      size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppFontsSizeManager.s25.sp
                          : AppFontsSizeManager.s16.sp,
                      weight: FontWeight.w500,
                      family: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? getTranslated(context, "Montserrat")
                          : getTranslated(context, "Ithra"),
                      align: TextAlign.start,
                    ),
                  ],
                ),
                kIsWeb || size.width >= AppConstants.kIsWebValue
                    ? SizedBox(
                        width: AppSize.w571_7.w,
                      )
                    : SizedBox(),
                kIsWeb || size.width >= AppConstants.kIsWebValue
                    // ? SvgPicture.asset(AssetsManager.edit2,
                    //     width: AppSize.w43_3.w, height: AppSize.h24.h)
                    ? SvgPicture.asset(AssetsManager.slidersHorizontalIconPath,
                        width: AppSize.w43_3.w, height: AppSize.h24.h)
                    : SizedBox(),
              ],
            ),
          ),
        ),

        //),
        //extra
        SizedBox(
          width: 1.w,
        ),
        kIsWeb || size.width >= AppConstants.kIsWebValue
            ? Container()
            : IconButton1(
                onPress: () {
                  _modalBottomSheetMenu(size);
                },
                Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w97.w
                    : AppSize.w70.w,
                Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h97.h
                    : AppSize.h50.h,
                ButtonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? 25.r
                    : 10.6.r,
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
    );
  }

  addingDialog(Size size, String icon, String text, String details, bool back) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular((kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppRadius.r90.r
                : AppRadius.r50.r),
          ),
        ),
        elevation: 5.0,
        content: Container(
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h478.h
              : null,
          width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.w718.w
              : null,
          // color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          //     ? AppColors.white
          //     : AppColors.grey2,
          child: Padding(
            padding: EdgeInsets.only(
                top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h54.h
                    : 0,
                left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w75.w
                    : 10,
                right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w75.w
                    : 0,
                bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h54.h
                    : 15),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: Navigator.of(context).pop,
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).primaryColor,
                      size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h66.h
                          : AppSize.w35,
                    ),
                  ),
                ),
                Image.asset(
                  AssetsManager.jobIcon,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h97.h
                      : AppSize.w40.w,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h98.h
                      : AppSize.h30.h,
                  fit: BoxFit.cover,
                ),
                SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h44.h
                        : AppSize.h15.h),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p70.w
                              : AppPadding.p15.w),
                  child: Stack(
                    children: <Widget>[
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                          fontWeight:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? null
                                  : AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : AppFontsSizeManager.s15.sp,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 0.3
                            ..color = Color(0xff202020),
                        ),
                      ),
                      // Solid text as fill.
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        softWrap: true,
                        style: TextStyle(
                            color: Color(0xff202020),
                            fontWeight: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? null
                                : AppFontsWeightManager.bold300,
                            fontFamily: getTranslated(context, "Ithra"),
                            fontStyle: FontStyle.normal,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : AppFontsSizeManager.s15.sp),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                details != " "
                    ? Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p15.w
                                : AppPadding.p0.w),
                        child: Stack(
                          children: <Widget>[
                            Text(
                              details,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s15.sp,
                                fontWeight: AppFontsWeightManager.bold300,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 0.3
                                  ..color = Color.fromRGBO(184, 180, 180, 1),
                              ),
                            ),
                            // Solid text as fill.
                            Text(
                              details,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.grey6,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s15.sp,
                                fontWeight: AppFontsWeightManager.bold300,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: AppSize.h10.h,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  void _modalBottomSheetMenu(Size size) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (builder) {
          return new Container(
            height: size.height * AppSize.h0_9,
            //color: Colors.transparent,
            decoration: new BoxDecoration(
                color: Colors.white,
                borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(AppRadius.r30),
                    topRight: const Radius.circular(AppRadius.r30))),
            //could change this to Color(0xFF737373),
            //so you don't have to change MaterialApp canvasColor
            child: SearchWidget(
              loggedUser: user,
            ),
          );
        });
  }

  bool firstLansh = false;

  Future<bool> getFirstLanch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("updateDialog")) {
      return false;
    } else {
      await prefs.setBool("updateDialog", true);
      return true;
    }
  }

  Future<void> getUpdateDialog() async {
    firstLansh = await getFirstLanch();
    print(firstLansh);
    if (firstLansh) {
      print('------------------------------------');
      updateDialog();
    } else {
      print('**************************************');
    }
  }

  updateDialog() {
    return showDialog(
      builder: (context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AssetsManager.updateImage,
            width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h97.h
                : AppSize.w174_6.w,
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h98.h
                : AppSize.h174_6.h,
            fit: BoxFit.cover,
          ),
          // SizedBox(
          //   width: AppSize.w21_3.w,
          // ),

          Container(
            height: AppSize.h228.h,
            child: Stack(
              textDirection: TextDirection.rtl,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: AppPadding.p25.w),
                  child: Container(
                    height: AppSize.h228.h,
                    width: AppSize.w300.w,
                    padding:
                        EdgeInsets.only(bottom: 0, top: 0, right: 0, left: 0),
                    decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppRadius.r21_3.r)),
                    child: Stack(
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      alignment: Alignment.topRight,
                      textDirection: TextDirection.ltr,
                      children: [
                        ImageSlideshow(
                          height: AppSize.h228.h,
                          // initialPage: 0,
                          // indicatorColor: AppColors.primaryUpdate,
                          // indicatorBackgroundColor: AppColors.grey,
                          // indicatorRadius: AppRadius.r6.r,
                          // indicatorBottomPadding: AppSize.h13_3.h,
                          // autoPlayInterval: 3000,
                          isLoop: false,
                          indicatorRadius: 0,
                          // isLoop: true,
                          children: [
                            Container(
                              padding: EdgeInsets.only(top: AppSize.h34_6.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        AssetsManager.starPurple,
                                        width: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h97.h
                                            : AppSize.w26_6.w,
                                        height: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h98.h
                                            : AppSize.h20.h,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(
                                        width: AppSize.w16.w,
                                      ),
                                      Text(
                                        getTranslated(context, "new2"),
                                        style: TextStyle(
                                            decoration: TextDecoration.none,
                                            color: AppColors.primaryColor,
                                            fontWeight: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? null
                                                : AppFontsWeightManager.bold500,
                                            fontFamily:
                                                getTranslated(context, "Ithra"),
                                            fontSize: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppFontsSizeManager.s32.sp
                                                : AppFontsSizeManager.s21_3.sp),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h44.h
                                          : AppSize.h28.h),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: AppPadding.p20.w),
                                    child: Stack(children: [
                                      Text(
                                        getTranslated(
                                            context, "educationalSupervisor"),
                                        textAlign: TextAlign.right,
                                        maxLines: 3,
                                        softWrap: true,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: AppColors.primaryColor,
                                          fontWeight: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? null
                                              : AppFontsWeightManager.bold,
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontStyle: FontStyle.normal,
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppFontsSizeManager.s32.sp
                                              : AppFontsSizeManager.s18_6.sp,
                                        ),
                                      ),
                                      Text(
                                        getTranslated(
                                            context, "educationalSupervisor"),
                                        textAlign: TextAlign.right,
                                        maxLines: 3,
                                        softWrap: true,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: AppColors.primaryColor,
                                          fontWeight: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? null
                                              : AppFontsWeightManager.bold,
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontStyle: FontStyle.normal,
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppFontsSizeManager.s32.sp
                                              : AppFontsSizeManager.s18_6.sp,
                                        ),
                                      ),
                                    ]),
                                  ),
                                  SizedBox(height: AppSize.h16.h),
                                  Text(
                                    getTranslated(context, "detailUpdate"),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: AppColors.black,
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s32.sp
                                          : AppFontsSizeManager.s16.sp,
                                      fontWeight: AppFontsWeightManager.bold,
                                    ),
                                  ),
                                  // SizedBox(
                                  //   height: AppSize.h34_6.h,
                                  // )
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              padding: EdgeInsets.all(0),
                              minWidth: 1,
                              height: 1,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: SvgPicture.asset(
                                AssetsManager.moveCloseIconPath,
                                width: AppSize.h21_3.w,
                                height: AppSize.h21_3.h,
                              ),
                            ),
                            Spacer()
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                    height: AppSize.h228.h,
                    width: AppSize.w340.w,
                    //color: AppColors.orange,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Spacer(flex: 2),
                            ClipPath(
                              clipper: MyClipper(),
                              child: Container(
                                height: AppSize.h40.h,
                                width: AppSize.w40.w,
                                color: AppColors.white,
                              ),
                            ),
                            Spacer(flex: 3),
                          ],
                        ),
                      ],
                    )),
              ],
            ),
          )
        ],
      ),
      // barrierDismissible: false,
      context: context,
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path_0 = Path();
    path_0.moveTo(size.width * 0.2487500, size.height * 0.0033333);
    path_0.quadraticBezierTo(size.width * 0.9990500, size.height * 0.3431500,
        size.width * 0.9983750, size.height * 0.4981167);
    path_0.quadraticBezierTo(size.width * 1.0120625, size.height * 0.6262500,
        size.width * 0.2512500, size.height * 0.9950000);
    return path_0;
  }

  @override
  bool shouldReclip(covariant CustomClipper oldClipper) {
    return true;
  }
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
