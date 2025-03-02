import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ontrack/models/product_model.dart';

class ProductController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addProduct(Product product) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .add(product.toMap());
    } else {
      throw Exception("User not logged in");
    }
  }

  Stream<List<Product>> getProducts() {
    final user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => Product.fromFirestore(doc.data()))
              .toList());
    } else {
      return Stream.value([]); // Return an empty stream if no user
    }
  }

  Future<void> updateProduct(String productId, Product updatedProduct) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .doc(productId)
          .update(updatedProduct.toMap());
    } else {
      throw Exception("User not logged in");
    }
  }

  Future<void> deleteProduct(String productId) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('products')
          .doc(productId)
          .delete();
    } else {
      throw Exception("User not logged in");
    }
  }
}
