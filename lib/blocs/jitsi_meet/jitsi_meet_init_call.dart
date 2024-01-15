




import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:jeras/blocs/web_rtc_bloc/check_call_state.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/user.dart';

enum call_permision{
  cameraGranted,
  micGranted,
  cameradined,
  micdined

}
enum call_State{
  anotherCall,
  calling,
  refusd,
  closed,
  inCall

}

///  caller            receiver
///  calling           inCall   => end
///  refused           calling  => end
///  calling           calling  => start call



class JitsiMeetInitCall {


  bool isVideoCall;
  String callerId='';
  String reciverId="";
  String appointmentId='';
  GroceryUser? loggedUser;

  JitsiMeetInitCall(this.isVideoCall,this.callerId,this.reciverId,this.appointmentId, this.loggedUser);

  Function (call_permision,call_permision) ? checkCallPermissions ;

  Function (call_State)? checkCallState ;

  trigerCallState(){

    FirebaseDatabase.instance.ref('userCallState')
        .child(reciverId).child('callState').onValue
        .listen((event) {
      if(event.snapshot.value=='calling'){
        checkCallState!.call(call_State.calling);
      }
      else if(event.snapshot.value=='refused'){
        checkCallState!.call(call_State.refusd);

      }else if(event.snapshot.value=='closed'){
        checkCallState!.call(call_State.closed);

      }else if(event.snapshot.value=='oncall'){
        checkCallState!.call(call_State.inCall);

      }



    });
  }
  Future<void> requstCallPermissions() async {

    if(kIsWeb){

      //checkPermissionsWeb().getmedia();
      //bool cameraAccess =await checkPermissionsWeb().checkCamera();
      //bool micAccess =await checkPermissionsWeb().checkMic();

      // if (cameraAccess&&micAccess) {
      //   checkCallPermissions?.call(call_permision.cameraGranted,call_permision.micGranted);
      //
      // }else{
      //   checkCallPermissions?.call(call_permision.cameradined,call_permision.micdined);
      // }


    }
    else{
      if(isVideoCall){
        var cameraStatus=  await  Permission.camera.request();
        var  MicStatus=   await  Permission.microphone.request();


        if (cameraStatus.isGranted&&MicStatus.isGranted) {
          checkCallPermissions?.call(call_permision.cameraGranted,call_permision.micGranted);
        }
        // if(MicStatus.isGranted){
        //
        //   checkCallPermissions?.call(call_permision.micGranted);
        //
        //
        //
        // }
        if(!cameraStatus.isGranted&&!MicStatus.isGranted){
          checkCallPermissions?.call(call_permision.cameradined,call_permision.micdined);

        }
        if(!MicStatus.isGranted){
          //  checkCallPermissions?.call(call_permision.micdined);

        }

      }
      else{
        await  Permission.microphone.request();
        var MicStatus = await Permission.microphone.status;

        if(MicStatus.isGranted){
          checkCallPermissions?.call(call_permision.micGranted,call_permision.micGranted);
        } else if(!MicStatus.isGranted){
          checkCallPermissions?.call(call_permision.micdined,call_permision.micdined);
        }
      }
    }
  }

  checkuserCallState() async {

    try{
      final res  = await CheckCallState(
          appointmentId:appointmentId,
          receiverId:reciverId,
          loggedUser: loggedUser,
          callerId:callerId).CheckState();

      return res;
    }catch(e){
      throw 'internal error';

    }

  }





}