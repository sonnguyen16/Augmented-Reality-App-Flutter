import 'package:flutter/material.dart';
import '../constant/color.dart';
import '../screen/product.dart';
import '../object/product.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:core';

// ignore: must_be_immutable
class Product extends StatefulWidget {
  Products product;
  List<Products> products;

  Product({super.key, required this.product, required this.products});

  @override
  State<Product> createState() => _ProductState();
}

class _ProductState extends State<Product> {
  late Products product;
  late List<Products> products;

  @override
  void initState() {
    super.initState();
    product = widget.product;
    products = widget.products;
  }


  @override
  void dispose() {
    super.dispose();
  }


  void addToCart() {
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var user = FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(phone);
    var cart = user.child("cart");
    cart.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        if(snapshot.hasChild(product.key.toString())) {
          int count = snapshot.child(product.key.toString()).value as int;
          cart.child(product.key.toString()).set(count + 1);
        } else {
          cart.child(product.key.toString()).set(1);
        }
      } else {
        cart.child(product.key.toString()).set(1);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text('Added to cart'),
        duration: Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 10,
        shadowColor: Colors.grey.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    ProductScreen(product: product, products: products),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(widget.product.image),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5,
                        right: -3,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.all(8),
                          ),
                          onPressed: () {
                            addToCart();
                          },
                          child: const Icon(
                            Icons.shopping_cart_outlined,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // ListTile inclue price and favorite
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              product.favorite.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
