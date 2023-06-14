import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  String? status = null;

  filterOrder(status) {
    this.status = status;
    notifyListeners();
  }
}
