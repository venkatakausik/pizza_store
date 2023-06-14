import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';

import '../pages/food/category_food_list.dart';
import '../providers/store_provider.dart';

class CategoryImageText extends StatefulWidget {
  const CategoryImageText({super.key});

  @override
  State<CategoryImageText> createState() => _CategoryImageTextState();
}

class _CategoryImageTextState extends State<CategoryImageText> {
  ProductService _services = ProductService();

  List _catList = [];
  @override
  void didChangeDependencies() {
    FirebaseFirestore.instance
        .collection("products")
        .get()
        .then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((doc) {
        setState(() {
          _catList.add(doc['category']['mainCategory']);
        });
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    StoreProvider _storeData = Provider.of<StoreProvider>(context);
    return FutureBuilder(
        future: _services.category.where("published", isEqualTo: true).get(),
        builder: (_, snapShot) {
          if (snapShot.hasError) {
            return Center(
              child: SmallText(text: "Something went wrong.."),
            );
          }

          if (_catList.length == 0) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapShot.hasData) {
            return Container();
          }
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapShot.data!.docs.length,
              itemBuilder: (context, int index) {
                DocumentSnapshot category = snapShot.data!.docs[index];
                return _catList.contains(category.get('name'))
                    ? Container(
                        margin: EdgeInsets.only(left: 15, right: 15),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              InkWell(
                                onTap: () {
                                  _storeData
                                      .selectedCategory(category.get('name'));
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: RouteSettings(
                                        name: CategoryFoodList.id),
                                    screen: CategoryFoodList(),
                                    withNavBar: false,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                },
                                child: Column(
                                  children: [
                                    _buildCircleImage(
                                        category.get('categoryImage')),
                                    SmallText(text: category.get('name'))
                                  ],
                                ),
                              ),
                            ]))
                    : SmallText(text: '');
              });
        });
  }

  _buildCircleImage(String assetImagePath) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Container(
        height: 70,
        width: 70,
        padding: EdgeInsets.all(0.5),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                  color: Color(0xFFe8e8e8),
                  blurRadius: 5.0,
                  offset: Offset(0, 5)),
            ],
            image: DecorationImage(
                fit: BoxFit.cover, image: NetworkImage(assetImagePath))),
      ),
    );
  }
}
