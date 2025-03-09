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
import 'package:ontrack/models/post_model.dart';
import 'package:ontrack/models/product_model.dart';
import 'package:ontrack/providers/post_by_user_provider.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/resources/firestore_methods.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:ontrack/screens/products/all_live_items_screen.dart';
import 'package:ontrack/screens/setttings/settings_screen.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/helpers/box_decoration_helper.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  final String username;
  final String photoUrl;
  const UserProfileScreen({
    super.key,
    required this.uid,
    required this.username,
    required this.photoUrl,
  });

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
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
      print('Error: $e');
    }
    setState(() {
      isLoading = false;
    });
  }

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final posts = ref.watch(userPostsProvider(widget.uid));

    final postNotifier = ref.read(userPostsProvider(widget.uid).notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      postNotifier.fetchUserPosts(widget.uid); // Fetch products
    });

    // Check if user is logged in

//UserModel? user = Provider.of<UserProvider>(context).getUser;

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: profileAppBar(),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  // Profile
                  profileImage(context, isDarkMode),
                  SizedBox(height: 10),

                  // User Location
                  userLocation(),
                  SizedBox(height: 15),

                  // User Stats
                  userStats(posts, context),
                  SizedBox(height: 15),

                  // Follow, Message, Location Buttons
                  buttonsRow(context),
                  SizedBox(height: MySizes.spaceBtwItems),

                  // Live Header
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
                            onPressed: () => Get.to(() => AllLiveItemsScreen(
                                  uid: widget.uid,
                                )),
                            icon: Icon(
                              CupertinoIcons.arrow_right_circle,
                              color: AppColors.primaryColor,
                            ))
                      ],
                    ),
                  ),

                  // Live Restaurant Items - Horizontal Scroll
                  liveProductItems(isDarkMode),
                  const SizedBox(height: 10),

                  // TabBar Section
                  tabBarSection(),

                  // TabBarView Section
                  tabBarViewSection(posts),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  AppBar profileAppBar() {
    return AppBar(
      centerTitle: true,
      elevation: 0,
      title: Text(
        widget.username,
      ),
      actions: [
        IconButton(
          onPressed: () => Get.to(() => SettingsScreen()),
          icon: Icon(
            Icons.menu,
          ),
        ),
      ],
    );
  }

  StreamBuilder<List<Product>> liveProductItems(bool isDarkMode) {
    return StreamBuilder<List<Product>>(
      stream: _productStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox.shrink();
        } else {
          final products = snapshot.data!;
          return SizedBox(
            height: 75.h,
            child: ListView.builder(
                key: PageStorageKey('live_items'),
                scrollDirection: Axis.horizontal,
                itemCount: min(5, products.length), // Number of live items
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
                          decoration: getDynamicBoxDecoration(context),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15.r),
                              child: Stack(
                                children: [
                                  // Item Image
                                  CachedNetworkImage(
                                    imageUrl: product.photoUrl,
                                    fit: BoxFit.cover,
                                    width: 80.w,
                                    height: 80.h,
                                  ),
                                  // "Not Available" Overlay if product is unavailable
                                  if (!product.isAvailable)
                                    Container(
                                      width: 80.w,
                                      height: 80.h,
                                      color: Colors.black
                                          .withOpacity(0.6), // Dark overlay
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Not Available",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
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
                                        product.name,
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
                              )),
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
                }),
          );
        }
      },
    );
  }

  SizedBox tabBarViewSection(List<Post> posts) {
    return SizedBox(
      height: 300.h,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // grid view
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
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
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      post.postUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 150, // Adjusted for uniformity
                                    ),
                                  ),
                                  Positioned(
                                      left: 5.w,
                                      bottom: 0,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.favorite_rounded,
                                            color: Colors.white.withAlpha(200),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            "${post.likeCount}",
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // video view
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                    ),
                    itemCount: postLen,
                    itemBuilder: (context, index) {
                      return Container(
                        color: Colors.blue,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TabBar tabBarSection() {
    return TabBar(
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
        Tab(icon: Icon(Icons.grid_view, color: AppColors.primaryColor)),
        Tab(icon: Icon(Icons.videocam, color: Colors.grey.shade500)),
      ],
    );
  }

  Row buttonsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sign Out Button
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
                  ref.read(userProvider.notifier).logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
                label: Text('Sign Out',
                    style:
                        TextStyle(color: ThemeUtils.sameBrightness(context))),
              )
            // Unfollow Button
            : isFollowing
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.person_remove,
                        color: ThemeUtils.sameBrightness(context)),
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
                            color: ThemeUtils.sameBrightness(context))),
                  )
                // Follow Button
                : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: Icon(Icons.person_add,
                        color: ThemeUtils.sameBrightness(context)),
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
                            color: ThemeUtils.sameBrightness(context))),
                  ),
        SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () {},
          icon:
              Icon(Icons.message, color: ThemeUtils.dynamicTextColor(context)),
          label: Text('Message',
              style: TextStyle(color: ThemeUtils.dynamicTextColor(context))),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        SizedBox(width: 10),
        _buildIconButton(AntDesign.twitter, context),
      ],
    );
  }

  Row userStats(List<Post> posts, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // total posts,
        _buildStatItem(posts.length.toString(), 'Posts', context),
        // followers
        StreamBuilder<DocumentSnapshot>(
          stream: getUserStream(widget.uid!),
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
                        color: ThemeUtils.dynamicTextColor(context)),
                  ),
                  Text('Followers',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
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
        // following
        _buildStatItem(following.toString(), 'Following', context),
      ],
    );
  }

  Text userLocation() {
    return Text(
      'Edappally, Kerala',
      style: TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  Stack profileImage(BuildContext context, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Gradient Circle
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
                AppColors.primaryColor.withOpacity(0.8),
                ThemeUtils.dynamicTextColor(context)
              ],
              //stops: const [0.0, 0.5, 1.0],
              //transform: GradientRotation(controller.value * 3 * pi),
            ),
          ),
        ),
        // Profile Image
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
              widget.photoUrl ??
                  'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
            ),
          ),
        ),
      ],
    );
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
        Tab(
          icon: Icon(Iconsax.grid_3),
        ),
        Tab(
          icon: Icon(Iconsax.video),
        ),
        Tab(icon: Icon(Iconsax.tag)),
      ],
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
