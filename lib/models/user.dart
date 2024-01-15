import 'package:cloud_firestore/cloud_firestore.dart';

import 'AppAppointments.dart';

class GroceryUser {
  String? accountStatus;
  String? link;
  bool? isBlocked;
  bool? isDeveloper;
  bool? isSupervisor;
  bool? isGlorified;
  String? uid;
  String? name;
  String? nameEn;
  String? nameFr;
  String? email;
  String? userType;
  String? phoneNumber;
  String? photoUrl;
  dynamic rating;
  dynamic rate;
  int? reviewsCount;
  String? tokenId;
  String? defaultAddress;
  List<Address>? address;
  List<dynamic>? promoList;
  List<dynamic>? languages;
  List<dynamic>? consultOpenAppointmentDates;
  List<dynamic>? searchIndex;
  List<dynamic>? searchIndexEn;
  List<dynamic>? searchIndexFr;
  List<dynamic>? interestListIds;
  bool? voice;
  bool? chat;
  String? bio;
  String? bioEn;
  String? bioFr;
  String? country;
  List<WorkTimes>? workTimes;
  List<dynamic>? workDays;
  String? userConsultIds;
  String? price;
  dynamic balance;
  int? ageValue;
  dynamic payedBalance;
  int? ordersNumbers;
  String? loggedInVia;
  AppointmentDate? date;
  String? supportListId;
  String? customerId;
  dynamic order;
  dynamic openOrders;
  dynamic answeredSupportNum;
  String? countryCode;
  String? countryISOCode;
  String? userLang;
  String? preferredPaymentMethod;
  bool? profileCompleted = false;
  Timestamp? createdDate;
  int? createdDateValue;
  String? fullName;
  String? bankName;
  String? bankAccountNumber;
  String? fullAddress;
  String? personalIdUrl;
  String? fromUtc;
  String? toUtc;
  String? age;
  String? education;
  String? location;
  String? locationEn;
  String? consultType;
  bool? allowEditPayinfo;
  bool? sendGrant;
  String? destinationId;
  List<dynamic>? courses;
  List<dynamic>? favoriteCorses;

  GroceryUser({
    this.destinationId,
    this.sendGrant,
    this.link,
    this.isGlorified,
    this.isSupervisor,
    this.allowEditPayinfo,
    this.consultType,
    this.accountStatus,
    this.age,
    this.ageValue,
    this.date,
    this.openOrders,
    this.consultOpenAppointmentDates,
    this.location,
    this.locationEn,
    this.education,
    this.userLang,
    this.isDeveloper,
    this.fullName,
    this.fullAddress,
    this.bankName,
    this.answeredSupportNum,
    this.bankAccountNumber,
    this.personalIdUrl,
    this.countryCode,
    this.countryISOCode,
    this.order,
    this.customerId,
    this.isBlocked,
    this.uid,
    this.searchIndex,
    this.searchIndexEn,
    this.searchIndexFr,
    this.interestListIds,
    this.email,
    this.userType,
    this.phoneNumber,
    this.rating,
    this.rate,
    this.reviewsCount,
    this.name,
    this.nameEn,
    this.nameFr,
    this.bioEn,
    this.bioFr,
    this.photoUrl,
    this.languages,
    this.ordersNumbers,
    this.chat,
    this.voice,
    this.bio,
    this.workDays,
    this.workTimes,
    this.country,
    this.userConsultIds,
    this.price,
    this.balance,
    this.payedBalance,
    this.defaultAddress,
    this.address,
    this.tokenId,
    this.promoList,
    this.loggedInVia,
    this.supportListId,
    this.profileCompleted,
    this.createdDate,
    this.createdDateValue,
    this.preferredPaymentMethod,
    this.fromUtc,
    this.toUtc,
    this.courses,
    this.favoriteCorses,
  });

