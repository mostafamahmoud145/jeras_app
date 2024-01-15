import 'dart:core';

class Messages{
  late final String fromid;
  late final String toid;
  late final String type;
  late final String msg;
  late final String sent;
  late final String read;

  Messages({
    required this.fromid,
    required this.toid,
    required this.type,
    required this.msg,
    required this.sent,
    required this.read,

});
  Messages.fromJson(Map<String,dynamic>json){
    fromid=json['fromid'].toString();
    toid=json['toid'].toString();
    msg=json['msg'].toString();
    sent=json['sent'].toString();
    read=json['read'].toString();
    type=json['type'].toString();
  }
  Map<String, dynamic> toJson(){
    final data= <String, dynamic>{};
    data['fromid']=fromid;
    data['toid']=toid;
    data['msg']=msg;
    data['sent']=sent;
    data['read']=read;
    data['type']=type;
    return data;
  }





}
enum Type{texts,images}