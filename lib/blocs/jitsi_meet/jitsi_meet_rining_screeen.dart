

import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/blocs/web_rtc_bloc/start_call.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:lottie/lottie.dart';
import 'package:shimmer/shimmer.dart';
//import 'package:wakelock/wakelock.dart';

import '../../config/app_constat.dart';
import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../methods/check_if_the_caller_cancel.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../services/call_services.dart';
import '../../widget/dialogs/notification_blocked_dialog.dart';
import 'jitsi_meet_init_call.dart';

class JitsiMeetRiningScreen extends StatefulWidget {
  static String tag = 'call_sample';

  final String host;
  bool? iscaller = false;
  bool? acceptNotfi = false;
  AppAppointments? appointment;
  GroceryUser? loggedUser;

  String? CallerId = "";
  String? ReciverId = "";

  bool? isVideo = true;
  bool? normalCall = true;

  JitsiMeetRiningScreen(
      {required this.host,
        this.iscaller,
        this.acceptNotfi,
        this.appointment,
        this.loggedUser,
        this.isVideo,
        this.normalCall,
        this.CallerId,
        this.ReciverId});

  @override
  JitsiMeetRiningScreenState createState() => JitsiMeetRiningScreenState();
}

class JitsiMeetRiningScreenState extends State<JitsiMeetRiningScreen> {
  bool? isVideoRemoteSignaling = true;
  bool? isVideolocalSignaling = true;
  bool cameraGranted = false;
  bool micGranted = false;
  bool anotherCall = false;
  bool refused = false;
  bool closed = false;
  bool calling = false;
  bool _isDisposed = false;
  bool inCallNow = false;
  bool errorCall = false;

  bool startRecord = false;
  String micStateIcon = 'assets/icons/mute.png';
  String cameraStateIcon = 'assets/icons/videoon.png';

  late Size size;
  bool mic = true, camera = true, share = true, toggle = true;
  int minutes = 0, seconds = 0;
  bool navigate = false;

  bool _inCalling = false;

