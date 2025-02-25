import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserNotifier extends StateNotifier<UserModel?> {
  UserNotifier() : super(null) {
    _init();
  }

  Future<void> _init() async {
    await _loadUser(); // ✅ Load user data when provider initializes
  }

  // Set user after registration or login
  void setUser(UserModel user) async {
    state = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'user', jsonEncode(user.toJson())); // Save user as JSON
  }

  // ✅ Load user data from SharedPreferences
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user');

    if (userData != null) {
      state = UserModel.fromJson(jsonDecode(userData));
    }
  }

  // ✅ Logout and clear user data
  void logout() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user'); // Remove user from storage
    Get.offAll(() => LoginScreen());
  }

  // Fetch user from Firestore
  Future<void> fetchUser(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (userDoc.exists) {
        state = UserModel.fromSnap(userDoc);
      }
    } catch (e) {
      print("Error fetching user: $e");
    }
  }
}

// Riverpod Provider
final userProvider = StateNotifierProvider<UserNotifier, UserModel?>((ref) {
  return UserNotifier();
});
