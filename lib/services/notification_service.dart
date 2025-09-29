import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _notificationsEnabled = true;
  bool _dailyBriefingEnabled = true;
  bool _analysisRemindersEnabled = true;
  bool _insightUpdatesEnabled = true;

  // Getters
  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailyBriefingEnabled => _dailyBriefingEnabled;
  bool get analysisRemindersEnabled => _analysisRemindersEnabled;
  bool get insightUpdatesEnabled => _insightUpdatesEnabled;

  Future<void> init() async {
    // Initialize timezone
    tz.initializeTimeZones();

    // Initialize local notifications (available on all platforms)
    await _initLocalNotifications();

    // Initialize Firebase messaging only on mobile platforms
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      await _initFirebaseMessaging();
    }

    // Load preferences
    await _loadNotificationSettings();
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSInitSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iOSInitSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );
  }

  Future<void> _initFirebaseMessaging() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permissions
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _showNotification(
          message.notification?.title ?? 'Inner Five',
          message.notification?.body ?? '',
        );
      });
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }

  Future<void> _showNotification(String title, String body) async {
    if (!_notificationsEnabled) return;

    // Skip local notifications on web
    if (kIsWeb) {
      print('Notification: $title - $body');
      return;
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'innerfive_channel',
      'Inner Five Notifications',
      channelDescription: 'Notifications from Inner Five app',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  // Settings methods
  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _saveNotificationSettings();
    notifyListeners();
  }

  Future<void> setDailyBriefingEnabled(bool enabled) async {
    _dailyBriefingEnabled = enabled;
    await _saveNotificationSettings();
    if (enabled) {
      await _scheduleDailyBriefing();
    } else {
      await _cancelDailyBriefing();
    }
    notifyListeners();
  }

  Future<void> setAnalysisRemindersEnabled(bool enabled) async {
    _analysisRemindersEnabled = enabled;
    await _saveNotificationSettings();
    notifyListeners();
  }

  Future<void> setInsightUpdatesEnabled(bool enabled) async {
    _insightUpdatesEnabled = enabled;
    await _saveNotificationSettings();
    notifyListeners();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _dailyBriefingEnabled = prefs.getBool('daily_briefing_enabled') ?? true;
    _analysisRemindersEnabled =
        prefs.getBool('analysis_reminders_enabled') ?? true;
    _insightUpdatesEnabled = prefs.getBool('insight_updates_enabled') ?? true;
    notifyListeners();
  }

  Future<void> _saveNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', _notificationsEnabled);
    await prefs.setBool('daily_briefing_enabled', _dailyBriefingEnabled);
    await prefs.setBool(
      'analysis_reminders_enabled',
      _analysisRemindersEnabled,
    );
    await prefs.setBool('insight_updates_enabled', _insightUpdatesEnabled);
  }

  Future<void> _scheduleDailyBriefing() async {
    if (!_dailyBriefingEnabled) return;

    // Skip scheduling on web as local notifications are not supported
    if (kIsWeb) {
      print('Daily briefing scheduling is not supported on web platform');
      return;
    }

    // Cancel any existing scheduled notifications
    await _cancelAllScheduledNotifications();

    // Schedule morning fortune notification (9:00 AM)
    await _scheduleMorningFortune();

    // Schedule afternoon tarot notification (1:00 PM)
    await _scheduleAfternoonTarot();
  }

  Future<void> _scheduleMorningFortune() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      9, // 9:00 AM
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1, // ID for morning notification
      'Good Morning! ☀️',
      'Start your day with today\'s fortune and cosmic insights.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_fortune',
          'Morning Fortune',
          channelDescription: 'Daily morning fortune notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleAfternoonTarot() async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      13, // 1:00 PM
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2, // ID for afternoon notification
      'Tarot Time 🔮',
      'Discover what the cards reveal about your afternoon and evening.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'afternoon_tarot',
          'Afternoon Tarot',
          channelDescription: 'Daily afternoon tarot notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _cancelDailyBriefing() async {
    if (kIsWeb) return; // Skip on web
    await _cancelAllScheduledNotifications();
  }

  Future<void> _cancelAllScheduledNotifications() async {
    if (kIsWeb) return; // Skip on web
    await _flutterLocalNotificationsPlugin.cancel(1); // Morning fortune
    await _flutterLocalNotificationsPlugin.cancel(2); // Afternoon tarot
  }

  Future<void> showAnalysisCompleteNotification() async {
    if (!_notificationsEnabled || !_insightUpdatesEnabled) return;

    await _showNotification(
      'Analysis Complete!',
      'Your numerology analysis is ready. Tap to view your insights.',
    );
  }

  Future<void> showAnalysisReminder() async {
    if (!_notificationsEnabled || !_analysisRemindersEnabled) return;

    await _showNotification(
      'Time for your analysis!',
      'Discover new insights about yourself with Inner Five.',
    );
  }

  // Core notification methods for app functionality
  Future<void> showDailyFortuneNotification() async {
    if (!_notificationsEnabled || !_insightUpdatesEnabled) return;

    await _showNotification(
      'Daily Insights Ready! ✨',
      'Your tarot reading and eidos guidance are waiting for you.',
    );
  }

  Future<void> showNewAnalysisNotification() async {
    if (!_notificationsEnabled || !_insightUpdatesEnabled) return;

    await _showNotification(
      'New Analysis Available 🔮',
      'Your personalized numerology insights have been updated.',
    );
  }

  Future<void> showWeeklyInsightNotification() async {
    if (!_notificationsEnabled || !_insightUpdatesEnabled) return;

    await _showNotification(
      'Weekly Eidos Insight 🌟',
      'Discover new patterns in your cosmic energy this week.',
    );
  }

  // Custom time scheduling methods
  Future<void> scheduleCustomDailyNotifications({
    int morningHour = 9,
    int morningMinute = 0,
    int afternoonHour = 13,
    int afternoonMinute = 0,
  }) async {
    if (!_dailyBriefingEnabled || kIsWeb) return;

    await _cancelAllScheduledNotifications();
    await _scheduleCustomMorningFortune(morningHour, morningMinute);
    await _scheduleCustomAfternoonTarot(afternoonHour, afternoonMinute);
  }

  Future<void> _scheduleCustomMorningFortune(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1,
      'Good Morning! ☀️',
      'Start your day with today\'s fortune and cosmic insights.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_fortune',
          'Morning Fortune',
          channelDescription: 'Daily morning fortune notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> _scheduleCustomAfternoonTarot(int hour, int minute) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      2,
      'Tarot Time 🔮',
      'Discover what the cards reveal about your afternoon and evening.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'afternoon_tarot',
          'Afternoon Tarot',
          channelDescription: 'Daily afternoon tarot notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}