  AudioPlayer audioPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);

  // ignore: unused_element
  JitsiMeetInitCall? inintCall;

  bool fristload = true;

  @override
  void dispose() {
    super.dispose();
//    FirebaseDatabase.instance.ref('userCallState').child(widget.CallerId!).child('callState').set('closed');
  }

  @override
  initState() {


    super.initState();
    inintCall = JitsiMeetInitCall(widget.normalCall!, widget.CallerId!, widget.ReciverId!, widget.host, widget.loggedUser);

    if(kIsWeb){
      startWebCall();
    }else{
      startMobileCall();
    }


    if (!widget.iscaller!) {
      setupAudio();
    } else {
      if (widget.iscaller!) {}
    }

  }




  startWebCall() async{

    if (widget.normalCall!) {   /// normal call means that the call is start from here (this is the caller screen).
      var res = await inintCall?.checkuserCallState();
      if (res['code'] == 101) {
        anotherCall = true;
        errorCall = false;
      }  else if (res['code'] == 102) {
        anotherCall = false;
        errorCall = true;
      }else if (res['code'] == 200) {
        anotherCall = false;
        errorCall = false;
        /// if the user not in anther call, send call to him.
        inintCall!.trigerCallState();
      }

      /// not normal call means that the call is received from here (this is the receiver screen).
    } else if (!widget.normalCall!) {

      var res = await inintCall?.checkuserCallState();

      if (res['code'] == 101) {
        anotherCall = true;
        errorCall = false;
      } else if (res['code'] == 102) {
        anotherCall = false;
        errorCall = true;
      } else if (res['code'] == 200) {
        anotherCall = false;
        errorCall = false;
        inintCall!.trigerCallState();
      }
    }

    if (mounted) {
      setState(() {
        fristload = false;
      });
    }

    /// here after check the user state
    inintCall?.checkCallState = (callStat) {
      switch (callStat) {
        case call_State.anotherCall:
          break;
        case call_State.calling:
          //checkIfTheReceiverNotificationBlocked(appointmentId: widget.appointment!.appointmentId);

          if (!widget.iscaller!) {
            if (mounted) {
              setState(() {
                fristload = false;    ///load shimmer.
                closed= false;
                refused= false;
                inCallNow= false;
              });
            }
          }
          // TODO: Handle this case.
          break;
        case call_State.refusd:
          if (mounted) {
            setState(() {
              fristload = false;
              calling= false;         ///---------
              //closed= true;                 ///--------
              refused = true;
              inCallNow= false;
            });
          }

          break;
        case call_State.closed:
          if (!_isDisposed && mounted) {
            setState(() {
              fristload = false;
              refused = false;
              closed = true;
              calling= false;
              inCallNow= false;
            });
          }

          break;
        case call_State.inCall:
          setState(() {
            inCallNow= true;
          });
          FirebaseDatabase.instance
              .ref('userCallState')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child('callState')
              .set('oncall')
              .then((value) {
            if (mounted) {
              CallServices.startWebCall(callerId: FirebaseAuth.instance.currentUser!.uid);
            }
          });


          break;
      }
    };

    if(widget.loggedUser!.userType == "CONSULTANT") {
      checkIfTheSenderCanceled(function: (){
        confirmEndCallDialog(
            context: context,
            loggedUser: widget.loggedUser!,
            appointment: widget.appointment!
        );
      });
    }
  }


  startMobileCall(){
    inintCall!.requstCallPermissions();


    if (widget.iscaller!) {

      inintCall?.checkCallPermissions =
          (checkpermission, checkpermission2) async {
        switch (checkpermission) {
          case call_permision.cameraGranted:
            cameraGranted = true;
            break;
          case call_permision.micGranted:
            micGranted = true;

            break;
          case call_permision.cameradined:
            cameraGranted = false;
            break;
          case call_permision.micdined:
            micGranted = false;
            break;
        }

        switch (checkpermission2) {
          case call_permision.cameraGranted:
            cameraGranted = true;
            break;
          case call_permision.micGranted:
            micGranted = true;

            break;
          case call_permision.cameradined:
            cameraGranted = false;
            break;
          case call_permision.micdined:
            micGranted = false;
            break;
        }

        if (widget.normalCall!) {   /// normal call means that the call is start from here (this is the caller screen).
          //if (cameraGranted && micGranted) {
          var res = await inintCall?.checkuserCallState();
          if (res['code'] == 101) {
            anotherCall = true;
            errorCall = false;
          }  else if (res['code'] == 102) {
            anotherCall = false;
            errorCall = true;
          }else if (res['code'] == 200) {
            anotherCall = false;
            errorCall = false;
            /// if the user not in anther call, send call to him.
            inintCall!.trigerCallState();
          }
          // }
          /// not normal call means that the call is received from here (this is the receiver screen).
        } else if (!widget.normalCall!) {
          //   if (micGranted) {
          var res = await inintCall?.checkuserCallState();

          if (res['code'] == 101) {
            anotherCall = true;
            errorCall = false;
          } else if (res['code'] == 102) {
            anotherCall = false;
            errorCall = true;
          } else if (res['code'] == 200) {
            anotherCall = false;
            errorCall = false;
            inintCall!.trigerCallState();
          }
        }



        if (mounted) {
          setState(() {
            fristload = false;
          });
        }
      };
    }

    /// here after check the user state
    inintCall?.checkCallState = (callStat) {
      switch (callStat) {
        case call_State.anotherCall:
          break;
        case call_State.calling:
          //checkIfTheReceiverNotificationBlocked(appointmentId: widget.appointment!.appointmentId);

          if (!widget.iscaller!) {
            if (mounted) {
              setState(() {
                fristload = false;    ///load shimmer.
                closed= false;
                refused= false;
                inCallNow= false;
              });
            }
          }
          // TODO: Handle this case.
          break;
        case call_State.refusd:
          if (mounted) {
            setState(() {
              fristload = false;
              calling= false;         ///---------
              //closed= true;                 ///--------
              refused = true;
              inCallNow= false;
            });
          }

          break;
        case call_State.closed:
          if (!_isDisposed && mounted) {
            setState(() {
              fristload = false;
              refused = false;
              closed = true;
              calling= false;
              inCallNow= false;
            });
          }

          break;
        case call_State.inCall:
          setState(() {
            inCallNow= true;
          });
          FirebaseDatabase.instance
              .ref('userCallState')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .child('callState')
              .set('oncall')
              .then((value) {
            if (mounted) {
              if (widget.loggedUser!.userType == "CONSULTANT")
              {
                StartCall(host: widget.host, iscaller: true, loggedUser: widget.loggedUser, appointment: widget.appointment, isVideo: true, normalCall: false, CallerId: FirebaseAuth.instance.currentUser!.uid, ReciverId: widget.appointment?.user.uid,context: context)..startCall();
              }
              if (widget.loggedUser!.userType == "USER")
              {
                StartCall(host: widget.host, iscaller: true, loggedUser: widget.loggedUser, appointment: widget.appointment, isVideo: true, normalCall: false, CallerId: FirebaseAuth.instance.currentUser!.uid, ReciverId: widget.appointment?.consult.uid,context: context)..startCall();
              }
            }
          });


          break;
      }
    };
  }


  ///If notification blocked, and the caller still calling,
  ///display [showNotificationBlockedDialog] to till the caller that the
  ///receiver blocked the notification permission.
  ///

  // checkIfTheReceiverNotificationBlocked({required String appointmentId}) async {
  //   await FirebaseDatabase.instance
  //       .ref('callNotifications')
  //       .child(appointmentId)
  //       .child('notificationState')
  //       .onValue
  //       .listen((event) {
  //     if (event.snapshot.value == 'blocked') {
  //       showNotificationBlockedDialog(
  //           context: context,
  //           callerId: widget.CallerId!,
  //           receiverId: widget.ReciverId!);
  //     }
  //   });
  // }


  setupAudio() async {
    audioPlayer.play(AssetSource('sound/jeraston.mp3'));
  }

  @override
  deactivate() {
    super.deactivate();

    audioPlayer.release();
  }


  Widget allWid() {
    if (fristload=false) {
      return ShimmerLoad();
    } else if (anotherCall) {
      return endWidget("anotherCall");
    } else if (errorCall) {
      Future(() => Fluttertoast.showToast(
          msg: getTranslated(context, "removeNotification"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: AppColors.red,
          textColor: AppColors.white,
          fontSize: 16.sp));
      return endWidget("errorCall");
    } else if (refused) {
      return endWidget("userRefuse");
    } else if (closed) {
      return endWidget("userClose", withButton: false);
    }else if (inCallNow) {
      return endWidget("userInCallNow", withButton: false);
    } else {
      return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(widget.ReciverId)
            .withConverter(
          fromFirestore: GroceryUser.fromFirestore,
          toFirestore: (GroceryUser user, _) => user.toFirestore(),
        )
            .get(),
        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<GroceryUser>> snapshot) {
          if (snapshot.hasError) {
            return endWidget('failed');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return ShimmerLoad();
          } else {
            return Stack(
              children: [
                Align(
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Column(
                          children: [
                            Stack(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Lottie.asset(
                                      'assets/lotifile/callinganim.json'),
                                ),
                                Positioned(
                                  bottom: 60,
                                  left: MediaQuery.of(context).size.width / 2 -
                                      50,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80.0),
                                    child: FadeInImage.assetNetwork(
                                      width: 80,
                                      height: 80,
                                      placeholder:
                                      'assets/call/bxs-user-circle@3x.png',
                                      placeholderScale: 0.5,
                                      imageErrorBuilder:
                                          (context, error, stackTrace) =>
                                          Container(
                                            width: 100,
                                            height: 100,
                                            color: Colors.grey,
                                            child: Image.asset(
                                              'assets/call/bxs-user-circle@3x.png',
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                      image: snapshot.data!.data()!.photoUrl!,
                                      fit: BoxFit.cover,
                                      fadeInDuration:
                                      Duration(milliseconds: AppConstants.milliseconds250),
                                      fadeInCurve: Curves.easeInOut,
                                      fadeOutDuration:
                                      Duration(milliseconds: AppConstants.milliseconds150),
                                      fadeOutCurve: Curves.easeInOut,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            text(snapshot.data!.data()!.name!, 28,
                                AppColors.black4, FontWeight.w600),
                            text(
                                getTranslated(context, "callingNow"),
                                15,
                                Color.fromRGBO(147, 147, 147, 1),
                                FontWeight.normal),
                          ],
                        ),
                        SizedBox(),
                        !widget.iscaller!
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  refuseWidget(),
                                  SizedBox(
                                    width: size.width * .20,
                                  ),
                                  //acceptWidget(),
                                ],
                              )
                            : widget.iscaller!
                                ? refuseWidget()
                                : Container(),
                      ],
                    ),
                  ),
                )
              ],
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async => true,
        child: Scaffold(
            backgroundColor: Color.fromRGBO(247, 247, 247, 1),
            extendBodyBehindAppBar: true,
            body: allWid()
        ),
    );
  }


  Widget ShimmerLoad() {
    return Stack(
      children: [
        // Positioned(
        //     left: 10,
        //     top: 10,
        //     child:
        //     Container(
        //       width: 150,
        //       height: 150,
        //       child: RTCVideoView( _localRenderer!),
        //     )
        // ),
        Align(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Column(
                  children: [
                    Stack(
                      children: [
                        Shimmer.fromColors(
                            period: Duration(milliseconds: 800),
                            baseColor: Colors.grey.withOpacity(0.6),
                            highlightColor: Colors.black.withOpacity(0.6),
                            child: Container(
                              height: 100,
                              width: 100,
                              padding: const EdgeInsets.all(8.0),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withOpacity(0.2),
                              ),
                            ))
                      ],
                    ),
                    SizedBox(
                      width: size.width * .20,
                      height: 10,
                    ),
                    Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.6),
                        highlightColor: Colors.black.withOpacity(0.6),
                        child: Container(
                          height: 50,
                          width:
                          kIsWeb && MediaQuery.of(context).size.width > 400
                              ? MediaQuery.of(context).size.width * .3
                              : MediaQuery.of(context).size.width * .8,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.r15.r),
                          ),
                        )),
                    SizedBox(
                      width: size.width * .20,
                      height: 10,
                    ),
                    Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.6),
                        highlightColor: Colors.black.withOpacity(0.6),
                        child: Container(
                          height: 50,
                          width:
                          kIsWeb && MediaQuery.of(context).size.width > 400
                              ? MediaQuery.of(context).size.width * .3
                              : MediaQuery.of(context).size.width * .8,
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(AppRadius.r15.r),
                          ),
                        ))
                  ],
                ),
                SizedBox(),
                !widget.iscaller!
                    ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.6),
                        highlightColor: Colors.black.withOpacity(0.6),
                        child: Container(
                          height: 60,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        )),
                    SizedBox(
                      width: size.width * .20,
                      height: 10,
                    ),
                    Shimmer.fromColors(
                        period: Duration(milliseconds: 800),
                        baseColor: Colors.grey.withOpacity(0.6),
                        highlightColor: Colors.black.withOpacity(0.6),
                        child: Container(
                          height: 60,
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        )),
                    SizedBox(
                      width: size.width * .20,
                      height: 10,
                    ),
                  ],
                )
                    : widget.iscaller!
                    ? Shimmer.fromColors(
                    period: Duration(milliseconds: 800),
                    baseColor: Colors.grey.withOpacity(0.6),
                    highlightColor: Colors.black.withOpacity(0.6),
                    child: Container(
                      height: 60,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ))
                    : Container(),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget refuseWidget() {
    return InkWell(
      onTap: () {
        audioPlayer.stop();

        /// todo: when the user cancel the call in the rining screen,
        /// then end the call in the user screen.
        changeUserState(userId: widget.CallerId!, state: 'closed');
        changeUserState(userId: widget.ReciverId!, state: 'closed');
        Navigator.pop(context);
      },
      child: Container(
        height: 60,
        width: 100,
        decoration: BoxDecoration(
          color: Color.fromRGBO(234, 33, 33, 1),
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Center(
          child: Image.asset(
            'assets/call/md-call@3x.png',
            width: 40,
            height: 40,
          ),
        ),
      ),
    );
  }

  Widget closeWidget() {
    return InkWell(
      onTap: () {
        audioPlayer.stop();

        //Wakelock.disable();
        Navigator.pop(context);
      },
      child: Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(AppRadius.r20),
        ),
        child: Center(
          child: text(
              getTranslated(context, "Ok"), 15, Colors.white, FontWeight.w300),
        ),
      ),
    );
  }

  endWidget(String _text, {bool withButton= true}) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
              height: 70,
              width: 70,
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
                  width: 6,
                  color: Colors.white,
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
          Center(
              child: text(getTranslated(context, _text), 13,
                  AppColors.black4, FontWeight.w500)),
          SizedBox(
            height: size.height * .15,
          ),
          withButton ? Center(child: closeWidget()) : SizedBox()
        ],
      ),
    );
  }

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

  BoxDecoration decoration() {
    return BoxDecoration(
        shape: BoxShape.circle,
        //color: Color.fromRGBO(255, 255, 255,.42),
        border: Border.all(color: Color.fromRGBO(211, 211, 211, 1), width: .5),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(255, 255, 255, 0),
            Color.fromRGBO(0, 0, 0, 1),
          ],
        ));
  }



  changeUserState({required String userId, required String state}){
    FirebaseDatabase.instance
        .ref('userCallState')
        .child(userId)
        .child('callState')
        .set(state);
  }
}

