//
//
//
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:jeras/Utils/checkpermission.dart' if (dart.library.html) 'package:jeras/Utils/checkpermissionweb.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// enum call_permision{
//   cameraGranted,
//   micGranted,
//   cameradined,
//   micdined
//
// }
// enum call_State{
//   anotherCall,
//   calling,
//   refusd,
//   closed,
//   inCall
//
// }
//
// class InintCall {
//
//
//   bool isVideoCall;
//   String callerId='';
//   String reciverId="";
//   String appointmentId='';
//   InintCall(this.isVideoCall,this.callerId,this.reciverId,this.appointmentId);
//
//   Function (call_permision,call_permision) ? checkCallPermissions ;
//
//   Function (call_State)? checkCallState ;
//
// trigerCallState(){
//
//   FirebaseDatabase.instance.ref('userCallState').child(reciverId).child('callState').onValue.listen((event) {
//     if(event.snapshot!=null){
//
//       if(event.snapshot.value=='calling'){
//         checkCallState!.call(call_State.calling);
//       }
//       else if(event.snapshot.value=='refused'){
//         checkCallState!.call(call_State.refusd);
//
//       }else if(event.snapshot.value=='closed'){
//         checkCallState!.call(call_State.closed);
//
//       }else if(event.snapshot.value=='oncall'){
//         checkCallState!.call(call_State.inCall);
//
//       }
//
//
//
//     }
//
//
//
//   });
// }
//  Future<void> requstCallPermissions() async {
//
//   if(kIsWeb){
//
//     checkPermissionsWeb().getmedia();
//     bool cameraAccess =await checkPermissionsWeb().checkCamera();
//     bool micAccess =await checkPermissionsWeb().checkMic();
//
//     if (cameraAccess&&micAccess) {
//       checkCallPermissions?.call(call_permision.cameraGranted,call_permision.micGranted);
//
//     }else{
//       checkCallPermissions?.call(call_permision.cameradined,call_permision.micdined);
//     }
//
//
//   }
//   else{
//     if(isVideoCall){
//       var cameraStatus=  await  Permission.camera.request();
//       var  MicStatus=   await  Permission.microphone.request();
//
//
//       if (cameraStatus.isGranted&&MicStatus.isGranted) {
//         checkCallPermissions?.call(call_permision.cameraGranted,call_permision.micGranted);
//
//       }
//       // if(MicStatus.isGranted){
//       //
//       //   checkCallPermissions?.call(call_permision.micGranted);
//       //
//       //
//       //
//       // }
//       if(!cameraStatus.isGranted&&!MicStatus.isGranted){
//         checkCallPermissions?.call(call_permision.cameradined,call_permision.micdined);
//
//       }
//       if(!MicStatus.isGranted){
//         //  checkCallPermissions?.call(call_permision.micdined);
//
//       }
//
//
//     }
//     else{
//       await  Permission.microphone.request();
//       var MicStatus = await Permission.microphone.status;
//
//
//       if(MicStatus.isGranted){
//
//         checkCallPermissions?.call(call_permision.micGranted,call_permision.micGranted);
//
//
//
//       } else if(!MicStatus.isGranted){
//         checkCallPermissions?.call(call_permision.micdined,call_permision.micdined);
//
//       }
//     }
//   }
//
//
//
//
//
//
//
//
//
//  }
//
//  checkuserCallState() async {
//
//    try{
//      FirebaseFunctions functions = FirebaseFunctions.instance;
//     // functions.useFunctionsEmulator('127.0.0.1', 5001);
//      //functions("10.0.2.2", 5001);
//
// //
//      HttpsCallable callable =   functions.httpsCallable("checkUserCallState");
//
//      final res  = await callable.call({
//        'appointmentId':appointmentId,
//        'reciverId':reciverId,
//        'isNormal':isVideoCall
//
//      });
//
//
//
//
//      if(res.data['code']==101){
//
//
//     //   Fluttertoast.showToast(msg:  res.data['message']);
//
//      //  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: res.data['message']));
//
//
//      }
//      else if(res.data['code']==200){
//
//        // Future(() =>
//        //     Navigator.of(context).push(MaterialPageRoute(builder: (con) =>
//        //         CallSample(host: widget.appointment.appointmentId, iscaller: true,
//        //           loggedUser: widget.loggedUser,appointment: widget.appointment, isVideo: true,normalCall: true,CallerId: FirebaseAuth.instance.currentUser!.uid!
//        //           ,ReciverId: widget.appointment.user.uid,))));
//
//      }
//
//
//
//
//
//
//      return res.data;
//
//
//    }catch(e){
//     throw 'internal error';
//
//    }
//
//  }
//
//
//
// }