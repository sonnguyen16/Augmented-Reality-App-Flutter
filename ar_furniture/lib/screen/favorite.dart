import 'package:ar_furniture/component/product.dart';

import '../constant/color.dart';
import 'package:flutter/material.dart';
import '../object/product.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Products> products = [];
  List<Products> productsFavorite = [];
  bool _isLoadingProducts = true;

  void getProductsFromFireBase() {
    var products = FirebaseDatabase.instance.ref().child("Models");
    List<Products> list = [];
    products.onValue.listen((event) {
      for (var product in event.snapshot.children) {
        if (product.child("isShow").value as bool == true) {
          list.add(Products(
              key: product.key as String,
              name: product.child("name").value as String,
              image: product.child("image").value as String,
              model: product.child("model").value as String,
              price: product.child("price").value as int,
              category: product.child("category").value as String,
              favorite: product.child("favorite").value as int,
              isShow: product.child("isShow").value as bool,
              material: product.child("material").value as String,
              description: product.child("description").value as String));
        }
      }

      if (!_isDisposed) {
        setState(() {
          this.products = list;
        });
      }

      getFavorite();
    });
  }

  void getFavorite() {
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var favorite = FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(phone)
        .child("favorite");

    List<Products> list = [];

    favorite.get().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        String jsonString = json.encode(dataSnapshot.value);
        List<dynamic> values = json.decode(jsonString);
        for (var element in values) {
          list.add(products[element]);
        }
      } else {}

      if (!_isDisposed) {
        setState(() {
          productsFavorite = list;
          _isLoadingProducts = false;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getProductsFromFireBase();
  }

  bool _isDisposed = false;
  @override
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Intro favorite screen
              Container(
                padding: const EdgeInsets.only(top: 50, bottom: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Favorite',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'You have ${productsFavorite.length} items',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.favorite,
                      color: primaryColor,
                      size: 40,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoadingProducts
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: productsFavorite.length,
                        itemBuilder: (context, index) {
                          return productsFavorite.isEmpty
                              ? const Center(
                                  child: Text(
                                      "You dont have any favorite product"),
                                )
                              : Product(
                                  product: productsFavorite[index],
                                  products: products);
                        },
                      ),
              ),
            ],
          )),
    );
  }
}
