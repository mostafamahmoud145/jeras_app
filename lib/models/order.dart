import 'package:cloud_firestore/cloud_firestore.dart';
class Orders {
  String orderId;
  String? chargeId;
  String orderStatus;
  Timestamp orderTimestamp;
  dynamic orderTimeValue;
  UserDetails consult;
  UserDetails user;
  String? packageId;
  String? promoCodeId;
  String payWith;
  String consultType;
  dynamic remainingCallNum;
  dynamic packageCallNum;
  dynamic answeredCallNum;
  dynamic callPrice;
  dynamic price;
  CourseOrder? course;

  Orders({
    required this.orderId,
    this.chargeId,
    required this.orderStatus,
    required this.orderTimestamp,
    required this.orderTimeValue,
    required this.consult,
    required this.consultType,
    required this.user,
    required this.payWith,
    required this.remainingCallNum,
    required this.packageCallNum,
    required this.answeredCallNum,
    this.packageId,
    this.promoCodeId,
    required this.callPrice,
    required this.price,
     this.course,

  });

  factory Orders.fromMap(Map data){
    //Map data = doc.data();
    return Orders(
        orderId: data['orderId'],
        chargeId: data['chargeId']==null?".":data['chargeId'],
        orderStatus: data['orderStatus'],
        payWith: data['payWith'],
        consultType:data['consultType']==null?"":data['consultType'],
        orderTimestamp: data['orderTimestamp'],
        orderTimeValue: data['orderTimeValue'],
        consult: UserDetails.fromHashmap(data['consult']),
        user: UserDetails.fromHashmap(data['user']),
        remainingCallNum: data['remainingCallNum'],
        packageCallNum: data['packageCallNum'],
        answeredCallNum: data['answeredCallNum'],
        packageId: data['packageId'],
        promoCodeId: data['promoCodeId'],
        callPrice: data['callPrice'],
        price: data['price'],
        course: data['course']==null?null:CourseOrder.fromJson(data['course']),
    );
  }
}
class UserDetails {
  String? name;
  String? image;
  String? uid;
  String? phone;
  String? countryCode;
  String? countryISOCode;

  UserDetails({
    this.name,
    this.image,
    this.uid,
    this.phone,
    this.countryCode,
    this.countryISOCode
  });

  factory UserDetails.fromHashmap(Map<String, dynamic> Details) {
    return UserDetails(
        name: Details['name'],
        uid: Details['uid'],
        image: Details['image'],
        phone:Details['phone'],
        countryCode: Details['countryCode'],
        countryISOCode:Details['countryISOCode']
    );
  }
}

class CourseOrder
{
  String id, name, image;

  CourseOrder({required this.id, required this.name, required this.image});

  factory CourseOrder.fromJson(Map<String, dynamic> course)
  {
    return CourseOrder(
      id: course['courseId'],
      name: course['courseName'],
      image: course['courseImage'],
    );
  }
}