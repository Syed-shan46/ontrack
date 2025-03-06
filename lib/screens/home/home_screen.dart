import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:ontrack/common/animation/like_animation.dart';
import 'package:ontrack/common/style/app_style.dart';
import 'package:ontrack/common/style/heading.dart';
import 'package:ontrack/common/style/reusable_text.dart';
import 'package:ontrack/controller/post_controller.dart';
import 'package:ontrack/models/post_model.dart';
import 'package:ontrack/models/user_model.dart';
import 'package:ontrack/providers/post_provider.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/resources/firestore_methods.dart';
import 'package:ontrack/screens/comment/comment_screen.dart';
import 'package:ontrack/screens/home/widgets/banner_slider.dart';
import 'package:ontrack/screens/home/widgets/home_header.dart';
import 'package:ontrack/utils/constants/constants.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/helpers/box_decoration_helper.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';

final pageBucket = PageStorageBucket();

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  bool isLikeAnimating = false;
  FireStoreMethods fireStoreMethods = FireStoreMethods();
  List<bool> randomBooleans = [];

  List<bool> generateSpecificBooleans() {
    Random random = Random();
    return [true, false, ...List.generate(4, (_) => random.nextBool())];
  }

  Future<void> _fetchPosts() async {
    final postController = PostController();
    try {
      final posts = await postController.fetchPosts();
      if (!mounted) return; // Prevent state update if widget is disposed
      ref.read(postProvider.notifier).setPosts(posts);
    } catch (e) {
      if (mounted) {
        print('$e');
      }
    }
  }

  deletePost(String postId) async {
    try {
      await FireStoreMethods().deletePost(postId);
    } catch (err) {
      Get.snackbar('Error', err.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchPosts();
    randomBooleans = generateSpecificBooleans();
    _controller = AnimationController(
      duration: const Duration(seconds: 20), // Slow rotation speed
      vsync: this,
    )..repeat(); // Loop the animation
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, String>> dummyStories = [
    {"name": "John", "imageUrl": "https://picsum.photos/400/500?random=100"},
    {"name": "Eve", "imageUrl": "https://picsum.photos/400/500?random=200"},
    {"name": "Joe", "imageUrl": "https://picsum.photos/400/500?random=300"},
    {"name": "Doe", "imageUrl": "https://picsum.photos/400/500?random=400"},
    {"name": "Lor", "imageUrl": "https://picsum.photos/400/500?random=500"},
    {"name": "ipsum", "imageUrl": "https://picsum.photos/400/500?random=600"},
  ];

  final List<String> names = [
    'Lulu HyperMarket',
    'McDonalds',
    'Burger King',
    'Pizza Hut',
    'Dominos',
    'Starbucks',
  ];

  final List<String> foods = [
    'Burger',
    'Pizza',
    'Fries',
    'Coffee',
    'Donut',
    'Sandwich',
    'Pasta',
    'Ice Cream',
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
// Handle empty list case

    final posts = ref.watch(postProvider);
    //final postNotifier = ref.read(postProvider.notifier);

    // Load Curry and Fry products when the widget is first built
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   postNotifier.fetchPosts(); // Fetch products
    // });
    final user = ref.watch(userProvider);
    return Scaffold(
      // Appbar
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h), child: const HomeHeader()),
      body: SingleChildScrollView(
        child: PageStorage(
          bucket: pageBucket,
          child: Column(
            children: [
              // Status / Stories
              SizedBox(
                height: 75.h, // Height of the story section
                child: ListView.builder(
                  key: PageStorageKey<String>('stories'),
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: dummyStories.length,
                  itemBuilder: (context, index) {
                    return buildStory(dummyStories[index], _controller,
                        isDarkMode, context); // Build story
                  },
                ),
              ),
              SizedBox(height: MySizes.spaceBtwItems / 2),

              // Banner slider
              MyBannerSlider(),

              // Category Tabbar
              CategoryTabbar(
                isDarkMode: isDarkMode,
                foods: foods,
                names: names,
              ),

              // Recommended blogs
              Heading(title: 'Recommeded'),
              Blogs(),
              SizedBox(height: MySizes.spaceBtwSections),
              Blogs(),

              SizedBox(height: MySizes.spaceBtwItems),
              Heading(title: 'Trending'),
              TrendingHotels(names: names),
              SizedBox(height: MySizes.spaceBtwSections),

              // Restaurant posts
              restaurnatPosts(posts, user),
            ],
          ),
        ),
      ),
    );
  }

  ListView restaurnatPosts(List<Post> posts, UserModel? user) {
    return ListView.builder(
      controller: _scrollController,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(
              horizontal: MySizes.spaceBtwItems / 2, vertical: 5.h),
          child: Container(
            decoration: getDynamicBoxDecoration(context),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User details
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://picsum.photos/400/500?random=300',
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Text(
                        posts[index].username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ThemeUtils.dynamicTextColor(context),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Edappally .',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: ThemeUtils.dynamicTextColor(context),
                            ),
                          ),
                          SizedBox(width: 2),
                          Text(
                            '1 mins ago',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: ThemeUtils.dynamicTextColor(context),
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(Icons.public, color: Colors.grey, size: 10.sp),
                        ],
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_horiz,
                        color: ThemeUtils.dynamicTextColor(context)),
                    onPressed: () {},
                  ),
                ),
                GestureDetector(
                  onDoubleTap: () async {
                    ref.read(postProvider.notifier).toggleLike(
                        posts[index].postId, user!.uid, posts[index].likes);
                    if (mounted) {
                      setState(() {
                        isLikeAnimating = true;
                      });
                    }
                  },
                  // Image
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 13, vertical: 5),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: CachedNetworkImage(
                            imageUrl: posts[index].postUrl,
                            height: 230.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isLikeAnimating ? 1 : 0,
                        child: LikeAnimation(
                          isAnimating: isLikeAnimating,
                          duration: const Duration(
                            milliseconds: 400,
                          ),
                          onEnd: () {
                            if (mounted) {
                              setState(() {
                                isLikeAnimating = false;
                              });
                            }
                          },
                          child: const Icon(
                            Icons.favorite,
                            color: Colors.white,
                            size: 120,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 5.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                      'Best food in town i have ever tasted in my life and i will recommend this to everyone #BestFood #Foodie',
                      style: TextStyle(
                        color: ThemeUtils.dynamicTextColor(context),
                        fontSize: 10.sp,
                      )),
                ),
                SizedBox(height: 5.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    height: 6,
                    color: Colors.grey[500],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          LikeAnimation(
                            isAnimating: posts[index].likes.contains(user!.uid),
                            child: Row(
                              children: [
                                IconButton(
                                  icon: posts[index].likes.contains(user.uid)
                                      ? Icon(Icons.thumb_up, color: Colors.red)
                                      : Icon(Icons.thumb_up_outlined,
                                          color: ThemeUtils.dynamicTextColor(
                                              context)),
                                  onPressed: () => ref
                                      .read(postProvider.notifier)
                                      .toggleLike(posts[index].postId, user.uid,
                                          posts[index].likes),
                                ),
                                Text(
                                  '${posts[index].likeCount} ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          ThemeUtils.dynamicTextColor(context)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5.w),
                          IconButton(
                            icon: Row(
                              children: [
                                Icon(
                                  Iconsax.message,
                                  color: ThemeUtils.dynamicTextColor(context),
                                ),
                                SizedBox(width: 5.w),
                                Text(
                                  '3 ',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color:
                                          ThemeUtils.dynamicTextColor(context)),
                                ),
                              ],
                            ),
                            onPressed: () {
                              Get.to(
                                () => CommentsScreen(
                                  postId: posts[index].postId,
                                  username: user.username,
                                  uid: posts[index].uid,
                                  profilePic: user.photoUrl,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: 5.w),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Iconsax.bookmark,
                              color: ThemeUtils.dynamicTextColor(context),
                            ),
                            onPressed: () {},
                          ),
                          IconButton(
                            icon: Icon(
                              Iconsax.send_2,
                              color: ThemeUtils.dynamicTextColor(context),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrendingHotels extends StatelessWidget {
  const TrendingHotels({
    super.key,
    required this.names,
  });

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110.h,
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
                Column(
                  children: [
                    Container(
                      width: 90.w,
                      height: 80.h,
                      decoration: getDynamicBoxDecoration(context),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: Stack(
                          children: [
                            // Item Image
                            Image.asset(
                              'assets/images/r$index.jpg',
                              fit: BoxFit.cover,
                              width: 90.w,
                              height: 80.h,
                            ), // Item Name Overlay

                            Positioned(
                              top: -15,
                              child: SizedBox(
                                height: 80.h,
                                width: 80.w,
                                child: Lottie.asset(
                                  'assets/animation/closed.json',
                                  width: 80.w,
                                  height: 80.h,
                                  onLoaded: (composition) {
                                    print('Lottie animation loaded');
                                  },
                                  errorBuilder: (context, object, stacktrace) {
                                    print('Lottie animation error: $object');
                                    return const Text("Lottie Error");
                                  },
                                ),
                              ),
                            ),

                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 100.w,
                                color: Colors.black54,
                                padding: EdgeInsets.symmetric(
                                    vertical: 2.h, horizontal: 5.w),
                                child: Text(
                                  names[index],
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
                    SizedBox(height: 5.h),
                    // Follow button
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.07,
                          vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Colors.white,
                            size: 10.sp,
                          ),
                          Text('Follow',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                              )),
                        ],
                      ),
                    )
                  ],
                ),
                // Add Button

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
                      color: AppColors.primaryColor,
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
    );
  }
}

class Blogs extends StatelessWidget {
  const Blogs({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MySizes.spaceBtwItems),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                child: Image(
                  image: AssetImage('assets/images/restaurant.jpg'),
                  width: 120.w,
                  height: 90.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Blog description
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Crossroads',
                style: TextStyle(color: Colors.blueGrey),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 180.w,
                child: Text(
                  'Food is more than just an experience, a story, and a journey. Whether you\'re a foodie searching for hidden gems or a casual diner looking for the next best meal,',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: ThemeUtils.dynamicTextColor(context),
                  ),
                ),
              ),
              SizedBox(height: 5),
              // Profile row
              Row(
                children: [
                  SizedBox(
                    height: 30.h,
                    width: 30.w,
                    child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            'https://picsum.photos/400/500?random=300')),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'John Doe',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  SizedBox(width: 6),
                  Text('.'),
                  SizedBox(width: 6),
                  Text(
                    'Feb 28,2025',
                    style: TextStyle(color: Colors.blueGrey),
                  )
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}

class CategoryTabbar extends StatelessWidget {
  const CategoryTabbar({
    super.key,
    required this.isDarkMode,
    required this.foods,
    required this.names,
  });

  final bool isDarkMode;
  final List<String> foods;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          TabBar(
            tabAlignment: TabAlignment.start,
            labelPadding: EdgeInsets.symmetric(horizontal: 12.w),
            dragStartBehavior: DragStartBehavior.start,
            splashFactory: NoSplash.splashFactory,
            dividerColor: Colors.transparent,
            unselectedLabelStyle: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            isScrollable: true,
            labelStyle: TextStyle(
              color: ThemeUtils.dynamicTextColor(context),
              fontWeight: FontWeight.bold,
            ),
            indicator: DotIndicator(
              // Indicator
              color: AppColors.primaryColor,
              distanceFromCenter: 12,
              radius: 2.3,
            ),
            tabs: [
              Tab(
                text: 'Cakes',
              ),
              Tab(
                text: 'Rice',
              ),
              Tab(
                text: 'Burger',
              ),
              Tab(
                text: 'Pizza',
              ),
              Tab(
                text: 'Chicken',
              ),
              Tab(
                text: 'Drumstick',
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            height: 160.h,
            child: TabBarView(
              children: [
                // Cakes
                Stack(
                  children: [
                    SizedBox(
                      height: 150.h,
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),

                        scrollDirection: Axis.horizontal,
                        key: PageStorageKey('live_items'),
                        itemCount: 3, // Number of items
                        clipBehavior: Clip.none,

                        itemBuilder: (context, index) {
                          return GestureDetector(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: 12.w,
                              ),
                              child: LayoutBuilder(
                                  builder: (context, constraints) {
                                return Container(
                                  width: width * .39,
                                  decoration: getDynamicBoxDecoration(context),
                                  child: Column(
                                    // Use Column instead of ListView
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Image Section
                                      Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(12.w),
                                              topRight: Radius.circular(12.w),
                                            ),
                                            child: SizedBox(
                                              height: 100.h,
                                              width: width * 0.8,
                                              child: Image.asset(
                                                'assets/images/food$index.jpg',
                                                fit: BoxFit.cover,
                                              ).animate(delay: 400.ms).shimmer(
                                                    duration: 1000.ms,
                                                  ),
                                            ),
                                          ),

                                          // Name Overlay
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              color: Colors.black54,
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 1.h,
                                                  horizontal: 5.w),
                                              child: Text(
                                                names[index],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),

                                          // Favorite Button
                                          Positioned(
                                            right: 3.w,
                                            top: 3.h,
                                            child: AnimatedSwitcher(
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              transitionBuilder:
                                                  (child, animation) {
                                                return ScaleTransition(
                                                    scale: animation,
                                                    child: child);
                                              },
                                              child: IconButton(
                                                onPressed: () {},
                                                icon: Icon(
                                                  Icons.favorite_outline,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),

                                          // Product availability
                                          // Positioned(
                                          //   top: 40.h,
                                          //   left: 10.w,
                                          //   child: widget.product.isAvailable
                                          //       ? const SizedBox()
                                          //       : Container(
                                          //           padding:
                                          //               const EdgeInsets.all(4),
                                          //           decoration:
                                          //               const BoxDecoration(
                                          //                   color: Colors.red),
                                          //           child: const Text(
                                          //             'Currently Not Available',
                                          //             style: TextStyle(
                                          //                 color: Colors.white),
                                          //           ),
                                          //         ),
                                          // )
                                        ],
                                      ),
                                      // Details Section
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 5.w, right: 5.w, top: 12.w),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ReusableText(
                                                  text: foods[index],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13.sp,
                                                    color: ThemeUtils
                                                        .dynamicTextColor(
                                                            context),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(Iconsax.clock,
                                                        color: ThemeUtils
                                                            .dynamicTextColor(
                                                                context),
                                                        size: 14.sp),
                                                    ReusableText(
                                                      text: ' 30 min',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 12.sp,
                                                        color: ThemeUtils
                                                            .dynamicTextColor(
                                                                context),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ReusableText(
                                                  text: '\$10',
                                                  style: appStyle(
                                                      12,
                                                      AppColors.primaryColor,
                                                      FontWeight.w600),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 5),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.star,
                                                        color: AppColors
                                                            .primaryColor,
                                                        size: 14.sp,
                                                      ),
                                                      ReusableText(
                                                        text: '4.5',
                                                        style: appStyle(
                                                            12,
                                                            ThemeUtils
                                                                .dynamicTextColor(
                                                                    context),
                                                            FontWeight.w500),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                Center(child: Text("Rice Content")),
                Center(child: Text("Burger Content")),
                Center(child: Text("Pizza Content")),
                Center(child: Text("Chicken Content")),
                Center(child: Text("Drumstick Content")),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BestFoods extends StatelessWidget {
  const BestFoods({
    super.key,
    required this.foods,
  });

  final List<String> foods;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: getDynamicBoxDecoration(context),
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
                        ), // Item Name Overlay
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 80.w,
                            color: Colors.black54,
                            padding: EdgeInsets.symmetric(
                                vertical: 2.h, horizontal: 5.w),
                            child: Text(
                              foods[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Add Button

                // Faoruite
                Positioned(
                  right: 2.w,
                  top: 0.w,
                  child: Container(
                    width: 30.w,
                    height: 30.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(scale: animation, child: child);
                      },
                      child: IconButton(
                        onPressed: () {},
                        highlightColor: Colors.transparent,
                        icon: Icon(
                          Iconsax.heart,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                //  Add to cart btn
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12.r),
                              bottomRight: Radius.circular(12.r)),
                          color: ThemeUtils.dynamicTextColor(context)
                              .withAlpha(200),
                          shape: BoxShape.rectangle),
                      width: 30.w,
                      height: 25.h,
                      child: Icon(
                        Icons.add,
                        color: ThemeUtils.sameBrightness(context),
                      ),
                    )),

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
                      color: Colors.yellowAccent,
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
    );
  }
}

Widget buildStory(Map<String, String> user, AnimationController controller,
    bool isdarkMode, BuildContext context) {
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: controller, // Listen for changes in controller value
            builder: (context, child) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                height: 52.h,
                width: 52.w,
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
              );
            },
          ),
          Container(
            height: 48.h,
            width: 48.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isdarkMode ? Colors.black : Colors.white,
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
              backgroundImage: NetworkImage(user["imageUrl"]!),
            ),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Text(user["name"]!,
          style: TextStyle(
            color: ThemeUtils.dynamicTextColor(context),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          )),
    ],
  );
}
