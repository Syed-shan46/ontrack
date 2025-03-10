import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ontrack/common/animation/like_animation.dart';
import 'package:ontrack/common/style/heading.dart';
import 'package:ontrack/controller/post_controller.dart';
import 'package:ontrack/models/post_model.dart';
import 'package:ontrack/models/user_model.dart';
import 'package:ontrack/providers/post_provider.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/resources/firestore_methods.dart';
import 'package:ontrack/screens/comment/comment_screen.dart';
import 'package:ontrack/screens/home/widgets/blogs.dart';
import 'package:ontrack/screens/home/widgets/banner_slider.dart';
import 'package:ontrack/screens/home/widgets/category_tabbar.dart';
import 'package:ontrack/screens/home/widgets/home_header.dart';
import 'package:ontrack/screens/home/widgets/trending_hotels.dart';
import 'package:ontrack/utils/constants/sizes.dart';
import 'package:ontrack/utils/helpers/box_decoration_helper.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

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

              Container(
                color: AppColors.accentColor,
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12, right: 12, top: 5, bottom: 12),
                  child: CupertinoSearchTextField(
                    prefixIcon: Icon(
                      Icons.search,
                      size: 25.sp,
                      color: Colors.grey,
                    ),
                    placeholder: 'Search for food, restaurants, etc...',
                    style: GoogleFonts.poppins(
                      color: ThemeUtils.dynamicTextColor(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    itemSize: 15,
                    itemColor: ThemeUtils.dynamicTextColor(context),
                    onChanged: (value) {
                      print(value);
                    },
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: AppColors.accentColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
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

              SizedBox(height: MySizes.spaceBtwItems),

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

              user == null
                  ? SizedBox(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text(
                          'view posts',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  : restaurnatPosts(posts, user),

              SizedBox(height: MySizes.spaceBtwSections * 2),
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
                height: 48.h,
                width: 48.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(220),
                ),
              );
            },
          ),
          Container(
            height: 44.h,
            width: 44.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentColor,
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
      Text(user["name"]!,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          )),
    ],
  );
}
