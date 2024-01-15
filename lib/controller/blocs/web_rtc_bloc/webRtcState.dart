import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class WebRtcState {}

class WebRtcInitial extends WebRtcState {}


///getincomeCallState///
class getWebRtcCallProgressState extends WebRtcState {
  @override
  String toString() => 'getWebRtcCallProgressState';
}

class getWebRtcCallFailedState extends WebRtcState {
  @override
  String toString() => 'getWebRtcCallFailedState';
}

class getWebRtcCallCompletedState extends WebRtcState {
  DocumentSnapshot<Map<String, dynamic>> trigerCall;


  getWebRtcCallCompletedState(this.trigerCall);



  @override
  String toString() => 'getWebRtcCallCompletedState';
}

///getacceptfromnotficationCallState///

class getAcceptProgressState extends WebRtcState {
  @override
  String toString() => 'getWebRtcCallProgressState';
}

class getAcceptFailedState extends WebRtcState {
  @override
  String toString() => 'getWebRtcCallFailedState';
}

class getAcceptCompletedState extends WebRtcState {
bool accept=false;


  getAcceptCompletedState(this.accept);



  @override
  String toString() => 'getAcceptCompletedState';
}



///getincomeCallState///
///
///
///
///
///
///
///