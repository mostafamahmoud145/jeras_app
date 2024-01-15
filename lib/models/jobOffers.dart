
import 'AppAppointments.dart';
import 'order.dart';

class JobOffer {
  String jobOfferId;
  String jobId;
  String utcTime;
  UserDetails owner;
  String? desc;
  AppointmentDate date;
  String rate;
  String jobOwnerUid;


  JobOffer({

    required this.jobOfferId,
    required this.jobId,
     this.desc,
    required this.utcTime,
    required this.owner,
    required this.date,
    required this.rate,
    required this.jobOwnerUid,

  });

  factory JobOffer.fromMap(Map  data){
    //Map data = doc.data();
    return JobOffer(
        jobOfferId: data['jobOfferId'],
        desc: data['desc'],
        jobId: data['jobId'],
        rate: data['rate']==null?"0":data['rate'],
        date: AppointmentDate.fromHashmap(data['date']),
        owner: UserDetails.fromHashmap(data['owner']),
        utcTime: data['utcTime'],
        jobOwnerUid:data['jobOwnerUid'],
    );
  }
}


