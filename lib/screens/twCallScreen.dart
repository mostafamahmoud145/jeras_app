/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/timeHelper.dart';
import '../../models/user.dart';
import 'package:twilio_voice/twilio_voice.dart';
import 'package:http/http.dart' as http;

import '../controller/blocs/account_bloc/account_bloc.dart';

class VoiceCallScreen extends StatefulWidget {
  final GroceryUser? loggedUser;
  final AppAppointments? appointment ;
  final String? from ;
  const VoiceCallScreen({ this.loggedUser, this.appointment,this.from});
  @override
  _VoiceCallScreenState createState() => _VoiceCallScreenState();
}
//creete push notification
//https://githubmemory.com/repo/diegogarciar/twilio_voice/issues/39
//https://console.twilio.com/us1/develop/notify/try-it-out?frameUrl=%2Fconsole%2Fnotify%2Fcredentials%2FCR864c85133906feaf674f16b7e7a38b0b%3F__override_layout__%3Dembed%26bifrost%3Dtrue%26x-target-region%3Dus1
class _VoiceCallScreenState extends State<VoiceCallScreen> {
  var speaker = false;
  var mute = false;

  var isEnded = false;bool ending=false;
  bool endingCall=false;
  late AccountBloc accountBloc;
  String? message = "Connecting...";
  bool firstStateEnabled = false;
  bool showTimer=true;
  late StreamSubscription<CallEvent> callStateListener;
  final Dependencies dependencies = new Dependencies();
   bool logFound=false;
  void listenCall() {
    callStateListener = TwilioVoice.instance.callEventsListener.listen((event) async {
      switch (event) {

        case CallEvent.callEnded:
          if (!isEnded) {
            isEnded = true;
            Navigator.of(context).pop();

          }

          break;
        case CallEvent.log:
          if(widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT"&&widget.appointment!=null)
          {
            showNoNotifSnack(getTranslated(context, "notAvalaible"));
          }

          break;
        case CallEvent.mute:
          if(mounted)
          setState(() {
            mute = true;
          });
          break;
        case CallEvent.unmute:
          if(mounted)setState(() {
            mute = false;
          });
          break;
        case CallEvent.speakerOn:
         if(mounted) setState(() {
            speaker = true;
          });
          break;
        case CallEvent.speakerOff:
          if(mounted)setState(() {
            speaker = false;
          });
          break;
        case CallEvent.ringing:
          if(mounted) setState(() {
            message = "Ringing...";
          });
          break;
        case CallEvent.answer:

          if(mounted)setState(() {
            message = "Answer...";
          });
          break;
        case CallEvent.connected:
          if(mounted)setState(() {
            message = "Connected...";
          });
          break;

        case CallEvent.hold:
         //case CallEvent.log:
        case CallEvent.unhold:
          break;
        default:
          break;
      }
    });
  }

  late String caller;
  void showNoNotifSnack(String text) {
   */
/* Flushbar(
      margin: const EdgeInsets.all(8.0),
      borderRadius: BorderRadius.circular(7),
      backgroundColor: Colors.green.shade500,
      animationDuration: Duration(milliseconds: 500),
      isDismissible: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black12,
          spreadRadius: 1.0,
          blurRadius: 5.0,
          offset: Offset(0.0, 2.0),
        )
      ],
      shouldIconPulse: false,
      duration: Duration(milliseconds: AppConstants.milliseconds1500),
      icon: Icon(
        Icons.notification_important,
        color: Colors.white,
      ),
      messageText: Text(
        '$text',
        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
          fontSize: 14.0,
          fontWeight: AppFontsWeightManager.bold500,
          letterSpacing: AppConstants.letterSpacing0_3,
          color: Colors.white,
        ),
      ),
    )..show(context);*//*

  }
  String getCaller() {
    final activeCall = TwilioVoice.instance.call.activeCall;
    if(widget.loggedUser!=null&&widget.loggedUser!.userType=="CONSULTANT"&&widget.appointment!=null)
      return widget.appointment!.user.name!;
    else if(widget.loggedUser!=null&&widget.loggedUser!.userType!="CONSULTANT"&&widget.appointment!=null)
    return widget.appointment!.consult.name!;

    else
    return "Jeras App";
  }

  @override
  void initState() {
    accountBloc = BlocProvider.of<AccountBloc>(context);
    speaker=false;
    mute=false;
    listenCall();
    dependencies.stopwatch.start();
    super.initState();
    caller = getCaller();
  }

  @override
  void dispose() {
    super.dispose();
    updateCallCost();
    callStateListener.cancel();
  }
  Future<void> updateCallCost() async {
    try{
      if(widget.appointment!=null){
        final response = await http.post(
            Uri.parse('https://us-central1-app-jeras.cloudfunctions.net/updateCallCost'),
            body: {
              'appointmentId':widget.appointment?.appointmentId
            });

      }
    }catch(e){
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF7b6c94),//Colors.lightBlueAccent,//Theme.of(context).accentColor,
        body: Container(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        caller,
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(color: Colors.white),
                      ),
                      SizedBox(height: 8),
                      if (message != null)
                        Text(
                         message!,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(color: Colors.white),
                        )
                    ],
                  ),
                 SizedBox(),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Material(
                          type: MaterialType
                              .transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.white, width: 1.0),
                              color: speaker
                                  ?AppColors.brown// Theme.of(context).primaryColor
                                  : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(
                                  1000.0), //Something large to ensure a circle
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.volume_up,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                 setState(() {
                                   speaker = !speaker;
                                 });

                                   TwilioVoice.instance.call.toggleSpeaker(speaker);

                              },
                            ),
                          ),
                        ),
                        Material(
                          type: MaterialType
                              .transparency, //Makes it usable on any background color, thanks @IanSmith
                          child: Ink(
                            decoration: BoxDecoration(
                              border:
                              Border.all(color: Colors.white, width: 1.0),
                              color: mute
                                  ? AppColors.brown//Theme.of(context).accentColor
                                  : Colors.white24,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(
                                  1000.0), //Something large to ensure a circle
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Icon(
                                  Icons.mic_off,
                                  size: 40.0,
                                  color: Colors.white,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  mute = !mute;
                                });
                                TwilioVoice.instance.call.toggleMute(mute);
                                // setState(() {
                                //   mute = !mute;
                                // });
                              },
                            ),
                          ),
                        )
                      ]),
                  RawMaterialButton(
                    elevation: 2.0,
                    fillcolor: AppColors.red,
                    child: Icon(
                      Icons.call_end,
                      size: 40.0,
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.all(20.0),
                    shape: CircleBorder(),
                    onPressed: () async {
                      TwilioVoice.instance.call.hangUp();
                    },
                  )
                ],
              ),
            ),
          ),
        ));
  }


}
*/
