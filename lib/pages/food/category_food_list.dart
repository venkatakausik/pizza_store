import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:pizza_store/pages/cart.dart';
import 'package:pizza_store/providers/store_provider.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../../widgets/add_to_cart_widget.dart';
import '../../widgets/product_card.dart';
import '../../widgets/small_text.dart';

class CategoryFoodList extends StatefulWidget {
  const CategoryFoodList({super.key});

  static const String id = "category-product-screen";

  @override
  State<CategoryFoodList> createState() => _CategoryFoodListState();
}

class _CategoryFoodListState extends State<CategoryFoodList> {
  _CategoryFoodListState();

  ProductService _productService = ProductService();

  @override
  Widget build(BuildContext context) {
    StoreProvider _storeData = Provider.of<StoreProvider>(context);
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Column(children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: Dimensions.height10),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: Dimensions.height30,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: Dimensions.width20,
                                  right: Dimensions.width10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SmallText(
                                      size: 20,
                                      overFlow: TextOverflow.clip,
                                      maxLines: 2,
                                      text: _storeData.selectedProductCategory),
                                  SizedBox(height: Dimensions.height10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            // height: Dimensions.listViewTextContentSize,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: Dimensions.width20,
                                  right: Dimensions.width10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SmallText(
                                      overFlow: TextOverflow.clip,
                                      maxLines: 2,
                                      weight: FontWeight.w300,
                                      text:
                                          "Transport your taste buds to the heart of `${_storeData.selectedProductCategory}` with these delicious recipes."),
                                  SizedBox(height: Dimensions.height10),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: Dimensions.width20, right: Dimensions.width20),
                      child: new DottedLine(
                        lineThickness: 0.8,
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height10,
                    ),
                    FutureBuilder(
                      future: _productService.product
                          .where("published", isEqualTo: true)
                          .where("category.mainCategory",
                              isEqualTo: _storeData.selectedProductCategory)
                          .get(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: SmallText(text: "Something went wrong.."),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.data!.docs.isEmpty) {
                          return Container();
                        }
                        return ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            // scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data?.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot document = snapshot.data
                                  ?.docs[index] as DocumentSnapshot<Object?>;
                              return ProductCard(document: document);
                            });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ])),
    );
  }
}
