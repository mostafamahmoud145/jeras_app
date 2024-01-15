// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
// import 'package:events_emitter/events_emitter.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';
// import 'package:flutter_zoom_videosdk/native/zoom_videosdk_event_listener.dart';
// import 'package:flutter_zoom_videosdk/native/zoom_videosdk_live_transcription_message_info.dart';
// import 'package:flutter_zoom_videosdk/native/zoom_videosdk_user.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:jeras/Utils/jwt.dart';
// import 'package:jeras/localization/localization_methods.dart';
// import 'package:jeras/models/AppAppointments.dart';
// import 'package:jeras/models/user.dart';
// import 'package:jeras/screens/components/video_view.dart';
// import 'package:jeras/widget/endCallDialog.dart';
// import 'package:jeras/widget/responsive.dart';
//
//
// class ZoomCallScreen extends StatefulHookWidget {
//   const ZoomCallScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ZoomCallScreen> createState() => _ZoomCallScreenState();
// }
//
// class _ZoomCallScreenState extends State<ZoomCallScreen> {
//   double opacityLevel = 1.0;
//
//   void _changeOpacity() {
//     setState(() => opacityLevel = opacityLevel == 0 ? 1.0 : 0.0);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     var zoom = ZoomVideoSdk();
//     var eventListener = ZoomVideoSdkEventListener();
//     var isInSession = useState(false);
//     var sessionName = useState('');
//     var sessionPassword = useState('');
//     var users = useState(<ZoomVideoSdkUser>[]);
//     var fullScreenUser = useState<ZoomVideoSdkUser?>(null);
//     var sharingUser = useState<ZoomVideoSdkUser?>(null);
//     var isSharing = useState(false);
//     var isMuted = useState(true);
//     var isVideoOn = useState(false);
//     var isSpeakerOn = useState(false);
//     var isRecordingStarted = useState(false);
//     var isMounted = useIsMounted();
//     var audioStatusFlag = useState(false);
//     var videoStatusFlag = useState(false);
//     var userNameFlag = useState(false);
//     var userShareStatusFlag = useState(false);
//     var isReceiveSpokenLanguageContentEnabled = useState(false);
//     String acceptStatus = '';
//
//     if ((ModalRoute.of(context)!.settings.arguments as CallArguments).userType == "CONSULTANT"){
//       final databaseReference = FirebaseDatabase.instance.ref("zoomMeeting/${(ModalRoute.of(context)!.settings.arguments as CallArguments).sessionName}").child('userMeetAccept');
//       databaseReference.onValue.listen((event) async {
//         final String data = event.snapshot.value.toString();
//         acceptStatus = data;
//         if (data != null && data != "null") {
//           if(data == "cancel"){
//             return showDialog<void>(
//               context: context,
//               builder: (BuildContext context) {
//                 return AlertDialog(
//                   title: Text(getTranslated(context, "studentDeclinedZoomMeeting"),style: TextStyle(
//                       fontFamily: getTranslated(context, "Ithra"),
//                       fontWeight: FontWeight.w300)),
//                   actions: [
//                     TextButton(
//                       child: Text(getTranslated(context, "closeZoomMeeting"),style: TextStyle(
//                           fontFamily: getTranslated(context, "Ithra"),
//                           fontWeight: FontWeight.w300)),
//                       onPressed: () async {
//                         Navigator.of(context).pop();
//                         await Navigator.popAndPushNamed(
//                           context,
//                           "/home",
//                           arguments: JoinArguments(
//                               false,
//                               "",
//                               "",
//                               "",
//                               "",
//                               ""
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 );
//               },
//             );
//           }
//         }
//       });
//     }
//
//
//
//
//     //hide status bar
//     SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
//     var circleButtonSize = 100.0.r;
//     Color backgroundColor = const Color(0xFF232323);
//     Color buttonBackgroundColor = const Color.fromRGBO(0, 0, 0, 0.6);
//     final args =
//     ModalRoute.of(context)!.settings.arguments as CallArguments;
//
//     useEffect(() {
//       Future<void>.microtask(() async {
//         var token = generateJwt(args.sessionName, args.role);
//         try {
//           Map<String, bool> SDKaudioOptions = {"connect": true, "mute": true, "autoAdjustSpeakerVolume": false};
//           Map<String, bool> SDKvideoOptions = {
//             "localVideoOn": true,
//           };
//           JoinSessionConfig joinSession = JoinSessionConfig(
//             sessionName: args.sessionName,
//             sessionPassword: args.sessionPwd,
//             token: token,
//             userName: args.displayName,
//             audioOptions: SDKaudioOptions,
//             videoOptions: SDKvideoOptions,
//             sessionIdleTimeoutMins: int.parse(args.sessionIdleTimeoutMins),
//           );
//           await zoom.joinSession(joinSession);
//         } catch (e) {
//           const AlertDialog(
//             title: Text("Error"),
//             content: Text("Failed to join the session"),
//           );
//           Future.delayed(const Duration(milliseconds: 1000))
//               .asStream()
//               .listen((event) {
//             Navigator.popAndPushNamed(
//               context,
//               "Join",
//               arguments: JoinArguments(
//                   args.isJoin,
//                   sessionName.value,
//                   sessionPassword.value,
//                   args.displayName,
//                   args.sessionIdleTimeoutMins,
//                   args.role
//               ),
//             );
//           });
//         }
//       });
//       return null;
//     }, []);
//
//
//     useEffect(() {
//       eventListener.addEventListener();
//       EventEmitter emitter = eventListener.eventEmitter;
//
//       final sessionJoinListener =
//       emitter.on(EventType.onSessionJoin, (sessionUser) async {
//         isInSession.value = true;
//         zoom.session
//             .getSessionName()
//             .then((value) => sessionName.value = value!);
//         sessionPassword.value = await zoom.session.getSessionPassword();
//         ZoomVideoSdkUser mySelf =
//         ZoomVideoSdkUser.fromJson(jsonDecode(sessionUser.toString()));
//         List<ZoomVideoSdkUser>? remoteUsers =
//         await zoom.session.getRemoteUsers();
//         var muted = await mySelf.audioStatus?.isMuted();
//         var videoOn = await mySelf.videoStatus?.isOn();
//         var speakerOn = await zoom.audioHelper.getSpeakerStatus();
//         fullScreenUser.value = mySelf;
//         remoteUsers?.insert(0, mySelf);
//         users.value = remoteUsers!;
//         isMuted.value = muted!;
//         isSpeakerOn.value = speakerOn;
//         isVideoOn.value = videoOn!;
//         users.value = remoteUsers;
//         isReceiveSpokenLanguageContentEnabled.value =
//         await zoom.liveTranscriptionHelper.isReceiveSpokenLanguageContentEnabled();
//       });
//
//       final sessionLeaveListener =
//       emitter.on(EventType.onSessionLeave, (data) async {
//         isInSession.value = false;
//         users.value = <ZoomVideoSdkUser>[];
//         fullScreenUser.value = null;
//       });
//
//       final sessionNeedPasswordListener =
//       emitter.on(EventType.onSessionNeedPassword, (data) async {
//         showDialog<String>(
//           context: context,
//           builder: (BuildContext context) => AlertDialog(
//             title: const Text('Session Need Password'),
//             content: const Text('Password is required'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () async => {Navigator.popAndPushNamed(
//                     context,
//                     'Join',
//                     arguments: JoinArguments(
//                         args.isJoin,
//                         args.sessionName,
//                         "",
//                         args.displayName,
//                         args.sessionIdleTimeoutMins,
//                         args.role
//                     )),
//                   await zoom.leaveSession(false),
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       });
//
//       final sessionPasswordWrongListener =
//       emitter.on(EventType.onSessionPasswordWrong, (data) async {
//         showDialog<String>(
//           context: context,
//           builder: (BuildContext context) => AlertDialog(
//             title: const Text('Session Password Incorrect'),
//             content: const Text('Password is wrong'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () async => {Navigator.popAndPushNamed(
//                     context,
//                     'Join',
//                     arguments: JoinArguments(
//                         args.isJoin,
//                         args.sessionName,
//                         "",
//                         args.displayName,
//                         args.sessionIdleTimeoutMins,
//                         args.role
//                     )),
//                   await zoom.leaveSession(false),
//                 },
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       });
//
//       final userVideoStatusChangedListener =
//       emitter.on(EventType.onUserVideoStatusChanged, (data) async {
//         data = data as Map;
//         ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//         var userListJson = jsonDecode(data['changedUsers']) as List;
//         List<ZoomVideoSdkUser> userList = userListJson
//             .map((userJson) => ZoomVideoSdkUser.fromJson(userJson))
//             .toList();
//         for (var user in userList) {
//           {
//             if (user.userId == mySelf?.userId) {
//               mySelf?.videoStatus?.isOn().then((on) => isVideoOn.value = on);
//             }
//           }
//         }
//         videoStatusFlag.value = !videoStatusFlag.value;
//       });
//
//       final userAudioStatusChangedListener =
//       emitter.on(EventType.onUserAudioStatusChanged, (data) async {
//         data = data as Map;
//         ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//         var userListJson = jsonDecode(data['changedUsers']) as List;
//         List<ZoomVideoSdkUser> userList = userListJson
//             .map((userJson) => ZoomVideoSdkUser.fromJson(userJson))
//             .toList();
//         for (var user in userList) {
//           {
//             if (user.userId == mySelf?.userId) {
//               mySelf?.audioStatus
//                   ?.isMuted()
//                   .then((muted) => isMuted.value = muted);
//             }
//           }
//         }
//         audioStatusFlag.value = !audioStatusFlag.value;
//       });
//
//       final userShareStatusChangeListener =
//       emitter.on(EventType.onUserShareStatusChanged, (data) async {
//         data = data as Map;
//         ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//         ZoomVideoSdkUser shareUser =
//         ZoomVideoSdkUser.fromJson(jsonDecode(data['user'].toString()));
//
//         if (data['status'] == ShareStatus.Start) {
//           sharingUser.value = shareUser;
//           fullScreenUser.value = shareUser;
//           isSharing.value = (shareUser.userId == mySelf?.userId);
//         } else {
//           sharingUser.value = null;
//           isSharing.value = false;
//           fullScreenUser.value = mySelf;
//         }
//         userShareStatusFlag.value = !userShareStatusFlag.value;
//       });
//
//       final userJoinListener = emitter.on(EventType.onUserJoin, (data) async {
//         if (!isMounted()) return;
//         data = data as Map;
//         ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//         var userListJson = jsonDecode(data['remoteUsers']) as List;
//         List<ZoomVideoSdkUser> remoteUserList = userListJson
//             .map((userJson) => ZoomVideoSdkUser.fromJson(userJson))
//             .toList();
//         remoteUserList.insert(0, mySelf!);
//         users.value = remoteUserList;
//       });
//
//       final userLeaveListener = emitter.on(EventType.onUserLeave, (data) async {
//         if (!isMounted()) return;
//         ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//         data = data as Map;
//         var remoteUserListJson = jsonDecode(data['remoteUsers']) as List;
//         List<ZoomVideoSdkUser> remoteUserList = remoteUserListJson
//             .map((userJson) => ZoomVideoSdkUser.fromJson(userJson))
//             .toList();
//         var leftUserListJson = jsonDecode(data['leftUsers']) as List;
//         List<ZoomVideoSdkUser> leftUserLis = leftUserListJson
//             .map((userJson) => ZoomVideoSdkUser.fromJson(userJson))
//             .toList();
//         if (fullScreenUser.value != null) {
//           for (var user in leftUserLis) {
//             {
//               if (fullScreenUser.value?.userId == user.userId) {
//                 fullScreenUser.value = mySelf;
//               }
//             }
//           }
//         } else {
//           fullScreenUser.value = mySelf;
//         }
//         remoteUserList.add(mySelf!);
//         users.value = remoteUserList;
//       });
//
//       final userNameChangedListener =
//       emitter.on(EventType.onUserNameChanged, (data) async {
//         if (!isMounted()) return;
//         data = data as Map;
//         ZoomVideoSdkUser? changedUser =
//         ZoomVideoSdkUser.fromJson(jsonDecode(data['changedUser']));
//         int index;
//         for (var user in users.value) {
//           if (user.userId == changedUser.userId) {
//             index = users.value.indexOf(user);
//             users.value[index] = changedUser;
//           }
//         }
//         userNameFlag.value = !userNameFlag.value;
//       });
//
//       final commandReceived =
//       emitter.on(EventType.onCommandReceived, (data) async {
//         data = data as Map;
//         debugPrint(
//             "sender: ${ZoomVideoSdkUser.fromJson(jsonDecode(data['sender']))}, command: ${data['command']}");
//       });
//
//       final chatDeleteMessageNotify =
//       emitter.on(EventType.onChatDeleteMessageNotify, (data) async {
//         data = data as Map;
//         debugPrint(
//             "onChatDeleteMessageNotify: messageID: ${data['msgID']}, deleteBy: ${data['type']}");
//       });
//
//       final liveStreamStatusChangeListener =
//       emitter.on(EventType.onLiveStreamStatusChanged, (data) async {
//         data = data as Map;
//         debugPrint("onLiveStreamStatusChanged: status: ${data['status']}");
//       });
//
//       final liveTranscriptionStatusChangeListener =
//       emitter.on(EventType.onLiveTranscriptionStatus, (data) async {
//         data = data as Map;
//         debugPrint("onLiveTranscriptionStatus: status: ${data['status']}");
//       });
//
//       final cloudRecordingStatusListener =
//       emitter.on(EventType.onCloudRecordingStatus, (data) async {
//         data = data as Map;
//         debugPrint("onCloudRecordingStatus: status: ${data['status']}");
//         ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//         if (data['status'] == RecordingStatus.Start) {
//           if (mySelf != null && !mySelf.isHost!) {
//             showDialog<String>(
//               context: context,
//               builder: (BuildContext context) => AlertDialog(
//                 content: const Text('The session is being recorded.'),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () async {
//                       await zoom.acceptRecordingConsent();
//                       if (context.mounted) {
//                         Navigator.pop(context);
//                       };
//                     },
//                     child: const Text('accept'),
//                   ),
//                   TextButton(
//                     onPressed: () async {
//                       String currentConsentType =
//                       await zoom.getRecordingConsentType();
//                       if (currentConsentType ==
//                           ConsentType.ConsentType_Individual) {
//                         await zoom.declineRecordingConsent();
//                         Navigator.pop(context);
//                       } else {
//                         await zoom.declineRecordingConsent();
//                         zoom.leaveSession(false);
//                         if (!context.mounted) return;
//                         Navigator.popAndPushNamed(
//                           context,
//                           "Join",
//                           arguments: JoinArguments(
//                               args.isJoin,
//                               sessionName.value,
//                               sessionPassword.value,
//                               args.displayName,
//                               args.sessionIdleTimeoutMins,
//                               args.role
//                           ),
//                         );
//                       }
//                     },
//                     child: const Text('decline'),
//                   ),
//                 ],
//               ),
//             );
//           }
//           isRecordingStarted.value = true;
//         } else {
//           isRecordingStarted.value = false;
//         }
//       });
//
//       final liveTranscriptionMsgInfoReceivedListener =
//       emitter.on(EventType.onLiveTranscriptionMsgInfoReceived, (data) async {
//         data = data as Map;
//         ZoomVideoSdkLiveTranscriptionMessageInfo? messageInfo =
//         ZoomVideoSdkLiveTranscriptionMessageInfo.fromJson(jsonDecode(data['messageInfo']));
//         debugPrint("onLiveTranscriptionMsgInfoReceived: content: ${messageInfo.messageContent}");
//       });
//
//       final inviteByPhoneStatusListener =
//       emitter.on(EventType.onInviteByPhoneStatus, (data) async {
//         data = data as Map;
//         debugPrint(
//             "onInviteByPhoneStatus: status: ${data['status']}, reason: ${data['reason']}");
//       });
//
//       final multiCameraStreamStatusChangedListener =
//       emitter.on(EventType.onMultiCameraStreamStatusChanged, (data) async {
//         data = data as Map;
//         ZoomVideoSdkUser? changedUser =
//         ZoomVideoSdkUser.fromJson(jsonDecode(data['changedUser']));
//         var status = data['status'];
//         for (var user in users.value) {
//           {
//             if (changedUser.userId == user.userId) {
//               if (status == MultiCameraStreamStatus.Joined) {
//                 user.hasMultiCamera = true;
//               } else if (status == MultiCameraStreamStatus.Left) {
//                 user.hasMultiCamera = false;
//               }
//             }
//           }
//         }
//       });
//
//       final requireSystemPermission =
//       emitter.on(EventType.onRequireSystemPermission, (data) async {
//         data = data as Map;
//         var permissionType = data['permissionType'];
//         switch (permissionType) {
//           case SystemPermissionType.Camera:
//             showDialog<String>(
//               context: context,
//               builder: (BuildContext context) => AlertDialog(
//                 title: const Text("Can't Access Camera"),
//                 content: const Text(
//                     "please turn on the toggle in system settings to grant permission"),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, 'OK'),
//                     child: const Text('OK'),
//                   ),
//                 ],
//               ),
//             );
//             break;
//           case SystemPermissionType.Microphone:
//             showDialog<String>(
//               context: context,
//               builder: (BuildContext context) => AlertDialog(
//                 title: const Text("Can't Access Microphone"),
//                 content: const Text(
//                     "please turn on the toggle in system settings to grant permission"),
//                 actions: <Widget>[
//                   TextButton(
//                     onPressed: () => Navigator.pop(context, 'OK'),
//                     child: const Text('OK'),
//                   ),
//                 ],
//               ),
//             );
//             break;
//         }
//       });
//
//       final networkStatusChangeListener =
//       emitter.on(EventType.onUserVideoNetworkStatusChanged, (data) async {
//         data = data as Map;
//         ZoomVideoSdkUser? networkUser =
//         ZoomVideoSdkUser.fromJson(jsonDecode(data['user']));
//
//         if (data['status'] == NetworkStatus.Bad) {
//           debugPrint("onUserVideoNetworkStatusChanged: status: ${data['status']}, user: ${networkUser.userName}");
//         }
//       });
//
//       final eventErrorListener = emitter.on(EventType.onError, (data) async {
//         data = data as Map;
//         String errorType = data['errorType'];
//         showDialog<String>(
//           context: context,
//           builder: (BuildContext context) => AlertDialog(
//             title: const Text("Error"),
//             content: Text(errorType),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () => Navigator.pop(context, 'OK'),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//         if (errorType == Errors.SessionJoinFailed ||
//             errorType == Errors.SessionDisconncting) {
//           Timer(
//             const Duration(milliseconds: 1000),
//                 () => Navigator.popAndPushNamed(
//               context,
//               "Join",
//               arguments: JoinArguments(
//                   args.isJoin,
//                   sessionName.value,
//                   sessionPassword.value,
//                   args.displayName,
//                   args.sessionIdleTimeoutMins,
//                   args.role
//               ),
//             ),);
//         }
//       });
//
//       final userRecordingConsentListener =
//       emitter.on(EventType.onUserRecordingConsent, (data) async {
//         data = data as Map;
//         ZoomVideoSdkUser? user =
//         ZoomVideoSdkUser.fromJson(jsonDecode(data['user']));
//         debugPrint('userRecordingConsentListener: user= ${user.userName}');
//       });
//
//
//
//       return () => {
//         sessionJoinListener.cancel(),
//         sessionLeaveListener.cancel(),
//         sessionPasswordWrongListener.cancel(),
//         sessionNeedPasswordListener.cancel(),
//         userVideoStatusChangedListener.cancel(),
//         userAudioStatusChangedListener.cancel(),
//         userJoinListener.cancel(),
//         userLeaveListener.cancel(),
//         userNameChangedListener.cancel(),
//         userShareStatusChangeListener.cancel(),
//         liveStreamStatusChangeListener.cancel(),
//         cloudRecordingStatusListener.cancel(),
//         inviteByPhoneStatusListener.cancel(),
//         eventErrorListener.cancel(),
//         commandReceived.cancel(),
//         chatDeleteMessageNotify.cancel(),
//         liveTranscriptionStatusChangeListener.cancel(),
//         liveTranscriptionMsgInfoReceivedListener.cancel(),
//         multiCameraStreamStatusChangedListener.cancel(),
//         requireSystemPermission.cancel(),
//         userRecordingConsentListener.cancel(),
//         networkStatusChangeListener.cancel(),
//       };
//     }, [zoom, users.value, isMounted]);
//
//     void onPressAudio() async {
//       ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//       if (mySelf != null) {
//         final audioStatus = mySelf.audioStatus;
//         if (audioStatus != null) {
//           var muted = await audioStatus.isMuted();
//           if (muted) {
//             await zoom.audioHelper.unMuteAudio(mySelf.userId);
//           } else {
//             await zoom.audioHelper.muteAudio(mySelf.userId);
//           }
//         }
//       }
//     }
//
//     void onPressVideo() async {
//       ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//       if (mySelf != null) {
//         final videoStatus = mySelf.videoStatus;
//         if (videoStatus != null) {
//           var videoOn = await videoStatus.isOn();
//           if (videoOn) {
//             await zoom.videoHelper.stopVideo();
//           } else {
//             await zoom.videoHelper.startVideo();
//           }
//         }
//       }
//     }
//
//
//
//     void onSelectedUserVolume(ZoomVideoSdkUser user) async {
//       var isShareAudio = user.isSharing;
//       bool canSetVolume =
//       await user.canSetUserVolume(user.userId, isShareAudio);
//       num userVolume;
//
//       List<ListTile> options = [
//         ListTile(
//           title: Text(
//             'Adjust Volume',
//             style: GoogleFonts.lato(
//               textStyle: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: AppFontsWeightManager.semiBold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ),
//         ListTile(
//           title: Text(
//             'Current volume',
//             style: GoogleFonts.lato(
//               textStyle: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.normal,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           onTap: () async => {
//             debugPrint('user volume'),
//             userVolume = await user.getUserVolume(user.userId, isShareAudio),
//             debugPrint('user ${user.userName}\'s volume is ${userVolume!}'),
//           },
//         ),
//       ];
//       if (canSetVolume) {
//         options.add(
//           ListTile(
//             title: Text(
//               'Volume up',
//               style: GoogleFonts.lato(
//                 textStyle: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.normal,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             onTap: () async => {
//               userVolume = await user.getUserVolume(user.userId, isShareAudio),
//               if (userVolume < 10) {
//                 await user.setUserVolume(user.userId, userVolume + 1, isShareAudio),
//               } else {
//                 debugPrint("Cannot volume up."),
//               }
//             },
//           ),
//         );
//         options.add(
//           ListTile(
//             title: Text(
//               'Volume down',
//               style: GoogleFonts.lato(
//                 textStyle: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.normal,
//                   color: Colors.black,
//                 ),
//               ),
//             ),
//             onTap: () async => {
//               userVolume = await user.getUserVolume(user.userId, isShareAudio),
//               if (userVolume > 0) {
//                 await user.setUserVolume(user.userId, userVolume - 1, isShareAudio),
//               } else {
//                 debugPrint("Cannot volume down."),
//               }
//             },
//           ),
//         );
//       }
//       showDialog(
//           context: context,
//           builder: (context) {
//             return Dialog(
//                 elevation: 0.0,
//                 insetPadding: const EdgeInsets.symmetric(horizontal: 40),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20)),
//                 child: SizedBox(
//                   height: options.length * 58,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       ListView(
//                         shrinkWrap: true,
//                         children: ListTile.divideTiles(
//                           context: context,
//                           tiles: options,
//                         ).toList(),
//                       ),
//                     ],
//                   ),
//                 ));
//           });
//     }
//
//
//
//     void onLeaveSession(bool isEndSession) async {
//       await zoom.leaveSession(isEndSession);
//
//       if (context.mounted) {
//
//         DatabaseReference ref = FirebaseDatabase.instance.ref("zoomMeeting/${args.appointment.orderId}");
//         await ref.update({
//           "userMeetAccept" : "closed"
//         });
//
//         if ((ModalRoute.of(context)!.settings.arguments as CallArguments).userType == "CONSULTANT")
//         {
//           final args = await ModalRoute.of(context)!.settings.arguments as CallArguments;
//           await showDialog(
//             barrierDismissible: false,
//             context: context,
//             builder: (context) {
//
//               return EndCallDialog(
//                 user: args.loggedUser,
//                 appointment: args.appointment,);
//             },
//           );
//         }else{
//           await Navigator.popAndPushNamed(
//             context,
//             "/home",
//             arguments: JoinArguments(
//                 !isEndSession,
//                 sessionName.value,
//                 sessionPassword.value,
//                 args.displayName,
//                 args.sessionIdleTimeoutMins,
//                 args.role
//             ),
//           );
//         }
//       }
//
//
//
//       // if (context.mounted) {
//       //   await Navigator.popAndPushNamed(
//       //     context,
//       //     "/home",
//       //     arguments: JoinArguments(
//       //         !isEndSession,
//       //         sessionName.value,
//       //         sessionPassword.value,
//       //         args.displayName,
//       //         args.sessionIdleTimeoutMins,
//       //         args.role
//       //     ),
//       //   );
//       // }
//     }
//
//     void showLeaveOptions() async {
//       ZoomVideoSdkUser? mySelf = await zoom.session.getMySelf();
//       bool isHost = await mySelf!.getIsHost();
//
//       Widget endSession;
//       Widget leaveSession;
//       Widget cancel = TextButton(
//         child: Text(getTranslated(context, "cancel1")),
//         onPressed: () {
//           Navigator.pop(context); //close Dialog
//         },
//       );
//
//       switch (defaultTargetPlatform) {
//         case TargetPlatform.android:
//           endSession = TextButton(
//             child: Text(getTranslated(context, "closeZoomMeeting"),style: TextStyle(
//                 fontFamily: getTranslated(context, "Ithra"),
//                 fontWeight: FontWeight.w300)),
//             onPressed: () => onLeaveSession(true),
//           );
//           leaveSession = TextButton(
//             child: Text(getTranslated(context, "leaveZoomMeeting"),style: TextStyle(
//                 fontFamily: getTranslated(context, "Ithra"),
//                 fontWeight: FontWeight.w300)),
//             onPressed: () => onLeaveSession(false),
//           );
//           break;
//         default:
//           endSession = CupertinoActionSheetAction(
//             isDestructiveAction: true,
//             child: Text(getTranslated(context, "closeZoomMeeting"),style: TextStyle(
//                 fontFamily: getTranslated(context, "Ithra"),
//                 fontWeight: FontWeight.w300)),
//             onPressed: () => onLeaveSession(true),
//           );
//           leaveSession = CupertinoActionSheetAction(
//             child: Text(getTranslated(context, "leaveZoomMeeting"),style: TextStyle(
//                 fontFamily: getTranslated(context, "Ithra"),
//                 fontWeight: FontWeight.w300)),
//             onPressed: () => onLeaveSession(false),
//           );
//           break;
//       }
//
//       List<Widget> options = [
//         leaveSession,
//         cancel,
//       ];
//
//       if (Platform.isAndroid) {
//         if (isHost) {
//           options.removeAt(1);
//           options.insert(0, endSession);
//         }
//         showDialog(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 content: Text(getTranslated(context, "isLeaveZoomMeeting")),
//                 shape: const RoundedRectangleBorder(
//                     borderRadius: BorderRadius.all(Radius.circular(2.0))),
//                 actions: options,
//               );
//             });
//       } else {
//         options.removeAt(1);
//         if (isHost) {
//           options.insert(1, endSession);
//         }
//         showCupertinoModalPopup(
//           context: context,
//           builder: (context) => CupertinoActionSheet(
//             message:
//             const Text('Are you sure that you want to leave the session?'),
//             actions: options,
//             cancelButton: cancel,
//           ),
//         );
//       }
//     }
//
//
//
//     void onSelectedUser(ZoomVideoSdkUser user) async {
//       setState(() {
//         fullScreenUser.value = user;
//       });
//     }
//
//     Widget fullScreenView;
//     Widget smallView;
//
//     if (users.value.asMap().containsKey(1)) {
//       fullScreenView = AnimatedOpacity(
//         opacity: opacityLevel,
//         duration: const Duration(seconds: 3),
//         child: VideoView(
//           user: users.value[1],
//           hasMultiCamera: false,
//           sharing: sharingUser.value == null
//               ? false
//               : (sharingUser.value?.userId == fullScreenUser.value?.userId),
//           preview: false,
//           focused: false,
//           multiCameraIndex: "0",
//           videoAspect: VideoAspect.Original,
//           fullScreen: true,
//         ),
//       );
//
//       smallView = Container(
//         height: 110,
//         margin: const EdgeInsets.only(left: 20, right: 20),
//         alignment: Alignment.center,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           itemCount: 1,
//           itemBuilder: (BuildContext context, int index) {
//             return InkWell(
//               onTap: () async {
//                 onSelectedUser(users.value[index]);
//               },
//               onDoubleTap: () async {
//                 onSelectedUserVolume(users.value[index]);
//               },
//               child: Center(
//                 child: VideoView(
//                   user: users.value[index],
//                   hasMultiCamera: false,
//                   sharing: sharingUser.value == null
//                       ? false
//                       : sharingUser.value?.userId == users.value[index].userId,
//                   preview: false,
//                   focused: false,
//                   multiCameraIndex: "0",
//                   videoAspect: VideoAspect.Original,
//                   fullScreen: false,
//                 ),
//               ),
//             );
//           },
//           separatorBuilder: (BuildContext context, int index) =>
//           const Divider(),
//         ),
//       );
//     } else {
//       fullScreenView = Container(
//           color: Colors.black,
//           child: const Center(
//             child: Text(
//               "Connecting...",
//               style: TextStyle(
//                 fontSize: 20,
//                 color: Colors.white,
//               ),
//             ),
//           ));
//       smallView = Container(
//         height: 110,
//         color: Colors.transparent,
//       );
//     }
//
//     _changeOpacity;
//     return Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: backgroundColor,
//         body: Stack(
//           children: [
//             fullScreenView,
//             Container(
//                 padding: const EdgeInsets.only(top: 35),
//                 child: Stack(
//                   children: [
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           height: 70,
//                           width: 150,
//                           margin: const EdgeInsets.only(top: 16, left: 8),
//                           padding: const EdgeInsets.all(8),
//                           alignment: Alignment.topLeft,
//                           decoration: BoxDecoration(
//                             borderRadius:
//                             const BorderRadius.all(Radius.circular(8.0)),
//                             color: buttonBackgroundColor,
//                           ),
//                           child: InkWell(
//                             onTap: () async {
//                               showDialog(
//                                   context: context,
//                                   builder: (context) {
//                                     return Dialog(
//                                         elevation: 0.0,
//                                         insetPadding:
//                                         const EdgeInsets.symmetric(
//                                             horizontal: 40),
//                                         shape: RoundedRectangleBorder(
//                                             borderRadius:
//                                             BorderRadius.circular(20)),
//                                         child: SizedBox(
//                                           height: 280,
//                                           width: 200,
//                                           child: Column(
//                                             crossAxisAlignment:
//                                             CrossAxisAlignment.stretch,
//                                             children: [
//                                               ListView(
//                                                 shrinkWrap: true,
//                                                 children: ListTile.divideTiles(
//                                                   context: context,
//                                                   tiles: [
//                                                     ListTile(
//                                                       title: Text(
//                                                         'Session Information',
//                                                         style: GoogleFonts.lato(
//                                                           textStyle:
//                                                           const TextStyle(
//                                                             fontSize: 18,
//                                                             fontWeight:
//                                                             FontWeight.w600,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     ListTile(
//                                                       title: Text(
//                                                         'Session Name',
//                                                         style: GoogleFonts.lato(
//                                                           textStyle:
//                                                           const TextStyle(
//                                                             fontSize: 14,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       subtitle: Text(
//                                                         sessionName.value,
//                                                         style: GoogleFonts.lato(
//                                                           textStyle:
//                                                           const TextStyle(
//                                                             fontSize: 12,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     ListTile(
//                                                       title: Text(
//                                                         'Session Password',
//                                                         style: GoogleFonts.lato(
//                                                           textStyle:
//                                                           const TextStyle(
//                                                             fontSize: 14,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       subtitle: Text(
//                                                         sessionPassword.value,
//                                                         style: GoogleFonts.lato(
//                                                           textStyle:
//                                                           const TextStyle(
//                                                             fontSize: 12,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                     ListTile(
//                                                       title: Text(
//                                                         'Participants',
//                                                         style: GoogleFonts.lato(
//                                                           textStyle:
//                                                           const TextStyle(
//                                                             fontSize: 14,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                       subtitle: Text(
//                                                         '${users.value.length}',
//                                                         style: GoogleFonts.lato(
//                                                           textStyle:
//                                                           const TextStyle(
//                                                             fontSize: 12,
//                                                           ),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ).toList(),
//                                               ),
//                                             ],
//                                           ),
//                                         ));
//                                   });
//                             },
//                             child: Stack(
//                               children: [
//                                 Column(
//                                   children: [
//                                     const Padding(
//                                         padding:
//                                         EdgeInsets.symmetric(vertical: 2)),
//                                     Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(
//                                         sessionName.value,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: GoogleFonts.lato(
//                                           textStyle: const TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: AppFontsWeightManager.semiBold,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     const Padding(
//                                         padding:
//                                         EdgeInsets.symmetric(vertical: 5)),
//                                     Align(
//                                       alignment: Alignment.centerLeft,
//                                       child: Text(
//                                         "Participants: ${users.value.length}",
//                                         style: GoogleFonts.lato(
//                                           textStyle: const TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: AppFontsWeightManager.semiBold,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                                 Container(
//                                     alignment: Alignment.centerRight,
//                                     child: Image.asset(
//                                       "assets/zoom/icons/unlocked@2x.png",
//                                       height: 22,
//                                     )),
//                               ],
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                             onPressed: (showLeaveOptions),
//                             child: Container(
//                               alignment: Alignment.topRight,
//                               margin: const EdgeInsets.only(top: 16, right: 8),
//                               padding: const EdgeInsets.only(
//                                   top: 5, bottom: 5, left: 16, right: 16),
//                               height: 28,
//                               decoration: BoxDecoration(
//                                 borderRadius: const BorderRadius.all(
//                                     Radius.circular(20.0)),
//                                 color: buttonBackgroundColor,
//                               ),
//                               child: const Text(
//                                 "LEAVE",
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFFE02828),
//                                 ),
//                               ),
//                             )),
//                       ],
//                     ),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           IconButton(
//                             onPressed: onPressAudio,
//                             icon: isMuted.value
//                                 ? Image.asset("assets/zoom/icons/unmute@2x.png",width: circleButtonSize,)
//                                 : Image.asset("assets/zoom/icons/mute@2x.png",width: circleButtonSize,),
//                             iconSize: circleButtonSize,
//                             tooltip: isMuted.value == true ? "Unmute" : "Mute",
//                           ),
//                           IconButton(
//                             onPressed: onPressVideo,
//                             iconSize: circleButtonSize,
//                             icon: isVideoOn.value
//                                 ? Image.asset("assets/zoom/icons/video-off@2x.png",width: circleButtonSize,)
//                                 : Image.asset("assets/zoom/icons/video-on@2x.png",width: circleButtonSize,),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Container(
//                       alignment: Alignment.bottomLeft,
//                       margin: const EdgeInsets.only(bottom: 120),
//                       child: smallView,
//                     ),
//                   ],
//                 )),
//           ],
//         )
//       // drawer: const MenuBar()
//     );
//   }
// }
//
// class CallArguments {
//   final bool isJoin;
//   final String sessionName;
//   final String sessionPwd;
//   final String displayName;
//   final String sessionIdleTimeoutMins;
//   final String role;
//   final String userType;
//   final AppAppointments appointment;
//   final GroceryUser loggedUser;
//
//   CallArguments(
//       this.sessionName,
//       this.sessionPwd,
//       this.displayName,
//       this.sessionIdleTimeoutMins,
//       this.role,
//       this.isJoin, this.userType, this.appointment, this.loggedUser
//       );
// }
//
// class JoinArguments {
//   final bool isJoin;
//   final String sessionName;
//   final String sessionPwd;
//   final String displayName;
//   final String sessionTimeout;
//   final String roleType;
//
//   JoinArguments(
//       this.isJoin,
//       this.sessionName,
//       this.sessionPwd,
//       this.displayName,
//       this.sessionTimeout,
//       this.roleType
//       );
// }
