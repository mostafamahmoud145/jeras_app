

class consultPackage {
  String? Id;
  dynamic price;
  dynamic discount;
  String? consultUid;
  bool? active;
  dynamic callNum;


  consultPackage({
     this.Id,
     this.price,
     this.consultUid,
     this.discount,
     this.active,
     this.callNum,
  });
  factory consultPackage.fromMap(Map  data){
    //Map<String, dynamic> data = snapshot.data();
    return consultPackage(
        Id: data['Id'],
        price: data['price'],
        discount: data['discount'],
        consultUid: data['consultUid'],
        active: data['active'],
        callNum: data['callNum']
    );
  }

  tomap(){

    return <String,dynamic>{
      "Id":Id,
      "price":price,
      "discount":discount,
      "consultUid":consultUid,
      "active":active,
      "callNum":callNum,


    };
  }

  factory consultPackage.fromHashMap(Map<String, dynamic> review) {
    return consultPackage(
        Id: review['Id'],
        discount: review['discount'],
        price: review['price'],
        consultUid: review['consultUid'],
        active: review['active'],
        callNum: review['callNum']
    );
  }
}