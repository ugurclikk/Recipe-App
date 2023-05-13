import 'package:firebase_messaging/firebase_messaging.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<void> initMessaging() async {
  // Request permission for push notifications on iOS and Android
  NotificationSettings settings = await _firebaseMessaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  print('User granted permission: ${settings.authorizationStatus}');

  // Get the device token for this device
  String? token = await _firebaseMessaging.getToken();
  print('Device token: $token');

  // Handle incoming messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received message with data: ${message.data}');
    print('Received message with notification: ${message.notification}');
  });
}