//Model Đánh giá
class Review {
  //Properties
  final String id;
  final String email;
  final String idProducts;
  final String idOrder;
  final int start;
  final String slelect;
  final String review;
  final String nameBuy;
  
  //Constructor
  Review({
    required this.id,
    required this.email,
    required this.idProducts,
    required this.idOrder,
    required this.start,
    required this.slelect,
    required this.review,
    required this.nameBuy
  });
}
