class Message {
  late String msg;
  // this too id is mine id
  late String toId;
  late String read;
  late String sent;
  // and from id is sender id
  late String fromId;
  late Type type;

  Message(
      {required this.msg,
      required this.toId,
      required this.read,
      required this.type,
      required this.sent,
      required this.fromId});

  Message.fromJson(Map<String, dynamic> json) {
    msg = json['msg'].toString();
    toId = json['toId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    sent = json['sent'].toString();
    fromId = json['fromId'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['msg'] = msg;
    data['toId'] = toId;
    data['read'] = read;
    data['type'] = type.name;
    data['sent'] = sent;
    data['fromId'] = fromId;
    return data;
  }
}

// this for checking text type is image or text
enum Type { text, image }
