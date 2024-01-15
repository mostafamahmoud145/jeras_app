

class ConsultDays {
  String day;
  dynamic date;
  List<dynamic> todayAppointmentList;
  String consultUid;

  ConsultDays({
    required this.day,
    required this.date,
    required this.consultUid,
    required this.todayAppointmentList,
  });
  //factory ConsultDays.fromMap(DocumentSnapshot snapshot) {
   // Map<String, dynamic> data = snapshot.data();
  factory ConsultDays.fromMap(Map <dynamic,dynamic> data) {
    return ConsultDays(
      day: data['day'],
      date: data['date'],
      consultUid: data['consultUid'],
      todayAppointmentList: data['todayAppointmentList']==null?[]:data['todayAppointmentList'],
    );
  }
  factory ConsultDays.fromHashMap(Map<String, dynamic> data) {
    return ConsultDays(
      day: data['day'],
      date: data['date'],
      consultUid: data['consultUid'],
      todayAppointmentList: data['todayAppointmentList']==null?[]:data['todayAppointmentList'],
    );
  }
}