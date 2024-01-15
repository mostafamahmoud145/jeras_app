class Interests {
  String? icon;
  String? activeIcon;
  String interestId;
  String arName;
  String enName;
  String? lang;
  int? order;
  bool? active;


  Interests({
     this.icon,
     this.activeIcon,
     required this.interestId,
     required this.arName,
     required this.enName,
     this.order,
     this.lang,
     this.active,
  });

  factory Interests.fromMap(Map data) {
    //Map data = doc.data();
    return Interests(
      icon: data['icon'] == null ? "" : data['icon'],
      activeIcon: data['activeIcon'] == null ? "" : data['activeIcon'],
      interestId: data['interestId'],
      order: data['order'],
      arName: data['arName'],
      enName: data["enName"],
      lang: data['lang'],
      active: data["active"],
    );
  }
  factory Interests.fromHashmap(Map<String, dynamic> interests) {
    return Interests(
      activeIcon: interests['activeIcon'] == null ? "" : interests['activeIcon'],
      icon: interests['icon'] == null ? "" : interests['icon'],
      order: interests['order'] == null ? 100 : interests['order'],
      active: interests['active'] == null ? false : interests['active'],
      lang: interests['lang'] == null ? "ar" : interests['lang'],
      interestId: interests['interestId'],
      enName: interests['enName'],
      arName: interests['arName'],
    );
  }
}
