import '../constant/color.dart';
import '../object/product.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartSreen extends StatefulWidget {
  const CartSreen({Key? key}) : super(key: key);

  @override
  State<CartSreen> createState() => _CartSreenState();
}

class _CartSreenState extends State<CartSreen> {
  List<Products> products = [];
  List<Map<Products, int>> cart = [];
  bool _isLoading = true;
  int total = 0;

  @override
  void initState() {
    super.initState();
    getProductsFromFireBase();
  }

  void getCart() {
    total = 0;
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var user = FirebaseDatabase.instance.ref().child("Users").child(phone);
    var cart = user.child("cart");
    List<Map<Products, int>> list = [];
    cart.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        for (var element in snapshot.children) {
          list.add({
            products[int.parse(element.key.toString())]: element.value as int
          });
          total += products[int.parse(element.key.toString())].price *
              (element.value as int);
        }

        if(mounted){
          setState(() {
          this.cart = list;
          _isLoading = false;
        });
        }
      } else {
        if(mounted){
          setState(() {
          this.cart = [];
          _isLoading = false;
        });
        }
      }
    });
  }

  // function increase quantity cart in firebase
  void increaseQuantityCart(String key, int quantity) {
   
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var user = FirebaseDatabase.instance.ref().child("Users").child(phone);
    var cart = user.child("cart");
    cart.child(key).set(quantity + 1);
    setState(() {
      _isLoading = true;
    });
    getCart();
  }

  // function decrease quantity cart in firebase
  void decreaseQuantityCart(String key, int quantity) {
     if (quantity == 1) {
      return;
    }
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var user = FirebaseDatabase.instance.ref().child("Users").child(phone);
    var cart = user.child("cart");
    cart.child(key).set(quantity - 1);
    setState(() {
      _isLoading = true;
    });
    getCart();
  }

  void deletefromCart(String key) {
    String phone = FirebaseAuth.instance.currentUser!.phoneNumber.toString();
    var user = FirebaseDatabase.instance.ref().child("Users").child(phone);
    var cart = user.child("cart");
    cart.child(key).remove();
    setState(() {
      _isLoading = true;
    });
    getCart();
  }

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

     if(mounted){
       setState(() {
        this.products = list;
      });
      getCart();
     }
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Beautiful cart screen
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Intro cart screen
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'You have ${cart.length} items',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.shopping_cart,
                    color: primaryColor,
                    size: 40,
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: primaryColor,
                      ),
                    )
                  : ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(0, 5),
                                      blurRadius: 10,
                                      color: Colors.black.withOpacity(0.3),
                                    ),
                                  ],
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        cart[index].keys.first.image),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                margin: const EdgeInsets.only(right: 20),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cart[index].keys.first.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '\$${cart[index].keys.first.price}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Decrease button, increase button
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      decreaseQuantityCart(
                                        cart[index].keys.first.key.toString(),
                                        cart[index].values.first);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.remove,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${cart[index].values.first}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      increaseQuantityCart(
                                        cart[index].keys.first.key.toString(),
                                        cart[index].values.first);
                                    });
                                  },
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    deletefromCart(
                                        cart[index].keys.first.key.toString());
                                  });
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: primaryColor,
                                  size: 25,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, -1),
                    blurRadius: 20,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '$total\$',
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 20,
                      horizontal: 30,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Check out',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
