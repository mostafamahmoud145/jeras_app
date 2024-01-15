import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:jeras/screens/PrivacyScreen/privacyscreen.dart';
import 'package:jeras/screens/userAccountScreen.dart';
import 'package:jeras/services/callServiceKeep.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/paths.dart';
import '../main.dart';
import '../methods/check_if_the_caller_cancel.dart';
import '../models/AppAppointments.dart';
import '../models/chat.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../screens/AppointmentChatScreen.dart';
import '../screens/addObjectionScreen.dart';
import '../screens/addReviewScreen.dart';
import '../screens/chatDetailScreen.dart';
import '../screens/generalNotificationScreen.dart';
import '../screens/home_screen.dart';
import '../screens/job/JobDetailsScreen.dart';
import '../screens/marketPlaceScreen.dart';
import '../screens/payInfoScreen.dart';
import 'call_kit_service.dart';
import 'call_services.dart';

// final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();
dynamic notificationData;
FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
RemoteMessage? value;
BuildContext? _context;
class FirebaseService {


  static init(context, uid, User currentUser) async{
    _context=context;
    initDynamicLinks(context);
    await updateFirebaseToken(currentUser);
    //initFCM(uid, context, currentUser);
    configureFirebaseListeners(context, currentUser);
  }
}

initDynamicLinks(context) async {
}

//FCM
Future<void> updateFirebaseToken(User currentUser) async{
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  if(kIsWeb){
    FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
      'tokenId': 'web',
    });
  }else {
    firebaseMessaging.getToken().then((token) async{
      await FirebaseFirestore.instance.collection('Users').doc(currentUser.uid).update({
        'tokenId': token,
      });

      await FirebaseFirestore.instance.collection('NotRegisteredUsers')
          .where('token', isEqualTo: token).get().then((value) {

        if (value.docs.length > 0){

          FirebaseFirestore.instance.collection('NotRegisteredUsers')
              .doc(value.docs[0].data()['userId']).delete();
        }
      });
    });
  }
}

initFCM(String uid, context, User currentUser) async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  // flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //     AndroidFlutterLocalNotificationsPlugin>()?.requestPermission();
  flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();

  flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel = AndroidNotificationChannel(
      'call_channel', // id
      'call_channel', // title
      importance: Importance.high,
      vibrationPattern: Int64List.fromList([4]),
      playSound: true,
      sound:RawResourceAndroidNotificationSound('jeraston')
  );






  await flutterLocalNotificationsPlugin
      ?.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?..createNotificationChannel(channel);
  var android = new AndroidInitializationSettings('ic_stat_name');//('grocery');
  var ios =  DarwinInitializationSettings(
      notificationCategories:[DarwinNotificationCategory("Call",
        actions:[],
        /*   [

            DarwinNotificationAction.plain('Accept', langCode !=null&&langCode!=null&&langCode=='ar'?"متابعه الاتصال": "Continue Call",options:{
              DarwinNotificationActionOption.foreground,
            }),
            // DarwinNotificationAction.plain('Accept', "Accept",options:{
            //   DarwinNotificationActionOption.foreground,
            // }),
            // DarwinNotificationAction.plain('Dicline', "Dicline",options:{
            //   DarwinNotificationActionOption.destructive,
            // })

          ]*/

      )]
  ) ;

  var initSetting = new InitializationSettings(iOS: ios, android: android);
  flutterLocalNotificationsPlugin?.initialize(
      initSetting,
      onDidReceiveBackgroundNotificationResponse:onSelectNotification,
      onDidReceiveNotificationResponse:onSelectNotification

  );


}
@pragma('vm:entry-point')
Future<void> onSelectNotification(NotificationResponse? payload) async {
  // if(payload!.actionId=='accept'){
  //   FirebaseDatabase.instance.ref('userCallState').child(FirebaseAuth.instance.currentUser!.uid).child('acceptState').set('accepted');
  // }
  if(value!=null){
    navigation(value!.data['title'], value!.data['body'], value!.data['title_loc_key'], value!.data['body_loc_key']);
  }
}


