import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/pages/home/main_page.dart';
import 'package:pizza_store/pages/landing_screen.dart';
import 'package:pizza_store/pages/main_screen.dart';
import 'package:pizza_store/pages/map_screen.dart';
import 'package:pizza_store/providers/location_provider.dart';
import 'package:pizza_store/services/user_services.dart';
import 'package:pizza_store/widgets/small_text.dart';

import '../pages/home/home_screen.dart';

class AuthProvider with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  String smsOtp = '';
  String verificationId = '';
  String error = '';
  bool loading = false;
  UserServices _userServices = UserServices();
  LocationProvider locationData = LocationProvider();
  String screen = '';
  double latitude = 0.0;
  double longitude = 0.0;
  late String address = '';
  late String location = '';
  late DocumentSnapshot snapshot;

  Future<void> verifyPhone({BuildContext? context, String? number}) async {
    this.loading = true;
    notifyListeners();
    final PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential credential) async {
      this.loading = false;
      notifyListeners();
      await _auth.signInWithCredential(credential);
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException e) {
      this.loading = false;
      print(e.code);
      this.error = e.toString();
      notifyListeners();
    };

    final PhoneCodeSent smsOtpSend = (String verId, int? resendToken) {
      this.verificationId = verId;

      smsOtpDialog(context!, number!);
    } as PhoneCodeSent;

    try {
      _auth.verifyPhoneNumber(
          phoneNumber: number,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: smsOtpSend,
          codeAutoRetrievalTimeout: (String verId) {
            this.verificationId = verId;
          });
    } catch (e) {
      this.error = e.toString();
      this.loading = false;
      notifyListeners();
      print(e);
    }
  }

  Future smsOtpDialog(BuildContext context, String number) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Column(
              children: [
                SmallText(text: "Verification Code"),
                SizedBox(height: 6),
                SmallText(text: "Enter 6 digit OTP"),
              ],
            ),
            content: Container(
              height: 85,
              child: TextField(
                textAlign: TextAlign.center,
                maxLength: 6,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  this.smsOtp = value;
                },
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    try {
                      PhoneAuthCredential phoneAuthCredential =
                          PhoneAuthProvider.credential(
                              verificationId: verificationId, smsCode: smsOtp);
                      final User user = (await _auth
                              .signInWithCredential(phoneAuthCredential))
                          .user!;
                      if (user != null) {
                        this.loading = false;
                        notifyListeners();
                        _userServices.getUserById(user.uid).then((snapshot) {
                          if (snapshot.exists) {
                            if (this.screen == 'Login') {
                              if (snapshot['address'] != null) {
                                Navigator.pushReplacementNamed(
                                    context, MainScreen.id);
                              }
                              Navigator.pushReplacementNamed(
                                  context, LandingScreen.id);
                            } else {
                              updateUser(
                                  id: user.uid, number: user.phoneNumber);
                              Navigator.pushReplacementNamed(
                                  context, MainScreen.id);
                            }
                          } else {
                            _createUser(id: user.uid, number: user.phoneNumber);
                            Navigator.pushReplacementNamed(
                                context, LandingScreen.id);
                          }
                        });
                      } else {
                        print('Login failed');
                      }

                      if (user != null) {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                            context, MainScreen.id);
                      } else {
                        print('Login Failed');
                      }
                    } catch (e) {
                      this.error = 'Invalid OTP';
                      notifyListeners();
                      print(e.toString());
                      Navigator.of(context).pop();
                    }
                  },
                  child: SmallText(text: "Done"))
            ],
          );
        }).whenComplete(() {
      this.loading = false;
      notifyListeners();
    });
  }

  void _createUser({String? id, String? number}) {
    _userServices.createUser({
      'id': id,
      'number': number,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'address': this.address,
      'location': this.location,
      'name' : null
    });
  }

  void updateUser({String? id, String? number}) {
    _userServices.updateUser({
      'id': id,
      'number': number,
      'latitude': this.latitude,
      'longitude': this.longitude,
      'address': this.address,
      'location': this.location
    });
    this.loading = false;
    notifyListeners();
  }

  getUserDetails() async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .get();
    if (result != null) {
      this.snapshot = result;
      notifyListeners();
    } else {
      this.snapshot = null as DocumentSnapshot<Object?>;
      notifyListeners();
    }

    return result;
  }
}
