import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/pages/cart.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:pizza_store/utils/dimensions.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';

class CartNotification extends StatefulWidget {
  const CartNotification({super.key});

  @override
  State<CartNotification> createState() => _CartNotificationState();
}

class _CartNotificationState extends State<CartNotification> {
  ProductService _productService = ProductService();
  late DocumentSnapshot document;
  @override
  Widget build(BuildContext context) {
    final _cartProvider = Provider.of<CartProvider>(context);

    _cartProvider.getCartTotal();
    _productService.getShopName().then((doc) {
      this.document = doc;
    });
    return Visibility(
      visible: _cartProvider.cartQty > 0 ? true : false,
      child: Container(
        height: 45,
        width: MediaQuery.of(context).size.width,
        color: Colors.green,
        child: Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SmallText(
                          text:
                              "${_cartProvider.cartQty} ${_cartProvider.cartQty == 1 ? "Item" : "Items"}",
                          color: Colors.white,
                          weight: FontWeight.bold,
                        ),
                        SmallText(
                          text: " | ",
                          color: Colors.white,
                        ),
                        SmallText(
                          text:
                              '\$${_cartProvider.subTotal.toStringAsFixed(0)}',
                          color: Colors.white,
                          weight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(name: CartPage.id),
                    screen: CartPage(),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
                child: Container(
                  child: Row(
                    children: [
                      SmallText(
                        text: "View Cart",
                        color: Colors.white,
                        weight: FontWeight.bold,
                      ),
                      SizedBox(
                        width: Dimensions.width5,
                      ),
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
