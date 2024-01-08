// ignore_for_file: file_names
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_practice/Screen/view_profile_screen.dart';
import 'package:chatting_app_practice/helper/mydate.dart';
import 'package:chatting_app_practice/widgets/messaging_card.dart';
import 'package:chatting_app_practice/api/apis.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:chatting_app_practice/models/chat_user.dart';
import 'package:chatting_app_practice/models/message.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // textediting controller
  final _texteditingcontroller = TextEditingController();
  // for storing messages
  List<Message> mylist = [];

  // for showing emoji
  bool _showemoji = false;
  bool _isuploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue,
            automaticallyImplyLeading: false,
            flexibleSpace: _appbar(),
          ),
          backgroundColor: const Color.fromARGB(255, 204, 248, 255),
          body: Column(
            children: [
              messinging(),
              // progress indecator for showing uploading image
              if (_isuploading)
                const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )),
              chatinputfield(),
              if (_showemoji)
                SizedBox(
                  height: mq.height * .34,
                  child: EmojiPicker(
                    onBackspacePressed: () {
                      // Do something when the user taps the backspace button (optional)
                      // Set it to null to hide the Backspace-Button
                    },
                    textEditingController: _texteditingcontroller,
                    config: Config(
                      bgColor: const Color.fromARGB(255, 234, 248, 255),
                      columns: 8,
                      emojiSizeMax: 32 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.30
                              : 1.0),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _appbar() {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ViewProfileScreen(
                      user: widget.user,
                    )));
      },
      child: StreamBuilder(
        stream: APIs.getuserinfo(widget.user),
        builder: (context, snapshot) {
          final data = snapshot.data?.docs;
          final mylist =
              // here this Chatser is model of chatuser
              data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

          return Row(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back)),
              // user profile picture
              ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .4),
                child: CachedNetworkImage(
                  height: mq.height * 0.095,
                  width: mq.width * 0.095,
                  fit: BoxFit.contain,
                  imageUrl:
                      mylist.isNotEmpty ? mylist[0].image : widget.user.image,
                  // placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircularProgressIndicator(),
                ),
              ),
              // this is for space
              const SizedBox(
                width: 10,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // this is for user  name
                  Text(
                    mylist.isNotEmpty ? mylist[0].name : widget.user.name,
                    style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ),
                  // this is for last sense
                  Text(
                    mylist.isNotEmpty
                        ? mylist[0].isOnline
                            ? "Online"
                            : Mydate.getLastActive(
                                context: context,
                                lastActive: mylist[0].lastActive)
                        : Mydate.getLastActive(
                            context: context,
                            lastActive: widget.user.lastActive),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }

  Widget chatinputfield() {
    // this is for show background
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: mq.height * .01,
      ),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(27)),
              child: Row(
                children: [
                  // emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showemoji = !_showemoji;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.yellow.shade700,
                      )),
                  // this is for textfield
                  Expanded(
                      child: TextField(
                    onTap: () {
                      if (_showemoji) {
                        setState(() {
                          _showemoji = !_showemoji;
                        });
                      }
                    },
                    controller: _texteditingcontroller,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: "Type something...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none),
                  )),
                  // this is gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var i in images) {
                          // for progress indicator
                          setState(() => _isuploading = true);
                          // for picking muiltiiple images and uploading on  firebase
                          await APIs.sendChatImage(widget.user, File(i.path));
                          // for progress indicator
                          setState(() => _isuploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blue,
                      )),
                  // camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          // for progress indecator while uploading a imgae
                          setState(() => _isuploading = true);
                          // for uploaing on firebase a imag in chat
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          // for progress indicator
                          setState(() => _isuploading = false);
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blue,
                      )),
                ],
              ),
            ),
          ),
          // this is send button
          MaterialButton(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: const CircleBorder(),
            minWidth: 0,
            color: Colors.green,
            onPressed: () {
              if (_texteditingcontroller.text.isNotEmpty) {
                if (mylist.isEmpty) {
                  // on first message(add user  to my My_user collection of chat user)
                  APIs.sendFirstMessage(
                      widget.user, _texteditingcontroller.text, Type.text);
                } else {
                  // simply send message
                  APIs.sendmessage(
                      widget.user, _texteditingcontroller.text, Type.text);
                  _texteditingcontroller.text = "";
                }
              }
            },
            child: const Icon(
              Icons.send,
              size: 28,
              color: Colors.white,
            ),
          )
        ],
      ),
    );
  }

  // this is for messinging body
  Widget messinging() {
    return Expanded(
      child: StreamBuilder(
          stream: APIs.getallmessages(widget.user),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              //if data is loading
              case ConnectionState.waiting:
              case ConnectionState.none:
                return const Center(child: CircularProgressIndicator());
              //if some or all data is loaded then show it
              case ConnectionState.active:
              case ConnectionState.done:
                final data = snapshot.data?.docs;
                mylist =
                    // here this message is model of message
                    data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
                if (mylist.isNotEmpty) {
                  return ListView.builder(
                      itemCount: mylist.length,
                      reverse: true,
                      padding: EdgeInsets.only(top: mq.height * 0.01),
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return MessagingCard(
                          message: mylist[index],
                        );
                      });
                } else {
                  // if Screen is empty
                  return const Center(
                      child: Text(
                    "Say Hi! 👋",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ));
                }
            }
          }),
    );
  }
}
