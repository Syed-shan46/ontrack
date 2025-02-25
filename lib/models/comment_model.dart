import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String profilePic;
  final String name;
  final String uid;
  final String text;
  final String commentId;
  final DateTime datePublished;

  Comment({
    required this.profilePic,
    required this.name,
    required this.uid,
    required this.text,
    required this.commentId,
    required this.datePublished,
  });

  // Convert Comment object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'profilePic': profilePic,
      'name': name,
      'uid': uid,
      'text': text,
      'commentId': commentId,
      'datePublished':
          Timestamp.fromDate(datePublished), // Store as Firestore Timestamp
    };
  }

  // Convert Firestore document (Map) to Comment object
  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      profilePic: map['profilePic'] ?? '',
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      text: map['text'] ?? '',
      commentId: map['commentId'] ?? '',
      datePublished: (map['datePublished'] as Timestamp)
          .toDate(), // Convert Timestamp to DateTime
    );
  }

  // Convert Firestore document snapshot to Comment object
  factory Comment.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment.fromMap(data);
  }
}
