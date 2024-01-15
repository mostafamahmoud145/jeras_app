
import 'package:app_settings/app_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:jeras/main.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../config/app_shadow.dart';
import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../methods/show_call_permissions_dialog.dart';
import '../../services/call_services.dart';
import '../web_rtc_bloc/start_call.dart';
import 'call_cubit/call_cubit.dart';

class StartCallScreen extends StatefulWidget {

  final bool isWeb;
  final String? callerId;
  //final CallKeepCallData data;

  const StartCallScreen({this.isWeb = false, this.callerId,});

  @override
  State<StartCallScreen> createState() => _startCallScreenState();
}

class _startCallScreenState extends State<StartCallScreen> {

  late var data;
  bool callEnded = false;

  initState() {
    super.initState();
    print("caaaaaallllll");
    CallCubit.get(context).changeCallState(StartCallStates.loading);
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
      if (kIsWeb) {
        CallServices.startWebCall(callerId: widget.callerId!);
      } else {
        //joinCall(context);
        getActiveCall(context);
      }
    });
    //checkIfTheSenderCanceled();
  }

  /// Get the active call data from CallKit.
  /// end all calls.
  /// join the meeting.
  ///

  getActiveCall(context) async {
    await FlutterCallkitIncoming.activeCalls().then((value) {
      data = value;
      FlutterCallkitIncoming.endAllCalls();
      joinCall(context);
    });
    /*await CallKeep.instance.activeCalls().then((value) {
      data = value[0];
      await CallKeep.instance.endAllCalls();
      endCall();
      joinCall(context);
    });*/
  }

  /// if the user accept permissions for mic, [startCall] will called to :
  /// 1 => change current user state to 'oncall',
  /// 2 => get current user data by uId,
  /// 3 => get appointment data bu appointmentId,
  /// 4 => enter the call.
  ///

  startCall(BuildContext context) async {
    //var data = await FlutterCallkitIncoming.activeCalls();
    FirebaseDatabase.instance
        .ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('callState')
        .set('oncall')
        .then((value) =>  Future(() => StartCall(
        host: data[0]['extra']['appointmentId'],
        iscaller: false,
        isVideo: true,
        normalCall: false,
        CallerId: data[0]['extra']['callerId'],
        ReciverId: FirebaseAuth.instance.currentUser!.uid,
        context: context)
        .startCall()));
  }

  /// when the user enter to the call:
  /// => request permissions of mic from him.
  /// => if the permissions if granted, call [startCall] method to go direct to the call,
  /// => if denied, change callState in bloc to permissionNotAllowed, to rebuild the screen and show joinCall button.
  /// => if he denied multiple times, show the dialog to him to go to the settings to accept permissions.
  ///

  void joinCall(context) async {
    await Permission.microphone.request().then((mic) {
      Permission.camera.request().then((camera) {
        if (mic.isGranted == true && camera.isGranted== true) {
          startCall(context);
        } else if (mic.isDenied == true || camera.isDenied== true) {
          CallCubit.get(context)
              .changeCallState(StartCallStates.permissionsNotAllowed);
        } else if (mic.isPermanentlyDenied == true || camera.isPermanentlyDenied == true) {
          showPermissionsDialog(
            context: context,
            text: getTranslated(context, 'getSettings'),
            buttonTitle: getTranslated(context, 'goToSettings'),
            function: () {
              Navigator.pop(context);
              AppSettings.openAppSettings(
                type: AppSettingsType.settings,
              );
            },
            refusedFunction: () {
              Navigator.pop(context);
            },
          );
          CallCubit.get(context)
              .changeCallState(StartCallStates.permissionsNotAllowed);
        }
      });
    });
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          /// app logo
          ///
          Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                boxShadow: [AppShadow.primaryShadow],
                color: AppColors.white,
                border: Border.all(
                  width: 6,
                  color: AppColors.white,
                ),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                AssetsManager.whiteJerasLogoIconPath,
                width: 65,
                height: 65,
              )),
          SizedBox(
            height: size.height * .15,
          ),


          /// check for state of the call:
          /// if loading => load page.
          /// if the permission is disallowed => show joinCall button to open permission dialog, then enter call.
          /// if inCall => show (you are in the call now) page.
          /// if callEnded => show (ok) button to go to home.
          ///
          widget.isWeb
              ? WebStartCallScreen()
              : MobileStartCallScreen(function: () {
            joinCall(context);
          }),
          // BlocBuilder<CallCubit, CallStates>(
          //     bloc: CallCubit.get(context),
          //     builder: (context, state) {
          //       switch (context.read<CallCubit>().callState) {
          //         case StartCallStates.loading:
          //           return Column(
          //             children: [
          //               loadingWidget(),
          //               SizedBox(
          //                 height: (size.height * .15) + 40,
          //               ),
          //             ],
          //           );
          //
          //         case StartCallStates.inCall:
          //           return Column(
          //             children: [
          //               Center(
          //                   child: text(
          //                       getTranslated(context, 'userInCallNow'),
          //                       13,
          //                       AppColors.black4,
          //                       FontWeight.w500)),
          //               SizedBox(
          //                 height: (size.height * .15) + 40,
          //               ),
          //             ],
          //           );
          //
          //         case StartCallStates.permissionsNotAllowed:
          //           return Column(
          //             children: [
          //               loadingWidget(),
          //               SizedBox(
          //                 height: size.height * .15,
          //               ),
          //               Center(
          //                   child: buttonWidget(
          //                       context: context,
          //                       buttonText: getTranslated(context, 'joinCall'),
          //                       function: () {
          //                         joinCall(context);
          //                       })),
          //             ],
          //           );
          //
          //         case StartCallStates.callEnded:
          //           return Column(
          //             children: [
          //               Center(
          //                   child: text(
          //                       getTranslated(context, 'userClose'),
          //                       13,
          //                       AppColors.black4,
          //                       FontWeight.w500)),
          //               SizedBox(
          //                 height: size.height * .15,
          //               ),
          //               Center(
          //                   child: buttonWidget(
          //                       context: context,
          //                       buttonText: getTranslated(context, 'Ok'),
          //                       function: () {
          //                         Navigator.pop(context);
          //                         // Navigator.pushNamedAndRemoveUntil(
          //                         //     context, '/home', (route) => false);
          //                       })),
          //             ],
          //           );
          //       }
          //     }),
        ],
      ),
    );
  }













  Widget loadingWidget() => Center(
        child: Lottie.asset(
          'assets/lotifile/loading.json',
        ),
      );

  Widget text(String text, double size, Color color, FontWeight weight) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
          fontFamily: getTranslated(context, "Ithra"), // 'Montserrat',
          fontSize: size,
          color: color,
          fontWeight: weight),
    );
  }

  Widget buttonWidget(
      {context, required String buttonText, required Function function}) {
    return InkWell(
      onTap: () {
        function();
      },
      child: Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(AppRadius.r20),
        ),
        child: Center(
          child: text(buttonText, 15, AppColors.white, FontWeight.w300),
        ),
      ),
    );
  }
}


