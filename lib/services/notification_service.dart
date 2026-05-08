import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  
  static const String _channelId = 'vardchat_messages';
  static const String _channelName = 'Messages';
  
  Future<bool> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotification,
      );
      
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      return await _plugin.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      ) ?? false;
    } catch (e) {
      return false;
    }
  }
  
  static void _onBackgroundNotification(NotificationResponse response) {
    // Handle background notification tap
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to chat
  }
  
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _plugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e) {
      // Silently fail
    }
  }
  
  Future<void> clearAllNotifications() async {
    await _plugin.cancelAll();
  }
}
