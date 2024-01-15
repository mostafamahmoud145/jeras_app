
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order.dart';

class AppAppointments {
  String appointmentId;
  String appointmentStatus;
  Timestamp appointmentTimestamp;
  Timestamp timestamp;
  dynamic timeValue;
  dynamic secondValue;
  UserDetails consult;
  UserDetails user;
  AppointmentDate date;
  AppointmentTime time;
  String orderId;
  String type;
  dynamic callPrice;
  dynamic callCost;
  dynamic userChat;
  dynamic consultChat;
  dynamic lessonTime;
  String consultType;
  String utcTime;
  bool isUtc;
  bool allowCall;
  bool freeCall;
  dynamic remainingCallNum;
  CourseOrder? course;


  AppAppointments({
    required this.appointmentId,
    required this.appointmentStatus,
    required this.lessonTime,
    required this.callCost,
    required this.consultType,
    required this.isUtc,
    required this.remainingCallNum,
    required this.appointmentTimestamp,
    required this.orderId,
    required this.timestamp,
    required this.secondValue,
    required this.timeValue,
    required this.utcTime,
    required this.type,
    required this.date,
    required this.time,
    required this.consult,
    required this.user,
    this.callPrice,
    this.consultChat,
    this.userChat,
    required this.freeCall,
    required this.allowCall,
    this.course,



  });

 // factory AppAppointments.fromMap(DocumentSnapshot doc) {
    factory AppAppointments.fromMap(Map  data) {
      //Map data = snapshot.data();
    return AppAppointments(
      appointmentId: data['appointmentId'],
      lessonTime:data['lessonTime'],
      callCost: data['callCost']==null?0.0:data['callCost'],
      consultType:data['consultType'],
      remainingCallNum:data['remainingCallNum']==null?0:data['remainingCallNum'],
      appointmentStatus: data['appointmentStatus'],
      appointmentTimestamp: data['appointmentTimestamp'],
      orderId: data['orderId'],
      isUtc: data['isUtc'],
      utcTime:data['utcTime'],
      timeValue: data['timeValue'],
      type:data['type'],
      date: AppointmentDate.fromHashmap(data['date']),
      time: AppointmentTime.fromHashmap(data['time']),
      consult: UserDetails.fromHashmap(data['consult']),
      user: UserDetails.fromHashmap(data['user']),
      timestamp: data['timestamp'],
      allowCall: data['allowCall']==null?false:data['allowCall'],
      freeCall: data['freeCall']==null?false:data['freeCall'],
      secondValue: data['secondValue'],
      callPrice:data['callPrice'],
      consultChat:data['consultChat'],
      userChat:data['userChat'],
      course: data['course']==null?null:CourseOrder.fromJson(data['course']),

    );
  }
}
class ForEverAppointments {
  String appointmentId;
  String appointmentStatus;
  Timestamp timestamp;
  String utcTime;
  UserDetails consult;
  UserDetails user;
  AppointmentDate date;
  AppointmentTime time;
  String orderId;
  dynamic callPrice;
  String consultType;


  ForEverAppointments({
    required this.appointmentId,
    required this.appointmentStatus,
    required this.consultType,
    required this.orderId,
    required this.timestamp,
    required this.utcTime,
    required this.date,
    required this.time,
    required  this.consult,
    required this.user,
    this.callPrice,



  });

  //factory ForEverAppointments.fromMap(DocumentSnapshot doc) {
    factory ForEverAppointments.fromMap(Map  data) {
      //Map data = snapshot.data();
    return ForEverAppointments(
        appointmentId: data['appointmentId'],
        consultType:data['consultType'],
        callPrice:data['callPrice'],
        appointmentStatus: data['appointmentStatus'],
        orderId: data['orderId'],
        date: AppointmentDate.fromHashmap(data['date']),
        time: AppointmentTime.fromHashmap(data['time']),
        consult: UserDetails.fromHashmap(data['consult']),
        user: UserDetails.fromHashmap(data['user']),
        timestamp: data['timestamp'],
        utcTime: data['utcTime'],

    );
  }
}
class AppointmentDate {
  int day;
  int month;
  int year;

  AppointmentDate({
    required this.day,
    required this.month,
    required this.year,
  });

  factory AppointmentDate.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentDate(
        day: Details['day'],
        month: Details['month'],
        year: Details['year'],
    );
  }
}
class AppointmentTime {
  int hour;
  int minute;

  AppointmentTime({
    required this.hour,
    required this.minute,
  });

  factory AppointmentTime.fromHashmap(Map<String, dynamic> Details) {
    return AppointmentTime(
      hour: Details['hour'],
      minute: Details['minute'],
    );
  }
}


