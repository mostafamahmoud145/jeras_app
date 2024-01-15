

class Program {
  String id;
  String consultType;
  String name;
  String image;
  int courseNum;
  int lessonNum;
  String desc;
  String lang;
  String notes;
  bool active;

  Program({
    required this.id,
    required this.consultType,
    required this.name,
    required this.image,
    required this.courseNum,
    required this.lessonNum,
    required this.desc,
    required this.lang,
    required this.notes,
    required this.active,

  });
  factory Program.fromMap(Map  data){
    return Program(
      id: data['id'],
      consultType:data['consultType'],
      name:data['name'],
      image:data['image'],
      courseNum:data['courseNum'],
      lessonNum: data['lessonNum'],
      desc: data['desc'],
      lang: data['lang'],
      notes: data['notes'],
      active: data['active'],
    );
  }

}


