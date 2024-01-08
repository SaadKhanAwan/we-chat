import 'dart:io';
import 'package:chatting_app_practice/Screen/home_screen.dart';
import 'package:chatting_app_practice/api/apis.dart';
import 'package:chatting_app_practice/helper/diloguebox.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isAimated = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        isAimated = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Welcome to We chat",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .15,
            // here this minus sign is for side and give value in point
            right: isAimated ? mq.width * .25 : -mq.width * .5,
            width: mq.width * .5,
            duration: const Duration(seconds: 1),
            child: Image.asset("images/chat.png"),
          ),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              onPressed: () {
                _handlegooglebutton();
              },
              icon: Image.asset(
                "images/search.png",
                height: mq.height * .05,
              ),
              label: const Text("Sign in with Google"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: const StadiumBorder(),
                  elevation: 1),
            ),
          )
        ],
      ),
    );
  }

  // handle google login click button
  _handlegooglebutton() {
    Dilogue.showprogrssbar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        // if user already exist
        if ((await APIs.userExist())) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const HomeScreen()));
        }
        // or else firest make a user and then shift to nextpage
        else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint('\n_signInWithGoogle:$e');
      // ignore: use_build_context_synchronously
      Dilogue.showsnabar(context, "Something went wrong Check Internet");
      return null;
    }
  }
}
