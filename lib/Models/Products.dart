class Product {
  String id;
  String name;
  String description;
  String address;
  String email;
  String imageUrl;
  String type;
  String price;
  String total;
  String createdAt;
  bool hiden;
  

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.email,
    required this.imageUrl,
    required this.type,
    required this.price,
    required this.total,
    required this.createdAt,
    required this.hiden
  });
}