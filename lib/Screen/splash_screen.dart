import 'package:chatting_app_practice/Screen/auth/login_screen.dart';
import 'package:chatting_app_practice/Screen/home_screen.dart';
import 'package:chatting_app_practice/api/apis.dart';
import 'package:chatting_app_practice/main.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (APIs.auth.currentUser != null) {
        debugPrint("\n user:  ${APIs.auth.currentUser}");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Welcome to We chat",
            style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
        children: [
          Positioned(
            top: mq.height * .15,
            // here this minus sign is for side and give value in point
            right: mq.width * .25,
            width: mq.width * .5,
            child: Image.asset("images/chat.png"),
          ),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: const Text(
                "Made by Saad ❤️",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ))
        ],
      ),
    );
  }
}
