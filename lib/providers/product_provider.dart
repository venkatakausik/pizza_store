import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  List toppings = [];
  late String productSize;
  double sizePrice = 0.0;

  getProductSize(productSize) {
    this.productSize = productSize;
    notifyListeners();
  }

  getProductPriceForSize(sizePrize) {
    this.sizePrice = sizePrize;
    notifyListeners();
  }

  getProductToppings(toppings) {
    this.toppings = toppings;
    notifyListeners();
  }
}
