import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:pizza_store/widgets/veg_icon.dart';
import 'package:provider/provider.dart';
import 'package:select_card/select_card.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../providers/product_provider.dart';
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
  var sizeSelectionIndex = 0;
  List multipleSelected = [];
  var selectedIndices = [];
  Widget buildBottomSheet(
      DocumentSnapshot<Object?> document, ProductProvider productData) {
    String offer = (100 *
            (document['comparedPrice'] - document['price']) /
            document['comparedPrice'])
        .toStringAsFixed(0);
    return Wrap(children: [
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
              document["productImage"],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmallText(
                      text: document["productName"],
                      weight: FontWeight.w600,
                      size: 22,
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Row(
                      children: [
                        SmallText(
                            text: "\$" + document["price"].toStringAsFixed(0),
                            weight: FontWeight.bold),
                        SizedBox(
                          width: Dimensions.width10,
                        ),
                        if (document["comparedPrice"] > 0)
                          Text(
                            "\$" + document["comparedPrice"].toStringAsFixed(0),
                            style: TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 10),
                          ),
                        SizedBox(
                          width: Dimensions.width10,
                        ),
                        if (!(document['comparedPrice'] as double).isNaN)
                          Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10))),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10, top: 3, bottom: 3),
                              child: SmallText(
                                  text: "$offer% OFF", color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Row(
                      children: [
                        document['itemType'] == 'Veg'
                            ? VegIcon()
                            : NonVegIcon(),
                        SizedBox(
                          width: Dimensions.width5,
                        ),
                        SmallText(text: document['itemType']),
                        SizedBox(
                          width: Dimensions.width5,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    if ((document["itemSize"] as List).isNotEmpty)
                      Card(
                        child: SelectGroupCard(context,
                            cardSelectedColor: Theme.of(context).primaryColor,
                            titles: (document["itemSize"] as List)
                                .map((e) => e["name"].toString())
                                .toList(),
                            cardBackgroundColor: Colors.grey.shade100,
                            contents: (document["itemSize"] as List)
                                .map((e) => "\$" + e["price"].toString())
                                .toList(),
                            ids: (document["itemSize"] as List)
                                .map((e) => e["price"].toString())
                                .toList(), onTap: (title, id) {
                          setState(() {
                            productData.getProductSize(title);
                            productData.getProductPriceForSize(id);
                          });
                        }),
                      ),
                    //   Card(
                    //     child: Padding(
                    //       padding: const EdgeInsets.all(8.0),
                    //       child: ToggleSwitch(
                    //         minHeight: 60,
                    //         initialLabelIndex: 0,
                    //         activeFgColor: Colors.white,
                    //         inactiveBgColor: Colors.grey,
                    //         inactiveFgColor: Colors.white,
                    //         totalSwitches:
                    //             (document['itemSize'] as List).length,
                    //         labels: (document['itemSize'] as List)
                    //             .map((e) =>
                    //                 e["name"].toString() +
                    //                 "\n\$" +
                    //                 e["price"].toString())
                    //             .toList(),
                    //         onToggle: (index) {
                    //           setState(() {
                    //             productData.getProductSize(
                    //                 document['itemSize'][index]["name"]);
                    //             productData.getProductPriceForSize(
                    //                 document['itemSize'][index]['price']);
                    //           });
                    //         },
                    //       ),
                    //     ),
                    //   ),
                    if ((document["toppings"] as List).isNotEmpty)
                      Container(
                        height: 100,
                        child: Expanded(child: SmallText(text: "Toppings")),
                      ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, top: 8.0),
                      child: Column(
                        children: [AddToCartWidget(document: document)],
                      ),
                    )
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    var _productData = Provider.of<ProductProvider>(context);
    return Container(
      margin: EdgeInsets.only(
          left: Dimensions.width20,
          right: Dimensions.width20,
          bottom: Dimensions.height10),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
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
                        new InkWell(
                            onTap: () => showModalBottomSheet<dynamic>(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) => buildBottomSheet(
                                    widget.document, _productData)),
                            child: SmallText(
                              text: "More Details",
                              weight: FontWeight.normal,
                              color: Colors.black87,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: Dimensions.width5,
              ),
              // image section

              Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomCenter,
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
                      // const Positioned(
                      //     top: 10,
                      //     right: 10,
                      //     child: Icon(
                      //       Icons.favorite_border_outlined,
                      //       color: Colors.white,
                      //     )),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 8.0, top: 8.0, right: Dimensions.width20),
                        child: Column(
                          children: [
                            AddToCartWidget(document: widget.document)
                          ],
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
          Container(padding: EdgeInsets.only(top: 10), child: Divider())
        ],
      ),
    );
  }
}
