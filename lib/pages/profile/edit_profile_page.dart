import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:pizza_store/services/user_services.dart';
import 'package:pizza_store/utils/dimensions.dart';
import 'package:intl/intl.dart';

import '../../widgets/big_text.dart';
import '../../widgets/small_text.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  static const String id = "edit-profile-screen";

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String name = "";
  var nameTextController = TextEditingController();
  var emailTextController = TextEditingController();
  var mobileController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  User? user = FirebaseAuth.instance.currentUser;
  UserServices _userServices = UserServices();

  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //       context: context,
  //       initialDate: selectedDate,
  //       firstDate: DateTime(1950),
  //       lastDate: DateTime.now());
  //   if (picked != null && picked != selectedDate) {
  //     setState(() {
  //       selectedDate = picked;
  //     });
  //   }
  // }

  @override
  void initState() {
    _userServices.getUserById(user!.uid).then((value) {
      if (mounted) {
        var userDataMap = (value.data() as Map);
        setState(() {
          nameTextController.text = userDataMap.containsKey('name') && (userDataMap['name'] != null && userDataMap['name'] != '') ? value['name'] : '';
          emailTextController.text = userDataMap.containsKey('email') && (userDataMap['email'] != null && userDataMap['email'] != '') ? value['email'] : '';
          mobileController.text = user!.phoneNumber!;
        });
      }
    });
    super.initState();
  }

  updateProfile() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({
      'name': nameTextController.text,
      'email': emailTextController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: new Color.fromRGBO(211, 211, 211, 1),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 45, bottom: Dimensions.width15),
              padding: EdgeInsets.only(
                  left: Dimensions.width5, right: Dimensions.width20),
              child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                BackButton(
                  onPressed: () => Navigator.pop(context),
                ),
                BigText(
                  text: "Complete your profile",
                  weight: FontWeight.w500,
                )
              ]),
            ),
            Container(
              margin: EdgeInsets.only(
                  left: Dimensions.width20,
                  right: Dimensions.width20,
                  bottom: Dimensions.height10),
              child: Center(
                child: Container(
                  width: Dimensions.listViewImgSize / 1.5,
                  height: Dimensions.listViewImgSize / 1.5,
                  margin: EdgeInsets.only(
                      left: Dimensions.width10, right: Dimensions.width30),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius30),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/images/profile.png"))),
                ),
              ),
            ),
            Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: nameTextController,
                          decoration: InputDecoration(labelText: 'Name'),
                          keyboardType: TextInputType.name,
                          onFieldSubmitted: (value) {
                            setState(() {
                              name = value;
                            });
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter name";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: emailTextController,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              contentPadding: EdgeInsets.zero),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Enter email address";
                            }
                            return null;
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          enabled: false,
                          controller: mobileController,
                          decoration: InputDecoration(labelText: 'Mobile'),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      // TextFormField(
                      //   decoration: InputDecoration(labelText: 'Date of Birth'),
                      //   initialValue: "${selectedDate.toLocal()}".split(' ')[0],
                      //   onTap: () => _selectDate(context),
                      // ),
                      OutlinedButton(
                          style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              minimumSize: Size(100, 30),
                              elevation: 5,
                              shadowColor: Color(0xFFe8e8e8)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              EasyLoading.show(status: "Updating..");
                              updateProfile().then((value) {
                                EasyLoading.showSuccess("Updated succesfully");
                                Navigator.pop(context);
                              });
                            }
                            // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            //   backgroundColor: Color(0xFF00A300),
                            //   // duration: Duration(days: 365),
                            //   content: Container(
                            //     decoration: BoxDecoration(boxShadow: [
                            //       BoxShadow(
                            //           color: Color(0xFF00A300),
                            //           blurRadius: 5.0,
                            //           offset: Offset(0, 5)),
                            //     ]),
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Column(
                            //           crossAxisAlignment: CrossAxisAlignment.start,
                            //           children: [
                            //             Row(
                            //               children: [
                            //                 SmallText(
                            //                     color: Colors.white,
                            //                     text: "Profile updated !"),
                            //               ],
                            //             ),
                            //           ],
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            //   behavior: SnackBarBehavior.floating,
                            // ));
                          },
                          child: SmallText(
                            text: "UPDATE",
                            weight: FontWeight.bold,
                          ))
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
