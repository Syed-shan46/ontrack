import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ontrack/firebase_options.dart';
import 'package:ontrack/navigation_menu.dart';
import 'package:ontrack/providers/riv_auth_provider.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:ontrack/utils/themes/dark_theme.dart';
import 'package:ontrack/utils/themes/light_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(riverpod.ProviderScope(child: MyApp()));
}

class MyApp extends riverpod.ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  riverpod.ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends riverpod.ConsumerState<MyApp> {
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
    final authState = ref.watch(authStateProvider);
    return ScreenUtilInit(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        themeMode: ThemeMode.system,
        theme: lightTheme,
        darkTheme: darkTheme,
        home: authState.when(
          data: (user) {
            if (user != null) {
              return const NavigationMenu(); // User is logged in
            } else {
              return const NavigationMenu(); // User is not logged in
            }
          },
          loading: () => Scaffold(
            body: Center(
                child: CircularProgressIndicator()), // Show loading indicator
          ),
          error: (err, stack) => Scaffold(
            body: Center(child: Text("Error: $err")), // Show error message
          ),
        ),
      ),
    );
  }
}
