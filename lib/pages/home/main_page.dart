import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/pages/home/food_page_body.dart';
import 'package:pizza_store/pages/map_screen.dart';
import 'package:pizza_store/pages/profile/profile_page.dart';
import 'package:pizza_store/providers/auth_provider.dart';
import 'package:pizza_store/providers/location_provider.dart';
import 'package:pizza_store/widgets/big_text.dart';
import 'package:pizza_store/widgets/small_text.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/user_services.dart';
import '../../utils/dimensions.dart';
import '../orders/order_screen.dart';

class MainFoodPage extends StatefulWidget {
  const MainFoodPage({super.key});

  static const String id = 'main-food-page';

  @override
  State<MainFoodPage> createState() => _MainFoodPageState();
}

class _MainFoodPageState extends State<MainFoodPage> {
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  UserServices _userServices = UserServices();
  @override
  void initState() {
    getPrefs();
    _userServices.getToken().then((value) {
      _userServices.updateUserDeviceToken(deviceToken: value);
    });
    var androidInitialize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();
    final InitializationSettings settings = InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    flutterLocalNotificationsPlugin.initialize(settings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    super.initState();
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    if (notificationResponse.payload != null) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const OrderScreen()));
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContent: true);
      AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails('pizza_store', 'pizza_store',
              importance: Importance.max,
              styleInformation: bigTextStyleInformation,
              priority: Priority.max,
              playSound: false);
      NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: const DarwinNotificationDetails());
      await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
          message.notification!.body, notificationDetails,
          payload: message.data['body']);
    });
  }

  String? _location = '';
  String? _address = '';

  getPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? location = prefs.getString('location');
    String? address = prefs.getString('address');
    setState(() {
      _location = location;
      _address = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationData = Provider.of<LocationProvider>(context);

    return SafeArea(
      child: Scaffold(
          body: Column(
        children: [
          Container(
            child: Container(
              margin: EdgeInsets.only(
                  top: Dimensions.height15, bottom: Dimensions.width15),
              padding: EdgeInsets.only(
                  left: Dimensions.width20, right: Dimensions.width10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      locationData.getCurrentPosition().then((value) {
                        if (locationData.permissionAllowed == true) {
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
                          print("Permission not allowed");
                        }
                      });
                    },
                    child: SmallText(
                      text: _address == null || _address!.isEmpty
                          ? 'Press here to select delivery address'
                          : _address!,
                      color: Colors.black54,
                      maxLines: 2,
                      overFlow: TextOverflow.clip,
                    ),

                    // child: Column(
                    //   children: [
                    //     // Flexible(
                    //     //   child: BigText(
                    //     //       text: _location == null
                    //     //           ? 'Address not set'
                    //     //           : _location,
                    //     //       color: Colors.deepOrangeAccent),
                    //     // ),
                    //     Row(
                    //       children: [
                    //         Flexible(
                    //           child: SmallText(
                    //             text: _address == null
                    //                 ? 'Press here to select delivery address'
                    //                 : _address,
                    //             color: Colors.black54,
                    //             overFlow: TextOverflow.ellipsis,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(left: 10, right: 30),
                  //   child: Center(
                  //       child: BigText(
                  //     text: "PIZZA STORE",
                  //     weight: FontWeight.bold,
                  //   )),
                  // ),
                  // InkWell(
                  //   onTap: () {
                  //     pushNewScreenWithRouteSettings(
                  //       context,
                  //       settings: RouteSettings(name: ProfilePage.id),
                  //       screen: ProfilePage(),
                  //       withNavBar: false,
                  //       pageTransitionAnimation:
                  //           PageTransitionAnimation.cupertino,
                  //     );
                  //   },
                  //   child: Center(
                  //     child: Container(
                  //       width: Dimensions.height45,
                  //       height: Dimensions.height45,
                  //       child: CircleAvatar(
                  //         backgroundColor: Colors.deepOrangeAccent,
                  //         radius: 20,
                  //         child: Icon(
                  //           Icons.person_outline_outlined,
                  //           color: Colors.white,
                  //           size: Dimensions.iconSize24,
                  //         ),
                  //       ),
                  //       decoration: BoxDecoration(
                  //         borderRadius:
                  //             BorderRadius.circular(Dimensions.radius15),
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: FoodPageBody(),
          )),
        ],
      )),
    );
  }
}
