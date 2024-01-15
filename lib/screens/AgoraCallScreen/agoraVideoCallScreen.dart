
import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:wakelock/wakelock.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../controller/blocs/account_bloc/account_bloc.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../widget/endCallDialog.dart';

class AgoraVideoCallScreen extends StatefulWidget {
  final AppAppointments appointment;
  final GroceryUser loggedUser;

  AgoraVideoCallScreen({Key? key, required this.appointment, required this.loggedUser,}) : super(key: key);


  @override
  _AgoraVideoCallScreenState createState() => _AgoraVideoCallScreenState();
}

class _AgoraVideoCallScreenState extends State<AgoraVideoCallScreen> {
  static final _users = <int>[];
  final _infoStrings = <String>[];
  bool muted = false,endingCall=false,join=false,result=false,done=true,camera=false,firstTime=false,callStart=false,speaker = false;
  late RtcEngine _engine;
  late Size size;
  int minutes =0,  seconds=0;
  String? image,name;
  String appId="680d9b31416c46b3850f1709f2a54d9e",uidCloud="",sid="",resourceId='';
  late AccountBloc accountBloc;

  @override
  Future<void> dispose() async {
    if(widget.loggedUser.userType=="CONSULTANT")
    {
      await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
        'allowCall':false,
      }, SetOptions(merge: true));
    }
    super.dispose();
  }
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    if (widget.loggedUser == null) {
    } else if (widget.loggedUser.uid == widget.appointment.consult.uid) {
      image = widget.appointment.user.image;
      name = widget.appointment.user.name;
    } else {
      image = widget.appointment.consult.image;
      name = widget.appointment.consult.name;

    }
    initialize();
  }

  Future<void> initialize() async {
    try{
      await _initAgoraRtcEngine();
      _addAgoraEventHandlers();
      //Wakelock.enable();
      await _engine.joinChannel(null, widget.appointment.appointmentId, null, 0);
    }catch(e){}
  }

  Future<void> _initAgoraRtcEngine() async {
    await [Permission.microphone].request();
    await [Permission.camera].request();
    _engine = await RtcEngine.create(appId);
    await _engine.enableAudio();
    //if(widget.appointment.consultType=="video")
    await _engine.enableVideo();
    // else
    // await _engine.disableVideo();
    _engine.adjustPlaybackSignalVolume(400);
    _engine.muteLocalAudioStream(muted);
  }

  void _addAgoraEventHandlers() {
    _engine.setEventHandler(RtcEngineEventHandler(
      error: (code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (channel, uid, elapsed) {
        setState(() {
          uidCloud=uid.toString();
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });

        //acquire();
      },
      leaveChannel: (stats) {
        Fluttertoast.showToast(
            msg: "You are alone now",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: AppColors.red,
            textColor: AppColors.white,
            fontSize: AppFontsSizeManager.s16);
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (uid, elapsed) {

        setState(() {
          final info = 'userJoined: $uid';
          callStart=true;
          _infoStrings.add(info);
          _users.add(uid);
        });
      },
      userOffline: (uid, reason) {
        setState(() {
          final info = 'userOffline: $uid , reason: $reason';
          _infoStrings.add(info);
          _users.remove(uid);
        });
      },
      firstRemoteVideoFrame: (uid, width, height, elapsed) {
        setState(() {
          final info = 'firstRemoteVideoFrame: $uid';
          _infoStrings.add(info);
        });
      },
    ));
  }
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding:  EdgeInsets.symmetric(vertical: AppPadding.p48),
      child: Column(mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: _onTogglemuted,
                child: Icon(
                  muted ?Icons.mic: Icons.mic_off ,
                  color: muted ? Colors.white : Colors.blueAccent,
                  size: AppSize.w20,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: muted ? Colors.blueAccent : Colors.white,
                padding: const EdgeInsets.all(AppRadius.r12),
              ),
              endingCall?Center(child: CircularProgressIndicator()):RawMaterialButton(
                onPressed: () => _onCallEnd(),
                child: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: AppSize.w35,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(AppRadius.r15),
              ),
              RawMaterialButton(
                onPressed: _onSwitchCamera,
                child: Icon(
                  Icons.switch_camera,
                  color: Colors.blueAccent,
                  size: AppSize.w20,
                ),
                shape: CircleBorder(),
                elevation: 2.0,
                fillColor: Colors.white,
                padding: const EdgeInsets.all(AppRadius.r12),
              )
            ], ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return  Scaffold(
      backgroundColor: Colors.black,
      body: videoCallWidget(),// widget.appointment.consultType=="video"?videoCallWidget():audioCallWidget()
    );
  }
  Widget videoCallWidget(){
    return Center(child:
    Stack(
      children: <Widget>[
        _viewRows(),
      Positioned(top:AppPadding.p50,right: AppPadding.p20,
          child: RawMaterialButton(
            onPressed: _toggleSpeaker,
            child: Icon(
              speaker ? Icons.volume_up : Icons.volume_off,
              color: speaker ? AppColors.white : AppColors.blue,
              size: AppSize.w20,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: speaker ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(AppRadius.r12),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Column(mainAxisAlignment: MainAxisAlignment.end,crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.loggedUser.userType == "CONSULTANT"
                      ? widget.appointment.user.name.toString()
                      : widget.appointment.consult.name.toString(),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.white,
                    fontSize: AppFontsSizeManager.s15,
                    // fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: AppSize.h10,
                ),
                (widget.appointment.freeCall==true)?TweenAnimationBuilder<Duration>(
                    duration: Duration(minutes: widget.appointment.consultType=="vocal"?AppConstants.minutes30:AppConstants.minutes20),
                    tween: Tween(
                        begin: Duration(minutes: widget.appointment.consultType=="vocal"?AppConstants.minutes30:AppConstants.minutes20), end: Duration.zero),
                    onEnd: () {
                      _onCallEnd();
                    },
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      minutes = value.inMinutes;
                      seconds = value.inSeconds % 60;
                      return Text('$minutes:$seconds',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: minutes < 5 ? Colors.red : Colors.white,
                              fontSize: 15));
                    }):TweenAnimationBuilder<Duration>(
                    duration: Duration(minutes: widget.appointment.consultType=="vocal"?AppConstants.minutes30:AppConstants.minutes60),
                    tween: Tween(
                        begin: Duration(minutes: widget.appointment.consultType=="vocal"?AppConstants.minutes30:AppConstants.minutes60), end: Duration.zero),
                    onEnd: () {
                      _onCallEnd();
                    },
                    builder:
                        (BuildContext context, Duration value, Widget? child) {
                      minutes = value.inMinutes;
                      seconds = value.inSeconds % 60;
                      return Text('$minutes:$seconds',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: minutes < 5 ? Colors.red : Colors.white,
                              fontSize: AppFontsSizeManager.s15));
                    }),
                SizedBox(
                  height: AppSize.h10,
                ),
                _toolbar(),
              ],
            ),
          ),
        ),

      ],
    ),
    );
  }
  Widget audioCallWidget(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.p0, vertical: AppPadding.p40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: AppSize.h30,),
              Center(
                child: Container(
                  height: AppSize.h80,
                  width: AppSize.w80,
                  padding: EdgeInsets.all(AppPadding.p2),
                  decoration: BoxDecoration(
                    // border: Border.all(color: AppColors.grey, width: 1),
                    shape: BoxShape.circle,
                    //color: AppColors.grey,
                  ),
                  child: image!.isEmpty && image != null
                      ? Image.asset(
                    AssetsManager.whiteJerasLogoIconPath,
                    width: AppSize.w80,
                    height: AppSize.h80,
                    fit: BoxFit.fill,
                  )
                      : ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.r100),
                    child: FadeInImage.assetNetwork(
                      placeholder: AssetsManager.lodeGif,
                      placeholderScale: 0.5,
                      imageErrorBuilder: (context, error,
                          stackTrace) =>
                          Image.asset(
                              AssetsManager.whiteJerasLogoIconPath,
                              width: AppSize.w80,
                              height: AppSize.h80,
                              fit: BoxFit.fill),
                      image: image!,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration(milliseconds: AppConstants.milliseconds250),
                      fadeInCurve: Curves.easeInOut,
                      fadeOutDuration:
                      Duration(milliseconds: AppConstants.milliseconds150),
                      fadeOutCurve: Curves.easeInOut,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSize.h5),
              Text(
                name! == null ? " " : name!,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s15,
                  fontWeight: FontWeight.normal,
                  color: AppColors.white,
                ),
              ),
              SizedBox(height: AppSize.h2),
              (callStart == false)
                  ? Text(
                getTranslated(context, "waitAgora") +
                    " " +
                    " " +
                    getTranslated(context, "join"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s10,
                  fontWeight: FontWeight.normal,
                  color: AppColors.pink,
                ),
              )
                  : SizedBox(),
              SizedBox(height: AppSize.h8),
              callStart
                  ? TweenAnimationBuilder<Duration>(
                  duration: Duration(minutes: widget.appointment.consultType=="vocal"?AppConstants.minutes30:AppConstants.minutes60),
                  tween: Tween(
                      begin: Duration(minutes: widget.appointment.consultType=="vocal"?AppConstants.minutes30:AppConstants.minutes60),
                      end: Duration.zero),
                  onEnd: () {
                    _onCallEnd();
                  },
                  builder: (BuildContext context2, Duration value,
                      Widget? child) {
                    minutes = value.inMinutes;
                    seconds = value.inSeconds % 60;
                    if (minutes == 5 && seconds == 0) {
                      firstTime = true;
                    }
                    return Padding(
                        padding:
                        const EdgeInsets.symmetric(vertical: AppPadding.p5),
                        child: Column(
                          children: [
                            Text('$minutes:$seconds',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: minutes < 5
                                        ? AppColors.red
                                        : AppColors.white,
                                    fontSize: AppFontsSizeManager.s15)),
                            firstTime
                                ? Text(
                              getTranslated(
                                  context, "fiveMinutes") +
                                  minutes.toString() +
                                  getTranslated(
                                      context, "minutes"),
                              maxLines: 2,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              softWrap: true,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s11,
                                color: AppColors.red,
                              ),
                            )
                                : SizedBox(),

                          ],
                        ));
                  })
                  :  Text('0:0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:  AppColors.white,
                      fontSize: AppFontsSizeManager.s15)),
            ],
          ),
          SizedBox(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.p40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  child: FloatingActionButton(
                      heroTag: "mic",
                      backgroundColor: AppColors.black,
                      child: Icon(
                        muted ?Icons.mic_off: Icons.mic,
                        color: AppColors.white,
                        size: AppSize.w25,
                      ),
                      onPressed: () => _onTogglemuted()),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  child: Column(
                    children: [
                      FloatingActionButton(
                          heroTag: "end",
                          backgroundColor: AppColors.red,
                          child: Icon(
                            Icons.call_end,
                            size: AppSize.w20,color: AppColors.white,
                          ),
                          onPressed: () => _onCallEnd()),
                      SizedBox(
                        height: AppSize.h30,
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppPadding.p8),
                  child: FloatingActionButton(
                      heroTag: "speaker",
                      backgroundColor:AppColors.black,
                      child: Icon(
                        speaker ? Icons.volume_up : Icons.volume_off,
                        color:AppColors.white,
                        size: AppSize.w25,
                      ),
                      onPressed: () => _toggleSpeaker()),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }
  List<Widget> _getRenderViews() {
    final List<StatefulWidget> list = [];
    list.add(RtcLocalView.SurfaceView());
    _users.forEach((int uid) => list.add(RtcRemoteView.SurfaceView(uid: uid,channelId: '',)));
    return list;
  }

  Widget _viewRows() {
    final views = _getRenderViews();

    if(views.length>1){
      setState(() {

        join=true;
        result=true;
      });
      }
    else
      setState(() {

        join=false;
        result=false;
      });

    return views.length==1?Container(
        child: Column(
          children: <Widget>[_videoView(views[0])],
        )):Container(
        child: Stack(
          children: <Widget>[
            //_expandedVideoRow([views[0]]),
            Positioned.fill(child: views[1]),
            Positioned(top:0,left: 0,child: Container(height:size.width*AppSize.h0_40,width:size.width*AppSize.w0_35,child: views[0]))
          ],
        ));

  }


  _toggleSpeaker() {
    setState(() {
      speaker = !speaker;
    });

    if (speaker)
      _engine.adjustPlaybackSignalVolume(400);
    else
      _engine.adjustPlaybackSignalVolume(100);
  }
  void _onTogglemuted() {
    setState(() {
      muted = !muted;
    });

    _engine.muteLocalAudioStream(muted);
    _engine.setEnableSpeakerphone(muted);

  }
  void _onSwitchCamera() {
    setState(() {
      camera = !camera;
    });
    _engine.switchCamera();
  }
  Future<void> _onCallEnd() async {
    _users.clear();
    _engine.leaveChannel();
    _engine.destroy();
    //stopRecording();
    if (widget.loggedUser.userType == "CONSULTANT")
    {
      confirmEndCallDialog(size);
    }
    else {
      if(widget.appointment.freeCall==true){
        setState(() {
          endingCall = true;
        });
        await FirebaseFirestore.instance.collection(Paths.appAppointments).doc(widget.appointment.appointmentId).set({
          'freeCall':false,
        }, SetOptions(merge: true));
        Navigator.pop(context);
      }else{
        setState(() {
          endingCall = true;
        });
        Navigator.pop(context);
      }

    }

  }

  confirmEndCallDialog(Size size) async {

    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return EndCallDialog(
          user: widget.loggedUser,
          appointment: widget.appointment, result: result,);
      },
    );

    /*if(widget.appointment.consult.name != null){
      print(widget.appointment.user.uid);
      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return EndCallDialog(
            user: widget.loggedUser,
            appointment: widget.appointment,);
        },
      );
    }
    else{
      print("notfound");
    }*/

  }


}
