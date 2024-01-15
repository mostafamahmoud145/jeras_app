import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;


  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;
  //updade read status of message
  static Future<void> updateMessagereadstatus( String doc) async {
    await firestore
        .collection('messages')
        .doc(doc.toString())
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static UploadTask? uploadTask(String destination,File data){
    try{final reference = FirebaseStorage.instance.ref(destination);
    return reference.putFile(data);}
    on FirebaseException {
      return null;
    }
  }

  //update message
  static Future<void> updateMessage( String updatedMsg) async {
    await firestore
        .collection('messages')
        .doc('sEmPWF9pvKZ6mOCTRaZx')
        .update({'msg': updatedMsg});
  }
}