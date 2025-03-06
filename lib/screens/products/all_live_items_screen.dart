import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ontrack/models/product_model.dart';

class AllLiveItemsScreen extends StatefulWidget {
  final String uid;
  const AllLiveItemsScreen({super.key, required this.uid});

  @override
  State<AllLiveItemsScreen> createState() => _AllLiveItemsScreenState();
}

class _AllLiveItemsScreenState extends State<AllLiveItemsScreen> {
  bool isProfUser = false;
  late Stream<List<Product>> _productStream;

  @override
  void initState() {
    super.initState();
    _initializeProductStream();
    isProfUser = FirebaseAuth.instance.currentUser!.uid == widget.uid;
  }

  void _initializeProductStream() {
    _productStream = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .collection('products')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  // Moved _buildAppBar to the top
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16),
      height: 80,
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'Menu Items',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/menu-bg1.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay
          Container(
            color: Colors.black.withAlpha(220), // Dark transparent layer
          ),
          // App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildAppBar(context),
          ),
          // Product List
          Positioned.fill(
            top: 90, // Adjusted to leave space for the AppBar
            child: StreamBuilder<List<Product>>(
              stream: _productStream,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final products = snapshot.data!;
                  if (products.isEmpty) {
                    return const Center(
                      child: Text(
                        "No live items available",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        color: Colors.transparent,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: product.photoUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: product.photoUrl,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    height: 50,
                                    width: 50,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 30),
                                  ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(
                              color: Colors.white.withAlpha(150),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Text(
                            '\₹${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white)));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
