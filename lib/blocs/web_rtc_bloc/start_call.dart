import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/paths.dart';
import 'package:jeras/models/AppAppointments.dart';
import 'package:jeras/models/user.dart';
import 'package:jeras/widget/endCallDialog.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
//import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart';

import '../../methods/change_user_call_state.dart';
import '../../methods/stop_foreground_service.dart';
import '../jitsi_meet/call_cubit/call_cubit.dart';

class StartCall {
  StartCall(
      {required this.host,
        required this.context,
        this.iscaller,
        this.acceptNotfi,
        this.appointment,
        this.loggedUser,
        this.isVideo,
        this.normalCall,
        this.CallerId,
        this.ReciverId});

  final String host;
  bool? iscaller = false;
  bool? acceptNotfi = false;
  AppAppointments? appointment;
  GroceryUser? loggedUser;
  String? CallerId = "";
  String? ReciverId = "";
  bool? isVideo = true;
  bool? normalCall = true;
  String? _reciverId = '';
  GroceryUser? peerInfo;
  BuildContext context;
  String ? technicalAccountId;

  startCall() async {
    if (CallerId == FirebaseAuth.instance.currentUser!.uid) {
      _reciverId = CallerId;
    } else {
      _reciverId = ReciverId;
    }
    Map<String, Object> featureFlags = {};
    Map<String, Object> configOverrides = {};
    var ref = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(_reciverId)
        .withConverter(
      fromFirestore: GroceryUser.fromFirestore,
      toFirestore: (GroceryUser user, _) => user.toFirestore(),
    );
    final docSnap = await ref.get();
    peerInfo = await docSnap.data();
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshotServer =
    await FirebaseFirestore.instance.collection('servers').doc('settings').get();
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshotFeatureFlags =
    await FirebaseFirestore.instance.collection('servers').doc('featureFlags').get();
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshotConfigOverrides =
    await FirebaseFirestore.instance.collection('servers').doc('configOverrides').get();


    documentSnapshotFeatureFlags.data()!.forEach((key, value) {
      featureFlags[key] = value;
    });
    documentSnapshotConfigOverrides.data()!.forEach((key, value) {
      configOverrides[key] = value;
    });

    featureFlags['ios.recording.enabled'] = await iscaller!;
    featureFlags['ios.screensharing.enabled'] = await iscaller!;
    featureFlags['android.screensharing.enabled'] = await iscaller!;
    featureFlags['reactions.enabled'] = await iscaller!;



    // Define meetings options here

    var jitsiMeet = JitsiMeet();
    var options2 = JitsiMeetConferenceOptions(
      room: CallerId!,
      serverURL: documentSnapshotServer.data()!["jitsiServer"],
      //subject: peerInfo!.name,
      token: documentSnapshotServer.data()!["jitsiToken"],
      userInfo: JitsiMeetUserInfo(
        displayName: peerInfo!.name,
        email: "",
        avatar: 'https://firebasestorage.googleapis.com/v0/b/app-jeras.appspot.com/o/whiteLogo.png?alt=media&token=3875f85e-77fe-42b7-b32f-22507a05797f',
      ),
      featureFlags: featureFlags,
      configOverrides: configOverrides,
    );

    var listener = JitsiMeetEventListener(
      participantJoined: (email, name, role, participantId) {
        if(name!= null && name != '' && name.contains("support")){
          technicalAccountId= participantId;
        }
      },
      conferenceJoined: (url) {
        CallCubit.get(context).changeCallState(StartCallStates.inCall);
        FirebaseDatabase.instance
            .ref('userCallState')
            .child(FirebaseAuth.instance.currentUser!.uid)
            .child('joinedDate')
            .set(ServerValue.timestamp);
      },
      participantLeft: (participantId){
        print(participantId);
        print(technicalAccountId);
        if(participantId != technicalAccountId){
          jitsiMeet.hangUp();
        }
      },
      readyToClose: () {
        _hangUp();
      },
    );

    try {
      jitsiMeet.join(
          options2,
          listener
      );
    } catch (e) {
      print(e);
    }

    // var options = JitsiMeetingOptions(
    //   roomNameOrUrl: CallerId!,
    //   serverUrl: documentSnapshotServer.data()!["jitsiServer"],
    //   subject: peerInfo!.name,
    //   token: documentSnapshotServer.data()!["jitsiToken"],
    //   isAudioMuted: false,
    //   isAudioOnly: false,
    //   isVideoMuted: false,
    //   userDisplayName: peerInfo!.name,
    //   userEmail: '',
    //   featureFlags: featureFlags,
    //   userAvatarUrl:
    //       'https://firebasestorage.googleapis.com/v0/b/app-jeras.appspot.com/o/whiteLogo.png?alt=media&token=3875f85e-77fe-42b7-b32f-22507a05797f',
    //   configOverrides: configOverrides,
    // );
    //
    // try {
    //   await JitsiMeetWrapper.joinMeeting(
    //     options: options,
    //     listener: JitsiMeetingListener(
    //       onOpened: () {},
    //       onConferenceWillJoin: (url) {},
    //       onConferenceJoined: (url) {
    //         CallCubit.get(context).changeCallState(StartCallStates.inCall);
    //       },
    //       onConferenceTerminated: (url, error) {},
    //       onAudioMutedChanged: (isMuted) {},
    //       onVideoMutedChanged: (isMuted) {},
    //       onScreenShareToggled: (participantId, isSharing) {},
    //       onParticipantJoined: (email, name, role, participantId) {},
    //       onParticipantLeft: (participantId) {
    //         JitsiMeetWrapper.hangUp();
    //         //_hangUp();
    //       },
    //       onParticipantsInfoRetrieved: (participantsInfo, requestId) {},
    //       onChatMessageReceived: (senderId, message, isPrivate) {},
    //       onChatToggled: (isOpen) {},
    //       onClosed: () {
    //         _hangUp();
    //       },
    //     ),
    //   );
    // } catch (e) {
    //   print(e);
    // }
  }

