import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ontrack/models/product_model.dart';
import 'package:ontrack/utils/themes/app_colors.dart';

class AllLiveItemsScreen extends StatefulWidget {
  final String uid;
  const AllLiveItemsScreen({super.key, required this.uid});

  @override
  State<AllLiveItemsScreen> createState() => _AllLiveItemsScreenState();
}

class _AllLiveItemsScreenState extends State<AllLiveItemsScreen> {
  late Stream<List<Product>> _productStream;

  @override
  void initState() {
    super.initState();
    _initializeProductStream();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        flexibleSpace: Stack(
          children: [
            // Background Image
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/menu-bg1.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay (Semi-transparent black layer)
            Container(
              color: Colors.black.withAlpha(170), // Adjust opacity as needed
            ),
          ],
        ),
        title: CupertinoSearchTextField(
          style: TextStyle(color: Colors.white),
          placeholder: 'Search',
          onChanged: (value) {
            // ref.read(searchQueryProvider.notifier).state = value.trim();
          },
        ),
        backgroundColor:
            Colors.transparent, // Make the app bar background transparent
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/menu-bg1.jpg"),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Container(
            color: Colors.black.withAlpha(170),
          ),
          StreamBuilder<List<Product>>(
            stream: _productStream,
            builder: (context, snapshot) {
              print('widget uid: ${widget.uid}');
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
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
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: Text(
                          '₹${product.price.toString()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(150),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.white)),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}
