import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:icons_flutter/icons_flutter.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pizza_store/pages/home/main_page.dart';
import 'package:pizza_store/pages/profile/edit_profile_page.dart';
import 'package:pizza_store/pages/welcome_screen.dart';
import 'package:pizza_store/providers/auth_provider.dart';
import 'package:pizza_store/widgets/big_text.dart';
import 'package:provider/provider.dart';

import '../../utils/dimensions.dart';
import '../../widgets/small_text.dart';
import '../orders/order_screen.dart';

class ProfilePage extends StatelessWidget {
  static const String id = 'profile-screen';
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<AuthProvider>(context);
    userDetails.getUserDetails();
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
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
                    settings: RouteSettings(name: MainFoodPage.id),
                    screen: MainFoodPage(),
                    withNavBar: true,
                    pageTransitionAnimation: PageTransitionAnimation.cupertino,
                  );
                },
              ),
              BigText(text: "Profile")
            ]),
          ),
          Container(
            margin: EdgeInsets.only(
                left: Dimensions.width20,
                right: Dimensions.width20,
                bottom: Dimensions.height10),
            child: Card(
              elevation: 5,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(
                              left: Dimensions.width10,
                              right: Dimensions.width10,
                              top: Dimensions.width20),
                          height: Dimensions.listViewImgSize,
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: Dimensions.width10,
                                right: Dimensions.width10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SmallText(
                                    size: 20,
                                    overFlow: TextOverflow.clip,
                                    maxLines: 2,
                                    color: Colors.black,
                                    text:
                                        userDetails.snapshot.get('name') != null
                                            ? '${userDetails.snapshot['name']}'
                                            : 'Update your name'),
                                SizedBox(height: Dimensions.height20),
                                Row(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        pushNewScreenWithRouteSettings(
                                          context,
                                          settings: RouteSettings(
                                              name: EditProfilePage.id),
                                          screen: EditProfilePage(),
                                          withNavBar: false,
                                          pageTransitionAnimation:
                                              PageTransitionAnimation.cupertino,
                                        );
                                      },
                                      child: SmallText(
                                        text: "Edit Profile",
                                        color: Colors.deepOrangeAccent,
                                        size: 15,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: Dimensions.height10),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: Dimensions.width5,
                      ),
                      // image section

                      Column(
                        children: [
                          InkWell(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings:
                                    RouteSettings(name: EditProfilePage.id),
                                screen: EditProfilePage(),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: Container(
                              width: Dimensions.listViewImgSize / 1.5,
                              height: Dimensions.listViewImgSize / 1.5,
                              margin: EdgeInsets.only(
                                  left: Dimensions.width10,
                                  right: Dimensions.width30),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.radius20),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage(
                                          "assets/images/profile.png"))),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                    top: Dimensions.height15, bottom: Dimensions.height15),
                padding: EdgeInsets.only(
                    left: Dimensions.width20, right: Dimensions.width20),
                child: Card(
                  child: Column(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 0, right: 0),
                        children: [
                          ListTile(
                            title: SmallText(
                              text: "Food orders",
                              weight: FontWeight.bold,
                              size: 15,
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(name: OrderScreen.id),
                                screen: OrderScreen(),
                                withNavBar: true,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: ListTile(
                              title: SmallText(text: "Your orders"),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              // contentPadding: EdgeInsets.only(left: 8.0),
                              // leading: CircleAvatar(
                              //   backgroundColor: Colors.grey.shade200,
                              //   radius: 15,
                              //   child: Icon(
                              //     Entypo.shopping_bag,
                              //     color: Colors.deepOrangeAccent,
                              //     size: Dimensions.iconSize24 / 1.5,
                              //   ),
                              // ),
                              leading: Icon(Icons.history_outlined),
                            ),
                          ),
                          ListTile(
                            title: SmallText(text: "Favorites"),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            // contentPadding: EdgeInsets.all(8.0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey.shade200,
                              radius: 15,
                              child: Icon(
                                Icons.favorite_border,
                                color: Colors.deepOrangeAccent,
                                size: Dimensions.iconSize24 / 1.5,
                              ),
                            ),
                          ),
                          // ListTile(
                          //   title: SmallText(text: "Address book"),
                          //   trailing: const Icon(Icons.arrow_forward_ios),
                          //   // contentPadding: EdgeInsets.all(8.0),
                          //   leading: CircleAvatar(
                          //     backgroundColor: Colors.grey.shade200,
                          //     radius: 15,
                          //     child: Icon(
                          //       FontAwesome5.address_book,
                          //       color: Colors.deepOrangeAccent,
                          //       size: Dimensions.iconSize24 / 1.5,
                          //     ),
                          //   ),
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                // margin: EdgeInsets.only(
                //     top: Dimensions.height15, bottom: Dimensions.height15),
                padding: EdgeInsets.only(
                    left: Dimensions.width20, right: Dimensions.width20),
                child: Card(
                  child: Column(
                    children: [
                      ListView(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(left: 0, right: 0),
                        children: [
                          InkWell(
                            onTap: () {
                              FirebaseAuth.instance.signOut();
                              pushNewScreenWithRouteSettings(
                                context,
                                settings: RouteSettings(name: WelcomeScreen.id),
                                screen: WelcomeScreen(),
                                withNavBar: false,
                                pageTransitionAnimation:
                                    PageTransitionAnimation.cupertino,
                              );
                            },
                            child: ListTile(
                              title: SmallText(
                                text: "Sign Out",
                                weight: FontWeight.bold,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
