import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final List<dynamic> likes;
  final String postId;
  final DateTime datePublished;
  final String postUrl;
  final String profImage;

  const Post({
    required this.description,
    required this.uid,
    required this.username,
    required this.likes,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
  });

  /// Compute like count dynamically
  int get likeCount => likes.length;

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
        description: snapshot["description"],
        uid: snapshot["uid"],
        likes: List<String>.from(snapshot["likes"] ?? []), // Ensure it's a list
        postId: snapshot["postId"],
        datePublished: (snapshot["datePublished"] as Timestamp)
            .toDate(), // Convert Timestamp to DateTime
        username: snapshot["username"],
        postUrl: snapshot['postUrl'],
        profImage: snapshot['profImage']);
  }

  Map<String, dynamic> toJson() => {
        "description": description,
        "uid": uid,
        "likes": likes,
        "username": username,
        "postId": postId,
        "datePublished":
            Timestamp.fromDate(datePublished), // Convert DateTime to Timestamp
        'postUrl': postUrl,
        'profImage': profImage
      };

  Post copyWith({
    String? uid,
    List<dynamic>? likes,
  }) {
    return Post(
      description: description,
      uid: uid ?? this.uid,
      username: username,
      likes: likes ?? this.likes,
      postId: postId,
      datePublished: datePublished,
      postUrl: postUrl,
      profImage: profImage,
    );
  }
}
