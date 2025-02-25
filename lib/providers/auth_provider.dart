import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class AuthStateNotifier extends StateNotifier<UserModel?> {
  final Ref ref; // Add this

  AuthStateNotifier(this.ref) : super(null);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        state = UserModel.fromSnap(userDoc); // Properly updates Riverpod state
        return 'success';
      } else {
        return 'User not found';
      }
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> logoutUser() async {
    await _auth.signOut();
    state = null;
  }
}

// **Riverpod Provider with ref**
final authProvider = StateNotifierProvider<AuthStateNotifier, UserModel?>(
  (ref) => AuthStateNotifier(ref),
);
