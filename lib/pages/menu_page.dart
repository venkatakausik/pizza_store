import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/pages/search_page.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:search_page/search_page.dart';

import '../models/Product.dart';
import '../utils/dimensions.dart';
import '../widgets/product_card.dart';

class MenuPage extends StatefulWidget {
  static const String id = "menu-screen";
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static List<Product> products = [];

  @override
  void initState() {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: Column(
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
          Expanded(
            child: FirestoreListView<Map<String, dynamic>>(
              shrinkWrap: true,
              pageSize: 10,
              padding: const EdgeInsets.all(8.0),
              loadingBuilder: (context) =>
                  Center(child: CircularProgressIndicator()),
              emptyBuilder: (context) => SmallText(text: 'No data'),
              query: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('productName'),
              itemBuilder: (context, snapshot) {
                DocumentSnapshot doc = snapshot as DocumentSnapshot;
                return ProductCard(document: doc);
              },
            ),
          ),
          //   Scrollbar(
          //   child: PaginateFirestore(
          //     // Use SliverAppBar in header to make it sticky
          //     header: const SliverToBoxAdapter(child: Text('HEADER')),
          //     footer: const SliverToBoxAdapter(child: Text('FOOTER')),
          //     // item builder type is compulsory.
          //     itemBuilderType:
          //         PaginateBuilderType.listView, //Change types accordingly
          //     itemBuilder: (context, documentSnapshots, index) {
          //       final data = documentSnapshots[index].data() as Map?;
          //       return ListTile(
          //         leading: const CircleAvatar(child: Icon(Icons.person)),
          //         title: data == null
          //             ? const Text('Error in data')
          //             : Text(data['name']),
          //         subtitle: Text(documentSnapshots[index].id),
          //       );
          //     },
          //     // orderBy is compulsory to enable pagination
          //     query: FirebaseFirestore.instance.collection('products').orderBy('productName'),
          //     itemsPerPage: 10,
          //     // to fetch real-time data
          //     isLive: true,
          //   ),
          // ),
        ],
      ),
    ));
  }
}