  factory GroceryUser.fromMap(Map data) {
    return GroceryUser(
      destinationId: data['destinationId'] == null ? "" : data['destinationId'],
      link: data['link'] == "" ? null : data['link'],
      openOrders: data['openOrders'] == null ? 0 : data['openOrders'],
      isGlorified: data['isGlorified'] == null ? false : data['isGlorified'],
      sendGrant: data['sendGrant'] == null ? false : data['sendGrant'],
      isSupervisor: data['isSupervisor'] == null ? false : data['isSupervisor'],
      allowEditPayinfo:
          data['allowEditPayinfo'] == null ? false : data['allowEditPayinfo'],
      consultType: data["consultType"] == null ? "" : data["consultType"],
      consultOpenAppointmentDates: data['consultOpenAppointmentDates'] == null
          ? []
          : data['consultOpenAppointmentDates'],
      accountStatus:
          data['accountStatus'] == null ? "NotActive" : data['accountStatus'],
      preferredPaymentMethod: data['preferredPaymentMethod'] == null
          ? "tapCompany"
          : data['preferredPaymentMethod'],
      profileCompleted:
          data['profileCompleted'] == null ? false : data['profileCompleted'],
      userLang: data['userLang'] == null ? "ar" : data['userLang'],
      countryCode: data['countryCode'],
      location: data['location'] == null ? " " : data['location'],
      locationEn: data['locationEn'] == null ? " " : data['locationEn'],
      nameEn: data['nameEn'] == null ? " " : data['nameEn'],
      nameFr: data['nameFr'] == null ? " " : data['nameFr'],
      countryISOCode: data['countryISOCode'],
      order: data['order'] == null ? 0 : data['order'],
      answeredSupportNum:
          data['answeredSupportNum'] == null ? 0 : data['answeredSupportNum'],
      isBlocked: data['isBlocked'],
      uid: data['uid'],
      email: data['email'],
      age: data['age'],
      ageValue: data['ageValue'],
      education: data['education'] == null ? "" : data['education'],
      customerId: data['customerId'],
      supportListId: data['supportListId'],
      userType: data['userType'] == null ? " " : data['userType'],
      phoneNumber: data['phoneNumber'],
      name: data['name'] == null ? " " : data['name'],
      bio: data['bio'] == null ? " " : data['bio'],
      bioEn: data['bioEn'] == null ? " " : data['bioEn'],
      bioFr: data['bioFr'] == null ? " " : data['bioFr'],
      country: data['country'],
      workTimes: data['workTimes'] == null
          ? []
          : List<WorkTimes>.from(
              data['workTimes'].map(
                (workTimes) {
                  return WorkTimes.fromHashmap(workTimes);
                },
              ),
            ),
      userConsultIds: data['userConsultIds'],
      workDays: data['workDays'] == null ? [] : data['workDays'],
      reviewsCount: data['reviewsCount'] == null ? 0 : data['reviewsCount'],
      rating: data['rating'] == null ? 0.0 : data['rating'],
      languages: data['languages'] == null ? [] : data['languages'],
      ordersNumbers: data['ordersNumbers'] == null ? 0 : data['ordersNumbers'],
      price: data['price'] == null ? "0" : data['price'],
      balance: data['balance'] == null ? 0.0 : data['balance'],
      payedBalance: data['payedBalance'] == null ? 0.0 : data['payedBalance'],
      voice: data['voice'] == null ? false : data['voice'],
      chat: data['chat'] == null ? false : data['chat'],
      isDeveloper: data['isDeveloper'] == null ? false : data['isDeveloper'],
      photoUrl: data['photoUrl'] == null ? "" : data['photoUrl'],
      tokenId: data['tokenId'],
      promoList: data['promoList'] == null ? [] : data['promoList'],
      courses: data['courses'] == null ? [] : data['courses'],
      favoriteCorses:
          data['favoriteCourses'] == null ? [] : data['favoriteCourses'],
      searchIndex: data['searchIndex'],
      searchIndexEn: data['searchIndexEn'],
      searchIndexFr: data['searchIndexFr'],
      interestListIds:
          data["interestListIds"] == null ? [] : data['interestListIds'],
      loggedInVia: data['loggedInVia'],
      createdDate: data['createdDate'],
      createdDateValue: data['createdDateValue'],
      date: AppointmentDate.fromHashmap(data['date']),
      fullName: data['fullName'],
      fullAddress: data['fullAddress'],
      bankName: data['bankName'],
      bankAccountNumber: data['bankAccountNumber'],
      personalIdUrl: data['personalIdUrl'],
      fromUtc: data['fromUtc'],
      toUtc: data['toUtc'],
    );
  }

