import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontrack/models/comment_model.dart';

final commentProvider =
    StateNotifierProvider<CommentNotifier, List<Comment>>((ref) {
  return CommentNotifier();
});

class CommentNotifier extends StateNotifier<List<Comment>> {
  CommentNotifier() : super([]);

  Future<void> fetchComments(String postId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('datePublished', descending: true)
          .get();

      state =
          querySnapshot.docs.map((doc) => Comment.fromMap(doc.data())).toList();
    } catch (e) {
      print("Error fetching comments: $e");
    }
  }

  Future<void> addComment(String postId, Comment newComment) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(newComment.commentId)
          .set(newComment.toMap());

      state = [
        newComment,
        ...state
      ]; // Add new comment to the beginning of the list
    } catch (e) {
      print("Error adding comment: $e");
    }
  }
}
