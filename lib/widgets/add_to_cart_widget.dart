import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:pizza_store/widgets/product_details.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:pizza_store/widgets/veg_icon.dart';
import 'package:provider/provider.dart';
import 'package:select_card/select_card.dart';

import '../providers/product_provider.dart';
import '../utils/dimensions.dart';
import 'counter_widget.dart';
import 'non_veg_icon.dart';

class AddToCartWidget extends StatefulWidget {
  final DocumentSnapshot document;
  final String screen;
  AddToCartWidget({required this.document, required this.screen});

  @override
  State<AddToCartWidget> createState() => _AddToCartWidgetState();
}

class _AddToCartWidgetState extends State<AddToCartWidget> {
  ProductService _productServices = ProductService();
  User? user = FirebaseAuth.instance.currentUser;
  bool _loading = true;
  bool _exist = false;
  int _qty = 1;
  String _docId = '';

  alertDialog({context, title, content}) {
    return showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: SmallText(text: title),
            content: Expanded(
                child: SmallText(
              text: content,
              maxLines: 3,
              overFlow: TextOverflow.clip,
            )),
            actions: [
              CupertinoDialogAction(
                child: SmallText(text: 'OK'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

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
    ProductProvider _productData = Provider.of<ProductProvider>(context);
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
                screen: widget.screen,
              )
            : OutlinedButton(
                style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: Size(100, 30),
                    elevation: 5,
                    shadowColor: Color(0xFFe8e8e8)),
                onPressed: () {
                  if ((widget.document['itemSize'] as List).length > 0) {
                    if (_productData.sizeToppingsDoc
                        .containsKey(widget.document.id)) {
                      if (!(_productData.sizeToppingsDoc[widget.document.id]
                              as Map)
                          .containsKey('productSize')) {
                        if (widget.screen == 'productCard') {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductDetails(
                                      document: widget.document)));
                        } else if (widget.screen == 'bottomSheet') {
                          alertDialog(
                              context: context,
                              title: 'Size selection',
                              content:
                                  'Please choose the size of ${widget.document["category"]["mainCategory"]}');
                        }
                      } else {
                        if ((widget.document['toppings'] as List).length > 0) {
                          double _price = double.parse(
                              _productData.sizeToppingsDoc[widget.document.id]
                                  ['sizePrice']);
                          if ((_productData.sizeToppingsDoc[widget.document.id]
                                  as Map)
                              .containsKey('toppings')) {
                            for (int i = 0;
                                i <
                                    (_productData.sizeToppingsDoc[widget
                                            .document.id]["toppings"] as List)
                                        .length;
                                i++) {
                              _price = _price +
                                  _productData
                                          .sizeToppingsDoc[widget.document.id]
                                      ["toppings"][i]['price'];
                            }
                            _productServices
                                .addToCart(
                                    widget.document,
                                    _productData
                                            .sizeToppingsDoc[widget.document.id]
                                        ['productSize'],
                                    _price,
                                    (_productData
                                            .sizeToppingsDoc[widget.document.id]
                                        ["toppings"] as List))
                                .then((value) {
                              initState();
                              setState(() {
                                _exist = true;
                              });
                            });
                          } else {
                            _productServices
                                .addToCart(
                                    widget.document,
                                    _productData
                                            .sizeToppingsDoc[widget.document.id]
                                        ['productSize'],
                                    _price,
                                    null)
                                .then((value) {
                              initState();
                              setState(() {
                                _exist = true;
                              });
                            });
                          }
                        } else {
                          _productServices
                              .addToCart(
                                  widget.document,
                                  _productData
                                          .sizeToppingsDoc[widget.document.id]
                                      ['productSize'],
                                  _productData
                                          .sizeToppingsDoc[widget.document.id]
                                      ['sizePrice'],
                                  null)
                              .then((value) {
                            initState();
                            setState(() {
                              _exist = true;
                            });
                          });
                        }
                        // _productData.reset();
                      }
                    } else {
                      if (widget.screen == 'productCard') {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetails(document: widget.document)));
                      } else if (widget.screen == 'bottomSheet') {
                        alertDialog(
                            context: context,
                            title: 'Size selection',
                            content:
                                'Please choose the size of ${widget.document["category"]["mainCategory"]}');
                      }
                    }
                  } else {
                    _productServices
                        .addToCart(widget.document, null, null, null)
                        .then((value) {
                      initState();
                      setState(() {
                        _exist = true;
                      });
                    });
                  }
                },
                child: SmallText(
                  text: "ADD",
                  weight: FontWeight.bold,
                  color: Colors.green,
                ));
  }
}
