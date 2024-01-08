import 'package:chatting_app_practice/Screen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';

// Global object for accessing device screen size
late Size mq;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    await Firebase.initializeApp();
    _notificationChannel();
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.black),
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 1,
            titleTextStyle: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

_notificationChannel() async {
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing message Notifications',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    name: 'Chats',
  );
  debugPrint(result);
}
