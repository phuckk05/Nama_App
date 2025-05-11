//Model thông tin người dùng
class User {

  //Properties
  final String name;
  final String email;
  final String image;
  final DateTime createdAt;
  
  //Constructor
  User({
    required this.name,
    required this.email,
    required this.image,
    required this.createdAt,
  });
}