import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 10, // Number of reels
        itemBuilder: (context, index) {
          return Stack(
            children: [
              // Video Container (Replace with video player)
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://picsum.photos/500/800?random=$index',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Gradient Overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // Reels Info and Actions
              Positioned(
                left: 15,
                bottom: 60,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '@username',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'This is an awesome reel description #hashtag',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Iconsax.music, color: Colors.white, size: 18),
                        SizedBox(width: 5),
                        Text(
                          'Original Audio - Artist Name',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Right Side Action Buttons
              Positioned(
                right: 10,
                bottom: 80,
                child: Column(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.heart, color: Colors.white),
                    ),
                    const Text(
                      '1.2K',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.message, color: Colors.white),
                    ),
                    const Text(
                      '345',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Iconsax.share, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
