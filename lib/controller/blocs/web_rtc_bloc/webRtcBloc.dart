// import 'dart:async';
//
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:jeras/controller/blocs/web_rtc_bloc/webRtcEvent.dart';
// import 'package:jeras/controller/blocs/web_rtc_bloc/webRtcState.dart';
//
// import '../../../repositories/web_Rtc_repository.dart';
//
//
// class WebRtcBloc extends Bloc<WebRtcEvent, WebRtcState> {
//  final WebRtcRepository webRtcRepository;
//  StreamSubscription? comingcallSubscription;
//
//   WebRtcBloc({required this.webRtcRepository}) : super(WebRtcInitial()) {
//
//
// on<parantEvent>((event, emit)  {
//
//
//   try{
//     // if(FirebaseAuth.instance.currentUser!=null){
//     //   emit(getWebRtcCallProgressState());
//     //   comingcallSubscription=   webRtcRepository.getInomingCall().listen((event) {
//     //
//     //     add(getWebRtcCallEvent(event));
//     //   });
//     //
//     // }
//
//
//
//
//
//     // await   event.listen((event) async {
//     //   emit.isDone;
//     //
//     //
//     // });
//
//
//
//
//
//
//
//
//
//
//
//   }catch(e)
//   {
//     emit(getWebRtcCallFailedState());
//
//   }
//
//
//
// });
//
// on<getWebRtcCallEvent>((event, emit) async {
//   emit( getWebRtcCallCompletedState(event.event));
// });
//
//
// on<AcceptEvent>((event, emit) async {
//
//
//
//
//   emit( getAcceptCompletedState(event.accept));
// });
//
//
//
//   }
//
//
//   bool  acceptstate  =false;
//
//   @override
//   WebRtcState get initialState => WebRtcInitial();
//
//
//
//
//   Stream<RTCVideoRenderer>getlocalrender() async*{
//
//     yield* webRtcRepository.getlocalRender().transform(StreamTransformer<RTCVideoRenderer,RTCVideoRenderer>.fromHandlers(
//       handleData: (value,sink){
//         sink.add(value);
//       }
//
//     ));
//
//   }
//
//
//  Stream<RTCVideoRenderer>getremoterender() async*{
//
//    yield* webRtcRepository.getremoteRender().transform(StreamTransformer<RTCVideoRenderer,RTCVideoRenderer>.fromHandlers(
//        handleData: (value,sink){
//          sink.add(value);
//        }
//
//    ));
//
//  }
//
//
// }