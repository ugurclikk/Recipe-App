import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe/controller/storage_controller.dart';
import 'package:recipe/pages/signinPage.dart';

import 'controller/firebase_notification.dart';
import 'controller/local_notification_controller.dart';
import 'controller/recipecontrol.dart';
import 'pages/signupPage.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

void getToken() async {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();
  print('Token: $token');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   await NotificationHelper.initialize();
  await Firebase.initializeApp();
  await initMessaging();
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(HomePage());
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyLogin(),
    );
  }
}
