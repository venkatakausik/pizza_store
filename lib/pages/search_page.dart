import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:pizza_store/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:search_page/search_page.dart';
import '../models/Product.dart';
import '../utils/dimensions.dart';
import '../widgets/add_to_cart_widget.dart';
import '../widgets/non_veg_icon.dart';
import '../widgets/product_card.dart';
import '../widgets/small_text.dart';
import '../widgets/veg_icon.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static const String id = "search-screen";

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static List<Product> products = [];

  @override
  void dispose() {
    products.clear();
    super.dispose();
  }

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
    ProductProvider _productData = Provider.of<ProductProvider>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
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
            // Expanded(
            //   child: Container(
            //     margin: EdgeInsets.only(top: 45, bottom: Dimensions.width15),
            //     padding: EdgeInsets.only(
            //         left: Dimensions.width20, right: Dimensions.width20),
            //     // decoration: BoxDecoration(
            //     //     borderRadius: BorderRadius.circular(Dimensions.radius20),
            //     //     boxShadow: [
            //     //       BoxShadow(
            //     //           color: Color(0xFFe8e8e8),
            //     //           blurRadius: 5.0,
            //     //           offset: Offset(0, 5)),
            //     //     ]),
            //     child: ListView.builder(
            //       itemCount: products.length,
            //       itemBuilder: (context, index) {
            //         final Product person = products[index];

            //         return ListTile(
            //           title: SmallText(text: person.productName),
            //           subtitle: SmallText(text: person.category),
            //           trailing: SmallText(text: '\$${person.price}'),
            //         );
            //       },
            //     ),
            //   ),
            // ),
          ],
        ),
        // floatingActionButton: FloatingActionButton(
        //   tooltip: 'Search foods',
        //   backgroundColor: Theme.of(context).primaryColor,
        //   onPressed: () => showSearch(
        //     context: context,
        //     delegate: SearchPage<Product>(
        //         items: products,
        //         searchLabel: "Search \"pizza\"",
        //         searchStyle: TextStyle(color: Colors.white),
        //         suggestion: Center(
        //           child: SmallText(
        //               text: 'Filter food by name, category or price '),
        //         ),
        //         barTheme: ThemeData(
        //           hintColor: Colors.white,
        //           appBarTheme: AppBarTheme(
        //             color: Theme.of(context).primaryColor,
        //           ),
        //         ),
        //         failure: Center(
        //           child: SmallText(text: 'No product found :('),
        //         ),
        //         filter: (product) => [
        //               product.productName,
        //               product.category,
        //               product.price.toString(),
        //             ],
        //         builder: (product) => ProductCard(document: product.document)),
        //   ),
        //   child: const Icon(Icons.search),
        // ),
      ),
    );
  }
}
