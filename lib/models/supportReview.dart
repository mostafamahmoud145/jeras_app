
import 'package:cloud_firestore/cloud_firestore.dart';
class SupportReview {
  String review;
  dynamic rating;
  Timestamp reviewTime;
  String supportListId;
  String supportImage;
  String supportUid;
  String supportName;
  String userName;
  SupportReview({
    required this.review,
    required this.rating,
    required this.reviewTime,
    required this.supportListId,
    required this.supportImage,
    required this.supportUid,
    required this.supportName,
    required this.userName,
  });
  factory SupportReview.fromMap(Map  data){
    //Map<String, dynamic> data = snapshot.data();
    return SupportReview(

      rating: data['rating'],
      review: data['review'],
      reviewTime:data['reviewTime'],
      supportListId: data['supportListId'],
      supportImage: data['supportImage'],
      supportUid: data['supportUid'],
      supportName: data['supportName'],
      userName: data['userName'],

    );
  }
  factory SupportReview.fromHashMap(Map<String, dynamic> review) {
    return SupportReview(
      rating: review['rating'],
      review: review['review'],
      reviewTime: review['reviewTime'],
      supportListId: review['supportListId'],
      supportImage: review['supportImage'],
      supportUid: review['supportUid'],
      supportName: review['supportName'],
      userName: review['userName'],
    );
  }
}