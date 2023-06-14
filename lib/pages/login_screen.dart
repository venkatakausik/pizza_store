import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/pages/home/home_screen.dart';
import 'package:pizza_store/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../widgets/small_text.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String id = 'login-screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _validPhoneNumber = false;
  var _phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
        body: Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
              labelText: '10 digit mobile number',
            ),
            autofocus: true,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            controller: _phoneNumberController,
            onChanged: (value) {
              if (value.length == 10) {
                setState(() {
                  _validPhoneNumber = true;
                });
              } else {
                setState(() {
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
                        setState(() {
                          auth.loading = true;
                          auth.screen = 'MapScreen';
                          auth.latitude = locationData.latitude;
                          auth.longitude = locationData.longitude;
                          auth.address = locationData.selectedAddress.street! +
                              ", " +
                              locationData.selectedAddress.subLocality! +
                              ", " +
                              locationData.selectedAddress.locality! +
                              ", " +
                              locationData.selectedAddress.country! +
                              ", " +
                              locationData.selectedAddress.postalCode!;
                        });
                        String number = '+01${_phoneNumberController.text}';
                        auth
                            .verifyPhone(
                          context: context,
                          number: number,
                        )
                            .then((value) {
                          _phoneNumberController.clear();
                          setState(() {
                            auth.loading = false;
                          });
                          //
                        });
                      },
                      child: auth.loading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
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
    ));
  }
}
