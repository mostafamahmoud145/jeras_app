
import 'package:cloud_firestore/cloud_firestore.dart';

class SupportList {
  String supportListId;
  String owner;
  bool? pending;
  bool supportListStatus;
  bool openingStatus;
  Timestamp messageTime;
  String userUid;
  String userName;
  String lastMessage;
  dynamic image;
  dynamic userMessageNum;
  dynamic supportMessageNum;

  SupportList({
    required this.supportListId,
    required this.owner,
    required this.supportListStatus,
    required this.openingStatus,
    required this.messageTime,
    required this.userUid,
    required this.userName,
    required this.lastMessage,
    required this.image,
    required this.userMessageNum,
    required this.supportMessageNum,
    this.pending,


  });

  factory SupportList.fromMap(Map  data){
    return SupportList(
      owner:data['owner']==null?"client":data['owner'],
      supportListId: data['supportListId'],
      supportListStatus: data['supportListStatus']==null?false:data['supportListStatus'],
      openingStatus:data['openingStatus']==null?false:data['openingStatus'],
      pending:data['pending']==null?false:data['pending'],
      messageTime: data['messageTime']==null?Timestamp.now():data['messageTime'],
      userUid: data['userUid'],
      userName: data['userName']==null?"-1":data['userName'],
      lastMessage: data['lastMessage'],
      image: data['image'],
      userMessageNum: data['userMessageNum'],
      supportMessageNum: data['supportMessageNum'],


    );
  }
}

