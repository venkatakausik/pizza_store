import 'package:flutter/material.dart';

class ProductProvider with ChangeNotifier {
  Map<String, dynamic> sizeToppingsDoc = {};

  getProductPriceForSize(docId, productSize, sizePrice) {
    sizeToppingsDoc[docId] = {
      "productSize": productSize,
      "sizePrice": sizePrice
    };
    notifyListeners();
  }

  getProductToppings(docId, topping) {
    List toppings = [];
    if(sizeToppingsDoc.containsKey(docId)){
    if ((sizeToppingsDoc[docId] as Map).containsKey("toppings")) {
      toppings = sizeToppingsDoc[docId]['toppings'];
    }
    toppings.add(topping);
    } else {
     sizeToppingsDoc[docId]= {}; 
    }
    sizeToppingsDoc[docId]['toppings'] = toppings;
    notifyListeners();
  }

  removeProductTopping(docId, topping) {
    if ((sizeToppingsDoc[docId] as Map).containsKey("toppings")) {
      (this.sizeToppingsDoc[docId]['toppings'] as List).forEach((toppingDoc) {
        if (toppingDoc['name'] == topping["name"]) {
          (this.sizeToppingsDoc[docId]['toppings'] as List).remove(toppingDoc);
          notifyListeners();
        }
      });
    }
  }

  reset() {
    this.sizeToppingsDoc = {};
    notifyListeners();
  }

  void removeProductFromMap(String docId) {
    if (sizeToppingsDoc.containsKey(docId)) {
      this.sizeToppingsDoc.remove(docId);
      notifyListeners();
    }
  }
}
