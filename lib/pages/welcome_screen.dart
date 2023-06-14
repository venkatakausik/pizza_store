import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/pages/map_screen.dart';
import 'package:pizza_store/providers/auth_provider.dart';
import 'package:pizza_store/providers/location_provider.dart';
import 'package:pizza_store/utils/dimensions.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';

import 'onboard_screen.dart';

class WelcomeScreen extends StatefulWidget {
  static const String id = 'welcome-screen';

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    bool _validPhoneNumber = false;
    var _phoneNumberController = TextEditingController();
    void showBottomSheet(BuildContext context) {
      showModalBottomSheet(
          context: context,
          builder: (context) =>
              StatefulBuilder(builder: (context, StateSetter myState) {
                return Container(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Visibility(
                            visible: auth.error == 'Invalid OTP' ? true : false,
                            child: Container(
                              child: Column(
                                children: [
                                  SmallText(
                                    text: auth.error,
                                    color: Colors.red,
                                  ),
                                  SizedBox(height: 3),
                                ],
                              ),
                            ),
                          ),
                          SmallText(
                            text: "Login",
                            size: 25,
                            weight: FontWeight.bold,
                          ),
                          SmallText(text: "Enter your phone number to proceed"),
                          SizedBox(
                            height: 20,
                          ),
                          TextField(
                            decoration: InputDecoration(
                                prefixText: '+01',
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor)),
                                labelText: '10 digit mobile number',
                                labelStyle: TextStyle(
                                    color: Theme.of(context).primaryColor)),
                            autofocus: true,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            controller: _phoneNumberController,
                            onChanged: (value) {
                              if (value.length == 10) {
                                myState(() {
                                  _validPhoneNumber = true;
                                });
                              } else {
                                myState(() {
                                  _validPhoneNumber = false;
                                });
                              }
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: AbsorbPointer(
                                  absorbing: _validPhoneNumber ? false : true,
                                  child: TextButton(
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        backgroundColor: _validPhoneNumber
                                            ? Theme.of(context).primaryColor
                                            : Colors.grey,
                                      ),
                                      onPressed: () {
                                        myState(() {
                                          auth.loading = true;
                                        });
                                        auth.loading = true;
                                        String number =
                                            '+91${_phoneNumberController.text}';
                                        auth
                                            .verifyPhone(
                                          context: context,
                                          number: number,
                                        )
                                            .then((value) {
                                          _phoneNumberController.clear();
                                          //  auth.loading = false;
                                        });
                                      },
                                      child: auth.loading
                                          ? CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            )
                                          : SmallText(
                                              text: _validPhoneNumber
                                                  ? "Continue"
                                                  : "Enter phone number")),
                                ),
                              ),
                            ],
                          ),
                        ]),
                  ),
                );
              })).whenComplete(() {
        setState(() {
          auth.loading = false;
          _phoneNumberController.clear();
        });
      });
    }

    final locationData = Provider.of<LocationProvider>(context, listen: false);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(child: OnBoardScreen()),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    SmallText(text: "Ready to order food from our store ?"),
                    SizedBox(
                      height: Dimensions.height20,
                    ),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).primaryColor),
                        onPressed: () async {
                          setState(() {
                            locationData.loading = true;
                          });
                          await locationData.getCurrentPosition();
                          if (locationData.permissionAllowed) {
                            Navigator.pushReplacementNamed(
                                context, MapScreen.id);
                            setState(() {
                              locationData.loading = false;
                            });
                          } else {
                            print("Permission not allowed");
                            setState(() {
                              locationData.loading = false;
                            });
                          }
                        },
                        child: locationData.loading
                            ? CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : SmallText(
                                text: "Set Delivery Location",
                                color: Colors.white,
                              )),
                    SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          auth.screen = 'Login';
                        });
                        showBottomSheet(context);
                      },
                      child: RichText(
                        text: TextSpan(
                            text: "Already a customer ? ",
                            style: TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                  text: 'Login',
                                  style: TextStyle(fontWeight: FontWeight.bold))
                            ]),
                      ),
                    ),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
