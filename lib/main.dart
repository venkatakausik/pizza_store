import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:pizza_store/pages/cart.dart';
import 'package:pizza_store/pages/category_list_screen.dart';
import 'package:pizza_store/pages/food/category_food_list.dart';
import 'package:pizza_store/pages/home/home_screen.dart';
import 'package:pizza_store/pages/home/main_page.dart';
import 'package:pizza_store/pages/landing_screen.dart';
import 'package:pizza_store/pages/login_screen.dart';
import 'package:pizza_store/pages/main_screen.dart';
import 'package:pizza_store/pages/map_screen.dart';
import 'package:pizza_store/pages/menu_page.dart';
import 'package:pizza_store/pages/orders/order_screen.dart';
import 'package:pizza_store/pages/profile/edit_profile_page.dart';
import 'package:pizza_store/pages/profile/profile_page.dart';
import 'package:pizza_store/pages/register_screen.dart';
import 'package:pizza_store/pages/search_page.dart';
import 'package:pizza_store/pages/splash_screen.dart';
import 'package:pizza_store/pages/welcome_screen.dart';
import 'package:pizza_store/providers/auth_provider.dart';
import 'package:pizza_store/providers/cart_provider.dart';
import 'package:pizza_store/providers/location_provider.dart';
import 'package:pizza_store/providers/order_provider.dart';
import 'package:pizza_store/providers/product_provider.dart';
import 'package:pizza_store/providers/store_provider.dart';
import 'package:provider/provider.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
      ChangeNotifierProvider(create: (_) => LocationProvider()),
      ChangeNotifierProvider(create: (_) => StoreProvider()),
      ChangeNotifierProvider(create: (_) => CartProvider()),
      ChangeNotifierProvider(create: (_) => OrderProvider()),
      ChangeNotifierProvider(create: (_) => ProductProvider())
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pizza Store',
      theme: ThemeData(
        primaryColor: Colors.deepOrangeAccent,
        // fontFamily: 'Metropolis',
      ),
      initialRoute: SplashScreen.id,
      builder: EasyLoading.init(),
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        MainFoodPage.id: (context) => MainFoodPage(),
        WelcomeScreen.id: (context) => WelcomeScreen(),
        MapScreen.id: (context) => MapScreen(),
        HomeScreen.id: (context) => HomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        LandingScreen.id: (context) => LandingScreen(),
        MainScreen.id: (context) => MainScreen(),
        ProfilePage.id: (context) => ProfilePage(),
        CategoryFoodList.id: (context) => CategoryFoodList(),
        CategoryListScreen.id: (context) => CategoryListScreen(),
        CartPage.id: (context) => CartPage(),
        EditProfilePage.id: (context) => EditProfilePage(),
        OrderScreen.id: (context) => OrderScreen(),
        SearchScreen.id: (context) => SearchScreen(),
        MenuPage.id: (context) => MenuPage(),
      },
    );
  }
}
