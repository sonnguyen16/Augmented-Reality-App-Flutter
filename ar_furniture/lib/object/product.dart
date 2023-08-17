class Products {
  final String? key;
  final String name;
  final String image;
  final String model;
  final int price;
  final String category;
  int favorite;
  final bool isShow;
  final String material;
  final String description;

  Products(
      {this.key,
      required this.name,
      required this.image,
      required this.model,
      required this.price,
      required this.category,
      required this.favorite,
      required this.isShow,
      required this.material,
      required this.description});
}
