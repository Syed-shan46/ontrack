import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:ontrack/common/style/app_style.dart';
import 'package:ontrack/providers/search_provider.dart';
import 'package:ontrack/screens/profile_screen.dart';
import 'package:ontrack/utils/themes/app_colors.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: CupertinoSearchTextField(
          controller: _searchController,
          style: TextStyle(color: ThemeUtils.dynamicTextColor(context)),
          placeholder: 'Search',
          onChanged: (value) {
            ref.read(searchQueryProvider.notifier).state = value.trim();
          },
        ),
      ),
      body: searchResults.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No users found.'));
          }
          return ListView.separated(
            padding: EdgeInsets.all(10),
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => ProfileScreen(
                        uid: user.uid,
                        username: user.username,
                        photoUrl: user.photoUrl,
                      ));
                },
                child: Container(
                  height: 70.h,
                  padding: EdgeInsets.all(5.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                              width: 60,
                              height: 60,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        user.photoUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: appStyle(
                                  14,
                                  ThemeUtils.dynamicTextColor(context)
                                      .withOpacity(0.8),
                                  FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Delivery in 30 mins',
                                style: appStyle(
                                    11,
                                    ThemeUtils.dynamicTextColor(context)
                                        .withOpacity(0.8),
                                    FontWeight.normal),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentColor
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      'Al-fahm',
                                      style: appStyle(
                                        8.sp,
                                        Colors.white,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentColor
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      'Mandhi',
                                      style: appStyle(
                                        8.sp,
                                        Colors.white,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentColor
                                          .withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      'Biriyani',
                                      style: appStyle(
                                        8.sp,
                                        Colors.white,
                                        FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white.withOpacity(0.9),
                              size: 12,
                            ),
                            const SizedBox(width: 2),
                            Text('4.2',
                                style: appStyle(
                                  11.sp,
                                  Colors.white.withOpacity(0.9),
                                  FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () =>
            Center(child: Lottie.asset('assets/animation/search.json')),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