class MobileStartCallScreen extends StatelessWidget {
  final Function function;

  const MobileStartCallScreen({Key? key, required this.function})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<CallCubit, CallStates>(
        bloc: CallCubit.get(context),
        builder: (context, state) {
          switch (context.read<CallCubit>().callState) {
            case StartCallStates.loading:
              return Column(
                children: [
                  loadingWidget(),
                  SizedBox(
                    height: (size.height * .15) + 40,
                  ),
                ],
              );

            case StartCallStates.inCall:
              return Column(
                children: [
                  Center(
                      child: text(
                          getTranslated(context, 'userInCallNow'),
                          13,
                          Color.fromRGBO(32, 32, 32, 1),
                          FontWeight.w500,
                          context)),
                  SizedBox(
                    height: (size.height * .15) + 40,
                  ),
                ],
              );

            case StartCallStates.permissionsNotAllowed:
              return Column(
                children: [
                  loadingWidget(),
                  SizedBox(
                    height: size.height * .15,
                  ),
                  Center(
                      child: buttonWidget(
                          context: context,
                          buttonText: getTranslated(context, 'joinCall'),
                          function: () {
                            function();
                            // joinCall(context);
                          })),
                ],
              );

            case StartCallStates.callEnded:
              return Column(
                children: [
                  Center(
                      child: text(
                          getTranslated(context, 'userClose'),
                          13,
                          Color.fromRGBO(32, 32, 32, 1),
                          FontWeight.w500,
                          context)),
                  SizedBox(
                    height: size.height * .15,
                  ),
                  Center(
                      child: buttonWidget(
                          context: context,
                          buttonText: getTranslated(context, 'Ok'),
                          function: () {
                            Navigator.pop(context);
                          })),
                ],
              );
          }
        });
  }
}


