import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/screens/add_post_screen.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:ontrack/screens/home/home_screen.dart';
import 'package:ontrack/screens/profile/my_profile_screen.dart';
import 'package:ontrack/screens/profile/user_profile_screen.dart';
import 'package:ontrack/screens/reels_screen.dart';
import 'package:ontrack/screens/search/search_screen.dart';
import 'package:ontrack/utils/themes/app_colors.dart';

class NavigationMenu extends ConsumerStatefulWidget {
  const NavigationMenu({super.key});

  @override
  ConsumerState<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends ConsumerState<NavigationMenu> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    final List<Widget> screens = [
      const HomeScreen(),
      const SearchScreen(),
      AddPostScreen(),
      const ReelsScreen(),
      if (user != null)
        MyProfileScreen(), // Add profile screen only if user is logged in
    ];

    final List<BottomNavigationBarItem> items = [
      const BottomNavigationBarItem(icon: Icon(CupertinoIcons.home, size: 24)),
      const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.search, size: 26)),
      const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.add_circled, size: 26)),
      const BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.play_circle, size: 26)),
      if (user != null)
        const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person,
                size: 26)), // Add profile tab only if user is logged in
    ];

    // Ensure _selectedIndex is within bounds
    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: AppColors.primaryColor.withOpacity(0.8),
        inactiveColor: Colors.grey,
        items: items,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        currentIndex: _selectedIndex,
      ),
      tabBuilder: (context, index) {
        return CupertinoTabView(
          builder: (context) => screens[index],
        );
      },
    );
  }
}
