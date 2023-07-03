import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/services/product_services.dart';

class CartProvider with ChangeNotifier {
  ProductService _productService = ProductService();
  double subTotal = 0.0;
  double saving = 0.0;
  int cartQty = 0;
  double distance = 0.0;
  String sellerUid = '';

  bool cod = true;
  late QuerySnapshot snapshot;
  List cartList = [];

  Future<double?> getCartTotal() async {
    var cartTotal = 0.0;
    List _newList = [];
    var sellerUid = '';
    QuerySnapshot snapshot = await _productService.cart
        .doc(_productService.user!.uid)
        .collection('products')
        .get();
    DocumentSnapshot _cartDoc =
        await _productService.cart.doc(_productService.user!.uid).get();
    if (snapshot == null) {
      return null;
    }
    snapshot.docs.forEach((doc) {
      if (!_newList.contains(doc.data())) {
        _newList.add(doc.data());
        this.cartList = _newList;
        notifyListeners();
      }
      cartTotal = cartTotal + doc['total'];
      saving = saving + (doc['comparedPrice'] - doc['price']) > 0
          ? (doc['comparedPrice'] - doc['price'])
          : 0;
    });

    if (_cartDoc.exists) {
      sellerUid = _cartDoc.get('seller');
    }

    this.subTotal = cartTotal;
    this.cartQty = snapshot.size;
    this.snapshot = snapshot;
    this.sellerUid = sellerUid;
    notifyListeners();
    return cartTotal;
  }

  getDistance(distance) {
    this.distance = distance;
    notifyListeners();
  }

  getPaymentMethod(index) {
    if (index == 0) {
      this.cod = false;
      notifyListeners();
    } else {
      this.cod = true;
      notifyListeners();
    }
  }
}