  GroceryUser.fromSnapshot(Map<String, dynamic> doc)
      : name = doc['name'] == null ? " " : doc['name'],
        nameEn = doc['nameEn'] == null ? " " : doc['nameEn'],
        nameFr = doc['nameFr'] == null ? " " : doc['nameFr'],
        locationEn = doc['locationEn'] == null ? " " : doc['locationEn'],
        destinationId =
            doc['destinationId'] == null ? "" : doc['destinationId'],
        link = doc['link'] == "" ? null : doc['link'],
        openOrders = doc['openOrders'] == null ? 0 : doc['openOrders'],
        isGlorified = doc['isGlorified'] == null ? false : doc['isGlorified'],
        sendGrant = doc['sendGrant'] == null ? false : doc['sendGrant'],
        isSupervisor =
            doc['isSupervisor'] == null ? false : doc['isSupervisor'],
        allowEditPayinfo =
            doc['allowEditPayinfo'] == null ? false : doc['allowEditPayinfo'],
        consultType = doc["consultType"] == null ? "" : doc["consultType"],
        consultOpenAppointmentDates = doc['consultOpenAppointmentDates'] == null
            ? []
            : doc['consultOpenAppointmentDates'],
        accountStatus =
            doc['accountStatus'] == null ? "NotActive" : doc['accountStatus'],
        preferredPaymentMethod = doc['preferredPaymentMethod'] == null
            ? "tapCompany"
            : doc['preferredPaymentMethod'],
        profileCompleted =
            doc['profileCompleted'] == null ? false : doc['profileCompleted'],
        userLang = doc['userLang'] == null ? "ar" : doc['userLang'],
        countryCode = doc['countryCode'],
        location = doc['location'] == null ? " " : doc['location'],
        countryISOCode = doc['countryISOCode'],
        order = doc['order'] == null ? 0 : doc['order'],
        answeredSupportNum =
            doc['answeredSupportNum'] == null ? 0 : doc['answeredSupportNum'],
        isBlocked = doc['isBlocked'],
        uid = doc['uid'],
        email = doc['email'],
        age = doc['age'],
        ageValue = doc['ageValue'],
        education = doc['education'] == null ? "" : doc['education'],
        customerId = doc['customerId'],
        supportListId = doc['supportListId'],
        phoneNumber = doc['phoneNumber'],
        bio = doc['bio'] == null ? " " : doc['bio'],
        userType = doc['userType'] == null ? " " : doc['userType'],
        bioEn = doc['bioEn'] == null ? " " : doc['bioEn'],
        bioFr = doc['bioFr'] == null ? " " : doc['bioFr'],
        country = doc['country'],
        workTimes = doc['workTimes'] == null
            ? []
            : List<WorkTimes>.from(
                doc['workTimes'].map(
                  (workTimes) {
                    return WorkTimes.fromHashmap(workTimes);
                  },
                ),
              ),
        userConsultIds = doc['userConsultIds'],
        workDays = doc['workDays'] == null ? [] : doc['workDays'],
        courses = doc['courses'] == null ? [] : doc['courses'],
        favoriteCorses =
            doc['favoriteCourses'] == null ? [] : doc['favoriteCourses'],
        reviewsCount = doc['reviewsCount'] == null ? 0 : doc['reviewsCount'],
        rating = doc['rating'] == null ? 0.0 : doc['rating'],
        languages = doc['languages'] == null ? [] : doc['languages'],
        ordersNumbers = doc['ordersNumbers'] == null ? 0 : doc['ordersNumbers'],
        price = doc['price'] == null ? "0" : doc['price'],
        balance = doc['balance'] == null ? 0.0 : doc['balance'],
        payedBalance = doc['payedBalance'] == null ? 0.0 : doc['payedBalance'],
        voice = doc['voice'] == null ? false : doc['voice'],
        chat = doc['chat'] == null ? false : doc['chat'],
        isDeveloper = doc['isDeveloper'] == null ? false : doc['isDeveloper'],
        photoUrl = doc['photoUrl'] == null ? "" : doc['photoUrl'],
        tokenId = doc['tokenId'],
        promoList = doc['promoList'] == null ? [] : doc['promoList'],
        searchIndex = doc['searchIndex'],
        searchIndexEn = doc['searchIndexEn'],
        searchIndexFr = doc['searchIndexFr'],
        interestListIds =
            doc["interestListIds"] == null ? [] : doc['interestListIds'],
        loggedInVia = doc['loggedInVia'],
        createdDate = doc['createdDate'],
        createdDateValue = doc['createdDateValue'],
        date = AppointmentDate.fromHashmap(doc['date']),
        fullName = doc['fullName'],
        fullAddress = doc['fullAddress'],
        bankName = doc['bankName'],
        bankAccountNumber = doc['bankAccountNumber'],
        personalIdUrl = doc['personalIdUrl'],
        fromUtc = doc['fromUtc'],
        toUtc = doc['toUtc'];

