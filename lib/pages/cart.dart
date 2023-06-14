import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/pages/map_screen.dart';
import 'package:pizza_store/pages/profile/profile_page.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:pizza_store/services/product_services.dart';
import 'package:pizza_store/services/user_services.dart';
import 'package:pizza_store/widgets/cod_toggle.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/location_provider.dart';
import '../services/notification_services.dart';
import '../services/order_services.dart';
import '../utils/dimensions.dart';
import '../widgets/big_text.dart';
import '../widgets/non_veg_icon.dart';
import '../widgets/veg_icon.dart';

class CartPage extends StatefulWidget {
  CartPage({super.key});

  static const String id = "cart-screen";

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  ProductService _productService = ProductService();
  NotificationServices _notificationService = NotificationServices();
  UserServices _userService = UserServices();
  OrderServices _orderServices = OrderServices();
  User? user = FirebaseAuth.instance.currentUser;
  int deliveryFee = 20;

  String _location = '';
  String _address = '';
  bool _loading = false;
  bool _checkingUser = false;

  @override
  void initState() {
    getPrefs();
    super.initState();
  }

  _saveOrder(CartProvider cartProvider, payable) {
    _orderServices.saveOrder({
      'products': cartProvider.cartList,
      'userId': user!.uid,
      'deliveryFee': deliveryFee,
      'total': payable,
      'cod': cartProvider.cod,
      'orderStatus': 'Ordered',
      'timestamp': DateTime.now().toString(),
      'deliveryPartner': {
        'name': '',
        'phone': '',
        'location': '',
      }
    }).then((value) {
      _userService.getShopById(cartProvider.sellerUid).then((document) {
        var _sellerDeviceToken = document['deviceToken'];
        _notificationService.sendPushMessage(
            _sellerDeviceToken, "New order received", "Tap here to know more");
      });
      _productService.deleteCart().then((value) {
        _productService.checkCartData().then((value) {
          EasyLoading.showSuccess("Order placed successfully");
          Navigator.pop(context);
        });
      });
    });
  }

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? address = prefs.getString('address');
    setState(() {
      _location = location!;
      _address = address!;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _cartProvider = Provider.of<CartProvider>(context);
    var _payable = _cartProvider.subTotal + deliveryFee;
    final locationData = Provider.of<LocationProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      resizeToAvoidBottomInset: false,
      bottomSheet: Container(
        height: 160,
        color: Colors.blueGrey[900],
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: 100,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: SmallText(
                              text: "Deliver to this address",
                              weight: FontWeight.bold,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                _loading = true;
                              });
                              locationData.getCurrentPosition().then((value) {
                                setState(() {
                                  _loading = false;
                                });
                                if (value != null) {
                                  pushNewScreenWithRouteSettings(
                                    context,
                                    settings: RouteSettings(name: MapScreen.id),
                                    screen: MapScreen(),
                                    withNavBar: false,
                                    pageTransitionAnimation:
                                        PageTransitionAnimation.cupertino,
                                  );
                                  // Navigator.pushNamed(context, MapScreen.id);
                                } else {
                                  setState(() {
                                    _loading = false;
                                  });
                                  print("Permission not allowed");
                                }
                              });
                            },
                            child: _loading
                                ? CircularProgressIndicator()
                                : SmallText(
                                    text: "Change",
                                    color: Colors.red,
                                    weight: FontWeight.bold,
                                  ),
                          ),
                        ],
                      ),
                      SmallText(
                        text: "$_location, $_address",
                        maxLines: 3,
                        color: Colors.grey,
                      ),
                    ]),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SmallText(
                          text:
                              '\$${_cartProvider.subTotal.toStringAsFixed(0)}',
                          color: Colors.white,
                          weight: FontWeight.bold,
                        ),
                        SmallText(
                          text: '(Including taxes)',
                          color: Colors.white,
                          weight: FontWeight.bold,
                          size: 10,
                        )
                      ],
                    ),
                    ElevatedButton(
                        onPressed: () {
                          EasyLoading.show(status: "Please wait..");
                          _userService.getUserById(user!.uid).then((value) {
                            if (value['name'] == null) {
                              EasyLoading.dismiss();
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(name: ProfilePage.id),
                                screen: ProfilePage(),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            } else {
                              EasyLoading.show(status: "Please wait..");
                              _saveOrder(_cartProvider, _payable);
                              EasyLoading.showSuccess(
                                  "Order placed successfully");
                            }
                          });
                        },
                        style:
                            ElevatedButton.styleFrom(primary: Colors.redAccent),
                        child: _checkingUser
                            ? CircularProgressIndicator()
                            : SmallText(
                                text: "CheckOut",
                                color: Colors.white,
                                weight: FontWeight.bold,
                              ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: _cartProvider.cartQty > 0
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 45, bottom: Dimensions.width15),
                  padding: EdgeInsets.only(
                      left: Dimensions.width5, right: Dimensions.width20),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, top: 15, bottom: 10),
                          child: BigText(text: "Cart"),
                        )
                      ]),
                ),
                CodToggleBar(),
                Container(
                  // color: Colors.white,
                  margin: EdgeInsets.only(
                      top: Dimensions.height15, bottom: Dimensions.height15),
                  padding: EdgeInsets.only(
                      left: Dimensions.width20, right: Dimensions.width20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius20)),

                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 15,
                          ),
                          SizedBox(
                            width: Dimensions.width10,
                          ),
                          SmallText(text: "Delivery in"),
                          SizedBox(
                            width: Dimensions.width5,
                          ),
                          SmallText(
                            text: "30-35 min",
                            weight: FontWeight.bold,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: Dimensions.width20, right: Dimensions.width20),
                  child: Container(
                      child: Row(children: [
                    const Expanded(child: Divider(thickness: 1.5)),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SmallText(
                        text: "ITEM(S) ADDED",
                        spacing: 3,
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1.5)),
                  ])),
                ),
                Container(
                  // color: Colors.white,
                  margin: EdgeInsets.only(
                      top: Dimensions.height15, bottom: Dimensions.height15),
                  padding: EdgeInsets.only(
                      left: Dimensions.width20, right: Dimensions.width20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius30)),

                  child: StreamBuilder<QuerySnapshot>(
                      stream: _productService.cart
                          .doc(_productService.user!.uid)
                          .collection("products")
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: SmallText(text: "Something went wrong.."),
                          );
                        }

                        if (!snapshot.hasData) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return Card(
                          child: Column(
                            children: [
                              ListView(
                                shrinkWrap: true,
                                padding: EdgeInsets.only(left: 0, right: 0),
                                children: snapshot.data!.docs
                                    .map((DocumentSnapshot document) {
                                  return ListTile(
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SmallText(
                                          text: document["productName"],
                                          overFlow: TextOverflow.clip,
                                          maxLines: 2,
                                        ),
                                        SmallText(
                                          text: "\$${document['total']}",
                                          weight: FontWeight.bold,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (document["itemSize"] != null)
                                              SmallText(
                                                  text: document["itemSize"]),
                                            if ((document['toppings'] as List)
                                                    .length >
                                                0)
                                              SmallText(
                                                  text:
                                                      "${(document['toppings'] as List).length} toppings included")
                                          ],
                                        )
                                      ],
                                    ),
                                    contentPadding: EdgeInsets.only(left: 8.0),
                                    leading: document['itemType'] == 'Veg'
                                        ? VegIcon()
                                        : NonVegIcon(),
                                  );
                                }).toList(),
                              )
                            ],
                          ),
                        );
                      }),
                ),
                Container(
                  margin: EdgeInsets.only(
                      left: Dimensions.width20, right: Dimensions.width20),
                  child: Container(
                      child: Row(children: [
                    const Expanded(child: Divider(thickness: 1.5)),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                      child: SmallText(
                        text: "BILL SUMMARY",
                        spacing: 3,
                        height: 1,
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1.5)),
                  ])),
                ),
                Container(
                  // color: Colors.white,
                  margin: EdgeInsets.only(
                      top: Dimensions.height15, bottom: Dimensions.height15),
                  padding: EdgeInsets.only(
                      left: Dimensions.width20, right: Dimensions.width20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius30)),

                  child: Card(
                    child: Column(
                      children: [
                        ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.only(
                            left: 0,
                            right: 0,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SmallText(
                                          text: "Subtotal",
                                          weight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 8.0,
                                        top: 8.0,
                                        right: Dimensions.width20),
                                    child: Column(
                                      children: [
                                        SmallText(
                                          text: "\$${_cartProvider.subTotal}",
                                          weight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.monetization_on,
                                          size: Dimensions.iconSize24,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0, right: 210),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SmallText(
                                          text: "Saving",
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 8.0,
                                        top: 8.0,
                                        right: Dimensions.width20),
                                    child: Column(
                                      children: [
                                        SmallText(
                                          text: "\$${_cartProvider.saving}",
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.delivery_dining,
                                          size: Dimensions.iconSize24,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8.0, top: 8.0, right: 120),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SmallText(
                                          text: "Delivery partner fee",
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 8.0,
                                        top: 8.0,
                                        right: Dimensions.width20),
                                    child: Column(
                                      children: [
                                        SmallText(
                                          text: "\$${deliveryFee}",
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: Dimensions.width20,
                                  right: Dimensions.width20),
                              child: Container(
                                  child: Row(children: [
                                Expanded(child: Divider(thickness: 1.5)),
                              ])),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      top: 8.0,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SmallText(
                                          text: "Grand Total",
                                          weight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 8.0,
                                        top: 8.0,
                                        right: Dimensions.width20,
                                        bottom: 8),
                                    child: Column(
                                      children: [
                                        SmallText(
                                          text: "\$${_payable}",
                                          weight: FontWeight.bold,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Center(
              child: SmallText(text: "Cart is empty. Continue ordering"),
            ),
    );
  }
}
