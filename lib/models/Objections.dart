
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order.dart';

class Objections {
  String objectionId;
  String appointmentId;
  bool objectionStatus;
  Timestamp timestamp;
  UserDetails consult;
  UserDetails user;
  String objection;


  Objections({
   required this.objectionId,
   required this.appointmentId,
   required this.objectionStatus,
   required this.objection,
   required this.timestamp,
   required this.consult,
   required this.user,

  });

  factory Objections.fromMap(Map  data){
    //Map data = doc.data();
    return Objections(
        objectionId: data['objectionId'],
        appointmentId:data['appointmentId'],
        objectionStatus:data['objectionStatus'],
        objection: data['objection'],
        consult: UserDetails.fromHashmap(data['consult']),
        user: UserDetails.fromHashmap(data['user']),
        timestamp: data['timestamp'],
    );
  }
}


