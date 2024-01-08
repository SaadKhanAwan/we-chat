import 'dart:convert';
import 'dart:io';
import 'package:chatting_app_practice/models/chat_user.dart';
import 'package:chatting_app_practice/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart';

class APIs {
  // for authtecation
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for firestore instsance
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for firebase storage instsance
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static late ChatUser me;

  // to return auth.curremtuser
  static User get user => auth.currentUser!;

  // to access firebase messaging (push notification)
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  // for getting firebase message token
  static Future<void> getfirebaseMessagingToken() async {
    await fmessaging.requestPermission();
    fmessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        debugPrint(
            "Push Token**************************************************************: $t");
      }
    });
    // this is for show  message ifd app is in foreground
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   print('Got a message whilst in the foreground!');
    //   print('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     print('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notification from api
  static Future<void> sendPushNotification(
      ChatUser chatuser, String msg) async {
    try {
      // here this title is for user name shown in notification and message is the message send shown in notificatkion
      final body = {
        "to": chatuser.pushToken,
        "notification": {
          "title": chatuser.name,
          "body": msg,
          "android_channel_id": "chtas"
        },
        "data": {
          "some_data": "user ID: ${me.id}",
        },
      };
      var response =
          // here this url was given by video  teacher
          await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                // here this key was taken from firebase settings/cloud messaging
                HttpHeaders.authorizationHeader:
                    'key=AAAA0UnfCfg:APA91bGxRd9JKgc9EnpzHzdDCcjVCPeKvur0ttjxm6yydtNmjAxzlm4xZ_cY4L605eQB9BjYA-yDT--ZZ78nCh-KEHjxQeOC1ylPEEHwCiho-6M9fK13Xn2FBM8k53yhZkU9wmvG1Dyc'
              },
              body: jsonEncode(body));
// print('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

// print(await http.read(Uri.https('example.com', 'foobar.txt')));
    } catch (e) {
      debugPrint('\n SendPushNotificationError$e');
    }
  }

  // checking if user exist or not
  static Future<bool> userExist() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // For adding a chat user for our conversation
  static Future<bool> addChatuser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      // if user exist
      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});
      return true;
    } else {
      // if user doesnt exist
      return false;
    }
  }

  // for getting self user info
  static Future<void> getselfinformation() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        //  this is for messaging/ notification
        await getfirebaseMessagingToken();
        // for setting user status to active when app is  open
        APIs.updateActiveStatus(true);
      } else {
        await createUser().then((value) => getselfinformation());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final chatuser = ChatUser(
        name: user.displayName.toString(),
        about: "Hey I am using We Chat",
        image: user.photoURL.toString(),
        create: time,
        id: user.uid,
        lastActive: time,
        email: user.email.toString(),
        pushToken: '',
        isOnline: false);
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatuser.toJson());
  }

  // for getting my user which I know through email from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getmyuser() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection("my_users")
        .snapshots();
  }

  // for getting all user from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getalluser(
      List<String> userIds) {
    return firestore
        .collection('users')
        .where("id", whereIn: userIds)
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding a user to my user when first message is send
  static Future<void> sendFirstMessage(
      // this type is for sending image or text
      ChatUser chatuser,
      String msg,
      Type type) async {
    // this is for update
    await firestore
        .collection('users')
        .doc(chatuser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendmessage(chatuser, msg, type));
  }

  // for upddating user info
  static Future<void> updateuserinfo() async {
    // this is for update
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  // for storing image url in firestore from storage and updateing profile image
  static Future<void> uppdateProfilePicture(File file) async {
    // getting image file extention
    final ext = file.path.split('.').last;
    // storage file reference with path
    final ref = storage.ref().child('profilepicture/ ${user.uid}.$ext');
    // uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    // uploading image in firebase datababse
    me.image = await ref.getDownloadURL();
    await firestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getuserinfo(
      ChatUser chatuser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatuser.id)
        .snapshots();
  }

  // for getting online and last active status for user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'isOnline': isOnline,
      'lastActive': DateTime.now().millisecondsSinceEpoch.toString(),
      'pushToken': me.pushToken,
    });
  }

  // ********************now all data is related about chating and messaging*********************

  //usefull for getting conversation id
  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages for a specfic converesation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getallmessages(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages')
        .orderBy('sent', descending: true)
        .snapshots();
  }
  // for sending all messages for a specfic converesation from firestore database

  static Future<void> sendmessage(
      // this type is for sending image or text
      ChatUser senduser,
      String msg,
      Type type) async {
    // message sending time for id
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    // message to send
    final Message message = Message(
        msg: msg,
        toId: senduser.id,
        read: "",
        type: type,
        sent: time,
        fromId: user.uid);
    final ref = firestore
        .collection('chats/${getConversationId(senduser.id)}/messages');
    await ref
        .doc(time)
        .set(message.toJson())
        // here this senderuser is because sendpushnotification needs chatuser
        //and tpe is because if we send message show the message else show text of (image) in notification
        .then((value) =>
            sendPushNotification(senduser, type == Type.text ? msg : 'image'));
  }

  // update read status of message
  static Future<void> updateMessageingReadStatus(Message message) async {
    // ignore: unused_local_variable
    final ref = firestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  // for getting last messages for shwoing on profile
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastmessages(
      ChatUser chatUser) {
    return firestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // for image chat
  static Future<void> sendChatImage(ChatUser chatuser, File file) async {
    // getting image file extention
    final ext = file.path.split('.').last;
    // storage file reference with path
    final ref = storage.ref().child(
        'images/${getConversationId(chatuser.id)}/ ${DateTime.now().millisecondsSinceEpoch}.$ext');
    // uploading image
    await ref.putFile(file, SettableMetadata(contentType: 'image/$ext'));
    // uploading image in firebase datababse FOR MESSAGING
    final imageurl = await ref.getDownloadURL();
    await sendmessage(chatuser, imageurl, Type.image);
  }

  // delete message
  static Future<void> deletemessage(Message message) async {
    firestore
        // due to this toID i only delete my messages
        .collection('chats/${getConversationId(message.toId)}/messages')
        .doc(message.sent)
        .delete();
    if (message.type == Type.image) {
      storage.refFromURL(message.msg).delete();
    }
  }

  // update message
  static Future<void> updatemessage(Message message, String updatemsg) async {
    firestore
        // due to this toID i only delete my messages
        .collection('chats/${getConversationId(message.toId)}/messages')
        .doc(message.sent)
        .update({"msg": updatemsg});
  }
}
