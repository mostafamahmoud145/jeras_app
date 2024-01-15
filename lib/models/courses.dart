class Courses {
  String courseId;
  String name;
  String age;
  String desc;
  String sections;
  String notes;
  String? backgroundImage;
  int lessonNum;
  double rating;
  String? lang;
  String? summary;
  List<dynamic>? interestListIds;
  bool? active;
  bool? priceDisplay;
  double? discount;

  Courses({
    required this.courseId,
    required this.name,
    required this.age,
    this.summary,
    required this.desc,
    required this.sections,
    required this.notes,
    required this.backgroundImage,
    //required this.image,
    required this.lessonNum,
    required this.rating,
    this.lang,
    this.discount,
    this.active,
    this.priceDisplay,
    this.interestListIds,
  });

  factory Courses.fromMap(Map data) {
    return Courses(
      courseId: data['courseId'],
      name: data['name'],
      sections: data['sections'],
      age: data['age'],
      summary: data['summary'] == null ? "." : data['summary'],
      desc: data['desc'],
      notes: data['notes'],
      backgroundImage: data['backgroundImage'],
      //image: data['image'],
      lessonNum: data['lessonNum'],
      active: data['active'] == null ? false : data['active'],
      priceDisplay: data['priceDisplay'] == null ? false : data['priceDisplay'],
      rating: data['rating'].toDouble(),
      discount: data['discount'] == null ? 0.00 :data['discount'].toDouble(),
      lang: data['lang'] == null ? "ar" : data['lang'],
      interestListIds:
          data["interestListIds"] == null ? [] : data['interestListIds'],
    );
  }
}
