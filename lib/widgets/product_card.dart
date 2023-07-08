import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/widgets/counter_widget.dart';
import 'package:pizza_store/widgets/product_details.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:pizza_store/widgets/veg_icon.dart';
import '../utils/dimensions.dart';
import 'add_to_cart_widget.dart';
import 'non_veg_icon.dart';

class ProductCard extends StatefulWidget {
  final DocumentSnapshot document;
  const ProductCard({super.key, required this.document});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Widget? _addToCartWidget;
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    setState(() {
      _addToCartWidget = AddToCartWidget(
        document: widget.document,
        screen: 'productCard',
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: Dimensions.width20,
          right: Dimensions.width20,
          bottom: Dimensions.height10),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ProductDetails(document: widget.document))).then((value) {
            var _qty = 0;
            var docId = "";
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
                    _qty = doc['qty'];
                    docId = doc.id;
                  });
                }
              });
            });

            _addToCartWidget = CounterWidget(
                document: widget.document,
                qty: _qty,
                docId: docId,
                screen: "productCard");
            setState(() {});
          });
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height:
                      Dimensions.listViewTextContentSize + Dimensions.height10,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: Dimensions.width10, right: Dimensions.width10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SmallText(
                            size: 15,
                            overFlow: TextOverflow.clip,
                            maxLines: 2,
                            text: widget.document["productName"]),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            SmallText(
                                text: "\$" +
                                    widget.document["price"].toStringAsFixed(0),
                                weight: FontWeight.bold),
                          ],
                        ),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            widget.document['itemType'] == 'Veg'
                                ? VegIcon()
                                : NonVegIcon(),
                            SizedBox(
                              width: Dimensions.width5,
                            ),
                            SmallText(text: widget.document['itemType']),
                            // SmallText(text: widget.document["itemSize"]),
                            SizedBox(
                              width: Dimensions.width10,
                            ),
                            Icon(
                              Icons.timer_outlined,
                              size: 15,
                              color: Colors.deepOrangeAccent,
                            ),
                            SizedBox(
                              width: Dimensions.width5,
                            ),
                            SmallText(
                                text:
                                    '${widget.document["cookingTime"].toString()} min'),
                          ],
                        ),
                        SizedBox(height: Dimensions.height10),
                        InkWell(
                            onTap: () {
                              Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ProductDetails(
                                              document: widget.document)))
                                  .then((value) {
                                var _qty = 0;
                                var docId = "";
                                FirebaseFirestore.instance
                                    .collection('cart')
                                    .doc(user!.uid)
                                    .collection('products')
                                    .where('productId',
                                        isEqualTo: widget.document['productId'])
                                    .get()
                                    .then((QuerySnapshot snapshot) {
                                  snapshot.docs.forEach((doc) {
                                    if (doc['productId'] ==
                                        widget.document['productId']) {
                                      setState(() {
                                        _qty = doc['qty'];
                                        docId = doc.id;
                                      });
                                    }
                                  });
                                });

                                
                                setState(() {_addToCartWidget = CounterWidget(
                                    document: widget.document,
                                    qty: _qty,
                                    docId: docId,
                                    screen: "productCard");});
                              });
                            },
                            child: SmallText(
                              text: "More Details",
                              weight: FontWeight.normal,
                              color: Colors.black87,
                            )),
                        // new InkWell(
                        //     onTap: () => showModalBottomSheet<dynamic>(
                        //         context: context,
                        //         isScrollControlled: true,
                        //         builder: (context) => buildBottomSheet(
                        //             widget.document, _productData)),
                        //     child: SmallText(
                        //       text: "More Details",
                        //       weight: FontWeight.normal,
                        //       color: Colors.black87,
                        //     )),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: Dimensions.width5,
                ),
                // image section

                Column(
                  children: [
                    Container(
                      width: Dimensions.listViewImgSize,
                      height: Dimensions.listViewImgSize,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius20),
                          color: Colors.white38,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0xFFe8e8e8),
                                blurRadius: 5.0,
                                offset: Offset(0, 5)),
                          ],
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  widget.document["productImage"]))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        left: 8.0,
                        top: 8.0,
                      ),
                      child: Column(
                        children: [_addToCartWidget!],
                      ),
                    )
                  ],
                ),
              ],
            ),
            Container(padding: EdgeInsets.only(top: 10), child: Divider())
          ],
        ),
      ),
    );
  }
}