  factory GroceryUser.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return GroceryUser(
      bioEn: data?['bioEn'] == null ? " " : data?['bioEn'],
      bioFr: data?['bioFr'] == null ? " " : data?['bioFr'],
      locationEn: data?['locationEn'] == null ? " " : data?['locationEn'],
      nameEn: data?['nameEn'] == null ? " " : data?['nameEn'],
      nameFr: data?['nameFr'] == null ? " " : data?['nameFr'],
      destinationId:
          data?['destinationId'] == null ? "" : data?['destinationId'],
      link: data?['link'] == "" ? null : data?['link'],
      openOrders: data?['openOrders'] == null ? 0 : data?['openOrders'],
      isGlorified: data?['isGlorified'] == null ? false : data?['isGlorified'],
      sendGrant: data?['sendGrant'] == null ? false : data?['sendGrant'],
      allowEditPayinfo:
          data?['allowEditPayinfo'] == null ? false : data?['allowEditPayinfo'],
      consultType: data?["consultType"] == null ? "" : data?["consultType"],
      consultOpenAppointmentDates: data?['consultOpenAppointmentDates'] == null
          ? []
          : data?['consultOpenAppointmentDates'],
      accountStatus:
          data?['accountStatus'] == null ? "NotActive" : data?['accountStatus'],
      preferredPaymentMethod: data?['preferredPaymentMethod'] == null
          ? "tapCompany"
          : data?['preferredPaymentMethod'],
      profileCompleted:
          data?['profileCompleted'] == null ? false : data?['profileCompleted'],
      userLang: data?['userLang'] == null ? "ar" : data?['userLang'],
      countryCode: data?['countryCode'],
      location: data?['location'] == null ? " " : data?['location'],
      countryISOCode: data?['countryISOCode'],
      order: data?['order'] == null ? 0 : data?['order'],
      answeredSupportNum:
          data?['answeredSupportNum'] == null ? 0 : data?['answeredSupportNum'],
      isBlocked: data?['isBlocked'],
      uid: data?['uid'],
      email: data?['email'],
      age: data?['age'],
      ageValue: data?['ageValue'],
      education: data?['education'] == null ? "" : data?['education'],
      customerId: data?['customerId'],
      supportListId: data?['supportListId'],
      phoneNumber: data?['phoneNumber'],
      name: data?['name'] == null ? " " : data?['name'],
      userType: data?['userType'] == null ? " " : data?['userType'],
      bio: data?['bio'] == null ? " " : data?['bio'],
      country: data?['country'],
      workTimes: data?['workTimes'] == null
          ? []
          : List<WorkTimes>.from(
              data?['workTimes'].map(
                (workTimes) {
                  return WorkTimes.fromHashmap(workTimes);
                },
              ),
            ),
      userConsultIds: data?['userConsultIds'],
      workDays: data?['workDays'] == null ? [] : data?['workDays'],
      courses: data?['courses'] == null ? [] : data?['courses'],
      favoriteCorses:
          data?['favoriteCourses'] == null ? [] : data?['favoriteCourses'],
      reviewsCount: data?['reviewsCount'] == null ? 0 : data?['reviewsCount'],
      rating: data?['rating'] == null ? 0.0 : data?['rating'],
      languages: data?['languages'] == null ? [] : data?['languages'],
      ordersNumbers:
          data?['ordersNumbers'] == null ? 0 : data?['ordersNumbers'],
      price: data?['price'] == null ? "0" : data?['price'],
      balance: data?['balance'] == null ? 0.0 : data?['balance'],
      payedBalance: data?['payedBalance'] == null ? 0.0 : data?['payedBalance'],
      voice: data?['voice'] == null ? false : data?['voice'],
      chat: data?['chat'] == null ? false : data?['chat'],
      isDeveloper: data?['isDeveloper'] == null ? false : data?['isDeveloper'],
      isSupervisor:
          data?['isSupervisor'] == null ? false : data?['isSupervisor'],
      photoUrl: data?['photoUrl'] == null ? "" : data?['photoUrl'],
      tokenId: data?['tokenId'],
      promoList: data?['promoList'] == null ? [] : data?['promoList'],
      searchIndex: data?['searchIndex'],
      searchIndexEn: data?['searchIndexEn'],
      searchIndexFr: data?['searchIndexFr'],
      interestListIds:
          data?["interestListIds"] == null ? [] : data?['interestListIds'],
      loggedInVia: data?['loggedInVia'],
      createdDate: data?['createdDate'],
      createdDateValue: data?['createdDateValue'],
      date: AppointmentDate.fromHashmap(data?['date']),
      fullName: data?['fullName'],
      fullAddress: data?['fullAddress'],
      bankName: data?['bankName'],
      bankAccountNumber: data?['bankAccountNumber'],
      personalIdUrl: data?['personalIdUrl'],
      fromUtc: data?['fromUtc'],
      toUtc: data?['toUtc'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (name != null) "": name,
    };
  }
}

