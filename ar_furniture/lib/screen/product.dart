import 'package:flutter/material.dart';
import '../constant/color.dart';
import '../object/product.dart';
import '../component/product.dart';
import 'package:flutter/services.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

// ignore: must_be_immutable
class ProductScreen extends StatefulWidget {
  Products product;
  List<Products> products;
  ProductScreen({super.key, required this.product, required this.products});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  late Products product;
  List<Products> products = [];
  bool _isFavorite = false;
  bool _isDisposed = false;
  final MethodChannel _channel =
      const MethodChannel('com.example.ar_furniture');

  @override
  void initState() {
    super.initState();
    product = widget.product;
    for (var product in widget.products) {
      if (product.category == widget.product.category) {
        products.add(product);
      }
    }
    if(!_isDisposed) {
      getFavorite();
    }
  }

  void getFavorite() {
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var favorite = FirebaseDatabase.instance
        .ref()
        .child("Users")
        .child(phone)
        .child('favorite');

    favorite.get().then((DataSnapshot dataSnapshot) {
      if (dataSnapshot.value != null) {
        String jsonString = json.encode(dataSnapshot.value);
        List<dynamic> values = json.decode(jsonString);
        if(values.contains(int.parse(product.key.toString()))) {
          setState(() {
            _isFavorite = true;
          });
        } 
      } else {}
    });
  }

  void setFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var productfb = FirebaseDatabase.instance
        .ref()
        .child("Models")
        .child(product.key.toString());
    var like = productfb.child("favorite");
    var favorite = FirebaseDatabase.instance
        .ref()
        .child('Users')
        .child(phone)
        .child("favorite");
    favorite.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        String jsonString = json.encode(snapshot.value);
        List<dynamic> values = json.decode(jsonString);
        if (values.contains(int.parse(product.key.toString()))) {
          values.remove(int.parse(product.key.toString()));
          favorite.set(values);
          productfb.get().then((DataSnapshot dataSnapshot) {
            int likeValue = dataSnapshot.child("favorite").value as int;
            like.set(likeValue - 1);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.fixed,
              content: Text('Removed from favorite'),
              duration: Duration(milliseconds: 500),
            ),
          );
        } else {
          values.add(int.parse(product.key.toString()));
          favorite.set(values);
          productfb.get().then((DataSnapshot dataSnapshot) {
            int likeValue = dataSnapshot.child("favorite").value as int;
            like.set(likeValue + 1);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              behavior: SnackBarBehavior.fixed,
              content: Text('Added to favorite'),
              duration: Duration(milliseconds: 500),
            ),
          );
        }
      } else {
        List<int> values = [];
        values.add(int.parse(product.key.toString()));
        favorite.set(values);
        productfb.get().then((DataSnapshot dataSnapshot) {
          int likeValue = dataSnapshot.child("favorite").value as int;
          like.set(likeValue + 1);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.fixed,
            content: Text('Added to favorite'),
            duration: Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  void addToCart() {
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var user = FirebaseDatabase.instance.ref().child("Users").child(phone);
    var cart = user.child("cart");
    cart.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        if (snapshot.hasChild(product.key.toString())) {
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
  void dispose() {
    super.dispose();
    _isDisposed = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomAppBar(
        elevation: 10,
        // appbar include favorite button, add to cart button
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: GestureDetector(
                    onTap: setFavorite,
                    child: _isFavorite
                        ? const Icon(
                            Icons.favorite,
                            color: primaryColor,
                          )
                        : const Icon(
                            Icons.favorite_border,
                            color: primaryColor,
                          ),
                  )),
              Container(
                margin: EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GestureDetector(
                  onTap: addToCart,
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: inputColor,
                  ),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    try {
                      _channel.invokeMethod('openJavaScreen', product.model);
                    } on PlatformException catch (e) {
                      print(e.message);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Try now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              SizedBox(
                width: double.infinity,
                height: 300,
                child: Image(
                  image: NetworkImage(product.image),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                top: 250,
                child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            '${product.price}\$',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: primaryColor),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: primaryColor,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: primaryColor,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: primaryColor,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: primaryColor,
                                        ),
                                        Icon(
                                          Icons.star,
                                          color: inputColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          '4.0',
                                          style: TextStyle(
                                            fontSize: 18,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      '94 Reviews',
                                      style: TextStyle(
                                          color: inputColor, fontSize: 14),
                                    )
                                  ],
                                ),
                                Column(
                                  children: [
                                    Image(
                                      image: AssetImage(
                                          'assets/images/reviews.png'),
                                      width: 110,
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          // Tabbar menu include description, review, and material, bottom of the tabbar is the content of each tabbar
                          DefaultTabController(
                            length: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TabBar(
                                  labelColor: primaryColor,
                                  unselectedLabelColor: inputColor,
                                  labelStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  indicator: BoxDecoration(
                                    color: const Color(0XFFFFEEDD),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  tabs: const [
                                    Tab(
                                      text: 'Description',
                                    ),
                                    Tab(
                                      text: 'Material',
                                    ),
                                    Tab(
                                      text: 'Review',
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                SizedBox(
                                  height: 140,
                                  child: TabBarView(
                                    children: [
                                      Text(
                                        product.description,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Color(0xFFAAAAAA),
                                        ),
                                        textAlign: TextAlign.justify,
                                      ),
                                      Text(
                                        product.material,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFFAAAAAA)),
                                        textAlign: TextAlign.justify,
                                      ),
                                      const Text(
                                        'Review is Lorem ispum dolor sit amet, consectetur adipiscing elit. Nulla eget nunc vitae ex ultricies blandit. Donec euismod, nisl eget aliquam ultricies, nisl nisl aliquet nisl, eget aliquam nisl nisl eget nisl.',
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xFFAAAAAA)),
                                        textAlign: TextAlign.justify,
                                      ),
                                    ],
                                  ),
                                ),
                                const Text(
                                  'Related Product',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: products.length,
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return SizedBox(
                                          width: 160,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Product(
                                              product: products[index],
                                              products: products,
                                            ),
                                          ));
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 80,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}