// checkNotificationPermission({required String appointmentId})async{
//
//   Permission.notification.status.asStream().listen((value) async{
//     if(value.isGranted){
//       await FirebaseDatabase.instance.ref('callNotifications')
//           .child(appointmentId).child('notificationState').set('received');
//
//     }else if(value.isDenied || value.isPermanentlyDenied){
//       await FirebaseDatabase.instance.ref('callNotifications')
//           .child(appointmentId).child('notificationState').set('blocked');
//     }
//   });
// }



callKitEvents(){

  /*CallKeep.instance.onEvent.listen((event) async {
    // TODO: Implement other events
    if (event == null) return;
    switch (event.type) {
      case CallKeepEventType.callIncoming:
        checkIfTheSenderCanceled(function: (){
          CallKeep.instance.endAllCalls();
          // FlutterCallkitIncoming.endAllCalls();
        });
        break;
      case CallKeepEventType.callAccept:
        mayAppCheckCall(_context);
        break;
      case CallKeepEventType.callDecline:
        await Firebase.initializeApp();
        final data = event.data as CallKeepCallData;
        CallKeep.instance.endAllCalls();
        CallServices.refuseCall(state: 'refused', callerId: data.extra!['callerId']);
        break;
      case CallKeepEventType.callTimedOut:
        await Firebase.initializeApp();
        final data = event.data as CallKeepCallData;
        CallKeep.instance.endAllCalls();
        CallServices.refuseCall(state: 'closed', callerId: data.extra!['callerId']);
        break;
      default:
        break;
    }
  });*/

  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
    switch (event!.event) {
      case Event.actionCallIncoming:
        checkIfTheSenderCanceled(function: (){
          //CallKeep.instance.endAllCalls();
          FlutterCallkitIncoming.endAllCalls();
        });
        break;
      case Event.actionCallStart:
      // TODO: started an outgoing call
      // TODO: show screen calling in Flutter
        break;
      case Event.actionCallAccept:
        mayAppCheckCall(_context);
        break;
      case Event.actionCallDecline:
        await Firebase.initializeApp();
        Map<String, dynamic> data = event.body;
        FlutterCallkitIncoming.endAllCalls();
        CallServices.refuseCall(state: 'refused', callerId: data['extra']['callerId']);
        break;
      case Event.actionCallEnded:
      // TODO: ended an incoming/outgoing call
        break;
      case Event.actionCallTimeout:
        await Firebase.initializeApp();
        Map<String, dynamic> data = event.body;
        FlutterCallkitIncoming.endAllCalls();
        CallServices.refuseCall(state: 'closed', callerId: data['extra']['callerId']);
        break;
      case Event.actionCallCallback:
      // TODO: only Android - click action `Call back` from missed call notification
        break;
      case Event.actionCallToggleHold:
      // TODO: only iOS
        break;
      case Event.actionCallToggleMute:
      // TODO: only iOS
        break;
      case Event.actionCallToggleDmtf:
      // TODO: only iOS
        break;
      case Event.actionCallToggleGroup:
      // TODO: only iOS
        break;
      case Event.actionCallToggleAudioSession:
      // TODO: only iOS
        break;
      case Event.actionDidUpdateDevicePushTokenVoip:
      // TODO: only iOS
        break;
      case Event.actionCallCustom:
      // TODO: for custom action
        break;
    }
  });

  // FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async{
  //
  //   switch (event!.event) {
  //     case Event.actionCallIncoming:
  //     /// received an incoming call4
  //       checkIfTheSenderCanceled();
  //       break;
  //     case Event.actionCallStart:
  //
  //       break;
  //     case Event.actionCallAccept:
  //     /// accepted an incoming call
  //     /// show screen calling in Flutter
  //     ///
  //       mayAppCheckCall();
  //
  //       break;
  //     case Event.actionCallDecline:
  //     /// declined an incoming call
  //
  //       Map<String, dynamic> data= event.body;
  //       FlutterCallkitIncoming.endAllCalls();
  //       CallServices.refuseCall(state: 'refused', callerId: data['extra']['callerId']);
  //
  //       break;
  //     case Event.actionCallEnded:
  //     // TODO: ended an incoming/outgoing call
  //       break;
  //     case Event.actionCallTimeout:
  //     /// missed an incoming call
  //     ///
  //     // await Firebase.initializeApp();
  //       Map<String, dynamic> data= event.body;
  //       FlutterCallkitIncoming.endAllCalls();
  //       CallServices.refuseCall(state: 'closed', callerId: data['extra']['callerId']);
  //       break;
  //     case Event.actionCallCallback:
  //     // TODO: only Android - click action `Call back` from missed call notification
  //       break;
  //     case Event.actionCallToggleHold:
  //     // TODO: only iOS
  //       break;
  //     case Event.actionCallToggleMute:
  //     // TODO: only iOS
  //       break;
  //     case Event.actionCallToggleDmtf:
  //     // TODO: only iOS
  //       break;
  //     case Event.actionCallToggleGroup:
  //     // TODO: only iOS
  //       break;
  //     case Event.actionCallToggleAudioSession:
  //     // TODO: only iOS
  //       break;
  //     case Event.actionDidUpdateDevicePushTokenVoip:
  //     // TODO: only iOS
  //       break;
  //     case Event.actionCallCustom:
  //     // TODO: for custom action
  //       break;
  //   }
  // });
}


