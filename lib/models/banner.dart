

class banner {
  String? id;
  bool? status;
  String?  itemId;
  String? type;
  String? image;
  String?lang;
  String? webImage;
  banner({
    this.id,
    this.status,
    this.itemId,
    this.type,
    this.image,
    this.lang,
    this.webImage,

  });

  factory banner.fromMap(Map  data) {
    return banner(
      id: data['id'],
      status: data['status'],
      itemId: data['itemId'],
      type: data['type'],
      image: data['image'],
      lang: data['lang'],
        webImage:data['webImage']
    );
  }
}
