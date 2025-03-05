import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String photoUrl;
  final double price;

  Product(
      {required this.name,
      required this.id,
      required this.price,
      required this.photoUrl});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'price': price,
    };
  }

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
    );
  }
}
