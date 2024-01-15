import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/screens/home_screen.dart';
import 'package:jeras/screens/userAccountScreen.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/paths.dart';
import '../../models/user.dart';
import '../config/assets_manager.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../repositories/user_data_repository.dart';
import '../services/app_flyer_service.dart';
import 'consultRules.dart';
import 'languageScreen.dart';

class SplashScreen extends StatefulWidget {
  //PendingDynamicLinkData? initialLink;
  SplashScreen();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? userType;
  dynamic androidBuildNum, iosBuildNum;
  bool loading = true;
  Video? video;
  final UserDataRepository userDataRepository = UserDataRepository();

  late AccountBloc accountBloc =
      AccountBloc(userDataRepository: userDataRepository);

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());

    ///Update userCallState to close state.
    // if(FirebaseAuth.instance.currentUser!= null){
    //   changeUserState(userId: FirebaseAuth.instance.currentUser!.uid, state: 'closed');
    // }

    Timer(Duration(milliseconds: 3000), () {
      checkUserAccount();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? Color(0xff83759c)
          : Theme.of(context).primaryColor,
      body: Center(
          child: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? Image.asset(AssetsManager.webSplashImage)
              : Image.asset(AssetsManager.mobSplashImage)),
    );
  }

  webSplash(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //SizedBox(height: size.height * .35,),
        Center(
            child: Image.asset(
          AssetsManager.whiteJerasLogoIconPath,
          width: AppSize.w104.w,
          height: AppSize.h140.h,
        )),
        SizedBox(
          height: size.height * .1.h,
        ),
        Center(
            child: Image.asset(
          AssetsManager.textSplashImage,
          width: AppSize.w570.w,
          height: AppSize.h63_5.h,
        )),
      ],
    );
  }

  bool firstLansh = false;
  Future<bool> getFirstLanch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.containsKey("firstLaunch")) {
      return false;
    } else {
      await prefs.setBool("firstLaunch", true);
      return true;
    }
  }

  Future<void> checkUserAccount() async {
    FirebaseFirestore.instance
        .collection(Paths.settingPath)
        .doc("pzBqiphy5o2kkzJgWUT7")
        .get()
        .then((DocumentSnapshot value) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        androidBuildNum = value['androidBuildNumber'];
        iosBuildNum = value['iosBuildNumber'];
      });
      firstLansh = await getFirstLanch();
      print(firstLansh);
      if (firstLansh) {
        print('2');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LanguageScreen()));
      } else {
        if (kIsWeb ||
            (Platform.isAndroid &&
                int.parse(packageInfo.buildNumber) >= androidBuildNum) ||
            (Platform.isIOS &&
                int.parse(packageInfo.buildNumber) >= iosBuildNum)) {
          /* if (widget.initialLink != null) {
          final Uri link = widget.initialLink!.link;

          if(link.queryParameters['consultant_id']!=null){
            String? consultantId = link.queryParameters['consultant_id'];
            Navigator.pushNamed(context, '/home');
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(
                    name: 'conslultant?consultant_id=${consultantId}',
                    arguments: {"consultant_id": consultantId}),
                builder: (context) => ConsultantDetailsScreen(  consoltantId: '${consultantId}',),
              ),
            );
          }
          else if(link.queryParameters['course_id']!=null){
            String? course_id = link.queryParameters['course_id'];
            Navigator.pushNamed(context, '/home');
            Navigator.push(
              context,
              MaterialPageRoute(
                settings: RouteSettings(
                    name: 'courses?course_id=${course_id}',
                    arguments: {"course_id": course_id}),
                builder: (context) => CourseDetailScreen(  courseId: '${course_id}',),
              ),
            );
          }
        }*/
          if (FirebaseAuth.instance.currentUser != null) {
            var ref = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .withConverter(
                  fromFirestore: GroceryUser.fromFirestore,
                  toFirestore: (GroceryUser user, _) => user.toFirestore(),
                );
            final docSnap = await ref.get();
            GroceryUser? currentUser = docSnap.data();
            if (currentUser != null) {

              /// get user name.
              List<String> names= currentUser.name!.trim().split(' ');

              if (currentUser.isBlocked!) {
                AppFlyerService().clear();
                await FirebaseAuth.instance.signOut();
                // Navigator.popAndPushNamed(
                //   context,
                //   '/home',
                //   arguments: {
                //     'userType': userType,
                //   },
                // );
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                              user2: accountBloc.loggeduser,
                            )));
              } else if (currentUser.userType == "CONSULTANT" &&
                  currentUser.profileCompleted == false)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => consultRuleScreen(
                      user: currentUser,
                      video: video!,
                    ),
                  ),
                );
              else if (currentUser.userType != "CONSULTANT" &&
                  (currentUser.ageValue == null || currentUser.profileCompleted == false) ) {

                /// Profile not completed.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserAccountScreen(user: currentUser, firstLogged: true),
                  ),
                );

              } else if (currentUser.userType != "CONSULTANT" && names.length<2){

                /// User name is one word.
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserAccountScreen(user: currentUser, firstLogged: false, firstNameOnly: true),
                  ),
                );

              } else
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HomeScreen(
                          user2: accountBloc.loggeduser,
                        )));
            }
          } else
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          user2: accountBloc.loggeduser,
                        )));
        } else
          Navigator.popAndPushNamed(context, '/ForceUpdateScreen');
      }
    }).catchError((err) {});
  }
}
