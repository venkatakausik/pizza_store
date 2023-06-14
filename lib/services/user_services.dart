import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/models/user_model.dart';

class UserServices {
  String collection = 'users';
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // create new user
  Future<void> createUser(Map<String, dynamic> values) async {
    String id = values['id'];
    await _firestore.collection(collection).doc(id).set(values);
  }

  // update user data
  Future<void> updateUser(Map<String, dynamic> values) async {
    String id = values['id'];
    await _firestore.collection(collection).doc(id).update(values);
  }

  // get user data by id
  Future<DocumentSnapshot> getUserById(String id) async {
    var result = await _firestore.collection(collection).doc(id).get();
    return result;
  }

  Future<DocumentSnapshot> getShopById(String id) async {
    var result = await _firestore.collection('vendors').doc(id).get();
    return result;
  }

  Future<String> getToken() async {
    var deviceToken = '';
    await FirebaseMessaging.instance.getToken().then((value) {
      print("My token is $value");
      deviceToken = value!;
    });
    return deviceToken;
  }

  Future<void> updateUserDeviceToken({deviceToken}) async {
    User? user = FirebaseAuth.instance.currentUser;
    getUserById(user!.uid).then((userData) {
      return FirebaseFirestore.instance
          .collection('vendors')
          .doc(user.uid)
          .update({"deviceToken": deviceToken});
    });
  }
}
