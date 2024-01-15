class CourseRate
{
  String appointmentId, courseId, desc, courseName, name, uid;
  double rate;

  CourseRate({
    required this.appointmentId,
    required this.courseId,
    required this.desc,
    required this.courseName,
    required this.name,
    required this.rate,
    required this.uid
  });

  factory CourseRate.fromMap(Map data) {
    return CourseRate(
      courseName: data['courseName'],
      name: data['name'],
      courseId: data['courseId'],
      appointmentId: data['appointmentId'],
      desc: data['desc'],
      rate: data['rating'],
      uid: data['uid'],
    );
  }

}