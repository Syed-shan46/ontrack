import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontrack/models/post_model.dart';
import 'firestore_provider.dart';

final userPostsProvider =
    FutureProvider.family<List<Post>, String>((ref, userId) async {
  final firestore = ref.read(firestoreProvider);

  final querySnapshot = await firestore
      .collection('posts')
      .where('uid', isEqualTo: userId)
      .orderBy('datePublished', descending: true)
      .get();

  return querySnapshot.docs.map((doc) => Post.fromSnap(doc)).toList();
});
