
import '../../models/interests.dart';
import 'AppAppointments.dart';
import 'order.dart';

class Job {
  String jobId;
  String title;
  String status;
  String utcTime;
  UserDetails owner;
  String desc;
  List<Interests>interests;
  List<dynamic>interestsIds;
  List<dynamic>cosultIds;
  AppointmentDate date;
  bool? approved;


  Job({
    required this.jobId,
    required this.title,
    required this.status,
    required this.desc,
    required this.utcTime,
    required this.owner,
    required this.interests,
    required this.interestsIds,
    required this.cosultIds,
    required this.date,
    this.approved,

  });

  factory Job.fromMap(Map  data){
    //Map data = doc.data();
    return Job(
        jobId: data['jobId'],
        approved: data['approved'] == null ? true : data['approved'],
        title:data['title'],
        status:data['status'],
        desc: data['desc'],
        cosultIds:data['cosultIds']==null?[]:data['cosultIds'],
        date: AppointmentDate.fromHashmap(data['date']),
        owner: UserDetails.fromHashmap(data['owner']),
        interests: List<Interests>.from(
          data['interests'].map(
                (interests) {
              return Interests.fromHashmap(interests);
            },
          ),
        ),
        utcTime: data['utcTime'],
        interestsIds:data['interestsIds']==null?[]:data['interestsIds']
    );
  }
}


