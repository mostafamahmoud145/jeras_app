import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

@immutable
abstract class WebRtcEvent {}



///getincomeCallEvent///
class parantEvent extends WebRtcEvent {


  parantEvent();


  @override
  String toString() => 'getWebRtcCallEvent';
}
class getWebRtcCallEvent extends WebRtcEvent {

  DocumentSnapshot<Map<String, dynamic>> event;

  getWebRtcCallEvent(this.event );


  @override
  String toString() => 'getWebRtcCallEvent';
}

class AcceptEvent extends WebRtcEvent {

bool accept=false;

AcceptEvent(this.accept );


  @override
  String toString() => 'acceptEvent';
}



///getincomeCallEvent///