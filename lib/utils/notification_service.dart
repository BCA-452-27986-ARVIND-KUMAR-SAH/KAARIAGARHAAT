import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    try {
      // Request permission for iOS/Android 13+
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Get FCM Token and save it to Firestore
      // Wrapped in try-catch to prevent app crash if service is not available (e.g. emulators without Play Services)
      String? token;
      try {
        token = await _fcm.getToken();
      } catch (e) {
        debugPrint("FM Token Error: $e");
      }
      
      if (token != null) {
        _saveTokenToFirestore(token);
      }

      // Initialize Local Notifications for Foreground
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
      await _localNotifications.initialize(initSettings);

      // Handle Foreground Messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'order_status_channel',
                'Order Status Updates',
                importance: Importance.max,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });
    } catch (e) {
      debugPrint("Notification Service Initialization Error: $e");
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  // Logic to "send" a notification (simulated for now, usually done via Cloud Functions)
  Future<void> sendOrderStatusNotification(String userId, String status) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).collection('notifications').add({
      'title': 'Order Updated!',
      'body': 'Your order is now $status. Track it in your profile.',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }
}
