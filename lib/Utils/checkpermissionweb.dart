// import 'dart:html';
//
// class checkPermissionsWeb{
//
//   checkMic() async {
//    // var checked=  await  window.navigator.getUserMedia(audio: true, video: true);
//    PermissionStatus? permission = await window.navigator.permissions?.query({'name': 'microphone'});
//
//
//    if( permission?.state== 'granted'){
//
//      return true;
//    }else {
//      return false;
//    }
//
//   }
//
//
//   checkCamera () async {
//     PermissionStatus? permission = await window.navigator.permissions!.query({'name': 'camera'});
//
//     if( permission?.state== 'granted'){
//
//       return true;
//     }else {
//       return false;
//     }
//
//
//   }
//
// getmedia(){
//   var mediaStream= window.navigator.getUserMedia(audio: true, video: true).then((value) {
//
//   }).onError((error, stackTrace) {
//
//
//   });
//
//   return mediaStream;
//
// }
//
// }
//
//
