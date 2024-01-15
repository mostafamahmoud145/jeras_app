
import 'package:cloud_firestore/cloud_firestore.dart';


class Setting {
  String settingId;
  String firstTitleAr;
  String firstTitleEn;
  dynamic androidVersion;
  dynamic androidBuildNumber;
  dynamic iosVersion;
  dynamic iosBuildNumber;
  dynamic taxes;
  bool appReview;
  Setting( {
    required this.settingId,
    required this.firstTitleAr,
    required this.firstTitleEn,
    required this.androidVersion,
    required this.androidBuildNumber,
    required this.iosVersion,
    required this.iosBuildNumber,
    required this.taxes,
    required this. appReview,
  });
  factory Setting.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot,SnapshotOptions? options,) {
    final data = snapshot.data();
    return Setting(
        settingId: data?['settingId'],
        firstTitleAr: data?['firstTitleAr'],
        firstTitleEn: data?['firstTitleEn'],
        androidVersion: data?['androidVersion'],
        androidBuildNumber: data?['androidBuildNumber'],
        iosVersion: data?['iosVersion'],
        iosBuildNumber: data?['iosBuildNumber'],
        taxes: data?['taxes'],
        appReview:data?['appReview']==null?false:data?['appReview']
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      if (taxes != null) "taxes": taxes,
    };
  }
  factory Setting.fromMap(Map  data){
    //Map data = doc.data();
    return Setting(
        settingId: data['settingId'],
        firstTitleAr: data['firstTitleAr'],
        firstTitleEn: data['firstTitleEn'],
        androidVersion: data['androidVersion'],
        androidBuildNumber: data['androidBuildNumber'],
        iosVersion: data['iosVersion'],
        iosBuildNumber: data['iosBuildNumber'],
        taxes: data['taxes'],
        appReview:data['appReview']==null?false:data['appReview']

    );
  }



}

