import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_practice/Screen/view_profile_screen.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:chatting_app_practice/models/chat_user.dart';
import 'package:flutter/material.dart';

class ProfileDilogue extends StatelessWidget {
  final ChatUser user;
  const ProfileDilogue({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            // this is for name of user
            Text(
              user.name,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.normal),
            ),
            // this is for image
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                // this is for profile pictuer from server
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: CachedNetworkImage(
                  width: mq.width * .5,
                  fit: BoxFit.fill,
                  imageUrl: user.image,
                  // placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>
                      const CircularProgressIndicator(),
                ),
              ),
            ),
            // this is icon
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ViewProfileScreen(user: user)));
                },
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 35,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
