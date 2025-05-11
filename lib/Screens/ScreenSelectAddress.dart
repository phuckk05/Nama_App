import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienChonDiaChi extends StatefulWidget {
  final String? email;
  const GiaoDienChonDiaChi({super.key, this.email});

  @override
  State<GiaoDienChonDiaChi> createState() => _GiaoDienChonDiaChiState();
}

class _GiaoDienChonDiaChiState extends State<GiaoDienChonDiaChi> {
  // Khai báo đối tượng Firebase Authentication và các biến cần thiết
  Firebauth _firebauth = Firebauth();
  int? selected; // Biến lưu trữ địa chỉ đã chọn
  List<Map<String, dynamic>> listRadio =[]; // Danh sách các địa chỉ dưới dạng danh sách radio
  List<Map<String, dynamic>> items = []; // Danh sách địa chỉ từ cơ sở dữ liệu

  // Hàm thiết lập giá trị radio khi người dùng chọn địa chỉ
  SetValueRadio(int value) async {
    String idItem = value.toString(); // Chuyển giá trị chọn thành chuỗi
    setState(() {
      selected = value; // Cập nhật giá trị đã chọn
    });

    // Cập nhật địa chỉ đã chọn trên cơ sở dữ liệu Firebase
    _firebauth.UpdateSelectedAddress(widget.email.toString(), idItem);

    // Đợi một chút rồi đóng trang hiện tại
    await Future.delayed(Duration(milliseconds: 200), () {
      Navigator.pop(context, true); // Trở lại trang trước với giá trị true
    });
  }

  // Hàm set selected, có thể sẽ dùng để xử lý các thao tác khác khi chọn
  void SetSelected(int index) {
    // Chưa có logic cụ thể, có thể sử dụng sau này
  }

  // Lấy dữ liệu từ cơ sở dữ liệu Firestore và cập nhật danh sách địa chỉ
  void LayDuLieu() async {
    items = await _firebauth.GetAddress2(
      widget.email.toString(),
    ); // Lấy danh sách địa chỉ từ Firebase
    for (int i = 0; i < items.length; i++) {
      // Thêm các địa chỉ vào listRadio, dùng để liên kết với các nút radio
      listRadio.addAll([
        {"value$i": int.tryParse(items[i]['id'])},
      ]);

      // Kiểm tra nếu địa chỉ này đã được chọn trước, cập nhật biến selected
      if (items[i]['select'] == true) {
        selected = int.tryParse(items[i]['id']);
      }
    }

    // Kiểm tra xem widget có còn được render không, nếu có thì setState để cập nhật UI
    if (mounted) {
      setState(() {});
    }
  }

  // Hàm khởi tạo, gọi khi widget được tạo
  @override
  void initState() {
    super.initState();
    LayDuLieu(); // Gọi hàm lấy dữ liệu từ Firebase khi widget được khởi tạo
  }

  // Hàm build để xây dựng giao diện của widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Tắt nút quay lại mặc định của AppBar
        backgroundColor: Colors.white, // Màu nền của AppBar
        actions: [
          // Nút quay lại, khi nhấn sẽ quay lại trang trước
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context); // Quay lại trang trước
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
            ),
          ),
          // Tiêu đề "Chọn địa chỉ nhận hàng"
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'Chọn địa chỉ nhận hàng',
                style: TextStyle(
                  fontSize: AppStyle.textSizeTitle,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Nút tìm kiếm (chưa sử dụng trong trường hợp này)
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.search, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300], // Màu nền của Scaffold
      body: SingleChildScrollView(
        // Dùng SingleChildScrollView để cuộn toàn bộ nội dung nếu cần
        child: Column(
          children: [
            // Tiêu đề phần "Địa chỉ"
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Địa chỉ',
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: AppStyle.textSizeMedium,
                  ),
                ),
              ),
            ),

            // Danh sách các địa chỉ được render bằng ListView.builder
            ListView.builder(
              shrinkWrap:
                  true, // Làm cho ListView chỉ chiếm không gian cần thiết trong Column
              physics:
                  NeverScrollableScrollPhysics(), // Tắt scroll của ListView, để chỉ cuộn trang chính
              itemCount: items.length, // Số lượng phần tử trong danh sách
              itemBuilder: (context, i) {
                // Dùng Padding để tạo khoảng cách giữa các item
                return Padding(
                  padding: EdgeInsets.only(left: 0, right: 0, bottom: 1),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white, // Màu nền của mỗi phần tử
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 100,
                          color: Colors.grey,
                        ), // Đổ bóng cho phần tử
                      ],
                    ),
                    child: Row(
                      children: [
                        // Phần radio button để chọn địa chỉ
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Radio(
                              value:
                                  listRadio[i]['value$i'], // Giá trị của radio button
                              groupValue: selected, // Giá trị được chọn
                              onChanged: (value) {
                                SetValueRadio(
                                  value!,
                                ); // Gọi hàm khi chọn radio button
                              },
                            ),
                          ),
                        ),
                        // Phần thông tin địa chỉ (Tên, điện thoại, địa chỉ)
                        Expanded(
                          flex: 9,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Hiển thị tên người nhận
                                    items.isNotEmpty
                                        ? Text(
                                          '${items[i]['name']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppStyle.textSizeMedium,
                                          ),
                                        )
                                        : Text(
                                          'Đang tải lên...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppStyle.textSizeMedium,
                                          ),
                                        ),

                                    SizedBox(width: 10),

                                    // Hiển thị số điện thoại
                                    items.isNotEmpty
                                        ? Text(
                                          '${items[i]['telephone']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        )
                                        : Text(
                                          'Đang tải lên...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppStyle.textSizeMedium,
                                          ),
                                        ),
                                  ],
                                ),
                                // Hiển thị địa chỉ người nhận
                                items.isNotEmpty
                                    ? Text(
                                      '${items[i]['address']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    )
                                    : Text(
                                      'Đang tải lên...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
