import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ontrack/firebase_options.dart';
import 'package:ontrack/navigation_menu.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:ontrack/utils/themes/dark_theme.dart';
import 'package:ontrack/utils/themes/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ValueNotifier<User?> _userNotifier =
      ValueNotifier(FirebaseAuth.instance.currentUser);

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.userChanges().listen((user) {
      _userNotifier.value = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: ValueListenableBuilder<User?>(
          valueListenable: _userNotifier,
          builder: (context, user, child) {
            if (user != null) {
              return const NavigationMenu();
            } else {
              return const LoginScreen();
            }
          },
        ),
      ),
    );
  }
}
