import 'dart:math';

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
import 'package:ontrack/models/product_model.dart';
import 'package:ontrack/providers/post_by_user_provider.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/resources/auth_methods.dart';
import 'package:ontrack/resources/firestore_methods.dart';
import 'package:ontrack/screens/products/add_product_screen.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/helpers/box_decoration_helper.dart';
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
  late Stream<List<Product>> _productStream;
  bool isLoading = false;
  var userData = {};
  int followers = 0;
  int following = 0;
  int postLen = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _initializeProductStream();
    getData();
  }

  // Future<void> _fetchPosts() async {
  //   try {
  //     ref.read(userPostsProvider(widget.uid));
  //   } catch (error) {
  //     final logger = Logger();
  //     logger.e('Error fetching posts in initState: $error');
  //   }
  // }

  void _initializeProductStream() {
    _productStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('products')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  getData() async {
    try {
      var userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      // get post lENGTH
      var postSnap = await FirebaseFirestore.instance
          .collection('posts')
          .where('uid', isEqualTo: widget.uid)
          .get();

      postLen = postSnap.docs.length;
      userData = userSnap.data()!;
      followers = userSnap.data()!['followers'].length;
      following = userSnap.data()!['following'].length;
      isFollowing = userSnap
          .data()!['followers']
          .contains(FirebaseAuth.instance.currentUser!.uid);

      // Initialize product stream

      setState(() {});
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(userPostsProvider(widget.uid));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final user = ref.watch(userProvider);

    final posts = ref.watch(userPostsProvider(widget.uid));
    final postNotifier = ref.read(userPostsProvider(widget.uid).notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      postNotifier.fetchUserPosts(widget.uid); // Fetch products
    });

    // Check if user is logged in
    bool isProfUser = FirebaseAuth.instance.currentUser!.uid ==
        widget.uid; // If user exists, they're logged in

    if (user == null) {
      return Center(
        child: Container(
          child: Text('User not found'),
        ),
      );
    }

//UserModel? user = Provider.of<UserProvider>(context).getUser;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: Text(
              widget.username ?? user.username,
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.menu,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  // Profile header with gradient border, user's avatar, name, and options icon.
                  // A widget that displays a profile section with icons, text, and buttons in a row layout.

                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        height: 70.h,
                        width: 70.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            center: FractionalOffset.center,
                            startAngle: 0.0,
                            endAngle: 2 * pi,
                            colors: [
                              ThemeUtils.dynamicTextColor(context),
                              Colors.green.withOpacity(0.8),
                              ThemeUtils.dynamicTextColor(context)
                            ],
                            //stops: const [0.0, 0.5, 1.0],
                            //transform: GradientRotation(controller.value * 3 * pi),
                          ),
                        ),
                      ),
                      Container(
                        height: 66.h,
                        width: 66.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkMode ? Colors.black : Colors.white,
                          border: Border.fromBorderSide(
                            BorderSide(
                              color: Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 35,
                          backgroundImage: CachedNetworkImageProvider(
                            widget.photoUrl ?? user.photoUrl,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  Text(
                    'Edappally, Kerala',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(posts.length.toString(), 'Posts', context),
                      StreamBuilder<DocumentSnapshot>(
                        stream: getUserStream(widget.uid),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data!.exists) {
                            followers = snapshot.data!['followers'].length;
                            return Column(
                              children: [
                                Text(
                                  followers.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color:
                                          ThemeUtils.dynamicTextColor(context)),
                                ),
                                Text('Followers',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Text(
                                  '0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      _buildStatItem(
                          following.toString(), 'Following', context),
                    ],
                  ),
                  SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FirebaseAuth.instance.currentUser!.uid == widget.uid
                          ? ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: Icon(Icons.logout,
                                  color: ThemeUtils.sameBrightness(context)),
                              onPressed: () async {
                                await AuthMethods().signOut();
                                if (context.mounted) {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                }
                              },
                              label: Text('Sign Out',
                                  style: TextStyle(
                                      color:
                                          ThemeUtils.sameBrightness(context))),
                            )
                          : isFollowing
                              ? ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: Icon(Icons.person_remove,
                                      color:
                                          ThemeUtils.sameBrightness(context)),
                                  onPressed: () async {
                                    await FireStoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid'],
                                    );

                                    setState(() {
                                      isFollowing = false;
                                      followers--;
                                    });
                                  },
                                  label: Text('Unfollow',
                                      style: TextStyle(
                                          color: ThemeUtils.sameBrightness(
                                              context))),
                                )
                              : ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: Icon(Icons.person_add,
                                      color:
                                          ThemeUtils.sameBrightness(context)),
                                  onPressed: () async {
                                    await FireStoreMethods().followUser(
                                      FirebaseAuth.instance.currentUser!.uid,
                                      userData['uid'],
                                    );

                                    setState(() {
                                      isFollowing = true;
                                      followers++;
                                    });
                                  },
                                  label: Text('Follow',
                                      style: TextStyle(
                                          color: ThemeUtils.sameBrightness(
                                              context))),
                                ),
                      SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(Icons.message,
                            color: ThemeUtils.dynamicTextColor(context)),
                        label: Text('Message',
                            style: TextStyle(
                                color: ThemeUtils.dynamicTextColor(context))),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      _buildIconButton(AntDesign.twitter, context),
                    ],
                  ),
                  SizedBox(height: MySizes.spaceBtwItems),

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
                            color: ThemeUtils.dynamicTextColor(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                            onPressed: () {
                              Get.to(() => ProductScreen());
                            },
                            icon: Icon(
                              CupertinoIcons.arrow_right_circle,
                              color: AppColors.primaryColor,
                            ))
                      ],
                    ),
                  ),
                  // Live Restaurant Items - Horizontal Scroll

                  StreamBuilder<List<Product>>(
                    stream: _productStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      } else {
                        final products = snapshot.data!;
                        return SizedBox(
                          height: 75.h,
                          child: ListView.builder(
                              key: PageStorageKey('live_items'),
                              scrollDirection: Axis.horizontal,
                              itemCount: min(
                                  5, products.length), // Number of live items
                              itemBuilder: (context, index) {
                                final product = products[index];

                                return Padding(
                                  padding: EdgeInsets.only(
                                    left: 15.w,
                                    right: 0,
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 80.w,
                                        height: 80.h,
                                        decoration:
                                            getDynamicBoxDecoration(context),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15.r),
                                          child: Stack(
                                            children: [
                                              // Item Image
                                              Image.network(
                                                product.photoUrl,
                                                fit: BoxFit.cover,
                                                width: 80.w,
                                                height: 80.h,
                                              ), // Item Name Overlay
                                              Align(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Container(
                                                  width: 80.w,
                                                  color: Colors.black54,
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 2.h,
                                                      horizontal: 5.w),
                                                  child: Text(
                                                    'Mandhi periperi ${index + 1}',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10.sp,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.4),
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
                                            borderRadius:
                                                BorderRadius.circular(4.r),
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
                              }),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 10),

                  TabBar(
                    splashFactory: NoSplash.splashFactory,
                    dividerColor: Colors.transparent,
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                      insets: EdgeInsets.symmetric(horizontal: 30),
                    ),
                    tabs: [
                      Tab(
                          icon: Icon(Icons.grid_view,
                              color: AppColors.primaryColor)),
                      Tab(
                          icon: Icon(Icons.videocam,
                              color: Colors.grey.shade500)),
                      Tab(
                          icon: Icon(Icons.favorite,
                              color: Colors.grey.shade500)),
                    ],
                  ),

                  SizedBox(
                    height: 300,
                    child: TabBarView(children: [
                      RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: SizedBox(
                          height: 400,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio:
                                  0.8, // Adjusted for better layout
                            ),
                            padding: const EdgeInsets.all(8),
                            itemCount: posts.length,
                            itemBuilder: (context, index) {
                              final post = posts[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
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
                                          height:
                                              150, // Adjusted for uniformity
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
                                              style: TextStyle(
                                                  color: ThemeUtils
                                                      .dynamicTextColor(
                                                          context),
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
                        ),
                      ), // Center(child: Text("Video View")),
                      Center(child: Text("Favorites View")),
                      Center(child: Text("Favorites View")),
                    ]),
                  ),
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

Widget _buildStatItem(String value, String label, BuildContext context) {
  return Column(
    children: [
      Text(value,
          style: TextStyle(
              fontSize: 18,
              color: ThemeUtils.dynamicTextColor(context),
              fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 14, color: Colors.grey)),
    ],
  );
}

Widget _buildIconButton(IconData icon, BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: ThemeUtils.dynamicTextColor(context).withAlpha(200),
      shape: BoxShape.circle,
    ),
    child: IconButton(
      onPressed: () {},
      icon: Icon(Iconsax.location, color: ThemeUtils.sameBrightness(context)),
    ),
  );
}
