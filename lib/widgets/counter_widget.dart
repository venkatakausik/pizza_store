import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/providers/product_provider.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:pizza_store/utils/dimensions.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';

import 'add_to_cart_widget.dart';

class CounterWidget extends StatefulWidget {
  final DocumentSnapshot document;
  final int qty;
  final String docId;
  final String screen;
  CounterWidget(
      {required this.document,
      required this.qty,
      required this.docId,
      required this.screen});

  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  late int _qty;
  ProductService _productService = ProductService();
  bool _updating = false;
  bool _exists = true;

  @override
  void initState() {
    setState(() {
      _qty = widget.qty;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProductProvider _productData = Provider.of<ProductProvider>(context);
    return _exists
        ? Container(
            color: Colors.white,
            height: 56,
            // margin: EdgeInsets.only(
            //     left: Dimensions.width5, right: Dimensions.width5),
            child: Center(
                child: Padding(
              padding: EdgeInsets.all(8),
              child: FittedBox(
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _updating = true;
                        });
                        if (_qty == 1) {
                          _productService
                              .removeFromCart(widget.docId)
                              .then((value) {
                            if (mounted) {
                              setState(() {
                                _updating = false;
                                _exists = false;
                              });
                            }
                            _productData
                                .removeProductFromMap(widget.document.id);
                            _productService.checkCartData();
                          });
                        }

                        if (_qty > 1) {
                          setState(() {
                            _qty--;
                          });
                          var total = _qty * widget.document['price'];
                          _productService
                              .updateCartQty(widget.docId, _qty, total)
                              .then((value) {
                            setState(() {
                              _updating = false;
                            });
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.red)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                              _qty == 1 ? Icons.delete_outlined : Icons.remove),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 8.0, top: 8),
                      child: Container(
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: Colors.black)),
                        child: _updating
                            ? Container(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                      Theme.of(context).primaryColor),
                                ),
                              )
                            : SmallText(text: _qty.toString()),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _updating = true;
                          _qty++;
                        });
                        var total = _qty * widget.document['price'];
                        _productService
                            .updateCartQty(widget.docId, _qty, total)
                            .then((value) {
                          setState(() {
                            _updating = false;
                          });
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.green)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.add),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )),
          )
        : AddToCartWidget(
            document: widget.document,
            screen: widget.screen,
          );
  }
}
