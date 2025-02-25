import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ontrack/models/comment_model.dart';
import 'package:ontrack/providers/comment_provider.dart';
import 'package:ontrack/providers/user_provider.dart';
import 'package:ontrack/screens/authentication/login_screen.dart';
import 'package:ontrack/screens/comment/widgets/comment_card.dart';
import 'package:uuid/uuid.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  final String username;
  final String uid;
  final String profilePic;

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.username,
    required this.uid,
    required this.profilePic,
  });

  @override
  ConsumerState createState() => CommentsScreenState();
}

class CommentsScreenState extends ConsumerState<CommentsScreen> {
  final TextEditingController commentEditingController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(commentProvider.notifier).fetchComments(widget.postId));
  }

  Future<void> postComment() async {
    final user = ref.read(userProvider);
    if (user == null || commentEditingController.text.trim().isEmpty) return;

    String commentId = const Uuid().v1();
    Comment newComment = Comment(
      profilePic: widget.profilePic,
      name: widget.username,
      uid: user.uid,
      text: commentEditingController.text.trim(),
      commentId: commentId,
      datePublished: DateTime.now(),
    );

    await ref
        .read(commentProvider.notifier)
        .addComment(widget.postId, newComment);
    commentEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final comments = ref.watch(commentProvider); // Watch comments from state

    if (user == null) {
      return LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: comments.isEmpty
          ? const Center(child: Text("No comments yet"))
          : ListView.builder(
              itemCount: comments.length,
              itemBuilder: (ctx, index) {
                return CommentCard(
                  snap: comments[index].toMap(),
                  comment: comments[index],
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(user!.photoUrl),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    controller: commentEditingController,
                    decoration: InputDecoration(
                      hintStyle:
                          TextStyle(fontSize: 14, color: Colors.blueGrey),
                      hintText: 'Comment as ${user.username}',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: postComment,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
