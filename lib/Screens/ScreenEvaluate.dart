import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Models/Review.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDanhGia extends StatefulWidget {
  final List<DonHang>? listDanhGia;
  final int? index;
  final String? email;
  const GiaoDienDanhGia({super.key, this.listDanhGia, this.index, this.email});

  @override
  State<GiaoDienDanhGia> createState() => _GiaoDienDanhGiaState();
}

class _GiaoDienDanhGiaState extends State<GiaoDienDanhGia> {
  // Khởi tạo đối tượng Firebauth, biến lưu trữ đánh giá sao, lựa chọn đánh giá và bộ điều khiển cho TextField
  Firebauth _firebauth = Firebauth();
  int selectedStar = 0; // Biến lưu trữ số sao đã chọn
  String selectedOption =
      'Tốt'; // Biến lưu trữ lựa chọn đánh giá (ví dụ: 'Tốt', 'Khá', 'Xấu')
  final feedbackController =
      TextEditingController(); // Bộ điều khiển cho trường nhập liệu đánh giá

  // Khai báo các màu sắc cho các sao
  Color colorGrey1 = Colors.grey;
  Color colorGrey2 = Colors.grey;
  Color colorGrey3 = Colors.grey;
  Color colorGrey4 = Colors.grey;
  Color colorGrey5 = Colors.grey;

  // Hàm SetColor để thay đổi màu sắc của các sao dựa trên chỉ số sao đã chọn
  void SetColor(int index) {
    setState(() {
      selectedStar = index; // Cập nhật số sao đã chọn
      // Cập nhật màu sắc của các sao (từ màu xám đến màu vàng khi sao được chọn)
      colorGrey1 = index >= 1 ? Colors.amberAccent : Colors.grey;
      colorGrey2 = index >= 2 ? Colors.amberAccent : Colors.grey;
      colorGrey3 = index >= 3 ? Colors.amberAccent : Colors.grey;
      colorGrey4 = index >= 4 ? Colors.amberAccent : Colors.grey;
      colorGrey5 = index >= 5 ? Colors.amberAccent : Colors.grey;
    });
  }

  // Hàm lưu đánh giá, kiểm tra điều kiện và gọi hàm lưu vào Firestore
  void saveReview(Review review) async {
    if (selectedOption.isNotEmpty &&
        feedbackController.text.isNotEmpty &&
        selectedStar != 0) {
      // Kiểm tra nếu tất cả các trường đều được điền đầy đủ: lựa chọn, đánh giá và số sao
      _firebauth.SaveReview(
        review,
      ); // Lưu đánh giá vào Firestore (hoặc cơ sở dữ liệu tương ứng)

      // Hiển thị thông báo thành công khi lưu đánh giá thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Lưu đánh giá thành công'))),
      );

      // Cập nhật trạng thái của đơn hàng đã được đánh giá
      await _firebauth.updateDonHangdaDuocDanhGia(
        widget.listDanhGia![widget.index!].id,
      );

      // Đóng màn hình đánh giá và trả về giá trị true để cập nhật trạng thái bên ngoài
      Navigator.pop(context, true);
    } else {
      // Nếu các trường chưa được điền đầy đủ, hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Vui lòng nhập đánh giá'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đánh giá',
          style: GoogleFonts.robotoSlab(
            fontSize: AppStyle.textSizeTitle,
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Để cho phép cuộn màn hình khi nội dung vượt quá không gian hiển thị
        child: Column(
          children: [
            // Một thanh ngang màu xám ngăn cách các phần
            Container(width: double.infinity, height: 10, color: Colors.grey),

            Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
              ), // Padding cho các phần tử con
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start, // Căn lề trái cho các phần tử con
                children: [
                  // Tên sản phẩm
                  Row(
                    children: [
                      Text(
                        'Tên sản phẩm : ', // Text hiển thị nhãn "Tên sản phẩm"
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: AppStyle.textSizeMedium,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          maxLines: 1, // Giới hạn một dòng để tránh tràn chữ
                          overflow:
                              TextOverflow
                                  .ellipsis, // Nếu tên quá dài, sẽ hiển thị "..."
                          widget
                              .listDanhGia![widget.index!]
                              .name, // Tên sản phẩm lấy từ danh sách đánh giá
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: AppStyle.textSizeMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Khoảng cách giữa các phần tử
                  // Đánh giá sao
                  Text(
                    'Bạn đánh giá sản phẩm này mấy sao?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: AppStyle.textSizeMedium,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Căn giữa các sao
                    children: [
                      // Các icon sao cho phép người dùng đánh giá sản phẩm từ 1 đến 5 sao
                      IconButton(
                        onPressed:
                            () => SetColor(
                              1,
                            ), // Hàm SetColor được gọi khi người dùng chọn sao
                        icon: Icon(Icons.star, size: 32, color: colorGrey1),
                      ),
                      IconButton(
                        onPressed: () => SetColor(2),
                        icon: Icon(Icons.star, size: 32, color: colorGrey2),
                      ),
                      IconButton(
                        onPressed: () => SetColor(3),
                        icon: Icon(Icons.star, size: 32, color: colorGrey3),
                      ),
                      IconButton(
                        onPressed: () => SetColor(4),
                        icon: Icon(Icons.star, size: 32, color: colorGrey4),
                      ),
                      IconButton(
                        onPressed: () => SetColor(5),
                        icon: Icon(Icons.star, size: 32, color: colorGrey5),
                      ),
                    ],
                  ),
                  SizedBox(height: 20), // Khoảng cách giữa các phần tử
                  // Dropdown cho loại đánh giá (Tốt, Trung bình, Tệ)
                  Text(
                    'Loại đánh giá:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedOption, // Lựa chọn mặc định của Dropdown
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items:
                        ['Tốt', 'Trung bình', 'Tệ']
                            .map(
                              (label) => DropdownMenuItem(
                                child: Text(label),
                                value: label,
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOption =
                            value!; // Cập nhật lựa chọn khi người dùng thay đổi
                      });
                    },
                  ),
                  SizedBox(height: 20), // Khoảng cách giữa các phần tử
                  // Ô nhập phản hồi của người dùng
                  Text(
                    'Phản hồi của bạn:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller:
                        feedbackController, // Gắn bộ điều khiển cho TextField
                    maxLines: 5, // Giới hạn số dòng của TextField
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung phản hồi...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 30), // Khoảng cách giữa các phần tử
                  // Nút Lưu đánh giá
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        String id = _firebauth.generateVerificationCode(
                          5,
                        ); // Tạo mã xác thực ngẫu nhiên
                        Review review = Review(
                          id: id,
                          email:
                              widget.email
                                  .toString(), // Email của người đánh giá
                          idProducts:
                              widget
                                  .listDanhGia![widget.index!]
                                  .idProducts, // ID sản phẩm
                          idOrder:
                              widget
                                  .listDanhGia![widget.index!]
                                  .id, // ID đơn hàng
                          start: selectedStar, // Số sao người dùng chọn
                          slelect: selectedOption.toString(), // Loại đánh giá
                          review:
                              feedbackController.text
                                  .toString(), // Phản hồi của người dùng
                          nameBuy:
                              "hello", // Tên người mua (hoặc tên giả định ở đây)
                        );
                        saveReview(review); // Gọi hàm để lưu đánh giá
                      },
                      icon: Icon(Icons.save), // Biểu tượng lưu
                      label: Text(
                        'Lưu đánh giá',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(
                          double.infinity,
                          50,
                        ), // Chiều rộng nút đầy màn hình
                        backgroundColor: Colors.green, // Màu nền nút
                        foregroundColor: Colors.white, // Màu chữ nút
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
