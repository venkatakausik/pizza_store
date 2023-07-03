import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/models/Product.dart';
import 'package:pizza_store/providers/product_provider.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';

class ProductSizeWidget extends StatefulWidget {
  final DocumentSnapshot document;
  const ProductSizeWidget({super.key, required this.document});

  @override
  State<ProductSizeWidget> createState() => _ProductSizeWidgetState();
}

class _ProductSizeWidgetState extends State<ProductSizeWidget> {
  var selectedSizeIndex = -1;
  User? user = FirebaseAuth.instance.currentUser;

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
          var sizeList = (widget.document["itemSize"] as List);
          for (var i = 0; i < sizeList.length; i++) {
            if (doc['itemSize'] == (sizeList[i] as Map)["name"]) {
              setState(() {
                selectedSizeIndex = i;
              });
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 80,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: (widget.document["itemSize"] as List).length,
            itemBuilder: (BuildContext context, int position) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedSizeIndex = position;
                  });
                  productData.getProductPriceForSize(
                      widget.document.id,
                      (widget.document["itemSize"] as List)[position]["name"],
                      (widget.document["itemSize"] as List)[position]["price"]
                          .toString());
                },
                child: Card(
                  shape: (selectedSizeIndex == position)
                      ? RoundedRectangleBorder(
                          side: BorderSide(color: Colors.green))
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        SmallText(
                            text: (widget.document["itemSize"]
                                as List)[position]["name"]),
                        SmallText(
                            size: 12,
                            color: Colors.grey,
                            text: "\$" +
                                (widget.document["itemSize"] as List)[position]
                                        ["price"]
                                    .toString()),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
