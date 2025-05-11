import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/DataBase/Sqlite.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Screens/ScreenAddress.dart';
import 'package:nama_app/Screens/ScreenInformation.dart';
import 'package:nama_app/Screens/ScreenLogin.dart';
import 'package:nama_app/Screens/ScreenManagerOrder.dart';
import 'package:nama_app/Screens/ScreenOrder.dart';
import 'package:nama_app/Screens/ScreenPayment.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Screens/ScreenSetting.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:google_fonts/google_fonts.dart';

//còn lỗi load chậm , xóa xong chưa thêm được vào bên tab đã giao

class GiaoDienTaiKhoan extends StatefulWidget {
  final String? email;
  GiaoDienTaiKhoan({Key? Key, this.email}) : super(key: Key);

  @override
  State<GiaoDienTaiKhoan> createState() => _GiaoDienTaiKhoanState();
}

class _GiaoDienTaiKhoanState extends State<GiaoDienTaiKhoan> {
  SQLiteService _sqLiteService =
      SQLiteService(); // Khởi tạo dịch vụ SQLite để quản lý dữ liệu local.
  Firebauth _firebauth =
      Firebauth(); // Khởi tạo dịch vụ Firebase để tương tác với Firestore và Firebase Authentication.
  List<Map<String, dynamic>> items =
      []; // Danh sách items (chưa sử dụng trong đoạn code này, có thể là dành cho tính năng khác).
  int?
  _selectedIndex; // Lưu chỉ số của item được chọn (có thể là dùng cho việc chọn tab hoặc item trong danh sách).
  int? Index; // Biến chưa được sử dụng trong đoạn code này.
  String? _result; // Kết quả lấy thông tin từ Firebase về người dùng.
  List<String> _split =
      []; // Dùng để lưu trữ thông tin người dùng sau khi chia tách từ _result.
  List<DonHang> listDonHang = []; // Danh sách đơn hàng chờ xác nhận.
  List<DonHang> listDonHangChoGiao = []; // Danh sách đơn hàng chờ giao.
  List<DonHang> listDonHangDaGiao = []; // Danh sách đơn hàng đã giao.
  List<DonHang> listDuyetDonHang = []; // Danh sách đơn hàng đang được duyệt.
  List<Map<String, dynamic>> address = []; // Danh sách địa chỉ chờ duyệt.
  List<Map<String, dynamic>> addressDaGiao = []; // Danh sách địa chỉ đã giao.
  List<String> index2 =
      []; // Danh sách các địa chỉ đơn hàng chờ giao và đã giao.
  List<String> index3 = []; // Danh sách các địa chỉ đơn hàng đã giao.

  @override
  void initState() {
    super.initState();
    _Lay_Thong_Tin_User(); // Gọi phương thức lấy thông tin người dùng từ Firebase.
    LayThonTinDonHang(); // Lấy thông tin đơn hàng.
  }

  // Lấy thông tin người dùng từ Firebase
  void _Lay_Thong_Tin_User() async {
    _result = await _firebauth.GetAllUser(
      widget.email.toString(),
    ); // Lấy thông tin người dùng bằng email.
    if (mounted) {
      // Kiểm tra widget còn tồn tại trước khi setState.
      setState(() {
        _split = _result.toString().split(
          '+',
        ); // Chia thông tin người dùng ra bằng dấu "+".
      });
    }
  }

