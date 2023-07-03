import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/providers/store_provider.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:pizza_store/utils/dimensions.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';

import '../../models/Product.dart';
import '../../widgets/add_to_cart_widget.dart';
import '../../widgets/big_text.dart';
import '../../widgets/image_text.dart';
import '../../widgets/non_veg_icon.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_details.dart';
import '../../widgets/veg_icon.dart';
import '../search_page.dart';

class FoodPageBody extends StatefulWidget {
  const FoodPageBody({super.key});

  @override
  State<FoodPageBody> createState() => _FoodPageBodyState();
}

class _FoodPageBodyState extends State<FoodPageBody> {
  PageController pageController = PageController(viewportFraction: 0.85);
  var _currPageValue = 0.0;
  final double _scaleFactor = 0.8;
  final double _height = Dimensions.pageViewContainer;
  final ProductService _productServices = ProductService();
  static List<Product> products = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('products')
        .where("published", isEqualTo: true)
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        setState(() {
          products.add(Product(
              productName: doc.get('productName'),
              category: doc['category']['mainCategory'],
              // itemSize: doc['itemSize'],
              sku: doc['sku'],
              productId: doc['productId'],
              image: doc['productImage'],
              price: doc['price'],
              comparedPrice: doc['comparedPrice'],
              document: doc));
        });
      });
    });
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    StoreProvider _storeData = Provider.of<StoreProvider>(context);

    // String getDistance(location) {
    //   var distance = Geolocator.distanceBetween(_storeData.userLatitude,
    //       _storeData.userLongitude, location.latitude, location.longitude);
    //   var distanceInKm = distance / 1000;
    //   return distanceInKm.toStringAsFixed(2);
    // }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: Dimensions.height10, bottom: Dimensions.width15),
          padding: EdgeInsets.only(
              left: Dimensions.width20, right: Dimensions.width20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.radius20),
              boxShadow: [
                BoxShadow(
                    color: Color(0xFFe8e8e8),
                    blurRadius: 5.0,
                    offset: Offset(0, 5)),
              ]),
          child: TextField(
            onTap: () {
              // pushNewScreenWithRouteSettings(
              //   context,
              //   settings: RouteSettings(name: SearchScreen.id),
              //   screen: SearchScreen(),
              //   withNavBar: false,
              //   pageTransitionAnimation: PageTransitionAnimation.cupertino,
              // );
              showSearch(
                context: context,
                delegate: SearchPage<Product>(
                    items: products,
                    searchLabel: "Search \"pizza\"",
                    searchStyle: TextStyle(color: Colors.black),
                    suggestion: Center(
                      child: SmallText(
                          text: 'Filter food by name, category or price '),
                    ),
                    barTheme: ThemeData(
                        hintColor: Colors.black,
                        appBarTheme: AppBarTheme(color: Colors.white),
                        inputDecorationTheme: InputDecorationTheme(
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor)),
                        )),
                    failure: Center(
                      child: SmallText(text: 'No product found :('),
                    ),
                    filter: (product) => [
                          product.productName,
                          product.category,
                          product.price.toString(),
                        ],
                    builder: (product) =>
                        ProductCard(document: product.document)),
              );
            },
            decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                hintText: "Search \"pizza\"",
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.deepOrangeAccent),
          ),
        ),
        SizedBox(
          height: Dimensions.height20,
        ),
        // slider section
        Container(
          height: Dimensions.pageView,
          child: StreamBuilder<QuerySnapshot>(
            stream: _productServices.getSliderProducts(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return CircularProgressIndicator();
              // List shopDistance = [];
              // for (int i = 0; i <= snapshot.data!.docs.length; i++) {
              //   var distance = Geolocator.distanceBetween(
              //       _storeData.userLatitude,
              //       _storeData.userLongitude,
              //       snapshot.data!.docs[i]['location'].latitude,
              //       snapshot.data!.docs[i]['location'].longitude);
              //   var distanceInKm = distance / 1000;
              //   shopDistance.add(distanceInKm);
              // }
              return PageView.builder(
                  controller: pageController,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, position) {
                    DocumentSnapshot document = snapshot.data?.docs[position]
                        as DocumentSnapshot<Object?>;
                    return _buildPageItem(position, document);
                  });
            },
          ),
        ),
        // dots
        new DotsIndicator(
          dotsCount: 5,
          position: _currPageValue,
          decorator: DotsDecorator(
            activeColor: Colors.deepOrangeAccent,
            size: const Size.square(9.0),
            activeSize: const Size(18.0, 9.0),
            activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
          ),
        ),

        SizedBox(
          height: Dimensions.height30,
        ),

        Container(
          margin: EdgeInsets.only(
              left: Dimensions.width20, right: Dimensions.width20),
          child: Container(
              child: Row(children: [
            Expanded(child: Divider(thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SmallText(
                text: "WHAT'S ON YOUR MIND?",
                spacing: 2,
              ),
            ),
            Expanded(
                child: Divider(
              thickness: 1.5,
            )),
          ])),
        ),
        // categories
        Expanded(
            flex: 0,
            child: Container(
              height: 120,
              child: CategoryImageText(),
            )),

        // popular text
        SizedBox(
          height: Dimensions.height10,
        ),
        Container(
          margin: EdgeInsets.only(
              left: Dimensions.width20, right: Dimensions.width20),
          child: Container(
              child: Row(children: [
            Expanded(child: Divider(thickness: 1.5)),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: SmallText(
                text: "POPULAR",
                spacing: 2,
              ),
            ),
            Expanded(child: Divider(thickness: 1.5)),
          ])),
        ),
        SizedBox(
          height: Dimensions.height10,
        ),
        // list of food and images
        StreamBuilder<QuerySnapshot>(
          stream: _productServices.getPopularProducts(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError)
              return Center(
                child: SmallText(text: "Something went wrong.."),
              );
            if (!snapshot.hasData) {
              return Container();
            }
            if (snapshot.data!.docs.isEmpty) {
              return Container();
            }
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot document =
                      snapshot.data?.docs[index] as DocumentSnapshot<Object?>;
                  String offer = (100 *
                          (document['comparedPrice'] - document['price']) /
                          document['comparedPrice'])
                      .toStringAsFixed(0);
                  return Container(
                    margin: EdgeInsets.only(
                        left: Dimensions.width20,
                        right: Dimensions.width20,
                        bottom: Dimensions.height10),
                    child: Row(
                      children: [
                        // image section
                        Stack(
                          children: [
                            Container(
                              width: Dimensions.listViewImgSize,
                              height: Dimensions.listViewImgSize,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius20),
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
                                          document["productImage"]))),
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
                            // Positioned(
                            //     top: 10,
                            //     right: 10,
                            //     child: InkWell(
                            //       onTap: () {
                            //         // _productServices.saveToFavorites(document);
                            //       },
                            //       child: Icon(
                            //         Icons.favorite_border_outlined,
                            //         color: Colors.white,
                            //       ),
                            //     )),
                          ],
                        ),
                        SizedBox(
                          width: Dimensions.width5,
                        ),
                        // text section
                        Expanded(
                          child: Container(
                            height: Dimensions.listViewTextContentSize,
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                    color: Color(0xFFe8e8e8),
                                    blurRadius: 5.0,
                                    offset: Offset(0, 5)),
                              ],
                              borderRadius: BorderRadius.all(
                                  Radius.circular(Dimensions.radius20)),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: Dimensions.width10,
                                  right: Dimensions.width10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BigText(text: document["productName"]),
                                  SizedBox(height: Dimensions.height10),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: Dimensions.width10,
                                      ),
                                      // SmallText(text: document["itemSize"]),
                                      // SizedBox(
                                      //   width: Dimensions.width10,
                                      // ),
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
                                              "${document["cookingTime"].toString()} min"),
                                    ],
                                  ),
                                  SizedBox(height: Dimensions.height10),
                                  new InkWell(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProductDetails(
                                                        document: document)));
                                      },
                                      child: SmallText(
                                        text: "More Details",
                                        weight: FontWeight.normal,
                                        color: Colors.black87,
                                      )),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    products.clear();
    pageController.dispose();
  }

  Widget buildBottomSheet(DocumentSnapshot<Object?> document) {
    String offer = (100 *
            (document['comparedPrice'] - document['price']) /
            document['comparedPrice'])
        .toStringAsFixed(0);
    return Wrap(
      children: [
        Container(
          decoration: new BoxDecoration(
              borderRadius: new BorderRadius.only(
                  topLeft: const Radius.circular(25.0),
                  topRight: const Radius.circular(25.0))),
          // height: Dimensions.popularFoodImgSize,
          // color: Colors.transparent,
          child: Column(children: [
            Image.network(
              document["productImage"],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 8.0, bottom: 20),
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
                                text:
                                    "\$" + document["price"].toStringAsFixed(0),
                                weight: FontWeight.bold),
                            SizedBox(
                              width: Dimensions.width10,
                            ),
                            if (!(document["comparedPrice"] as double).isNaN)
                              Text(
                                "\$" +
                                    document["comparedPrice"]
                                        .toStringAsFixed(0),
                                style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
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
                        // Row(
                        //   children: [
                        //     // Wrap(
                        //     //   children: List.generate(
                        //     //       5,
                        //     //       (index) => Icon(
                        //     //             Icons.star,
                        //     //             size: 15,
                        //     //             color: Color(0xFFFFC000),
                        //     //           )),
                        //     // ),
                        //     // SizedBox(
                        //     //   width: Dimensions.width10,
                        //     // ),
                        //     // SmallText(text: document["rating"]),
                        //     // SizedBox(
                        //     //   width: Dimensions.width5,
                        //     // ),
                        //     // SmallText(text: document["reviewCount"]),

                        //   ],

                        // ),
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
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 8.0,
                      top: 8.0,
                    ),
                    child: Column(
                      children: [
                        AddToCartWidget(
                            document: document, screen: 'bottomSheet')
                      ],
                    ),
                  )
                ],
              ),
            )
          ]),
        ),
      ],
    );
  }

  Widget _buildPageItem(int index, DocumentSnapshot<Object?> document) {
    Matrix4 matrix = new Matrix4.identity();
    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 1;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale =
          _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 1;
      matrix = Matrix4.diagonal3Values(1, currScale, 2)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 1;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }

    return Transform(
        transform: matrix,
        child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductDetails(document: document)));
          },
          child: Stack(children: [
            Container(
              height: Dimensions.pageViewContainer,
              margin: EdgeInsets.only(
                  left: Dimensions.width15, right: Dimensions.width15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                  color: index.isEven ? Colors.amberAccent : Colors.blueAccent,
                  image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(document["productImage"]))),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                margin: EdgeInsets.only(
                    left: Dimensions.width30,
                    right: Dimensions.width30,
                    bottom: Dimensions.height30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius30),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Color(0xFFe8e8e8),
                          blurRadius: 5.0,
                          offset: Offset(0, 5)),
                      BoxShadow(color: Colors.white, offset: Offset(-5, 0)),
                      BoxShadow(color: Colors.white, offset: Offset(5, 0))
                    ]),
                child: Container(
                  padding: EdgeInsets.only(
                      top: Dimensions.height10,
                      left: Dimensions.width15,
                      right: Dimensions.width15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BigText(text: document["productName"]),
                      SizedBox(
                        height: Dimensions.height10,
                      ),
                      Row(
                        children: [
                          // Wrap(
                          //   children: List.generate(
                          //       5,
                          //       (index) => Icon(
                          //             Icons.star,
                          //             size: 15,
                          //             color: Color(0xFFFFC000),
                          //           )),
                          // ),
                          // SizedBox(
                          //   width: Dimensions.width10,
                          // ),
                          // SmallText(text: document['rating']),
                          // SizedBox(
                          //   width: Dimensions.width5,
                          // ),
                          // SmallText(text: document["reviewCount"]),
                          // SizedBox(
                          //   width: Dimensions.width10,
                          // ),
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
                                  "${document["cookingTime"].toString()} min"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ]),
        ));
  }
}