@pragma('vm:entry-point')
configureFirebaseListeners(context, User currentUser) async {
  //app is terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if(message!=null)
      navigation(message.data['title'], message.data['body'],message.data['title_loc_key'], message.data['body_loc_key']);
  });

  //App is in foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {

    if(message!.data['type']=='Call'){
      if(kIsWeb){
        // setUrlStrategy(PathUrlStrategy());
        // await Firebase.initializeApp(options: DefaultFirebaseConfig.platformOptions);

      }else{
        await Firebase.initializeApp();
        FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      }
      //checkNotificationPermission(appointmentId: message.data['appointmentId']);
     callKitEvents();
      //CallServiceKeep.displayIncomingCall(message.data);
     CallKitService.displayIncomingCall(message.data);
    }

    if (message != null) {

      showDataNotification(title: message.data['title'],body: message.data['body'],);
    }
  });
  // App is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {

    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        navigation(message.data['title'], message.data['body'],
            message.data['title_loc_key'], message.data['body_loc_key']);
      }
    });

  });
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    //'This channel is used for important notifications.', // description
    importance: Importance.max,playSound: true,sound:  RawResourceAndroidNotificationSound('soundandroid'),
  );
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);




}

showCallnotfication(notidata,bool iscall)
async {
  if(iscall){
    http.Response response = await http.get(Uri.parse(notidata['userimg']));

    var _base64 = base64Encode(response.bodyBytes);
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 4000;
    vibrationPattern[2] = 4000;
    vibrationPattern[3] = 4000;


    flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
    var aNdroid = new AndroidNotificationDetails(
        'call_channel',
        'call_channel',
        //'desc',
        icon:'ic_stat_name',

        autoCancel:true,
        fullScreenIntent: true,
        vibrationPattern: vibrationPattern,
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(_base64.toString()),
        actions:[],
        /* iscall? <AndroidNotificationAction>[
          AndroidNotificationAction('accept', langCode!=null&&langCode=='ar'?"متابعه الاتصال": "Continue Call",showsUserInterface: true),
         //  AndroidNotificationAction('accept', 'Accept',showsUserInterface: true,cancelNotification: true),
          // AndroidNotificationAction('dissmis', 'Dicline',showsUserInterface: true,cancelNotification: true),
        ]:[],*/
        importance: Importance.high,  priority: Priority.high,playSound: true,
        sound: iscall? RawResourceAndroidNotificationSound('jeraston'): RawResourceAndroidNotificationSound('soundandroid'),additionalFlags: Int32List.fromList(<int>[4])

    );
    var iOS = new DarwinNotificationDetails( sound: 'jeraston.aiff',
      presentAlert: true,
      categoryIdentifier: 'Call',
      presentBadge: true,
      presentSound: true,);
    var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
    //

    // value=data;
    flutterLocalNotificationsPlugin!.cancelAll();
    await flutterLocalNotificationsPlugin!.show( 22,
      notidata['title'],
      notidata['body'],
      platform,

    );
    //staticAudio.newInstance().setupAudio();
  }else {
    http.Response response = await http.get(Uri.parse(notidata['userimg']));

    var _base64 = base64Encode(response.bodyBytes);
    final Int64List vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 4000;
    vibrationPattern[2] = 4000;
    vibrationPattern[3] = 4000;

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var aNdroid = new AndroidNotificationDetails(
        'call_channel',
        'call_channel',
        //'desc',
        icon: 'ic_stat_name',

        autoCancel: true,
        fullScreenIntent: true,
        vibrationPattern: vibrationPattern,
        largeIcon: ByteArrayAndroidBitmap.fromBase64String(_base64.toString()),
        actions:[], /*iscall ? <AndroidNotificationAction>[
          AndroidNotificationAction(
              'accept', 'Accept', showsUserInterface: true),
          AndroidNotificationAction(
              'dissmis', 'Dicline', showsUserInterface: true),
        ] : [],*/
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: iscall
            ? RawResourceAndroidNotificationSound('jeraston')
            : RawResourceAndroidNotificationSound('soundandroid'),
        additionalFlags: Int32List.fromList(<int>[4])

    );
    var iOS = new DarwinNotificationDetails(sound: 'jeraston.aiff',
      presentAlert: true,
      categoryIdentifier: 'Call',
      presentBadge: true,
      presentSound: true,);
    var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
    //

    // value=data;
    await flutterLocalNotificationsPlugin!.show( 22,
      notidata['title'],
      notidata['body'],
      platform,

    );


  }

}

