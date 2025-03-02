import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontrack/models/post_model.dart';

class PostNotifier extends StateNotifier<List<Post>> {
  PostNotifier() : super([]);

  void setPosts(List<Post> posts) {
    state = posts;
  }

  Future<void> fetchPosts() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('datePublished', descending: true)
        .get();

    state = querySnapshot.docs.map((doc) => Post.fromSnap(doc)).toList();
  }

  Future<void> toggleLike(
      String postId, String userId, List<dynamic> currentLikes) async {
    final isLiked = currentLikes.contains(userId);
    final updatedLikes = isLiked
        ? currentLikes.where((id) => id != userId).toList()
        : [...currentLikes, userId];

    // Update UI instantly
    state = state.map((post) {
      if (post.postId == postId) {
        return post.copyWith(likes: updatedLikes);
      }
      return post;
    }).toList();

    // Update Firestore in the background
    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'likes': updatedLikes,
      });
    } catch (e) {
      print('Error updating likes: $e');
    }
  }
}

final postProvider = StateNotifierProvider<PostNotifier, List<Post>>(
  (ref) {
    return PostNotifier();
  },
);