enum WebStates{loading, inCall, callEnded}

class WebStartCallScreen extends StatefulWidget {
  const WebStartCallScreen({Key? key}) : super(key: key);

  @override
  State<WebStartCallScreen> createState() => _WebStartCallScreenState();
}

class _WebStartCallScreenState extends State<WebStartCallScreen> {


  WebStates webStates= WebStates.loading;

  @override
  void initState() {
    super.initState();
    FirebaseDatabase.instance.ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid).child('callState').onValue
        .listen((event) {
      if(event.snapshot.value=='closed'){
        webStates= WebStates.callEnded;
      }else if(event.snapshot.value=='oncall'){
        webStates= WebStates.inCall;
      }
      setState(() {});
    });
  }


  /// 1 => loading.
  /// 2 => inCallNow.
  /// 3 => call ended.

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;


    return Builder(
        builder: (context) {
          switch (webStates) {
            case WebStates.loading:
              return Column(
                children: [
                  loadingWidget(),
                  SizedBox(
                    height: (size.height * .15) + 40,
                  ),
                ],
              );

            case WebStates.inCall:
              return Column(
                children: [
                  Center(
                      child: text(
                          getTranslated(context, 'userInCallNow'),
                          13,
                          Color.fromRGBO(32, 32, 32, 1),
                          FontWeight.w500,
                          context)),
                  SizedBox(
                    height: (size.height * .15) + 40,
                  ),
                ],
              );

            case WebStates.callEnded:
              return Column(
                children: [
                  Center(
                      child: text(
                          getTranslated(context, 'userClose'),
                          13,
                          Color.fromRGBO(32, 32, 32, 1),
                          FontWeight.w500,
                          context)),
                  SizedBox(
                    height: size.height * .15,
                  ),
                  Center(
                      child: buttonWidget(
                          context: context,
                          buttonText: getTranslated(context, 'Ok'),
                          function: () {
                            Navigator.pop(context);
                            // Navigator.pushNamedAndRemoveUntil(
                            //     context, '/home', (route) => false);
                          })),
                ],
              );
          }
        });
  }
}



Widget loadingWidget() => Center(
  child: Lottie.asset(
    'assets/lotifile/loading.json',
  ),
);

Widget text(String text, double size, Color color, FontWeight weight, context) {
  return Text(
    text,
    textAlign: TextAlign.center,
    style: TextStyle(
        fontFamily: getTranslated(context, "Ithra"), // 'Montserrat',
        fontSize: size,
        color: color,
        fontWeight: weight),
  );
}

Widget buttonWidget(
    {context, required String buttonText, required Function function}) {
  return InkWell(
    onTap: () {
      function();
    },
    child: Container(
      height: 40,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Center(
        child: text(buttonText, 15, AppColors.white, FontWeight.w300, context),
      ),
    ),
  );
}
