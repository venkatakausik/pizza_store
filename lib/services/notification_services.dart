import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class NotificationServices {
  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAA92OTcNQ:APA91bEPsCpg68h-67J9MBPV8cCYmmL9f7wWCdOQz7My9AXUyRbFXYAf0GhgwHo6I7hKm1Y-GSHRjFg8WVSwW3lmDnyrFb9R-Na9UEAdGFqj7FAY7lNyekbhkHwl0NLecRRbBm2pdQKg',
          },
          body: jsonEncode(<String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': body,
              'title': title,
            },
            'notification': <String, dynamic>{
              'body': body,
              'title': title,
              'android_channel_id': 'piiza_store_vendor'
            },
            'to': token
          }));
    } catch (e) {
      if (kDebugMode) {
        print("Error pushing notification");
      }
    }
  }
}
