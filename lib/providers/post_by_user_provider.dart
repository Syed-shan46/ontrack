import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontrack/models/post_model.dart';
import 'firestore_provider.dart';

final userPostsProvider =
    StateNotifierProvider.family<UserPostsNotifier, List<Post>, String>(
        (ref, userId) {
  final notifier = UserPostsNotifier(ref);
  notifier.fetchUserPosts(userId); // Fetch posts immediately
  return notifier;
});

class UserPostsNotifier extends StateNotifier<List<Post>> {
  UserPostsNotifier(this.ref) : super([]);

  final Ref ref;

  Future<void> fetchUserPosts(String userId) async {
    final firestore = ref.read(firestoreProvider);

    final querySnapshot = await firestore
        .collection('posts')
        .where('uid', isEqualTo: userId) // Filter posts by userId
        .orderBy('datePublished', descending: true)
        .get();

    state = querySnapshot.docs.map((doc) => Post.fromSnap(doc)).toList();
  }
}
