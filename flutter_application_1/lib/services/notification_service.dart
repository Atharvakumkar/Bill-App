import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import '../main.dart'; 

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  GlobalKey<NavigatorState>? _navigatorKey;

  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    _navigatorKey = navigatorKey;
    tz.initializeTimeZones();
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (e) {
      // Fallback
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload == 'pending_payments') {
           _navigatorKey?.currentState?.pushNamed('/pending_payments');
        }
      },
    );
  }

  Future<void> requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> updateDailyReminder() async {
    await flutterLocalNotificationsPlugin.cancelAll();

    bool enabled = storageService.box.get('notifications_enabled', defaultValue: true);
    if (!enabled) return;

    int hour = storageService.box.get('notification_hour', defaultValue: 9);
    int minute = storageService.box.get('notification_minute', defaultValue: 0);

    final bills = storageService.getBills();
    final unpaidBills = bills.where((b) => b.paymentStatus == 'Unpaid').toList();

    if (unpaidBills.isEmpty) return;

    final customers = unpaidBills.map((b) => b.customer.name).toSet().take(5).join(', ');
    final suffix = unpaidBills.length > 5 ? ' and more...' : '';
    final body = 'Unpaid bills from: $customers$suffix';

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
            'unpaid_bills_channel', 'Unpaid Bills',
            channelDescription: 'Daily reminder for unpaid bills',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
            
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: 'Pending Payments Reminder',
        body: body,
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'pending_payments');
  }


}

final notificationService = NotificationService();
