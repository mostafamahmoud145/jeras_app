//
// import 'dart:async';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:jeras/blocs/web_rtc_bloc/getRenders.dart';
//
// import 'base_provider.dart';
//
// class WebRtcProvider extends BaseWebRtcProvider{
//   RTCPeerConnection ? pcs;
//
//   final localRender= RTCVideoRenderer();
//   RTCVideoRenderer remoteRenderer = new RTCVideoRenderer();
//
//   MediaStream ?  mediaStream;
//
//   getrenders ? getRenders;
//
//
//
//   @override
//   Future<bool> createAnswer(bool audioEnable, bool videoEnable,String AppAppointmentsId, String? userid,String? callerid) async {
//
//     getOffer(AppAppointmentsId,callerid!, userid!);
//
//   //  getCandidateOffer(AppAppointmentsId);
//
//
//
//
//
//     return true;
//
//
//   }
//
//   @override
//   Future<bool> createOffer(bool audioEnable, bool videoEnable,String AppAppointmentsId,String? userid,String? callerid) async {
//     await setCandidateOffer(AppAppointmentsId);
//
//     final Map<String, dynamic> _constraints = {
//       'mandatory': {
//         'OfferToReceiveAudio': true,
//         'OfferToReceiveVideo': true,
//       },
//       'optional': [],
//       'sdpSemantics': 'uinified-plan'
//
//     };
//
//     var offer= await  pcs!.createOffer(_constraints);
//     pcs!.setLocalDescription(offer);
//
//     var dataOffer = {
//       'offerData': {
//         'userId':FirebaseAuth.instance.currentUser!.uid,
//         'type': offer.type,
//         'sdp': offer.sdp
//       }
//     };
//     await FirebaseFirestore.instance.collection("AppAppointments").doc(
//         AppAppointmentsId).set(dataOffer, SetOptions(merge: true));
//
//     FirebaseFirestore.instance.collection("AppAppointmentsCall").doc(
//         AppAppointmentsId).set({      'callState':'pinding',
//       'appointmentId':AppAppointmentsId,
//       'callerId':callerid,
//       'reciverId':userid
//     });
//
//     getAnswer(AppAppointmentsId,callerid!, userid!);
//
//   //  getCandidateAnswer(AppAppointmentsId);
//
//
//     return true;
//   }
//
//   @override
//   Future<RTCPeerConnection> createPeerConnectionprovider(bool audioEnable, bool videoEnable) async {
//
//
//     Map<String, dynamic> configuration = {
//       "sdpSemantics": "unified-plan", // Add this line
//       "iceServers": [
//         {"url": "stun:stun1.l.google.com:19302"},
//         {"url": "stun:stun2.l.google.com:19302"},
//         {"url": "stun:stun3.l.google.com:19302"},
//         {"url": "stun:stun4.l.google.com:19302"},
//         {"url": "stun:stun.voipbuster.com"},
//
//       ]
//     };
//
//     final Map<String, dynamic> offerSdpConstraints = {
//       "mandatory": {
//         "OfferToReceiveAudio": true,
//         "OfferToReceiveVideo": true,
//       },
//       "optional": [],
//     };
//
//     await  getUserMedia(audioEnable, videoEnable);
//
//     RTCPeerConnection pc = await createPeerConnection(configuration, offerSdpConstraints);
//
//
//     mediaStream?.getTracks().map((e) {
//       pc.addTrack(e,mediaStream!);
//
//
//     });
//
//
//     pc.onIceConnectionState = (e) {
//     };
//
//
//
//     pc.onTrack=(ontr){
//       for(int x =0;x<ontr.streams.length;x++){
//         if(x>0){
//
//           remoteRenderer.srcObject = ontr.streams[1];
//
//
//           this.getRenders?.getrender(localRender, remoteRenderer);
//
//         }
//       }
//
//
//
//
//     };
//
//     pc.onAddTrack=(meds,medt){
//       //
//       // remoteRenderer.srcObject = meds;
//       //
//       //
//       //
//       // this.getRenders?.getrender(localRender, remoteRenderer);
//       //
//
//
//
//     };
//
//     // pc.onAddStream = (stream) {
//     //   //
//     //   // remoteRenderer.srcObject = stream;
//     //   //
//     //   //
//     //   //
//     //   // this.getRenders?.getrender(localRender, remoteRenderer);
//     //   //
//     //
//     //   // remoteRenderer.value=(RTCVideoValue(width: 100,height: 100,renderVideo: true));
//     //
//     // };
//
//     return pc;
//
//
//   }
//
//   // @override
//   //  dactiveCall() async{
//   //   localRender.dispose();
//   //   mediaStream!.dispose();
//   //   _remoteRenderer.dispose();
//   //
//   //   return true;
//   //
//   // }
//
//   @override
//   void dispose() {
//     localRender.dispose();
//     mediaStream!.dispose();
//     remoteRenderer.dispose();
//   }
//
//   @override
//   Stream<Map<String, dynamic>> getAnswer(String AppAppointmentsId,String callerid,String userid) async* {
//     FirebaseFirestore.instance.collection("AppAppointments").doc(AppAppointmentsId).snapshots().listen((event) async {
//
//       if(event.exists) {
//         final data = event.data();
//
//
//         if (data!['answerData']["type"].toString() == "answer") {
//           //   console.log('Set remote description: ', data.answer);
//           final answer = new RTCSessionDescription(
//               data["answerData"]["sdp"], data["answerData"]["type"]);
//
//           await pcs!.setRemoteDescription(answer);
//         }
//
//         var zz=RTCIceCandidate(event.data()!['CandidateAnswerData']['CandidateAnswer']['candidate'],event.data()!['CandidateAnswerData']['CandidateAnswer']['sdpMid'],event.data()!['CandidateAnswerData']['CandidateAnswer']['sdpMLineIndex']);
//
//         pcs!.addCandidate(zz);
//
//
//
//       }
//     });
//
//   }
//
//   @override
//    getCandidateAnswer(String AppAppointmentsId)async* {
//     // TODO: implement getCandidateAnswer
//     FirebaseFirestore.instance.collection("AppAppointments").doc(AppAppointmentsId)
//         .snapshots().listen((event) async {
//
//
//       var zz=RTCIceCandidate(event.data()!['CandidateAnswerData']['CandidateAnswer']['candidate'],event.data()!['CandidateAnswerData']['CandidateAnswer']['sdpMid'],event.data()!['CandidateAnswerData']['CandidateAnswer']['sdpMLineIndex']);
//
//        pcs!.addCandidate(zz);
//
//
//
//
//
//     });
//
//   }
//
//   @override
//   Stream<Map<String, dynamic>> getCandidateOffer(String AppAppointmentsId)async* {
//
//
//     FirebaseFirestore.instance.collection("AppAppointments").doc(AppAppointmentsId)
//         .snapshots().listen((event) async {
//
//
//       var zz=RTCIceCandidate(event.data()!['CandidateOfferData']['CandidateOffer']['candidate'],event.data()!['CandidateOfferData']['CandidateOffer']['sdpMid'],event.data()!['CandidateOfferData']['CandidateOffer']['sdpMLineIndex']);
//
//        pcs!.addCandidate(zz);
//
//
//
//
//
//     });  }
//
//   @override
//    getOffer(String AppAppointmentsId,String callerid,String userid)  {
//
//
//
//     FirebaseFirestore.instance.collection("AppAppointments").doc(AppAppointmentsId).get().then((event)  async {
//
//
//
//       if(event.exists) {
//         final data = event.data();
//
//
//         if (data!['offerData']["type"].toString() == "offer") {
//           //   console.log('Set remote description: ', data.answer);
//           final answer = new RTCSessionDescription(
//               data["offerData"]["sdp"], data["offerData"]["type"]);
//
//            pcs!.setRemoteDescription(answer);
//         }
//
//         var zz=RTCIceCandidate(event.data()!['CandidateOfferData']['CandidateOffer']['candidate'],event.data()!['CandidateOfferData']['CandidateOffer']['sdpMid'],event.data()!['CandidateOfferData']['CandidateOffer']['sdpMLineIndex']);
//
//         pcs!.addCandidate(zz);
//
//
//         setCandidateAnswer(AppAppointmentsId);
//
//
//         final Map<String, dynamic> _constraints = {
//           'mandatory': {
//             'OfferToReceiveAudio': true,
//             'OfferToReceiveVideo': true,
//           },
//           'optional': [],
//           'sdpSemantics': 'uinified-plan'
//
//         };
//
//         var answer= await  pcs!.createAnswer(_constraints);
//         await  pcs!.setLocalDescription(answer);
//
//         var dataAnswer = {
//           'answerData': {
//             'userId':FirebaseAuth.instance.currentUser!.uid,
//             'type': answer.type,
//             'sdp': answer.sdp
//           }
//         };
//         await FirebaseFirestore.instance.collection("AppAppointments").doc(
//             AppAppointmentsId).set(dataAnswer, SetOptions(merge: true));
//
//         FirebaseFirestore.instance.collection("AppAppointmentsCall").doc(
//             AppAppointmentsId).set({      'callState':'oncall',
//           'appointmentId':AppAppointmentsId,
//           'callerId':callerid,
//           'reciverId':userid
//         });
//
//
//       }
//     });
//
//   }
//
//   @override
//   Future<RTCVideoRenderer> getUserMedia(bool audioEnable, bool videoEnable) async {
//
//     final Map<String, dynamic> mediaConstraints = {
//       'audio':audioEnable,
//
//       'video':videoEnable?  {
//         'mandatory': {
//           'minWidth':
//           '500',
//           // Provide your own width, height and frame rate here
//           'minHeight': '500',
//           'minFrameRate': '30',
//         },
//         'facingMode': 'user',
//         'optional': [],
//       }:false
//     };
//
//     mediaStream= await  navigator.getUserMedia(mediaConstraints);
//     localRender.srcObject=mediaStream;
//
//
//     return localRender;
//
//
//
//   }
//
//   @override
//   Future<bool> initRenderers(bool audioEnable, bool videoEnable) async {
//
//     await localRender.initialize();
//     await remoteRenderer.initialize();
//
//     pcs=  await  createPeerConnectionprovider( audioEnable,  videoEnable);
//
//     if(pcs!=null)
//     {
//       return true;
//
//     }else{
//       return false;
//     }
//
//   }
//
//   @override
//   Future<bool> setCandidateAnswer(String AppAppointmentsId) async{
//
//     pcs?.onIceCandidate = (e) async {
//
//       if (e.candidate != null) {
//
//
//         Map<String, dynamic>CandidateAnswer = {
//           'CandidateAnswerData': {
//             "UserId": FirebaseAuth.instance.currentUser!.uid,
//             'CandidateAnswer': e.toMap()
//           }
//         };
//
//
//         await FirebaseFirestore.instance.collection("AppAppointments").doc(
//             AppAppointmentsId).set(CandidateAnswer, SetOptions(merge: true));
//       }
//     };
//
//     return true;
//   }
//
//   @override
//   Future<bool> setCandidateOffer(String AppAppointmentsId) async {
//     pcs?.onIceCandidate = (e) async {
//       if (e.candidate != null) {
//
//
//
//
//
//
//       }
//     };
//
//     return true;
//   }
//
//   @override
//   Stream<DocumentSnapshot<Map<String, dynamic>>> getInomingCall()  async* {
//
//
//     // var ref = FirebaseFirestore.instance.collection(Paths.usersPath).doc(FirebaseAuth.instance.currentUser!.uid).withConverter(
//     //   fromFirestore: GroceryUser.fromFirestore,
//     //   toFirestore: (GroceryUser user, _) => user.toFirestore(), );
//     // final docSnap = await ref.get();
//     // GroceryUser? user = docSnap.data();
//
//     yield*   FirebaseFirestore.instance.collection("AppAppointmentsCall").where('reciverId',isEqualTo:FirebaseAuth.instance.currentUser!.uid )
//         .where('callState',isEqualTo: "pinding").snapshots().transform(
//
//         StreamTransformer<QuerySnapshot<Map<String, dynamic>>,DocumentSnapshot<Map<String, dynamic>>>.fromHandlers(
//           handleData: (QuerySnapshot<Map<String, dynamic>> value, EventSink<DocumentSnapshot<Map<String, dynamic>>>  sink) {
// if(value!=null){
//
//   sink.add(value.docs.first);
//
//
// }
//
//           },
//         )
//
//     )
//     ;
//
//
//     // final query= await   FirebaseFirestore.instance.collection("AppAppointments").where(user!.userType=='USER'?'user.uid':'consult.uid',isEqualTo:FirebaseAuth.instance.currentUser!.uid )
//     //     .where('callState',isEqualTo: "pinding").snapshots();
//     //
//     //
//
//
//
//
//
//
//   }
//
//   @override
//   Future<bool> cancelCall(String AppAppointmentsId) {
//     // TODO: implement cancelCall
//     throw UnimplementedError();
//   }
//
//   @override
//   Stream<RTCVideoRenderer> getlocalRender() {
//     // TODO: implement getlocalRender
//     throw UnimplementedError();
//   }
//
//   @override
//   Stream<RTCVideoRenderer> getremoteRender() async* {
//
//
//     yield remoteRenderer;
//
//   }
//
//   @override
//   void subscribeDomcment(String AppAppointmentsId) {
//     // TODO: implement subscribeDomcment
//   }
//
//   @override
//   Future<bool> dactiveCall(String AppAppointmentsId) {
//     // TODO: implement dactiveCall
//     throw UnimplementedError();
//   }
//
//   @override
//   void setrenderState(getrenders getrendersa) {
//
//    this.getRenders=getrendersa;
//
//   }
//
//
//
//
// }