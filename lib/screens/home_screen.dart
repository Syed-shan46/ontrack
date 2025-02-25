import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ontrack/common/animation/like_animation.dart';
import 'package:ontrack/controller/post_controller.dart';
import 'package:ontrack/providers/post_by_user_provider.dart';
import 'package:ontrack/providers/post_provider.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/resources/firestore_methods.dart';
import 'package:ontrack/screens/comment/comment_screen.dart';
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

  @override
  List<Map<String, String>> dummyStories = [
    {"name": "John", "imageUrl": "https://picsum.photos/400/500?random=100"},
    {"name": "Eve", "imageUrl": "https://picsum.photos/400/500?random=200"},
    {"name": "Joe", "imageUrl": "https://picsum.photos/400/500?random=300"},
    {"name": "Doe", "imageUrl": "https://picsum.photos/400/500?random=400"},
    {"name": "Lor", "imageUrl": "https://picsum.photos/400/500?random=500"},
    {"name": "ipsum", "imageUrl": "https://picsum.photos/400/500?random=600"},
  ];

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postProvider);
    //final postNotifier = ref.read(postProvider.notifier);

    // Load Curry and Fry products when the widget is first built
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   postNotifier.fetchPosts(); // Fetch products
    // });
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '𝒪𝓃𝓉𝓇𝒶𝒸𝓀',
          style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: ThemeUtils.dynamicTextColor(context)),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Iconsax.message_2,
            ),
            onPressed: () {
              ref.read(userProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: PageStorage(
        bucket: pageBucket,
        child: SingleChildScrollView(
          key: PageStorageKey('home_scroll'),
          child: Column(
            children: [
              SizedBox(
                height: 75.h, // Height of the story section
                child: ListView.builder(
                  key: PageStorageKey<String>('stories'),
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: dummyStories.length,
                  itemBuilder: (context, index) {
                    return buildStory(dummyStories[index], _controller);
                  },
                ),
              ),
              ListView.builder(
                controller: _scrollController,
                key: PageStorageKey<String>('posts'),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: posts.length, // Number of posts
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: SizedBox(
                            height: 40.h,
                            width: 40.w,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: CachedNetworkImageProvider(
                                    posts[index].profImage,
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            posts[index].username,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.sp,
                              color: ThemeUtils.dynamicTextColor(context),
                            ),
                          ),
                          subtitle: Text(
                            'Edappally, Kerala',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 11.sp,
                            ),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.more_horiz,
                              color: Colors.blueGrey,
                            ),
                            onPressed: () {},
                          ),
                        ),
                        GestureDetector(
                          onDoubleTap: () async {
                            ref.read(postProvider.notifier).toggleLike(
                                posts[index].postId,
                                user!.uid,
                                posts[index].likes);
                            setState(() {
                              isLikeAnimating = true;
                            });
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.r),
                                child: CachedNetworkImage(
                                  imageUrl: posts[index].postUrl,
                                  height: 250.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
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
                                    setState(() {
                                      isLikeAnimating = false;
                                    });
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
                        Padding(
                          padding: EdgeInsets.symmetric(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  LikeAnimation(
                                    isAnimating:
                                        posts[index].likes.contains(user!.uid),
                                    child: IconButton(
                                      icon: posts[index]
                                              .likes
                                              .contains(user.uid)
                                          ? Icon(Iconsax.heart5,
                                              color: Colors.red)
                                          : Icon(Iconsax.heart,
                                              color:
                                                  ThemeUtils.dynamicTextColor(
                                                      context)),
                                      onPressed: () => ref
                                          .read(postProvider.notifier)
                                          .toggleLike(posts[index].postId,
                                              user.uid, posts[index].likes),
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.message,
                                      color:
                                          ThemeUtils.dynamicTextColor(context),
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
                                  IconButton(
                                    icon: Icon(
                                      Iconsax.send_2,
                                      color:
                                          ThemeUtils.dynamicTextColor(context),
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(
                                  Iconsax.bookmark,
                                  color: ThemeUtils.dynamicTextColor(context),
                                ),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            '${posts[index].likeCount} likes',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: ThemeUtils.dynamicTextColor(context)),
                          ),
                        ),
                        // Padding(
                        //   padding: EdgeInsets.symmetric(
                        //       horizontal: 12.w, vertical: 5.h),
                        //   child: Text(
                        //     'Liked by ${posts[index].likes.join(', ')}',
                        //     style: TextStyle(
                        //       color: ThemeUtils.dynamicTextColor(context),
                        //       fontSize: 14.sp,
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 5.h),
                          child: Text(
                            posts[index].description,
                            style: TextStyle(
                              color: ThemeUtils.dynamicTextColor(context),
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 12.w, vertical: 3.h),
                          child: Text(
                            'View all 20 comments',
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildStory(Map<String, String> user, AnimationController controller) {
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
                      Colors.green.withOpacity(0.8),
                      Colors.red.withOpacity(0.8),
                      Colors.green.withOpacity(0.8),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                    transform: GradientRotation(controller.value * 3 * pi),
                  ),
                ),
              );
            },
          ),
          Container(
            height: 46.h,
            width: 46.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
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
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          )),
    ],
  );
}
