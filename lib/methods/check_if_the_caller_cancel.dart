

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

/// check the sender cancel the call.
checkIfTheSenderCanceled({required Function function}){
  FirebaseDatabase.instance.ref('userCallState')
      .child(FirebaseAuth.instance.currentUser!.uid).child('callState').onValue
      .listen((event) {
    if(event.snapshot.value=='closed'){
      function();
    }
  });
}