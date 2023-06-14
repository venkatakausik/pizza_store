import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductService {
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference favorite =
      FirebaseFirestore.instance.collection('favorites');

  getSliderProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where("published", isEqualTo: true)
        .where("collection", isEqualTo: 'Best Selling')
        .orderBy('productName')
        .limitToLast(5)
        .snapshots();
  }

  getPopularProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .where("published", isEqualTo: true)
        .where("collection", isEqualTo: 'Featured Products')
        .orderBy('productName')
        .limitToLast(10)
        .snapshots();
  }

  Future<void> saveToFavorites(DocumentSnapshot<Object?> document) {
    return favorite.add({'product': document.data(), 'customerId': user!.uid});
  }

  Future<void> addToCart(document, productSize, price, toppings) {
    cart
        .doc(user!.uid)
        .set({'user': user!.uid, 'seller': document['seller']['sellerUid']});

    return cart.doc(user!.uid).collection('products').add({
      'productId': document['productId'],
      'productName': document['productName'],
      'quantity': 1,
      'sku': document['sku'],
      'price': price == null ? document['price'] : price,
      'comparedPrice': document['comparedPrice'],
      'total': document['price'],
      if (productSize != null) 'itemSize': productSize,
      if (toppings != null) 'toppings': toppings
    });
  }

  Future<void> updateCartQty(docId, qty, total) {
    DocumentReference documentReference =
        cart.doc(user!.uid).collection('products').doc(docId);
    return FirebaseFirestore.instance
        .runTransaction((transaction) async {
          // Get the document
          DocumentSnapshot snapshot = await transaction.get(documentReference);

          if (!snapshot.exists) {
            throw Exception("Product does not exist in cart !");
          }
          // Perform an update on the document
          transaction
              .update(documentReference, {'qty': qty, 'total': total * qty});

          // Return the new count
          return qty;
        })
        .then((value) => print("Updated cart"))
        .catchError((error) => print("Failed to update cart: $error"));
  }

  Future<void> removeFromCart(docId) async {
    return cart.doc(user!.uid).collection("products").doc(docId).delete();
  }

  Future<void> checkCartData() async {
    final snapshot = await cart.doc(user!.uid).collection("products").get();
    if (snapshot.docs.length == 0) {
      cart.doc(user!.uid).delete();
    }
  }

  Future<void> deleteCart() async {
    final result =
        await cart.doc(user!.uid).collection('products').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  Future<DocumentSnapshot> getShopName() async {
    DocumentSnapshot doc = await cart.doc(user!.uid).get();
    return doc;
  }

  CollectionReference category =
      FirebaseFirestore.instance.collection('category');
  CollectionReference product =
      FirebaseFirestore.instance.collection('products');
  CollectionReference cart = FirebaseFirestore.instance.collection('cart');
}
