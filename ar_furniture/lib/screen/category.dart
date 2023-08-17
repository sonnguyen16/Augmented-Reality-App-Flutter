

import 'package:flutter/material.dart';
import '../object/product.dart';
import '../constant/color.dart';
import '../component/product.dart';

// ignore: must_be_immutable
class CategoryScreen extends StatefulWidget {
  String category;
  List<Products> products;
  CategoryScreen({super.key, required this.category, required this.products});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  var icon = Icons.favorite;

  @override
  void initState() {
    super.initState();
    switch (widget.category) {
      case 'Chair':
        icon = Icons.chair_alt;
        break;
      case 'Sofa':
        icon = Icons.weekend;
        break;
      case 'Desk':
        icon = Icons.desk;
        break;
      case 'Other':
        icon = Icons.more_horiz;
        break;
    }
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
                         Text(
                            widget.category,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${widget.category} have ${widget.products.where((element) => element.category == widget.category).length} items',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      icon,
                      color: primaryColor,
                      size: 40,
                    ),
                  ],
                ),
              ),
              Expanded(
                child:  GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: widget.products.where((element) => element.category == widget.category).length,
                        itemBuilder: (context, index) {
                          List<Products> productList = widget.products.where((element) => element.category == widget.category).toList();
                          return Product(
                              product: productList[index],
                              products: widget.products);
                        },
                      ),
              ),
            ],
          )),
    );

  }
}


