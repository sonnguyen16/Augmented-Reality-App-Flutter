import 'package:ar_furniture/object/category.dart';
import 'package:ar_furniture/screen/category.dart';
import 'package:ar_furniture/screen/product.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import '../constant/color.dart';
import '../object/product.dart';
import '../object/banner.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../component/product.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Categories> categories = <Categories>[];
  List<Products> products = <Products>[];
  List<Banners> bannerList = <Banners>[];
  List<Products> popular = <Products>[];
  List<Products> searchResults = <Products>[];
  bool _isLoadingCategories = true;
  bool _isLoadingProducts = true;
  bool _isLoadingBanner = true;
  bool _isDisposed = false;
  List<String> rooms = [
    'assets/images/room1.jpg',
    'assets/images/room2.jpg',
    'assets/images/room3.jpg',
  ];

  final PageController _pageController = PageController(initialPage: 0);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void dispose() {
    _stopTimer();
    _pageController.dispose();
    super.dispose();
    _isDisposed = true;
  }

  void search(String text) {
    List<Products> results = [];
    for (var product in products) {
      if (product.name.toLowerCase().contains(text.toLowerCase())) {
        results.add(product);
      }
    }
    setState(() {
      searchResults = results;
    });
  }

  void createProfileDefault() {
    var user = FirebaseAuth.instance.currentUser;
    var users = FirebaseDatabase.instance.ref().child("Users");
    users
        .child(user!.phoneNumber.toString())
        .get()
        .then((DataSnapshot snapshot) {
      if (snapshot.value == null) {
        users.child(user.phoneNumber.toString()).set({
          "name": "",
          "email": "",
          "address": "",
          "avatar": "",
          "coverPhoto": "",
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_currentPage < bannerList.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    if (!_isDisposed) {
      getCategoriesFromFireBase();
      getBannerFromFireBase();
      getProductsFromFireBase();
      createProfileDefault();
    }
  }

  void getCategoriesFromFireBase() {
    var categories = FirebaseDatabase.instance.ref().child("Categories");
    List<Categories> list = [];
    categories.onValue.listen((event) {
      for (var category in event.snapshot.children) {
        if (category.child("isShow").value as bool == true) {
          list.add(Categories(
              name: category.child("name").value as String,
              image: category.child("image").value as String,
              isShow: category.child("isShow").value as bool));
        }
      }

      if (!_isDisposed) {
        setState(() {
          _isLoadingCategories = false;
          this.categories = list;
        });
      }
    });
  }

  void getPopular() {
    Map<String, Products> topFavoritesByCategory = {};
    for (var product in products) {
      if (topFavoritesByCategory.containsKey(product.category)) {
        if (product.favorite >
            topFavoritesByCategory[product.category]!.favorite) {
          topFavoritesByCategory[product.category] = product;
        }
      } else {
        topFavoritesByCategory[product.category] = product;
      }
    }

    setState(() {
      _isLoadingProducts = false;
      popular = topFavoritesByCategory.values.toList();
    });
  }

  void getBannerFromFireBase() {
    var banners = FirebaseDatabase.instance.ref().child("Banners");
    List<Banners> list = [];
    banners.onValue.listen((event) {
      for (var banner in event.snapshot.children) {
        if (banner.child("isShow").value as bool == true) {
          list.add(Banners(
              image: banner.child("image").value as String,
              isShow: banner.child("isShow").value as bool));
        }
      }

      if (!_isDisposed) {
        setState(() {
          _isLoadingBanner = false;
          bannerList = list;
        });
      }
      _startTimer();
    });
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

      if (!_isDisposed) {
        setState(() {
          this.products = list;
        });
        getPopular();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Explore What\nYour Home Needs',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.notifications,
                  color: primaryColor,
                  size: 40,
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              onChanged: (value) {
                if (value.isNotEmpty) {
                  search(value);
                } else {
                  setState(() {
                    searchResults = [];
                  });
                }
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(5),
                hintText: 'Chair, table, lamp etc',
                hintStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: inputColor,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: inputColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: inputColor),
                    borderRadius: searchResults.isEmpty
                        ? BorderRadius.circular(10)
                        : const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10))),
                prefixIcon: const Icon(Icons.search, color: inputColor),
              ),
            ),
            // Show search results include image and name
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: Colors.white,
              ),
              height: searchResults.isEmpty ? 0 : 150,
              width: double.infinity,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: searchResults.length,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ProductScreen(
                              product: searchResults[index],
                              products: products,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 50,
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image:
                                      NetworkImage(searchResults[index].image),
                                  fit: BoxFit.cover,
                                )),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            searchResults[index].name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: inputColor,
                            ),
                          ),
                        ],
                      ));
                },
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 55,
              width: double.infinity,
              child: _isLoadingCategories
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : ListView.builder(
                      itemCount: categories.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CategoryScreen(
                                  category: categories[index].name,
                                  products: products,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 15),
                                child: Image(
                                  image: NetworkImage(categories[index].image),
                                ),
                              ),
                              Positioned(
                                top: 19,
                                left: 12,
                                child: Text(
                                  categories[index].name,
                                  style: const TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 150,
              width: double.infinity,
              child: _isLoadingBanner
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : PageView.builder(
                      scrollBehavior: const ScrollBehavior(),
                      controller: _pageController,
                      itemCount: bannerList.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image(
                            image: NetworkImage(bannerList[index].image),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                    ),
            ),
            const SizedBox(height: 5),
            Center(
              child: _isLoadingBanner
                  ? const Center(child: null)
                  : DotsIndicator(
                      dotsCount: bannerList.length,
                      position: _currentPage.toDouble(),
                      decorator: const DotsDecorator(
                        activeColor:
                            primaryColor, // Màu của indicator khi ở trạng thái active
                        color: inputColor, // Màu của các indicator khác
                      ),
                    ),
            ),
            const SizedBox(height: 15),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'See All',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 530,
              child: _isLoadingProducts
                  ? const Center(
                      child: CircularProgressIndicator(
                      color: primaryColor,
                    ))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: popular.length,
                      itemBuilder: (context, index) {
                        // Card product with shadow
                        return Product(
                          product: popular[index],
                          products: products,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 15),
            Container(
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: const DecorationImage(
                    image: AssetImage('assets/images/sale.jpg'),
                    fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Rooms',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Furniture for every corners in your home',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: inputColor,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: rooms.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: AssetImage(rooms[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ))
          ],
        ),
      ),
    );
  }
}
