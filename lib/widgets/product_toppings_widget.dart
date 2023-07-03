import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pizza_store/models/Product.dart';
import 'package:pizza_store/providers/product_provider.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';

import '../utils/dimensions.dart';

class ProductToppingsWidget extends StatefulWidget {
  final DocumentSnapshot document;
  const ProductToppingsWidget({super.key, required this.document});

  @override
  State<ProductToppingsWidget> createState() => _ProductToppingsWidgetState();
}

class _ProductToppingsWidgetState extends State<ProductToppingsWidget> {
  User? user = FirebaseAuth.instance.currentUser;
  List _toppingsSelected = [];

  @override
  void initState() {
    FirebaseFirestore.instance
        .collection('cart')
        .doc(user!.uid)
        .collection('products')
        .where('productId', isEqualTo: widget.document['productId'])
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        if (doc['productId'] == widget.document['productId']) {
          var toppingsList = (widget.document["toppings"] as List);
          var productToppingsInCart = (doc["toppings"] as List);
          for (var i = 0; i < toppingsList.length; i++) {
            for (var j = 0; j < productToppingsInCart.length; j++) {
              if (productToppingsInCart[j]["name"] ==
                  (toppingsList[i] as Map)["name"]) {
                setState(() {
                  _toppingsSelected.add(productToppingsInCart[i]);
                });
              }
            }
          }
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProductProvider productData = Provider.of<ProductProvider>(context);
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SmallText(
              text: "Toppings",
              size: 15,
            ),
          ),
          SizedBox(
            height: Dimensions.height10,
          ),
          Card(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: (widget.document["toppings"] as List).length,
              itemBuilder: (context, index) {
                bool isToppingAdded = false;
                bool isExtraToppingAdded = false;
                bool isRegularToppingAdded = false;
                if (_toppingsSelected.isNotEmpty) {
                  var toppingsNames = _toppingsSelected.map((topping) {
                    return (topping as Map)["name"];
                  });
                  isToppingAdded = toppingsNames
                      .contains(widget.document["toppings"][index]['name']);
                  if (isToppingAdded) {
                    _toppingsSelected.forEach((topping) {
                      var toppingMap = (topping as Map);
                      if (widget.document["toppings"][index]['name'] ==
                          toppingMap["name"]) {
                        isExtraToppingAdded = toppingMap["type"] == "extra";
                        isRegularToppingAdded = toppingMap["type"] == "regular";
                      }
                    });
                  }
                } else {
                  if (productData.sizeToppingsDoc
                      .containsKey(widget.document.id)) {
                    if ((productData.sizeToppingsDoc[widget.document.id] as Map)
                        .containsKey("toppings")) {
                      _toppingsSelected =
                          ((productData.sizeToppingsDoc[widget.document.id]
                              as Map)["toppings"] as List);
                      var toppingsNames = _toppingsSelected.map((topping) {
                        return (topping as Map)["name"];
                      });
                      isToppingAdded = toppingsNames
                          .contains(widget.document["toppings"][index]['name']);
                      if (isToppingAdded) {
                        _toppingsSelected.forEach((topping) {
                          var toppingMap = (topping as Map);
                          if (widget.document["toppings"][index]['name'] ==
                              toppingMap["name"]) {
                            isExtraToppingAdded = toppingMap["type"] == "extra";
                            isRegularToppingAdded =
                                toppingMap["type"] == "regular";
                          }
                        });
                      }
                    }
                  }
                }
                return Slidable(
                  // Specify a key if the Slidable is dismissible.
                  key: const ValueKey(0),

                  // The start action pane is the one at the left or the top side.
                  startActionPane: ActionPane(
                    // A motion is a widget used to control how the pane animates.
                    motion: const ScrollMotion(),

                    // A pane can dismiss the Slidable.
                    // dismissible:
                    //     DismissiblePane(onDismissed: () {}),

                    // All actions are defined in the children parameter.
                    children: [
                      // A SlidableAction can have an icon and/or a label.
                      SlidableAction(
                        onPressed: (context) {
                          if (!isToppingAdded) {
                            var topping = {
                              "type": "extra",
                              'name': widget.document["toppings"][index]
                                  ['name'],
                              "price": widget.document["toppings"][index]
                                  ['price']['extra']
                            };
                            productData.getProductToppings(
                                widget.document.id, topping);
                            setState(() {
                              isExtraToppingAdded = true;
                              isToppingAdded = true;
                            });
                          }
                        },

                        backgroundColor: isToppingAdded
                            ? isExtraToppingAdded
                                ? Theme.of(context).primaryColor
                                : Colors.grey
                            : Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        // icon: Icons.restaurant_outlined,
                        label:
                            'Extra\n\$${widget.document["toppings"][index]['price']['extra']}',
                      ),
                      SlidableAction(
                        onPressed: (context) {
                          if (!isToppingAdded) {
                            var topping = {
                              "type": "regular",
                              'name': widget.document["toppings"][index]
                                  ['name'],
                              "price": widget.document["toppings"][index]
                                  ['price']['regular']
                            };
                            productData.getProductToppings(
                                widget.document.id, topping);
                            setState(() {
                              isRegularToppingAdded = true;
                              isToppingAdded = true;
                            });
                          }
                        },
                        backgroundColor: isToppingAdded
                            ? isRegularToppingAdded
                                ? Color(0xFF21B7CA)
                                : Colors.grey
                            : Color(0xFF21B7CA),
                        foregroundColor: Colors.white,
                        // icon: Icons.share,
                        label:
                            'Regular\n\$${widget.document["toppings"][index]['price']['regular']}',
                      ),
                    ],
                  ),

                  // The end action pane is the one at the right or the bottom side.
                  endActionPane: ActionPane(
                    motion: ScrollMotion(),
                    children: [
                      SlidableAction(
                        // An action can be bigger than the others.
                        flex: 2,
                        onPressed: (context) {
                          if (isToppingAdded) {
                            productData.removeProductTopping(widget.document.id,
                                widget.document["toppings"][index]);
                            setState(() {
                              isToppingAdded = false;
                            });
                          }
                        },
                        backgroundColor:
                            !isToppingAdded ? Colors.grey : Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete_outline,
                        label: 'Remove',
                      ),
                    ],
                  ),

                  // The child of the Slidable is what the user sees when the
                  // component is not dragged.
                  child: ListTile(
                      title: SmallText(
                          text:
                              "${widget.document["toppings"][index]['name']}")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