showDataNotification({String? title, String? body}) async {
  // if(message.data['type']=="Call"||message.data['type']=="missedCall"){
  //
  //   return;
  // }

  flutterLocalNotificationsPlugin =new FlutterLocalNotificationsPlugin();
  var aNdroid = new AndroidNotificationDetails(
    'channelId',
    'channel_name',
    icon:'ic_launcher_playstore',
    autoCancel: true,
    fullScreenIntent: false,
    importance: Importance.high,  priority: Priority.high,playSound: true,sound:  null,

  );
  var iOS = new DarwinNotificationDetails(// sound: 'jeraston.aiff',
    presentAlert: true,
    presentBadge: true,
    presentSound: true,);
  var platform = new NotificationDetails(android: aNdroid, iOS: iOS);
  //value=message;
  await flutterLocalNotificationsPlugin!.show( Random().nextInt(100),
    //message.data['title'],
    //message.data['body'],
    title,
    body,
    platform,

  );
}


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler( RemoteMessage message, ) async {
  Map<String,dynamic> data=message.data;
  if(data!=null){
    switch(data['type']) {
      case "Call":
        await Firebase.initializeApp();
        //checkNotificationPermission(appointmentId: message.data['appointmentId']);
        // callKeepEvents();
        checkIfTheSenderCanceled(function: (){
          //CallKeep.instance.endAllCalls();
          FlutterCallkitIncoming.endAllCalls();
        });
        callKitEvents();
        //CallServiceKeep.displayIncomingCall(message.data);
        CallKitService.displayIncomingCall(message.data);
        //  showCallnotfication(  message.data, true);
        break;
      case "missedCall" :
      //  showCallnotfication( message.data,  false);
        break;
      default:
        showDataNotification(title: message.data['title'],body: message.data['body'],);
        break;
    }
  }
}


