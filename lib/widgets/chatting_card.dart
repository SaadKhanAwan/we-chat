import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_practice/Screen/chatScreen.dart';
import 'package:chatting_app_practice/api/apis.dart';
import 'package:chatting_app_practice/helper/mydate.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:chatting_app_practice/models/chat_user.dart';
import 'package:chatting_app_practice/models/message.dart';
import 'package:chatting_app_practice/widgets/dilogues/profile_dilogue.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  // last message info if(null--> no message)
  Message? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.03, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      color: Colors.blue.shade100,
      child: InkWell(
          onTap: () {
            // for navigator to chat screen
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(
                          user: widget.user,
                        )));
          },
          child: StreamBuilder(
            stream: APIs.getLastmessages(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final mylist =
                  // here this message is model of message
                  data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
              if (mylist.isNotEmpty) _message = mylist[0];
              return ListTile(
                  // user name
                  title: Text(widget.user.name),
                  // user last message
                  subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? "Photo"
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1,
                  ),
                  // user profile picture
                  leading: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (_) => ProfileDilogue(
                                user: widget.user,
                              ));
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(mq.height * .9),
                      child: CachedNetworkImage(
                        height: mq.height * 0.095,
                        width: mq.width * 0.095,
                        imageUrl: widget.user.image,
                        // placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  //last message time
                  // if message is empty show nothing
                  trailing: _message == null
                      ? null
                      // if message is sent once and is not open show green dot
                      : _message!.read.isEmpty &&
                              _message!.fromId != APIs.user.uid
                          ? Container(
                              height: 10,
                              width: 10,
                              decoration: const BoxDecoration(
                                  color: Colors.green, shape: BoxShape.circle),
                            )
                          // if message is open once  show its sent time
                          : Text(
                              Mydate.getlastmessagetime(
                                  context: context, time: _message!.sent),
                              style: const TextStyle(color: Colors.black54),
                            ));
            },
          )),
    );
  }
}
