import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:ontrack/models/user_model.dart' as model;

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:ontrack/screens/authentication/update_profile.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/image/img_pick.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  Uint8List? _image;
  bool isLoading = false;

  selectImage() async {
    Uint8List im = await pickImage(ImageSource.gallery);
    // set state because we need to display the image we selected on the circle avatar
    setState(() {
      _image = im;
    });
  }

  // Register User with Firebase
  Future<void> registerUser() async {
    // Validate inputs before proceeding
    if (usernameController.text.isEmpty || usernameController.text.length < 3) {
      Get.snackbar(
          'Invalid Username', 'Username must be at least 3 characters long.');
      return;
    }
    if (emailController.text.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
            .hasMatch(emailController.text)) {
      Get.snackbar('Invalid Email', 'Please enter a valid email address.');
      return;
    }
    if (passwordController.text.isEmpty ||
        passwordController.text.length < 6 ||
        !RegExp(r'^(?=.*?[A-Z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$')
            .hasMatch(passwordController.text)) {
      Get.snackbar('Invalid Password',
          'Password must be at least 6 characters long, include at least one uppercase letter, one number, and one special character.');
      return;
    }
    if (_image == null) {
      Get.snackbar('No Profile Image', 'Please select a profile image.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Firebase registration process
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      String? photoUrl;
      if (_image != null) {
        String cloudName = "dagq3j3dp";
        String uploadPreset = "fwejxnfu";

        var request = http.MultipartRequest(
          'POST',
          Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload"),
        );

        request.fields['upload_preset'] = uploadPreset;
        request.files.add(
          http.MultipartFile.fromBytes('file', _image!,
              filename: 'profile_image.png'),
        );

        var response = await request.send();
        var responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          var data = jsonDecode(responseData.body);
          photoUrl = data['secure_url'];
        } else {
          throw Exception("Image upload failed");
        }
      }

      model.UserModel user = model.UserModel(
        username: usernameController.text,
        uid: userCredential.user!.uid,
        photoUrl: photoUrl ?? '',
        email: emailController.text,
        followers: [],
        following: [],
      );

      // adding user in our database
      await _firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .set(user.toJson());

      // ✅ Set user in Riverpod state
      ref.read(userProvider.notifier).setUser(user);

      /// Redirect Immediately to Profile Update Screen
      Get.offAll(() => UpdateProfileScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'Registration Failed');
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
          appBar: AppBar(
            title: Text("Create Account"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Animation
                  // SizedBox(
                  //   height: 200.h,
                  //   width: 200.h,
                  //   child: Lottie.asset(
                  //     'assets/animation/log-delivery.json',
                  //   ),
                  // ),
                  Stack(
                    children: [
                      _image != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(_image!),
                              backgroundColor: Colors.red,
                            )
                          : const CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.grey,
                              child: Icon(Icons.person, size: 64),
                            ),
                      Positioned(
                        bottom: -10,
                        left: 70,
                        child: IconButton(
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: MySizes.spaceBtwSections),

                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey)),
                      labelText: 'Username',
                      labelStyle: TextStyle(
                          color: ThemeUtils.dynamicTextColor(context)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      prefixIcon: Icon(Icons.person_outline,
                          color: ThemeUtils.dynamicTextColor(context)),
                    ),
                  ),
                  SizedBox(height: MySizes.spaceBtwInputFields),
                  // Username textfield
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey)),
                      labelText: 'Email',
                      labelStyle: TextStyle(
                          color: ThemeUtils.dynamicTextColor(context)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      prefixIcon: Icon(Icons.email_outlined,
                          color: ThemeUtils.dynamicTextColor(context)),
                    ),
                  ),
                  SizedBox(height: MySizes.spaceBtwInputFields),
                  // Phone number
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey)),
                      labelText: 'Password',
                      labelStyle: TextStyle(
                          color: ThemeUtils.dynamicTextColor(context)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      prefixIcon: Icon(Icons.password_outlined,
                          color: ThemeUtils.dynamicTextColor(context)),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),
                  SizedBox(height: 20),
                  // Register button
                  ElevatedButton(
                    onPressed: () {
                      // Register user
                      registerUser();
                    },
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                          color: ThemeUtils.sameBrightness(context)
                              .withAlpha(220)),
                    ),
                  ),
                  SizedBox(height: MySizes.spaceBtwItems),
                  // Login text
                  RichText(
                    text: TextSpan(
                      text: 'Already have an account?',
                      style: TextStyle(
                          color: ThemeUtils.dynamicTextColor(context)),
                      children: <TextSpan>[
                        TextSpan(
                          text: ' Login',
                          style: TextStyle(color: Colors.blue),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // Navigate to login screen
                              Get.to(() => LoginScreen());
                            },
                        ),
                      ],
                    ),
                  )
                ],
              ),
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
