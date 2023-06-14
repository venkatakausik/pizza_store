import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/pages/profile/profile_page.dart';
import 'package:pizza_store/providers/order_provider.dart';
import 'package:pizza_store/services/order_services.dart';
import 'package:pizza_store/utils/dimensions.dart';
import 'package:pizza_store/widgets/big_text.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  static const String id = "order-screen";

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  OrderServices _orderServices = OrderServices();
  User? user = FirebaseAuth.instance.currentUser;

  int tag = 1;
  List<String> options = [
    'All Orders',
    'Ordered',
    'Accepted',
    'Picked up',
    'On the way',
    'Delivered'
  ];
  @override
  Widget build(BuildContext context) {
    var _orderProvider = Provider.of<OrderProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 45, bottom: Dimensions.width15),
            padding: EdgeInsets.only(
                left: Dimensions.width5, right: Dimensions.width20),
            child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              BackButton(
                onPressed: () {
                  pushNewScreenWithRouteSettings(
                    context,
                    settings: RouteSettings(name: ProfilePage.id),
                    screen: ProfilePage(),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              BigText(text: "Orders")
            ]),
          ),
          Container(
            height: 56,
            width: MediaQuery.of(context).size.width,
            child: ChipsChoice<int>.single(
              choiceStyle: C2ChipStyle(
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              value: tag,
              onChanged: (val) {
                if (val == 0) {
                  setState(() {
                    _orderProvider.status = null;
                  });
                }
                setState(() {
                  tag = val;
                  _orderProvider.status = options[val];
                });
              },
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: _orderServices.order
                  .where('userId', isEqualTo: user!.uid)
                  .where('orderStatus',
                      isEqualTo: tag > 0 ? _orderProvider.status : null)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: SmallText(text: "Something went wrong.."),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data!.size == 0) {
                  return Center(
                    child: SmallText(
                        text: tag > 0
                            ? "No ${options[tag]} orders"
                            : "No orders. Continue ordering"),
                  );
                }

                return Expanded(
                  child: ListView(
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      return Container(
                        color: Colors.white,
                        child: Column(children: [
                          ListTile(
                            horizontalTitleGap: 0,
                            leading: CircleAvatar(
                              radius: 14,
                              child: _orderServices.statusIcon(document),
                            ),
                            title: SmallText(
                              text: document['orderStatus'],
                              weight: FontWeight.bold,
                              color: _orderServices.statusColor(document),
                            ),
                            trailing: SmallText(
                                weight: FontWeight.bold,
                                text:
                                    "Amount : \$${document['total'].toStringAsFixed(0)}"),
                            subtitle: SmallText(
                                text:
                                    "On ${DateFormat.yMMMd().format(document['timestamp'])}"),
                          ),
                          if (document['deliveryPartner']['name'].length > 2)
                            Padding(
                              padding: EdgeInsets.only(
                                  left: Dimensions.width10,
                                  right: Dimensions.width10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: ListTile(
                                  tileColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(.3),
                                  leading: CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.black,
                                      )),
                                  title: SmallText(
                                    text: document['deliveryPartner']['name'],
                                    size: 14,
                                  ),
                                  subtitle: SmallText(
                                      text: _orderServices
                                          .statusComment(document)),
                                ),
                              ),
                            ),
                          ExpansionTile(
                            title: SmallText(
                              text: "Order details",
                              size: 10,
                              color: Colors.black,
                            ),
                            subtitle: SmallText(
                              text: "View Order details",
                              color: Colors.grey,
                            ),
                            children: [
                              ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: document['products'].length,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Image.network(
                                            document['products'][index]
                                                ['productImage']),
                                      ),
                                      title: SmallText(
                                          text: document['products'][index]
                                              ['productName']),
                                      subtitle: SmallText(
                                          color: Colors.grey,
                                          text:
                                              '${document['products'][index]['qty']} x \$${document['products'][index]['price'].toStringAsFixed(0)} = \$${document['products'][index]['total'].toStringAsFixed(0)}'),
                                    );
                                  }),
                            ],
                          ),
                          Divider(
                            height: 3,
                            color: Colors.grey,
                          )
                        ]),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
