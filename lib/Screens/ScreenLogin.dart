import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/DataBase/Sqlite.dart';
import 'package:nama_app/Screens/ScreenLogup.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class DangNhap extends StatefulWidget {
  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  // Khai báo các đối tượng và biến cần thiết
  Firebauth _auth =
      Firebauth(); // Đối tượng Firebauth dùng để gọi các phương thức xác thực người dùng
  SQLiteService _sqLiteService =
      SQLiteService(); // Đối tượng SQLiteService dùng để quản lý dữ liệu SQLite
  int? lenghtText; // Biến lưu độ dài của text nhập vào từ sdt
  final sdt =
      TextEditingController(); // Controller cho TextField nhập số điện thoại
  final code =
      TextEditingController(); // Controller cho TextField nhập mã xác nhận
  bool isCheckSwich = false; // Biến kiểm tra trạng thái switch (nếu có)
  Color clicon = Colors.white; // Màu của icon khi chưa nhập dữ liệu
  Color isColor = Color.fromARGB(
    114,
    220,
    220,
    220,
  ); // Màu nền khi không có dữ liệu
  bool _offStateCode =
      true; // Trạng thái kiểm tra mã (true = chờ mã, false = đã có mã)

  // Hàm kiểm tra giá trị nhập vào từ số điện thoại
  void CheckValue() {
    if (sdt.text.isNotEmpty) {
      // Nếu có giá trị, thay đổi màu sắc của các thành phần giao diện
      setState(() {
        clicon = Colors.black; // Đổi màu của icon thành đen
        isColor = Colors.green; // Đổi màu nền thành xanh
      });
    } else {
      // Nếu không có giá trị, khôi phục màu sắc mặc định
      setState(() {
        clicon = Colors.white;
        isColor = Color.fromARGB(114, 220, 220, 220); // Màu nền mặc định
      });
    }
  }

  // Hàm xử lý khi cần xóa giá trị nhập vào và reset trạng thái
  void CheckSuffi() {
    setState(() {
      sdt.clear(); // Xóa giá trị trong TextField
      clicon = Colors.white; // Đặt lại màu icon
      isColor = Color.fromARGB(114, 220, 220, 220); // Đặt lại màu nền
      _offStateCode = true; // Đặt lại trạng thái chờ mã
    });
  }

  // Hàm kiểm tra giá trị khi người dùng nhập số điện thoại
  void CheckValue2() async {
    if (_offStateCode == true) {
      // Nếu trạng thái là chờ mã
      final email = sdt.text.trim();
      final isGmail = RegExp(
        r'^[\w-\.]+@gmail\.com$',
      ).hasMatch(email); // Kiểm tra định dạng email
      if (!isGmail) {
        setState(() {
          _offStateCode =
              true; // Nếu email không đúng định dạng, giữ trạng thái chờ mã
        });
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Center(
                child: Text(
                  'Vui lòng nhập đúng định dạng',
                  style: TextStyle(fontSize: AppStyle.paddingMedium),
                ),
              ),
            ),
          ),
        );
      } else {
        // Nếu email đúng định dạng
        setState(() {
          lenghtText = sdt.text.length; // Lưu độ dài của email
          _offStateCode = false; // Đặt trạng thái thành đã có mã
        });
        int kq = await _auth.CheckLoGin(
          email,
          context,
        ); // Kiểm tra nếu email có tồn tại trong hệ thống
        if (kq == 0) {
          setState(() {
            _offStateCode =
                true; // Nếu email không tồn tại, giữ trạng thái chờ mã
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Center(child: Text('Email không tồn tại'))),
            );
          });
        }
        XoaCode(); // Gọi hàm XoaCode để gửi mã
      }
    } else {
      // Nếu đã có mã
      if (code.text.isNotEmpty) {
        int ketQua = await _auth.checkCodeLogin(
          sdt.text.toString(),
          code.text.toString(),
        ); // Kiểm tra mã xác nhận
        if (ketQua == 1) {
          XoaCodeLuon(); // Nếu mã đúng, xóa mã xác nhận
          await _sqLiteService.insertUser({
            "email": sdt.text.toString(),
          }); // Lưu email vào SQLite
          // Điều hướng đến màn hình tiếp theo
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProcessSccreen(email: sdt.text.toString()),
            ),
          );
        } else {
          // Nếu mã sai, hiển thị thông báo lỗi
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sai mã xác nhận !')));
        }
      } else {
        // Nếu chưa nhập mã, yêu cầu người dùng nhập mã
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Vui lòng nhập mã',
                style: TextStyle(fontSize: AppStyle.textSizeSmall),
              ),
            ),
          ),
        );
      }
    }
  }

  // Hàm kiểm tra độ dài của số điện thoại có thay đổi hay không
  void CheckValue3() {
    if (lenghtText != sdt.text.length) {
      _offStateCode = true; // Nếu độ dài thay đổi, đặt lại trạng thái chờ mã
    }
  }

  // Hàm xóa mã xác nhận sau 60 giây
  void XoaCode() async {
    Timer(Duration(seconds: 60), () {
      _auth.TimeCode(
        sdt.text.toString(),
      ); // Gọi phương thức TimeCode từ Firebauth để xóa mã
    });
  }

  // Hàm xóa mã xác nhận ngay lập tức
  void XoaCodeLuon() async {
    await _auth.TimeCode(sdt.text.toString()); // Xóa mã ngay lập tức
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        centerTitle: true,
        leading: Icon(Icons.arrow_back_ios, color: Colors.white),
        title: Text(
          'Đăng Nhập',
          style: TextStyle(
            fontSize: AppStyle.textSizeTitle,
            color: AppStyle.textGreenColor,
            fontWeight: FontWeight.bold,
            fontFamily: AppStyle.fontFamily,
          ),
        ),
      ),
      body: body(),

      backgroundColor: Colors.white,
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Container(
          height: 70,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GiaoDienDangKi()),
              );
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Bạn chưa có tài khoản?",
                    style: TextStyle(
                      fontSize: AppStyle.paddingMedium,
                      color: AppStyle.textGreenColor,
                    ),
                  ),
                  TextSpan(
                    text: " Đăng kí ngay",
                    style: TextStyle(
                      fontSize: AppStyle.paddingMedium,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget body để tạo giao diện của màn hình đăng nhập
  Widget body() {
    return SingleChildScrollView(
      // Dùng SingleChildScrollView để cuộn khi nội dung dài
      child: Column(
        children: [
          SizedBox(height: 50), // Khoảng cách trên đầu màn hình
          Center(
            child: Image.asset(
              'lib/Image/logo.jpg',
              width: 250,
              height: 60,
            ), // Hiển thị logo ở giữa màn hình
          ),
          SizedBox(height: 50), // Khoảng cách dưới logo
          // TextField cho số điện thoại hoặc email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: sdt, // Gán controller cho TextField
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  top: 15,
                ), // Padding cho nội dung
                prefixIcon: Icon(Icons.email), // Biểu tượng email phía trước
                hintText: "Email", // Placeholder cho TextField
                hintStyle: TextStyle(
                  fontSize: AppStyle.paddingMedium, // Cỡ chữ của placeholder
                  color: Colors.black,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    CheckSuffi(); // Xử lý khi nhấn vào icon xóa
                  },
                  icon: Icon(Icons.close, color: clicon), // Icon xóa
                ),
              ),
              keyboardType:
                  TextInputType.emailAddress, // Loại bàn phím cho email
              onChanged: (value) {
                CheckValue(); // Kiểm tra giá trị nhập vào
                CheckValue3(); // Kiểm tra độ dài nhập vào
              },
            ),
          ),

          // TextField cho mã xác nhận, hiển thị khi _offStateCode là false
          Offstage(
            offstage:
                _offStateCode, // Ẩn TextField khi không cần nhập mã xác nhận
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
              child: TextField(
                controller: code, // Gán controller cho mã xác nhận
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15),
                  prefixIcon: Icon(Icons.verified), // Biểu tượng mã xác nhận
                  hintText: "Nhập code", // Placeholder cho mã xác nhận
                  hintStyle: TextStyle(
                    fontSize: AppStyle.paddingMedium,
                    color: AppStyle.textGreenColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      AppStyle.borderRadius,
                    ), // Border cho TextField
                  ),
                ),
                onChanged: (value) {},
                keyboardType:
                    TextInputType.phone, // Loại bàn phím cho mã xác nhận
                inputFormatters: [
                  FilteringTextInputFormatter
                      .digitsOnly, // Chỉ cho phép nhập số
                  LengthLimitingTextInputFormatter(
                    6,
                  ), // Giới hạn nhập tối đa 6 ký tự
                ],
              ),
            ),
          ),

          SizedBox(height: 20), // Khoảng cách dưới TextField
          // Nút "Tiếp theo"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isColor, // Màu nền nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppStyle.borderRadius,
                    ), // Bo góc cho nút
                    side: BorderSide(
                      color: Colors.black,
                      width: 2, // Viền nút
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {
                  if (sdt.text.isNotEmpty) {
                    CheckValue2(); // Gọi hàm kiểm tra email và mã
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text(
                            'Vui lòng nhập thông tin !',
                          ), // Thông báo nếu chưa nhập số điện thoại
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Tiếp theo',
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 50), // Khoảng cách giữa các phần tử
          // Phân cách giữa "Hoặc" và các nút đăng nhập
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 1,
                  child: Container(color: Colors.blueGrey), // Đường kẻ ngang
                ),
                Text(
                  ' Hoặc ',
                  style: TextStyle(
                    color: AppStyle.textGreenColor, // Màu chữ "Hoặc"
                    fontSize: AppStyle.paddingMedium,
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 1,
                  child: Container(color: Colors.blueGrey), // Đường kẻ ngang
                ),
              ],
            ),
          ),

          // Các nút đăng nhập bằng các nền tảng khác nhau (Google, Facebook, Apple)

          // Nút đăng nhập bằng Google
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.textGreenColor, // Màu nền của nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2, // Viền của nút
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {}, // Tạm thời không thực hiện hành động
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.google,
                      size: 25,
                    ), // Biểu tượng Google
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đăng nhập bằng Google', // Văn bản nút
                          style: TextStyle(
                            fontSize: AppStyle.paddingMedium,
                            color: Colors.white,
                            fontFamily: AppStyle.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 40),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10), // Khoảng cách dưới nút đăng nhập Google
          // Nút đăng nhập bằng Facebook
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.textGreenColor, // Màu nền của nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2, // Viền của nút
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {}, // Tạm thời không thực hiện hành động
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.facebook,
                      size: 25,
                    ), // Biểu tượng Facebook
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Đăng nhập bằng Facebook', // Văn bản nút
                          style: TextStyle(
                            fontSize: AppStyle.paddingMedium,
                            color: Colors.white,
                            fontFamily: AppStyle.fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 25),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10), // Khoảng cách dưới nút đăng nhập Facebook
          // Nút đăng nhập bằng Apple
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.textGreenColor, // Màu nền của nút
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2, // Viền của nút
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {}, // Tạm thời không thực hiện hành động
                child: Row(
                  children: [
                    FaIcon(
                      FontAwesomeIcons.apple,
                      size: 30,
                    ), // Biểu tượng Apple
                    SizedBox(width: 35),
                    Text(
                      'Đăng nhập bằng Apple', // Văn bản nút
                      style: TextStyle(
                        fontSize: AppStyle.paddingMedium,
                        color: Colors.white,
                        fontFamily: AppStyle.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
