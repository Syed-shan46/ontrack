import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ontrack/navigation_menu.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  UpdateProfileScreenState createState() => UpdateProfileScreenState();
}

class UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;

  String username = "";
  String photoUrl = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          username = userDoc["username"] ?? "User";
          photoUrl = userDoc["photoUrl"] ?? "";
        });
      }
    }
  }

  Future<void> updateUserDetails() async {
    String bio = bioController.text.trim();
    String location = locationController.text.trim();

    if (bio.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection("users").doc(user.uid).update({
          "bio": bio,
          "location": location,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully")),
        );

        Get.offAll(() => NavigationMenu());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: Text("Complete Profile")),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? Icon(Icons.person, size: 50, color: Colors.grey)
                          : null,
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        username,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: bioController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.grey)),
                    labelText: 'Bio',
                    labelStyle:
                        TextStyle(color: ThemeUtils.dynamicTextColor(context)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    prefixIcon: Icon(Icons.person_outline,
                        color: ThemeUtils.dynamicTextColor(context)),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.grey)),
                    labelText: 'Location',
                    labelStyle:
                        TextStyle(color: ThemeUtils.dynamicTextColor(context)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    prefixIcon: Icon(Icons.location_on,
                        color: ThemeUtils.dynamicTextColor(context)),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: updateUserDetails,
                  child: Text(
                    "Continue",
                    style: TextStyle(
                        color:
                            ThemeUtils.sameBrightness(context).withAlpha(220)),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black.withAlpha(200),
            child: Center(
                child: LoadingAnimationWidget.flickr(
              leftDotColor: AppColors.primaryColor,
              rightDotColor: Colors.white.withAlpha(200),
              size: 30.sp,
            )),
          ),
      ],
    );
  }
}
