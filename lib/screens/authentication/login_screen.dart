import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:get/get.dart';
import 'package:ontrack/models/user_model.dart';
import 'package:ontrack/navigation_menu.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/resources/auth_methods.dart';
import 'package:ontrack/screens/authentication/register_screen.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  // void loginUser() async {
  //   if (_formKey.currentState!.validate()) {
  //     setState(() {
  //       _isLoading = true;
  //     });

  //     UserModel? user = await AuthMethods().loginUser(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );

  //     if (user != null) {
  //       if (context.mounted) {
  //         ref.read(userProvider.notifier).setUser(user); // ✅ Pass UserModel
  //         Get.offAll(() => NavigationMenu());
  //       }
  //     } else {
  //       if (context.mounted) {
  //         Get.snackbar('Error', 'Invalid email or password');
  //       }
  //     }

  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }
  void loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserModel? user = await AuthMethods().loginUser(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (user != null) {
          if (context.mounted) {
            ref.read(userProvider.notifier).setUser(user);
            Get.offAll(() => NavigationMenu());
          }
        } else {
          if (context.mounted) {
            Get.snackbar('Error', 'Invalid email or password');
          }
        }
      } catch (e) {
        print('Login Error: $e');
        if (mounted) {
          Get.snackbar('Error', 'Something went wrong, please try again.');
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    try {
      String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
      RegExp regex = RegExp(pattern);
      if (!regex.hasMatch(value)) {
        return 'Enter a valid email address';
      }
    } catch (e) {
      return 'Error validating email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text("Login to your Account"),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 200.h,
                      width: 200.h,
                      child: LottieBuilder.asset(
                        'assets/animation/log-delivery.json',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      style: TextStyle(
                          color: ThemeUtils.dynamicTextColor(context)),
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                              color: ThemeUtils.dynamicTextColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelText: 'Email',
                        labelStyle: TextStyle(
                            color: ThemeUtils.dynamicTextColor(context)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: Icon(Icons.email,
                            color: ThemeUtils.dynamicTextColor(context)),
                      ),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(
                          color: ThemeUtils.dynamicTextColor(context)),
                      keyboardType: TextInputType.visiblePassword,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                              color: ThemeUtils.dynamicTextColor(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        labelText: 'Password',
                        labelStyle: TextStyle(
                            color: ThemeUtils.dynamicTextColor(context)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        prefixIcon: Icon(Icons.lock,
                            color: ThemeUtils.dynamicTextColor(context)),
                      ),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems),

                    // Login button
                    ElevatedButton(
                      onPressed: _isLoading ? null : loginUser,
                      child: Text(
                        "Login",
                        style: TextStyle(
                            color: ThemeUtils.sameBrightness(context)),
                      ),
                    ),
                    SizedBox(height: MySizes.spaceBtwItems),

                    // Register text
                    RichText(
                      text: TextSpan(
                        text: 'Do you need to create an account?',
                        style: TextStyle(
                            color: ThemeUtils.dynamicTextColor(context)),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' Register',
                            style: TextStyle(color: Colors.blue),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Get.to(() => RegisterScreen());
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_isLoading)
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
