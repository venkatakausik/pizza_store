import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/pages/home/main_page.dart';
import 'package:pizza_store/pages/map_screen.dart';
import 'package:pizza_store/providers/location_provider.dart';
import 'package:pizza_store/services/user_services.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  static const String id = 'landing-screen';

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  LocationProvider _locationProvider = LocationProvider();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SmallText(
                text: 'Delivery address not set',
                weight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SmallText(
                text:
                    'Please update your Delivery location for quick and seamless delivery',
                color: Colors.grey,
                weight: FontWeight.bold,
                maxLines: 2,
                overFlow: TextOverflow.clip,
              ),
            ),
            Container(
                width: 600,
                child: Image.asset(
                  "assets/images/city.png",
                  fit: BoxFit.fill,
                  // color: Colors.grey,
                )),
            _loading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _loading = true;
                      });

                      await _locationProvider.getCurrentPosition();
                     
                      if (_locationProvider.permissionAllowed == true) {
                        Navigator.pushReplacementNamed(context, MapScreen.id);
                      } else {
                        Future.delayed(Duration(seconds: 4), () {
                          if (_locationProvider.permissionAllowed == false) {
                            print("Permission not allowed");
                            setState(() {
                              _loading = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: SmallText(
                                    text:
                                        "Please allow permission to deliver for you")));
                          }
                        });
                      }
                      Navigator.pushReplacementNamed(context, MainScreen.id);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                    ),
                    child: SmallText(
                      text: 'Set your location',
                      color: Colors.white,
                    ))
          ],
        ),
      ),
    );
  }
}
