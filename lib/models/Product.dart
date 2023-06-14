import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productName, category, sku, productId, image;
  final double price, comparedPrice;
  final DocumentSnapshot document;

  Product(
      {required this.productName,
      required this.category,
      required this.sku,
      required this.productId,
      required this.image,
      required this.price,
      required this.comparedPrice, required this.document});
}
