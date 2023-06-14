import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:pizza_store/widgets/small_text.dart';

import '../providers/product_provider.dart';
import 'counter_widget.dart';

class AddToCartWidget extends StatefulWidget {
  final DocumentSnapshot document;
  AddToCartWidget({required this.document});

  @override
  State<AddToCartWidget> createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  ProductService _productServices = ProductService();
  User? user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  bool _exist = false;
  late int _qty = 1;
  late String _docId = '';

  @override
  void initState() {
    getCartData();
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document['productId'])
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        if (doc['productId'] == widget.document['productId']) {
          setState(() {
            _exist = true;
            _qty = doc['qty'];
            _docId = doc.id;
          });
        }
      });
    });
    super.initState();
  }

  getCartData() async {
    final snapshot =
        await _productServices.cart.doc(user!.uid).collection('products').get();
    if (snapshot.docs.length == 0) {
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ProductProvider _productData = ProductProvider();
    return _loading
        ? Container(
            height: 56,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            ),
          )
        : _exist
            ? CounterWidget(
                document: widget.document,
                qty: _qty,
                docId: _docId,
              )
            : OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(100, 30),
                    elevation: 5,
                    shadowColor: Color(0xFFe8e8e8)),
                onPressed: () {
                  if ((widget.document['itemSize'] as List).length > 0) {
                    if ((widget.document['toppings'] as List).length > 0) {
                      var _price = _productData.sizePrice;
                      for (int i = 0; i < _productData.toppings.length; i++) {
                        _price = _price + _productData.toppings[i]['price'];
                      }
                      _productServices.addToCart(
                          widget.document,
                          _productData.productSize,
                          _price,
                          _productData.toppings);
                    } else {
                      _productServices.addToCart(
                          widget.document,
                          _productData.productSize,
                          _productData.sizePrice,
                          null);
                    }
                  } else {
                    _productServices.addToCart(
                        widget.document, null, null, null);
                  }
                  setState(() {
                    _exist = true;
                  });
                },
                child: SmallText(
                  text: "ADD",
                  weight: FontWeight.bold,
                  color: Colors.green,
                ));
  }
}