  // Xóa người dùng khỏi SQLite và chuyển hướng đến màn hình đăng nhập.
  void _XoaUser() async {
    _sqLiteService.DeleteUser(
      widget.email.toString(),
    ); // Xóa người dùng khỏi cơ sở dữ liệu SQLite.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DangNhap(),
      ), // Chuyển hướng đến màn hình đăng nhập.
    );
  }

  // Xử lý khi nhấn vào các tab hoặc mục menu để điều hướng đến màn hình tương ứng.
  void SetColor(int index) async {
    if (index == 1) {
      // Nếu chọn mục "Thông tin cá nhân".
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GiaoDienThongTin(
                email: widget.email.toString(),
              ), // Chuyển đến màn hình thông tin cá nhân.
        ),
      );
      if (result == true) {
        // Nếu có thay đổi thông tin người dùng.
        _Lay_Thong_Tin_User(); // Lấy lại thông tin người dùng.
        setState(() {}); // Cập nhật lại giao diện.
      }
    } else if (index == 2) {
      // Nếu chọn mục "Thanh toán".
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GiaoDienThanhToan(),
        ), // Chuyển đến màn hình thanh toán.
      );
    } else if (index == 3) {
      // Nếu chọn mục "Địa chỉ".
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GiaoDienDiaChi(
                email: widget.email.toString(),
              ), // Chuyển đến màn hình địa chỉ.
        ),
      );
    } else if (index == 4) {
      // Nếu chọn mục "Cài đặt".
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => GiaoDienCaiDat(),
      //   ), // Chuyển đến màn hình cài đặt.
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Tính năng đang phát triển')))
      );
    } else if (index == 5) {
      // Nếu chọn mục "Đơn hàng đã giao".
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GiaoDienDonHang(
                email: widget.email.toString(),
                listDonHang:
                    listDonHangDaGiao, // Chuyển đến màn hình đơn hàng đã giao.
                    
              ),
        ),
      );
      if (result == true) {
        // Nếu có thay đổi trong đơn hàng.
        LayThonTinDonHang(); // Lấy lại thông tin đơn hàng.
        setState(() {}); // Cập nhật lại giao diện.
      }
    } else {
      // Nếu chọn mục "Quản lý đơn hàng".
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GiaoDienQuanLyDonHang(
                email: widget.email.toString(),
                listDonHang:
                    listDuyetDonHang, // Chuyển đến màn hình quản lý đơn hàng.
                address: address, // Thêm các địa chỉ liên quan đến đơn hàng.
                addressDaGiao: index2, // Địa chỉ đơn hàng chờ giao và đã giao.
                addressDaGiao2: index3, // Địa chỉ đơn hàng đã giao.
              ),
        ),
      );
      if (result == true) {
        // Nếu có thay đổi trong đơn hàng.
        LayThonTinDonHang(); // Lấy lại thông tin đơn hàng.
        setState(() {}); // Cập nhật lại giao diện.
      }
    }
  }

  // Lấy thông tin đơn hàng từ Firebase
  void LayThonTinDonHang() async {
    listDonHang = await _firebauth.GetOrderByEmailBuyChoXacNhan(
      widget.email.toString(), // Lấy đơn hàng của người mua đang chờ xác nhận.
    );
    listDonHangChoGiao = await _firebauth.GetOrderByEmailBuyChoGiao(
      widget.email.toString(), // Lấy đơn hàng của người mua đang chờ giao.
    );
    listDonHangDaGiao = await _firebauth.GetOrderByEmailSell(
      widget.email.toString(), // Lấy đơn hàng của người mua đã giao.
    );
    listDuyetDonHang = await _firebauth.getOrderSell(
      widget.email.toString(),
    ); // Lấy đơn hàng của người bán đang duyệt.

    List<String> index = []; // Khởi tạo danh sách để lưu trữ địa chỉ.

    // Xử lý các đơn hàng để phân loại chúng theo trạng thái.
    for (int i = 0; i < listDuyetDonHang.length; i++) {
      if (listDuyetDonHang[i].status == "Chờ xác nhận") {
        // Nếu đơn hàng đang chờ xác nhận.
        index.add(
          listDuyetDonHang[i].address.toString(),
        ); // Thêm địa chỉ vào danh sách index.
      }
      if (listDuyetDonHang[i].status == "Chờ giao") {
        // Nếu đơn hàng chờ giao.
        index2.add(
          listDuyetDonHang[i].address.toString(),
        ); // Thêm địa chỉ vào danh sách index2.
      }
      if (listDuyetDonHang[i].status == "Đã giao") {
        // Nếu đơn hàng đã giao.
        index2.add(
          listDuyetDonHang[i].address.toString(),
        ); // Thêm địa chỉ vào danh sách index2.
      }
    }

    // Chưa sử dụng code để lấy địa chỉ từ Firebase, nhưng có thể sử dụng `index` để truy vấn địa chỉ.
    // address = await _firebauth.getAddressById(index);

    if (mounted) {
      // Kiểm tra xem widget còn tồn tại trước khi cập nhật UI.
      setState(() {}); // Cập nhật lại giao diện.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        actions: [
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProcessSccreen(email: widget.email.toString()),
                    ),
                    (route) => false,
                  );
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  'Tài khoản',
                  style: GoogleFonts.robotoSlab(
                    fontSize: AppStyle.textSizeTitle,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
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
      backgroundColor: Colors.white,
      //Body
      body: body(),
    );
  }

  Widget body() {
    return SingleChildScrollView(
      // Dùng SingleChildScrollView để cho phép cuộn nội dung khi cần thiết.
      child: Column(
        // Sử dụng Column để chứa các phần tử theo chiều dọc.
        children: [
          // PHẦN AVATAR NGƯỜI DÙNG
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
            ), // Padding xung quanh Avatar.
            child: Container(
              width:
                  double
                      .infinity, // Chiều rộng của container sẽ chiếm toàn bộ chiều rộng của màn hình.
              padding: EdgeInsets.all(16), // Padding bên trong container.
              decoration: BoxDecoration(
                color: Colors.green, // Màu nền của container.
                borderRadius: BorderRadius.only(
                  // Bo góc của container.
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: Row(
                // Sử dụng Row để sắp xếp các phần tử theo chiều ngang.
                children: [
                  Stack(
                    // Dùng Stack để chồng các widget lên nhau, ví dụ như avatar và nút camera.
                    children: [
                      Container(
                        width: 80, // Kích thước avatar.
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            50,
                          ), // Bo góc cho avatar thành hình tròn.
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            50,
                          ), // Bo góc ảnh trong container.
                          child:
                              _split
                                      .isNotEmpty // Kiểm tra nếu dữ liệu người dùng đã được tải.
                                  ? Image.network(
                                    _split[1],
                                    fit: BoxFit.cover,
                                  ) // Hiển thị ảnh người dùng từ URL.
                                  : CircularProgressIndicator(), // Hiển thị CircularProgressIndicator khi đang tải ảnh.
                        ),
                      ),
                      Positioned(
                        // Đặt nút camera ở vị trí chồng lên ảnh avatar.
                        top: 50, // Vị trí từ trên xuống.
                        left: 50, // Vị trí từ trái qua.
                        bottom: 0, // Vị trí từ dưới lên.
                        right: 0, // Vị trí từ phải qua.
                        child: IconButton(
                          onPressed: () async {
                            final reslut = await Navigator.push(
                              // Điều hướng đến màn hình thay đổi thông tin người dùng.
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => GiaoDienThongTin(
                                      email:
                                          widget.email
                                              .toString(), // Truyền email vào màn hình thông tin người dùng.
                                    ),
                              ),
                            );
                            if (reslut == true) {
                              // Nếu thông tin người dùng được thay đổi.
                              _Lay_Thong_Tin_User(); // Lấy lại thông tin người dùng.
                              setState(() {}); // Cập nhật lại giao diện.
                            }
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                          ), // Hiển thị icon camera để người dùng thay đổi ảnh.
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 16,
                  ), // Khoảng cách giữa Avatar và thông tin người dùng.
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start, // Canh trái các phần tử trong Column.
                    children: [
                      Text(
                        maxLines: 1, // Đảm bảo chỉ hiển thị 1 dòng.
                        overflow:
                            TextOverflow
                                .ellipsis, // Thêm dấu "..." nếu văn bản dài quá.
                        _split
                                .isNotEmpty // Kiểm tra nếu dữ liệu người dùng đã được tải.
                            ? _split[2]
                                .toString() // Hiển thị tên người dùng.
                            : "Đang tải lên...", // Hiển thị thông báo nếu tên người dùng chưa tải.
                        style: TextStyle(
                          color: Colors.white, // Màu chữ trắng.
                          fontSize: 18, // Kích thước chữ.
                          fontWeight: FontWeight.bold, // Làm đậm chữ.
                        ),
                      ),
                      Text(
                        widget.email ??
                            'Đang tải lên...', // Hiển thị email người dùng hoặc thông báo nếu chưa tải.
                        style: TextStyle(color: Colors.white), // Màu chữ trắng.
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Các mục menu trong giao diện
          buildTile(
            6,
            Icons.assignment,
            "Quản lý đơn hàng",
          ), // Mục quản lý đơn hàng.
          Divider(height: 1, indent: 55), // Dòng phân cách giữa các mục menu.
          buildTile(
            5,
            Icons.production_quantity_limits,
            "Đơn hàng của bạn",
          ), // Mục đơn hàng của bạn.
          Divider(height: 1, indent: 55),
          buildTile(
            1,
            Icons.edit,
            "Thông tin cá nhân",
          ), // Mục thông tin cá nhân.
          Divider(height: 1, indent: 55),
          buildTile(
            2,
            Icons.payment,
            "Phương thức thanh toán",
          ), // Mục phương thức thanh toán.
          Divider(height: 1, indent: 55),
          buildTile(3, Icons.location_on, "Địa chỉ"), // Mục địa chỉ.
          Divider(height: 1, indent: 55),

          buildTile(4, Icons.settings, "Cài đặt"), // Mục cài đặt.
          Divider(height: 1, indent: 55),

          // Thông báo đăng xuất
          ListTile(
            leading: Icon(
              Icons.logout,
              color: Colors.red,
            ), // Icon logout màu đỏ.
            title: Text(
              "Đăng xuất",
              style: TextStyle(color: Colors.red),
            ), // Tiêu đề "Đăng xuất".
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible:
                    false, // Không thể tắt hộp thoại bằng cách chạm ra ngoài.
                builder: (context) {
                  return _Warning(
                    context,
                  ); // Hiển thị hộp thoại cảnh báo khi người dùng chọn đăng xuất.
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Hàm tạo widget cho các mục menu trong giao diện
  Widget buildTile(int index, IconData icon, String title) {
    return InkWell(
      // InkWell cho phép tạo hiệu ứng khi người dùng chạm vào mục.
      onTap: () {
        SetColor(index); // Gọi hàm SetColor khi người dùng chọn mục này.
      },
      child: ListTile(
        // ListTile là widget dùng để tạo các mục trong danh sách.
        leading: Icon(icon), // Biểu tượng nằm ở đầu của mỗi mục.
        title: Text(title), // Tiêu đề của mục.
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 20,
        ), // Biểu tượng mũi tên chỉ hướng tiếp theo.
      ),
    );
  }

  // Hộp thoại cảnh báo khi người dùng muốn đăng xuất
  Widget _Warning(BuildContext context) {
    return Dialog(
      // Dialog tạo một hộp thoại nổi.
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // Bo góc của hộp thoại.
      child: Padding(
        padding: const EdgeInsets.all(20), // Padding xung quanh hộp thoại.
        child: Column(
          // Sử dụng Column để sắp xếp các phần tử trong hộp thoại theo chiều dọc.
          mainAxisSize:
              MainAxisSize.min, // Thiết lập chiều cao của Column tối thiểu.
          children: [
            Icon(
              Icons.question_mark,
              color: Colors.redAccent,
              size: 60,
            ), // Biểu tượng dấu hỏi lớn màu đỏ ở đầu hộp thoại.
            const SizedBox(
              height: 16,
            ), // Khoảng cách giữa biểu tượng và câu hỏi.
            Text(
              'Bạn có chắc chắn muốn đăng xuất?', // Câu hỏi cảnh báo người dùng.
              textAlign: TextAlign.center, // Canh giữa câu hỏi.
              style: TextStyle(
                fontSize: 18, // Kích thước chữ của câu hỏi.
                fontWeight: FontWeight.bold, // Làm đậm câu hỏi.
                fontFamily:
                    AppStyle
                        .fontFamily, // Font chữ (có thể được định nghĩa trong AppStyle).
              ),
            ),
            const SizedBox(
              height: 24,
            ), // Khoảng cách giữa câu hỏi và các nút bấm.
            Row(
              // Sử dụng Row để chứa hai nút bấm.
              children: [
                Expanded(
                  // Mở rộng nút bấm để chiếm không gian đều.
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(
                        context,
                      ).pop(); // Đóng hộp thoại khi người dùng chọn "Quay lại".
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.grey[300], // Màu nền của nút "Quay lại".
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Bo góc của nút.
                      ),
                    ),
                    child: Text(
                      'Quay lại', // Text trên nút "Quay lại".
                      style: TextStyle(
                        color: Colors.black, // Màu chữ trên nút.
                        fontWeight: FontWeight.bold, // Làm đậm chữ.
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12), // Khoảng cách giữa hai nút.
                Expanded(
                  // Mở rộng nút bấm để chiếm không gian đều.
                  child: ElevatedButton(
                    onPressed: () {
                      _XoaUser(); // Gọi hàm _XoaUser khi người dùng chọn "Đồng ý" (xóa tài khoản).
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.white, // Màu nền của nút "Đồng ý".
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          12,
                        ), // Bo góc của nút.
                      ),
                    ),
                    child: Text(
                      'Đồng ý', // Text trên nút "Đồng ý".
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ), // Làm đậm chữ trên nút.
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
