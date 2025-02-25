import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ontrack/models/comment_model.dart';
import 'package:ontrack/screens/profile_screen.dart';
import 'package:ontrack/utils/themes/theme_utils.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment; // Use Comment model instead of snapshot

  const CommentCard(
      {super.key, required this.comment, required Map<String, dynamic> snap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
              onTap: () {
                Get.to(
                  () => ProfileScreen(
                    uid: comment.uid,
                    username: comment.name,
                    photoUrl: comment.profilePic,
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(comment.profilePic),
                    fit: BoxFit.cover,
                  ),
                ),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: comment.name,
                          style: TextStyle(
                            color: ThemeUtils.dynamicTextColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${comment.text}',
                          style: TextStyle(
                              color: ThemeUtils.dynamicTextColor(context)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat.yMMMd().format(comment.datePublished),
                      style: TextStyle(
                        color: ThemeUtils.dynamicTextColor(context),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: const Icon(
              Icons.favorite,
              size: 16,
            ),
          )
        ],
      ),
    );
  }
}
