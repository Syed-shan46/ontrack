import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ontrack/models/user_model.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<UserModel>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.isEmpty) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .where('username', isGreaterThanOrEqualTo: query)
      .get();

  return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
});
