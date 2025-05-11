import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/Sqlite.dart';
import 'package:nama_app/Screens/ScreenLogin.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';

// Định nghĩa lớp GiaoDienBatDau kế thừa StatelessWidget
// ignore: must_be_immutable
class GiaoDienBatDau extends StatelessWidget {
  // Tạo đối tượng SQLiteService để truy cập dữ liệu từ SQLite
  SQLiteService _sqLiteService = SQLiteService();
  GiaoDienBatDau({super.key});

  // Hàm kiểm tra người dùng (email) trong cơ sở dữ liệu
  void checkUser(BuildContext context) async {
    // Lấy email của người dùng từ SQLite
    String? reslut = await _sqLiteService.getUserEmail();

    // Nếu có email, điều hướng đến màn hình ProcessSccreen với email
    if (reslut != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProcessSccreen(email: reslut)),
      );
    }
    // Nếu không có email (người dùng chưa đăng nhập), điều hướng đến màn hình DangNhap
    else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DangNhap()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Sử dụng Timer để trì hoãn việc kiểm tra người dùng sau 5 giây
    Timer(Duration(seconds: 5), () {
      checkUser(context); // Kiểm tra người dùng sau 5 giây
    });

    // Giao diện chính của màn hình
    return Scaffold(
      // Nội dung của màn hình là một widget Center chứa một ảnh (logo)
      body: Center(
        child: Image.asset(
          'lib/Image/logonama.jpg', // Đường dẫn ảnh logo
          width: 200, // Chiều rộng của ảnh
          height: 50, // Chiều cao của ảnh
        ),
      ),
    );
  }
}
