import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/providers/product_provider.dart';
import 'package:pizza_store/widgets/non_veg_icon.dart';
import 'package:pizza_store/widgets/product_size_widget.dart';
import 'package:pizza_store/widgets/product_toppings_widget.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:pizza_store/widgets/veg_icon.dart';
import 'package:provider/provider.dart';

import '../utils/dimensions.dart';
import 'add_to_cart_widget.dart';

class ProductDetails extends StatefulWidget {
  final DocumentSnapshot document;
  const ProductDetails({super.key, required this.document});

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  var selectedSizeIndex = -1;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    return true; // return true if u want to stop back
  }

  @override
  Widget build(BuildContext context) {
    String offer = (100 *
            (widget.document['comparedPrice'] - widget.document['price']) /
            widget.document['comparedPrice'])
        .toStringAsFixed(0);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Wrap(children: [
            BackButton(
              onPressed: () => Navigator.pop(context, "Calback"),
            ),
            Container(
              decoration: new BoxDecoration(
                  borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(25.0),
                      topRight: const Radius.circular(25.0))),
              // height: Dimensions.popularFoodImgSize,
              // color: Colors.transparent,
              child: Expanded(
                child: Column(children: [
                  Image.network(
                    widget.document["productImage"],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 8.0, bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SmallText(
                            text: widget.document["productName"],
                            weight: FontWeight.w600,
                            size: 22,
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          Row(
                            children: [
                              SmallText(
                                  text: "\$" +
                                      widget.document["price"]
                                          .toStringAsFixed(0),
                                  weight: FontWeight.bold),
                              SizedBox(
                                width: Dimensions.width10,
                              ),
                              if (widget.document["comparedPrice"] > 0)
                                Text(
                                  "\$" +
                                      widget.document["comparedPrice"]
                                          .toStringAsFixed(0),
                                  style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10),
                                ),
                              SizedBox(
                                width: Dimensions.width10,
                              ),
                              if (!(widget.document['comparedPrice'] as double)
                                  .isNaN)
                                Container(
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10.0,
                                        right: 10,
                                        top: 3,
                                        bottom: 3),
                                    child: SmallText(
                                        text: "$offer% OFF",
                                        color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          Row(
                            children: [
                              widget.document['itemType'] == 'Veg'
                                  ? VegIcon()
                                  : NonVegIcon(),
                              SizedBox(
                                width: Dimensions.width5,
                              ),
                              SmallText(text: widget.document['itemType']),
                              SizedBox(
                                width: Dimensions.width5,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          if ((widget.document["itemSize"] as List).isNotEmpty)
                            ProductSizeWidget(
                                document: widget.document),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          if ((widget.document["toppings"] as List).isNotEmpty)
                            ProductToppingsWidget(
                                document: widget.document),
                          SizedBox(
                            height: Dimensions.height10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, top: 8.0),
                            child: Expanded(
                              child: Column(
                                children: [
                                  AddToCartWidget(
                                    document: widget.document,
                                    screen: 'bottomSheet',
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
