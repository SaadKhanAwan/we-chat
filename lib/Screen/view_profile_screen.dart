import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_practice/helper/mydate.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:chatting_app_practice/models/chat_user.dart';
import 'package:flutter/material.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

// view profile screen to view profile of a user
class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // this is for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // AppBar
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: Text(
              widget.user.name,
              style: const TextStyle(color: Colors.white),
            ),
            // AppBar trailing icons
          ),
          // floating action button
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Created on: ",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                Mydate.getlastmessagetime(
                  context: context,
                  time: widget.user.create,
                ),
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // body
          body: SingleChildScrollView(
            // this form is validation
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.05,
                  ),
                  ClipRRect(
                    // this is for profile pictuer from server
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      height: mq.height * .2,
                      width: mq.width * .4,
                      fit: BoxFit.fill,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const CircularProgressIndicator(),
                    ),
                  ),
                  // for adding some space
                  SizedBox(
                    width: mq.width,
                    height: mq.height * 0.03,
                  ),
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: mq.height * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "About: ",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black87,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.user.about,
                        style: const TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
