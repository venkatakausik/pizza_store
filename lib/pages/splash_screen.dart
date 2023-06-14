import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/pages/main_screen.dart';
import 'package:pizza_store/pages/welcome_screen.dart';
import 'package:pizza_store/services/user_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/small_text.dart';
import 'home/main_page.dart';
import 'landing_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id = 'splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  getUserData() async {
    UserServices _userServices = UserServices();
    _userServices.getUserById(user!.uid).then((result) {
      if (result.exists) {
        if (result['address'] != null) {
          updatePrefs(result);
        }
      }

      Navigator.pushReplacementNamed(context, LandingScreen.id);
    });
  }

  Future<void> updatePrefs(result) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('latitude', result['latitude']);
    prefs.setDouble('longitude', result['longitude']);
    prefs.setString('address', result['address']);
    prefs.setString('location', result['location']);
    Navigator.pushReplacementNamed(context, MainScreen.id);
  }

  @override
  void initState() {
    void requestPermission() async {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('User granted provisional permission');
      } else {
        print('User declined or has not accepted permission');
      }
    }

    requestPermission();
    Timer(Duration(seconds: 3), () {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          Navigator.pushReplacementNamed(context, WelcomeScreen.id);
        } else {
          // Navigator.pushReplacementNamed(context, LandingScreen.id);
          getUserData();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/images/cat-0.png"),
              SmallText(
                text: "Pizza Store",
                size: 15,
                weight: FontWeight.bold,
              )
            ],
          ),
        ),
      ),
    );
  }
}
