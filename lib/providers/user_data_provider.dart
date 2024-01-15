
import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../models/appAnalysis.dart';
import '../../models/consultPackage.dart';
import '../../models/consultReview.dart';
import '../../models/user.dart';
import '../../models/user_notification.dart';
import '../../providers/base_provider.dart';

class UserDataProvider extends BaseUserDataProvider {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  late GroceryUser user;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  // static FirebaseDatabase database = FirebaseDatabase(
  //     databaseURL:  'https://app-jeras-default-rtdb.europe-west1.firebasedatabase.app/');
  static final realtimeDbRef = FirebaseDatabase.instance.ref();

  @override
  void dispose() {}

  @override
  Future<GroceryUser> getUser(String uid) async {
    DocumentReference docRef = db.collection(Paths.usersPath).doc(uid);
    final DocumentSnapshot documentSnapshot = await docRef.get();

    return GroceryUser.fromMap(documentSnapshot.data() as Map);
  }

  @override
  Future<GroceryUser> getUserByphoneNumber(String phoneNumber) async {

    DocumentReference docRef =
        db.collection(Paths.usersPath).doc("3JWofqSKSsTTxWGKiplPT0hAiVr1");
    final DocumentSnapshot documentSnapshot = await docRef.get();

    return GroceryUser.fromMap(documentSnapshot.data() as Map);
  }

  @override
  Future<GroceryUser?> saveUserDetails({
    String? uid,
    String? name,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    String? tokenId,
    String? loggedInVia,
    String? userType,
    String? countryCode,
    String? countryISOCode,
  }) async {
    try {
      List<GroceryUser> users = [];
      DocumentReference ref = db.collection(Paths.usersPath).doc(uid);
      QuerySnapshot querySnapshot = await db
          .collection(Paths.usersPath)
          .where( 'phoneNumber',
            isEqualTo: phoneNumber,
          )
          .get();

      for (var doc in querySnapshot.docs) {
        users.add(GroceryUser.fromMap(doc.data() as Map));
      }
      if (users.length == 0) {
        var data = {
          'accountStatus': 'NotActive',
          'userLang': 'ar',
          'profileCompleted': false,
          'isBlocked': false,
          'uid': uid,
          'name': name,
          'email': email,
          'phoneNumber': phoneNumber,
          'photoUrl': photoUrl != null ? photoUrl : '',
          'tokenId': tokenId,
          'loggedInVia': loggedInVia,
          "userType": userType,
          "languages": [],
          "rating": 0.0,
          "reviewsCount": 0,
          "balance": 0.0,
          "payedBalance": 0.0,
          "ordersNumbers": 0,
          "chat": false,
          "voice": false,
          "price": "0",
          "userConsultIds": null,
          "order": 0,
          "countryCode": countryCode,
          "countryISOCode": countryISOCode,
          "createdDate": Timestamp.now(),
          "createdDateValue": DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .millisecondsSinceEpoch,
        };
        ref.set(data, SetOptions(merge: true));
        final DocumentSnapshot currentDoc = await ref.get();
        user = GroceryUser.fromMap(currentDoc.data() as Map);
        return user;
      } else {
        final DocumentSnapshot currentDoc = await ref.get();

        user = GroceryUser.fromMap(currentDoc.data() as Map);
        return user;
      }
    } catch (e) {

      
      return null;
    }
  }

  @override
  Stream<AppAnalysis>? getAppAnalysis() {
    AppAnalysis appAnalysis;

    try {
      DocumentReference documentReference = db.doc(Paths.appAnalysisDocPath);
      return documentReference.snapshots().transform(StreamTransformer<
              DocumentSnapshot<Map<String, dynamic>>, AppAnalysis>.fromHandlers(
            handleData: (DocumentSnapshot snap, EventSink<AppAnalysis> sink) {
              appAnalysis = AppAnalysis.fromMap(snap.data() as Map);
              sink.add(appAnalysis);
            },
            handleError: (error, stackTrace, sink) {
              sink.addError(error);
            },
          ));
    } catch (e) {
      
      return null;
    }
  }
  @override
  Future<List<ConsultReview>?> getConsultReviews(String uid) async {
    List<ConsultReview> reviews;
    try {
      QuerySnapshot querySnapshot = await db
          .collection(Paths.consultReviewsPath)
          .where('consultUid', isEqualTo: uid)
          .limit(3)
          .orderBy("reviewTime", descending: true)
          .get();
      reviews = List<ConsultReview>.from(
        querySnapshot.docs.map(
          (snapshot) => ConsultReview.fromMap(snapshot.data() as Map),
        ),
      );
      

      return reviews;
    } catch (e) {

      return null;
    }
  }