class Address {
  String? city;
  String? state;
  String? pincode;
  String? landmark;
  String? addressLine1;
  String? addressLine2;
  String? country;
  String? houseNo;

  Address({
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.country,
    this.houseNo,
    this.landmark,
    this.pincode,
    this.state,
  });

  factory Address.fromHashmap(Map<String?, dynamic> address) {
    return Address(
      addressLine1: address['addressLine1'],
      addressLine2: address['addressLine2'],
      city: address['city'],
      country: address['country'],
      houseNo: address['houseNo'],
      landmark: address['landmark'],
      pincode: address['pincode'],
      state: address['state'],
    );
  }
}

class KeyValueModel {
  dynamic key;
  String? value;

  KeyValueModel({this.key, this.value});
}

class WorkTimes {
  String? from;
  String? to;

  WorkTimes({
    this.from,
    this.to,
  });

  factory WorkTimes.fromHashmap(Map<String?, dynamic> ranges) {
    return WorkTimes(
      from: ranges['from'],
      to: ranges['to'],
    );
  }
}

class Video {
  String? id;
  String? consultUid;
  String? link;
  String? desc;
  String? link1;
  String? link2;

  Video({
    this.id,
    this.consultUid,
    this.link,
    this.desc,
    this.link1,
    this.link2,
  });

  factory Video.fromMap(Map data) {
    //Map data = doc.data();
    return Video(
      id: data['id'],
      consultUid: data['consultUid'],
      link: data['link'],
      link1: data['link1'],
      link2: data['link2'],
      desc: data['desc'],
    );
  }

  factory Video.fromHashmap(Map<String?, dynamic> ranges) {
    return Video(
      id: ranges['id'],
      consultUid: ranges['consultUid'],
      link: ranges['link'],
      link1: ranges['link1'],
      link2: ranges['link2'],
      desc: ranges['desc'],
    );
  }
}
