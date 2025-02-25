import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String? location;
  final String? bio;
  final List<dynamic> followers;
  final List<dynamic> following;

  const UserModel({
    required this.username,
    this.location,
    required this.uid,
    required this.photoUrl,
    required this.email,
    this.bio,
    this.followers = const [],
    this.following = const [],
  });

  static UserModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return UserModel(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      location: snapshot["location"],
      bio: snapshot["bio"],
      followers: List<String>.from(snapshot["followers"] ?? []),
      following: List<String>.from(snapshot["following"] ?? []),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      username: json['username'],
      email: json['email'],
      location: json['location'],
      photoUrl: json['photoUrl'],
      followers: json['followers'] ?? [],
      following: json['following'] ?? [],
      bio: json['bio'],
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "followers": followers,
        "following": following,
      };

  // factory UserModel.fromFirestore(
  //   Map<String, dynamic> data,
  //   String id,
  // ) {
  //   return UserModel(
  //     location: data['location'],
  //     username: data['username'],
  //     uid: id,
  //     email: data['email'],
  //     photoUrl: data['photoUrl'],
  //     bio: data['bio'],
  //     followers: data['followers'] ?? [],
  //     following: data['following'] ?? [],
  //   );
  // }

  /// Fix: Accept `QueryDocumentSnapshot` and extract data correctly
  factory UserModel.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return UserModel(
      uid: doc.id, // Extract document ID
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      bio: data['bio'] ?? '',
      location: data['location'] ?? '',
      followers: data['followers'] ?? [],
      following: data['following'] ?? [],
    );
  }
}
