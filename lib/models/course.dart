

class Course {
  String id;
  String name;
  String age;
  String desc;
  String sections;
  String notes;
  String image;
  int lessonNum;
  String price;
  double rate;
  String? lang;
  List<dynamic>?interestListIds;
  //bool isFavorite = false;

  Course({
    required this.id,
    required this.name,
    required this.age,
    required this.desc,
    required this.notes,
    required this.image,
    required this.lessonNum,
    required this.price,
    required this.rate,
    required this.sections,
    this.lang,
    this.interestListIds,
  });

  factory Course.fromMap(Map  data){
    return Course(
      id: data['courseId'],
      name:data['name'],
      age: data['age'],
      image:data['image'],
      lessonNum:data['lessonNum'],
      desc:data['desc'],
      sections:  data['sections'],
      notes: data['notes'],
      price: data['price'],
      rate:  data['rating'].toDouble(),
      lang:data['lang']==null?"ar":data['lang'],
      interestListIds:data['interestListIds']==null?[]:data['interestListIds'],
    );
  }

}


