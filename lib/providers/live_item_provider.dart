import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontrack/models/product_model.dart';

class LiveItemNotifier extends StateNotifier<List<Product>> {
  LiveItemNotifier() : super([]);

  void setLiveItems(List<Product> products) {
    state = products;
  }

  Future<void> fetchLiveItems() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('products')
        .where('isLive', isEqualTo: true)
        .get();
  }
}
