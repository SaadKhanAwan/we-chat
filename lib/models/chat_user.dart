class ChatUser {
  late String name;
  late String about;
  late String image;
  late String create;
  late String id;
  late String lastActive;
  late String email;
  late String pushToken;
  late bool isOnline;

  ChatUser(
      {required this.name,
      required this.about,
      required this.image,
      required this.create,
      required this.id,
      required this.lastActive,
      required this.email,
      required this.pushToken,
      required this.isOnline});

  ChatUser.fromJson(Map<String, dynamic> json) {
    name = json['name'] ?? "";
    about = json['about'] ?? "";
    image = json['image'] ?? "";
    create = json['Create'] ?? "";
    id = json['id'];
    lastActive = json['lastActive'] ?? "";
    email = json['email'] ?? "";
    pushToken = json['pushToken'] ?? "";
    isOnline = json['isOnline'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['name'] = name;
    data['about'] = about;
    data['image'] = image;
    data['Create'] = create;
    data['id'] = id;
    data['lastActive'] = lastActive;
    data['email'] = email;
    data['pushToken'] = pushToken;
    data['isOnline'] = isOnline;
    return data;
  }
}
