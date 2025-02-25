import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:logger/logger.dart';
import 'package:ontrack/providers/post_by_user_provider.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  final String? username;
  final String? photoUrl;
  const ProfileScreen({
    super.key,
    required this.uid,
    this.username,
    this.photoUrl,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool isLoading = false;
  var userData = {};
  int postLen = 0;

  @override
  void initState() {
    super.initState();
//addData();
  }

  Future<void> _fetchPosts() async {
    try {
      ref.read(userPostsProvider(widget.uid));
    } catch (error) {
      final logger = Logger();
      logger.e('Error fetching posts in initState: $error');
    }
  }

//   getData() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       var userSnap = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.uid)
//           .get();

// // get post lENGTH
//       var postSnap = await FirebaseFirestore.instance
//           .collection('posts')
//           .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//           .get();

//       postLen = postSnap.docs.length;
//       userData = userSnap.data()!;

//       setState(() {});
//     } catch (e) {
//       Get.snackbar('Error', e.toString());
//     }
//     setState(() {
//       isLoading = false;
//     });
//   }

// addData() async {
// UserProvider userProvider =
// Provider.of<UserProvider>(context, listen: false);
// await userProvider.refreshUser();
// }

// getData() async {
// setState(() {
// isLoading = true;
// });
// try {
// var userSnap = await FirebaseFirestore.instance
// .collection('users')
// .doc(widget.uid)
// .get();

// userData = userSnap.data()!;

// setState(() {});
// } catch (e) {
// Get.snackbar('Error', e.toString());
// }
// setState(() {
// isLoading = false;
// });
// }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    if (user == null) {
      return Center(
        child: Container(
          child: Text('User not found'),
        ),
      );
    }

    final postsAsyncValue = ref.watch(userPostsProvider(widget.uid));
//UserModel? user = Provider.of<UserProvider>(context).getUser;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  /// Profile header with gradient border, user's avatar, name, and options icon.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
// Gradient Border
                            Container(
                              width: 57,
                              height: 57,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green, // Purple-Pink Gradient Start
                                    Colors.redAccent,
                                    Colors.orangeAccent // Orange Gradient End
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
// Circle Avatar
                            SizedBox(
                              width: 50,
                              height: 50,
                              child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor:
                                      Colors.white, // Inner white border
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          widget.photoUrl ?? user.photoUrl,
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Text(
                          widget.username ?? user.username,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(Icons.more_vert)
                      ],
                    ),
                  ),

                  /// A widget that displays a profile section with icons, text, and buttons in a row layout.
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
// Profile Picture with Gradient Border
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  Column(
                                    children: [
                                      Icon(
                                        AntDesign.picture,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        '150',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: Icon(
                                      Icons.person_outline,
                                      color:
                                          ThemeUtils.dynamicTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Icon(Feather.users),
                                      const SizedBox(width: 5),
                                      Text(
                                        '2.3K',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: Icon(
                                      Iconsax.message,
                                      color:
                                          ThemeUtils.dynamicTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      Icon(FontAwesome.user_plus),
                                      const SizedBox(width: 5),
                                      Text(
                                        '500',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  OutlinedButton(
                                    onPressed: () {},
                                    child: Icon(
                                      Iconsax.location,
                                      color:
                                          ThemeUtils.dynamicTextColor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

// al_reem and Bio
// Row(
// mainAxisAlignment: MainAxisAlignment.center,
// children: [
// Padding(
// padding: const EdgeInsets.symmetric(horizontal: 16.0),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Row(
// mainAxisAlignment: MainAxisAlignment.spaceBetween,
// children: [
// const SizedBox(width: 10),
// OutlinedButton(
// onPressed: () {},
// child: Icon(
// Iconsax.add,
// color: ThemeUtils.dynamicTextColor(context),
// ),
// ),
// SizedBox(width: 5),
// OutlinedButton(
// onPressed: () {},
// child: Icon(
// Iconsax.message,
// color: ThemeUtils.dynamicTextColor(context),
// ),
// ),
// SizedBox(width: 5),
// OutlinedButton(
// onPressed: () {},
// child: Row(
// children: [
// Icon(
// Iconsax.location,
// color: ThemeUtils.dynamicTextColor(context),
// ),
// ],
// ),
// ),
// ],
// ),
// SizedBox(height: 5),
// ],
// ),
// ),
// ],
// ),
// Edit Profile Button

// Stats
// Column(
// children: const [
// Text(
// '150',
// style: TextStyle(
// fontWeight: FontWeight.bold,
// fontSize: 18,
// ),
// ),
// Text('Posts'),
// ],
// ),
// Column(
// children: const [
// Text(
// '2.3K',
// style: TextStyle(
// fontWeight: FontWeight.bold,
// fontSize: 18,
// ),
// ),
// Text('Followers'),
// ],
// ),
// Column(
// children: const [
// Text(
// '500',
// style: TextStyle(
// fontWeight: FontWeight.bold,
// fontSize: 18,
// ),
// ),
// Text('Following'),
// ],
// ),

// Live Restaurant Items - Horizontal Scroll
// Live Restaurant Items Section Title
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Live Now',
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                            onPressed: () {},
                            icon: Icon(
                              CupertinoIcons.arrow_right_circle,
                              color: AppColors.primaryColor,
                            ))
                      ],
                    ),
                  ),
// Live Restaurant Items - Horizontal Scroll
                  SizedBox(
                    height: 75.h,
                    child: ListView.builder(
                      key: PageStorageKey('live_items'),
                      scrollDirection: Axis.horizontal,
                      itemCount: 5, // Number of live items
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 15.w,
                            right: index == 4 ? 15.w : 0,
                          ),
                          child: Stack(
                            children: [
// Item Container
                              Container(
                                width: 80.w,
                                height: 80.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15.r),
                                  child: Stack(
                                    children: [
// Item Image
                                      Image.asset(
                                        'assets/images/food$index.jpg',
                                        fit: BoxFit.cover,
                                        width: 80.w,
                                        height: 80.h,
                                      ),
// Item Name Overlay
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          width: 80.w,
                                          color: Colors.black54,
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.h, horizontal: 5.w),
                                          child: Text(
                                            'Mandhi periperi ${index + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.bold,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
// Add Button
                              Positioned(
                                top: 5.h,
                                right: 5.h,
                                child: Container(
                                  width: 22.w,
                                  height: 18.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.4),
                                        spreadRadius: 1,
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Iconsax.add,
                                    size: 15.sp,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ),

// Rating Badge
                              Positioned(
                                top: 5.h,
                                left: 5.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                    vertical: 2.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        color: Colors.white,
                                        Icons.star,
                                        size: 10.sp,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        '4.${index + 1}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
// Tabs (Posts, Reels, Tagged)

                  Text('Posts',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),

// TabBarView (Posts, Reels, Tagged)
                  postsAsyncValue.when(
                    data: (posts) {
                      if (posts.isEmpty) {
                        return const Center(child: Text("No posts found."));
                      }
                      return SizedBox(
                        height: 400,
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.8, // Adjusted for better layout
                          ),
                          padding: const EdgeInsets.all(8),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        post.postUrl,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: 150, // Adjusted for uniformity
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Icon(Icons.favorite,
                                            color: post.likes.isNotEmpty
                                                ? Colors.red
                                                : Colors.grey),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            "${post.likeCount} likes",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stackTrace) {
                      final logger = Logger();
                      logger.e('Error: $error');
                      return Center(child: Text('Error: $error'));
                    },
                  ),

// Grid of Posts
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}

class TabBarSection extends StatefulWidget {
  const TabBarSection({super.key});

  @override
  State<TabBarSection> createState() => _TabBarSectionState();
}

class _TabBarSectionState extends State<TabBarSection>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return TabBar(
      dividerColor: Colors.transparent,
      unselectedLabelColor: Colors.grey,
      controller: _tabController,
      tabs: const [
        Tab(icon: Icon(Iconsax.grid_3)),
        Tab(icon: Icon(Iconsax.video)),
        Tab(icon: Icon(Iconsax.tag)),
      ],
    );
  }
}

class TabBarViewSection extends StatelessWidget {
  const TabBarViewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TabBarView(
        children: [
// Posts Section
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 9, // Number of posts
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/food$index.jpg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
// Reels Section
          Center(
            child: Text("Reels Section"),
          ),
// Tagged Section
          Center(
            child: Text("Tagged Section"),
          ),
        ],
      ),
    );
  }
}