  _hangUp() {
    if (loggedUser == null || loggedUser!.userType != "CONSULTANT") {
      CallCubit.get(context).changeCallState(StartCallStates.callEnded);
      bye();
      if (Platform.isAndroid) {
        stopForegroundService();
      }

    } else {
      confirmEndCallDialog(context: context, loggedUser: loggedUser!, appointment: appointment!);
      bye();
      if (Platform.isAndroid) {
        stopForegroundService();
      }
    }
    FirebaseDatabase.instance
        .ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('closedDate')
        .set(ServerValue.timestamp);
  }



  void bye() {
    changeUserState(userId: CallerId!, state: 'closed');
    changeUserState(userId: ReciverId!, state: 'closed');
  }


}
confirmEndCallDialog({required BuildContext context, required GroceryUser loggedUser, required AppAppointments appointment}) async {
  await showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return EndCallDialog(
        user: loggedUser,
        appointment: appointment,
      );
    },
  );
}


// Map<String, Object> featureFlags = {
//   'add-people.enabled': false,
//   'audio-focus.disabled': false,
//   'audio-mute.enabled': true,
//   'audio-only.enabled': false,
//   'calendar.enabled': false,
//   'call-integration.enabled': true,
//   'car-mode.enabled': false,
//   'close-captions.enabled': true,
//   'conference-timer.enabled': true,
//   'chat.enabled': true,
//   'invite.enabled': false,
//   'prejoinpage.enabled': false,
//   'filmstrip.enabled': true,
//   'help.enabled': true,
//   'ios.recording.enabled': iscaller!,
//   'ios.screensharing.enabled': iscaller!,
//   'android.screensharing.enabled': iscaller!,
//   'speakerstats.enabled': true,
//   'kick-out.enabled': false,
//   'live-streaming.enabled': false,
//   'lobby-mode.enabled': false,
//   'meeting-name.enabled': false,
//   'meeting-password.enabled': false,
//   'notifications.enabled': false,
//   'overflow-menu.enabled': true,
//   'pip.enabled': true,
//   'pip-while-screen-sharing.enabled': false,
//   'prejoinpage.hideDisplayName': false,
//   'raise-hand.enabled': true,
//   'reactions.enabled': true,
//   'recording.enabled': false,
//   'replace.participant': true,
//   // 'resolution': 'maximum',
//   'security-options.enabled': false,
//   'server-url-change.enabled': false,
//   'settings.enabled': false,
//   'tile-view.enabled': false,
//   'toolbox.alwaysVisible': true,
//   'toolbox.enabled': true,
//   'unsaferoomwarning.enabled': false,
//   'video-mute.enabled': true,
//   'video-share.enabled': false,
//   'welcomepage.enabled': false,
// };
//
// Map<String, Object> configOverrides = {
//   "startWithAudioMuted": false,
//   "startWithVideoMuted": false,
//   'hideParticipantsStats': false,
//   'readOnlyName': true,
//   'giphy': {
//     'enable': false,
//   },
//   'participantsPane': {
//     'hideModeratorSettingsTab': true,
//     'hideMoreActionsButton': true,
//     'hideMuteAllButton': true,
//   },
//   'hideAddRoomButton': true,
//   'breakoutRooms': {
//     'hideAddRoomButton': true,
//     'hideAutoAssignButton': true,
//     'hideJoinRoomButton': true,
//     'hideModeratorSettingsTab': true,
//     'hideMoreActionsButton': true,
//     'hideMuteAllButton': true,
//   },
// };