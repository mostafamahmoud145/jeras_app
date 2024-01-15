
import 'package:cloud_firestore/cloud_firestore.dart';

import 'order.dart';

class Invoice {
  String id;
  String? status;
  Timestamp timestamp;
  UserDetails user;
  Timestamp expire;
  dynamic price;
  String email;
  String? invoiceId;
  String invoice;


  Invoice({
    required this.id,
     this.status,
    required this.expire,
    required this.price,
    required this.timestamp,
    required this.user,
    required this.email,
    required this.invoiceId,
    required this.invoice,




  });

  factory Invoice.fromMap(Map  data){
    //Map data = doc.data();
    return Invoice(
        id: data['id'],
        status:data['status'],
        email:data['email'],
        expire:data["expiry"],
        price:data['price'],
       invoiceId:data["invoiceId"],
       invoice:data["invoice"],
        user: UserDetails.fromHashmap(data['user']),
        timestamp: data['timestamp'],
    );
  }
}



