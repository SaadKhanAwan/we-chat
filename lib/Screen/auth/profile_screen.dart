import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app_practice/Screen/auth/login_screen.dart';
import 'package:chatting_app_practice/api/apis.dart';
import 'package:chatting_app_practice/helper/diloguebox.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:chatting_app_practice/models/chat_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formkey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // this is for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          // AppBar
          appBar: AppBar(
            backgroundColor: Colors.blue,
            title: const Text("Profile Page"),
            // AppBar trailing icons
          ),

          // floating action button
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              // this is for progess indecator
              Dilogue.showprogrssbar(context);
              // this is when app is logout last sense is offline
              await APIs.updateActiveStatus(false);
              // signout for app
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  // for hiding progeess dilogue
                  Navigator.pop(context);
                  // this is for remove homeScreen when backbutton click
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(
              Icons.logout,
              size: 40,
              color: Colors.white,
            ),
            label: const Text(
              "Logout",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          // body
          body: SingleChildScrollView(
            // this form is validation
            child: Form(
              key: _formkey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
                child: Column(
                  children: [
                    // for adding some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.05,
                    ),
                    Stack(
                      children: [
                        _image != null
                            ? ClipRRect(
                                // this is for profile picture from gallery
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
                                child: Image.file(
                                  File(_image!),
                                  height: mq.height * .2,
                                  width: mq.width * .4,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                // this is for profile pictuer from server
                                borderRadius:
                                    BorderRadius.circular(mq.height * .1),
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
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                            elevation: 1,
                            onPressed: () {
                              _showbuttonsheet();
                            },
                            color: Colors.white,
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.blue,
                            ),
                          ),
                        )
                      ],
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
                          color: Colors.grey,
                          fontWeight: FontWeight.bold),
                    ),
                    // tis is adding some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.03,
                    ),
                    // this is for textfield
                    TextFormField(
                        initialValue: widget.user.name,
                        onSaved: (val) => APIs.me.name = val ?? '',
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : "Filled Fields ",
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: "eg. Harry",
                            label: const Text("name"),
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Colors.blue,
                            ))),
                    // tis is adding some space
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.03,
                    ),
                    // this is for textfield
                    TextFormField(
                        initialValue: widget.user.about,
                        onSaved: (val) => APIs.me.about = val ?? '',
                        validator: (value) => value != null && value.isNotEmpty
                            ? null
                            : "Filled Fields ",
                        decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            hintText: "eg. Calls only",
                            label: const Text("about"),
                            prefixIcon: const Icon(Icons.info_outline,
                                color: Colors.blue))),
                    SizedBox(
                      width: mq.width,
                      height: mq.height * 0.03,
                    ),
                    // this is for update butoon
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            minimumSize: Size(mq.width * .6, mq.height * .055)),
                        onPressed: () {
                          if (_formkey.currentState!.validate()) {
                            _formkey.currentState!.save();
                            APIs.updateuserinfo().then((value) {
                              Dilogue.showsnabar(
                                  context, "Profile Updated Successfully");
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Update ",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  void _showbuttonsheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .02, bottom: mq.height * .05),
            children: [
              const Text(
                " Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // for picking image from camera
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.camera, imageQuality: 70);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        // for updating in firebase
                        APIs.uppdateProfilePicture(File(_image!));
                        // for hiding bottom sheet
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    child: Image.asset("images/camera.png"),
                  ),
                  // for picking image from gallery
                  ElevatedButton(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      // Pick an image.
                      final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery, imageQuality: 70);
                      if (image != null) {
                        setState(() {
                          _image = image.path;
                        });
                        // for updating in firebase
                        APIs.uppdateProfilePicture(File(_image!));
                        // for hiding bottom sheet
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        fixedSize: Size(mq.width * .3, mq.height * .15)),
                    child: Image.asset("images/gallery.png"),
                  )
                ],
              )
            ],
          );
        });
  }
}