  @override
  Future<List<consultPackage>?> getConsultPackages(String uid) async {
    List<consultPackage> packages;
    try {

      QuerySnapshot querySnapshot = await db
          .collection(Paths.packagesPath)
          .where('consultUid', isEqualTo: uid)
          .where('active', isEqualTo: true)
          .orderBy("callNum", descending: false)
          .get();
      packages = List<consultPackage>.from(
        querySnapshot.docs.map(
          (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
        ),
      );
      return packages;
    } catch (e) {

      return null;
    }
  }


  @override
  Future<GroceryUser?> getAccountDetails(String uid) async {
    try {
      DocumentSnapshot documentSnapshot =await db.collection(Paths.usersPath).doc(uid).get();

      GroceryUser currentUser = GroceryUser.fromMap(documentSnapshot.data() as Map);

      return currentUser;
    } catch (e) {

      return null;
    }
  }


  @override
  Future<bool> updateAccountDetails(GroceryUser user, Uint8List? profileImage) async {
    try {
      List<Map> intrList = [];
      for (var add in user.workTimes!) {
        Map tempAdd = Map();
        tempAdd.putIfAbsent('from', () => add.from);
        tempAdd.putIfAbsent('to', () => add.to);
        intrList.add(tempAdd);
      }
      if (profileImage != null) {
        //upload profile image first
        var uuid = Uuid().v4();
        Reference storageReference =
            firebaseStorage.ref().child('profileImages/$uuid');
        await storageReference.putData(profileImage);

        var url = await storageReference.getDownloadURL();

        await db.collection(Paths.usersPath).doc(user.uid).set({
          'name': user.name,
          'nameEn':user.nameEn,
          'nameFr':user.nameFr,
          'bioEn':user.bioEn,
          'bioFr':user.bioFr,
          'locationEn':user.locationEn,
          'searchIndexEn':user.searchIndexEn,
          'searchIndexFr':user.searchIndexFr,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'photoUrl': url,
          'bio': user.bio,
          'price': user.price,
          'languages': user.languages,
          'workDays': user.workDays,
          'workTimes': intrList,
          'age': user.age,
          'ageValue':user.ageValue,
          'education': user.education,
          'voice': true,
          'chat': true,
          'userLang': user.userLang,
          'location': user.location,
          "consultType": user.consultType,
          'searchIndex': user.searchIndex,
          'interestListIds':user.interestListIds,
          'profileCompleted': user.profileCompleted,
          'fromUtc': user.fromUtc,
          'toUtc': user.toUtc,
          'link':user.link,
          'isGlorified': user.isGlorified,
        }, SetOptions(merge: true));
      } else {
        //just update details
        await db.collection(Paths.usersPath).doc(user.uid).set({
          'name': user.name,
          'nameEn':user.nameEn,
          'nameFr':user.nameFr,
          'bioEn':user.bioEn,
          'bioFr':user.bioFr,
          'locationEn':user.locationEn,
          'searchIndexEn':user.searchIndexEn,
          'searchIndexFr':user.searchIndexFr,
          'email': user.email,
          'phoneNumber': user.phoneNumber,
          'photoUrl': user.photoUrl,
          'bio': user.bio,
          'price': user.price,
          'location': user.location,
          'languages': user.languages,
          'workDays': user.workDays,
          'workTimes': intrList,
          'voice': true,
          'chat': true,
          "consultType": user.consultType,
          'userLang': user.userLang,
          'rate' : user.rate,
          'searchIndex': user.searchIndex,
          'interestListIds':user.interestListIds,
          'fromUtc': user.fromUtc,
          'toUtc': user.toUtc,
          'link':user.link,
          'age': user.age,
          'ageValue':user.ageValue,
          'education': user.education,
          'profileCompleted': user.profileCompleted,
          'isGlorified': user.isGlorified,
        }, SetOptions(merge: true));
      }

      return true;
    } catch (e) {
      return false;
    }
  }


  @override
  Stream<UserNotification>? getNotifications(String uid) {
    try {
      DocumentReference documentReference =
          db.collection(Paths.noticationsPath).doc(uid);
      return documentReference.snapshots().transform(
            StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
                UserNotification>.fromHandlers(
              handleData:
                  (DocumentSnapshot docSnap, EventSink<UserNotification> sink) {
                UserNotification userNotification =UserNotification.fromMap(docSnap.data() as Map);
               // 
                sink.add(userNotification);
              },
              handleError: (error, stackTrace, sink) {
                sink.addError(error);
              },
            ),
          );
    } catch (e) {
      
      return null;
    }
  }

  @override
  Future<void> markNotificationRead(String uid) async {
    try {
      await db.collection(Paths.noticationsPath).doc(uid).set({
        'unread': false,
      }, SetOptions(merge: true));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<GroceryUser?> getConsultDetails(String consultId) async {
    try {
      DocumentSnapshot documentSnapshot = await db.collection(Paths.usersPath).doc(consultId).get();

      GroceryUser Consult = GroceryUser.fromMap(documentSnapshot.data() as Map);

      return Consult;
    } catch (e) {

      return null;
    }
  }

  @override
  Future<GroceryUser?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await db.collection(Paths.usersPath).doc(uid).get();

      GroceryUser currentUser = GroceryUser.fromMap(documentSnapshot.data() as Map);

      return currentUser;
    } catch (e) {

      return null;
    }
  }
}
