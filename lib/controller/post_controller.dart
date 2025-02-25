import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ontrack/models/post_model.dart';

class PostController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Post>> fetchPosts() async {
    try {
      // Fetch categories from Firestore collection 'categories'
      QuerySnapshot snapshot = await _firestore.collection('posts').get();

      // Map each document to CategoriesModel
      return snapshot.docs.map((doc) => Post.fromSnap(doc)).toList();
    } catch (e) {
      print('Error fetching Posts: $e');
      return []; // Return empty list in case of an error
    }
  }
}