navigation(String? title,String? body,String? titleKey,String? bodyKey) async {

  if(titleKey==null)
  {
    return;
  }

  if((title=="المواعيد"||title=="Appointment")&&titleKey=="user"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 1,),
      ),
    );
  }

  else if(titleKey=="Call"||titleKey=="missedCall"){


  }

  else if((title=="المواعيد"||title=="Appointment")&&titleKey=="consult"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 0,),
      ),
    );
  }
  else if(title=="التقيم"||title=="Review"){
    List<String> dateParts = bodyKey!.split(",");
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            AddReviewScreen(consultId: dateParts[0],userId:titleKey.toString(),appointmentId: dateParts[1], isCourse:false),
      ),
    );
  }
  else if(title=="تقيم الكورس"||title=="Course review"){
    List<String> dateParts = bodyKey!.split(",");
    Navigator.push(
        _context!,
        MaterialPageRoute(
          builder: (context) =>
              AddReviewScreen(consultId:"",courseId: dateParts[0],userId:titleKey.toString(),appointmentId: dateParts[1], isCourse:true),
        )
    );
  }
  else if(title=="إنتهاء الدرس"||title=="close Lesson"){
    List<String> dateParts =bodyKey!.split(",");
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            AddObjectionScreen(consultId: dateParts[0],userId:titleKey.toString(),appointmentId: dateParts[1],),
      ),
    );
  }
  else if(title=="الدعم الفني"||title=="Technical Support"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            HomeScreen(notificationPage: 2,),
      ),
    );
  }
  // else if(title=="رسائل المحادثات"||title=="Chat messages"){
  //   DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
  //   final DocumentSnapshot documentSnapshot = await docRef.get();
  //   var user= GroceryUser.fromMap(documentSnapshot.data() as Map);
  //
  //   DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(bodyKey);
  //   final DocumentSnapshot documentSnapshot2 = await docRef2.get();
  //   var appointment = AppAppointments.fromMap(documentSnapshot2.data() as Map);
  //   Navigator.push(
  //     _context!,
  //     MaterialPageRoute(
  //       builder: (context) => AppointmentChatScreen(
  //           appointment: appointment,
  //           user:user
  //       ),
  //     ),
  //   );
  //
  // }
  else if(title=="رسائل المحادثات"||title=="Chat messages"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);

    DocumentReference docRef2 = FirebaseFirestore.instance.collection("Chat").doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var item = Chat.fromMap(documentSnapshot2.data() as Map);
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          item: item,
          user: user,theme: "light",
        ),
      ),
    );

  }
  else if(title=="الشروط و الاحكام"||title=="Terms and Conditions"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);

    DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var appointment = AppAppointments.fromMap(documentSnapshot2.data() as Map);
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>

            PrivacyScreen(

            user:user
        ),
      ),
    );

  }
  else if(title=="المحادثات"||title=="Chats"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);

    DocumentReference docRef2 = FirebaseFirestore.instance.collection("Chat").doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var item = Chat.fromMap(documentSnapshot2.data() as Map);
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          item: item,
          user: user,theme: "light",
        ),
      ),
    );

  }
  else if(title=="الوظائف"||title=="Jobs"){
    DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(titleKey);
    final DocumentSnapshot documentSnapshot = await docRef.get();
    var user= GroceryUser.fromMap(documentSnapshot.data() as Map);
    DocumentReference docRef2 = FirebaseFirestore.instance.collection("Job").doc(bodyKey);
    final DocumentSnapshot documentSnapshot2 = await docRef2.get();
    var job = Job.fromMap(documentSnapshot2.data() as Map);
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => JobDetailsScreen(
          job: job,
          loggedUser: user,
        ),
      ),
    );

  }
  else if(title=="اتصال"||title=="Calling"){
    /* DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(value!.title_loc_key);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromMap(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(value!.body_loc_key);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromMap(documentSnapshot2);
      Navigator.push(
        _context!,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            appointment: null,
            user:null,
            appointmentId:value!.body_loc_key ,
            consultName: value!.title_loc_key!,
          ),
        ),
      );*/

  }
  else if(title=="الحساب"||title=="Account"){
    /* DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(value!.title_loc_key);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromMap(documentSnapshot);

      DocumentReference docRef2 = FirebaseFirestore.instance.collection(Paths.appAppointments).doc(value!.body_loc_key);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var appointment = AppAppointments.fromMap(documentSnapshot2);*/
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => payInfoScreen(
          consultId: titleKey.toString(),
        ),
      ),
    );

  }



  else if(bodyKey=="consultJob"){
    if(FirebaseAuth.instance.currentUser!=null){
      DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(FirebaseAuth.instance.currentUser!.uid);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var user= GroceryUser.fromMap(documentSnapshot.data() as Map);
      DocumentReference docRef2 = FirebaseFirestore.instance.collection("Job").doc(title);
      final DocumentSnapshot documentSnapshot2 = await docRef2.get();
      var job = Job.fromMap(documentSnapshot2.data() as Map);
      Navigator.push(
        _context!,
        MaterialPageRoute(
          builder: (context) => JobDetailsScreen(
            job: job,
            loggedUser: user,
          ),
        ),
      );
    }
  }
  else if(title=="Marketplace"){
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) => MarketplaceScreen(
          link: titleKey.toString(),
        ),
      ),
    );
  }
  else{
    Navigator.push(
      _context!,
      MaterialPageRoute(
        builder: (context) =>
            GeneralNotificationScreen(
                title:title.toString(),
                body:body.toString(),
                image:titleKey,
                link:bodyKey
            ),
      ),
    );
  }
}
