import 'dart:math';

import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Screens/ScreenAccount.dart';
import 'package:nama_app/Screens/ScreenHome.dart';
import 'package:nama_app/Screens/ScreenNofi.dart';
import 'package:nama_app/Screens/ScreenSell.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class ProcessSccreen extends StatefulWidget {
  final String? email;
  const ProcessSccreen({Key? key, this.email}) : super(key: key);

  @override
  State<ProcessSccreen> createState() => _ProcessSccreenState();
}

class _ProcessSccreenState extends State<ProcessSccreen> {
  // Khởi tạo các biến và đối tượng cần thiết
  Firebauth firebaseAuth =
      Firebauth(); // Đối tượng Firebauth dùng để tương tác với Firebase
  int _slectedIndex = 0; // Biến lưu trữ chỉ mục của màn hình hiện tại
  List<Widget>? listScreen =
      []; // Danh sách các màn hình sẽ hiển thị trong ứng dụng

  // Hàm lấy thông tin cho giao diện thông báo
  void layThongTinChoGiaoDienThongBao() async {
    await Future.delayed(Duration(seconds: 2));
    // Khai báo danh sách các đơn bán, đơn mua và sản phẩm
    List<Map<String, dynamic>>? itemsSell = [];
    List<Map<String, dynamic>>? itemsBuy = [];
    List<Product> itemProducts = [];

    // Lấy các đơn bán, đơn mua và danh sách sản phẩm từ Firestore thông qua firebaseAuth
    itemsSell = await firebaseAuth.getOrderByEmailSell(widget.email.toString());
    itemsBuy = await firebaseAuth.GetOrderByEmailBuy(widget.email.toString());
    itemProducts = await firebaseAuth.getAllProduct();

    // Sắp xếp danh sách đơn mua theo thời gian tạo đơn (mới nhất lên đầu)
    itemsBuy.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(
        dateA,
      ); // So sánh ngày để sắp xếp đơn hàng theo thứ tự giảm dần
    });

    // Sắp xếp danh sách đơn bán theo thời gian tạo đơn (mới nhất lên đầu)
    itemsSell.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(
        dateA,
      ); // So sánh ngày để sắp xếp đơn hàng theo thứ tự giảm dần
    });

    // Sau khi lấy được dữ liệu, cập nhật lại giao diện với các màn hình tương ứng

    listScreen = [
      GiaoDienHome(
        email: widget.email,
        itemProducts: itemProducts,
      ), // Màn hình trang chủ
      GiaoDienBan(email: widget.email), // Màn hình bán hàng
      GiaoDienThongBao(
        email: widget.email,
        items: itemsSell,
        itemsBuy: itemsBuy,
      ), // Màn hình thông báo
      GiaoDienTaiKhoan(email: widget.email), // Màn hình tài khoản
    ];
    if (mounted) setState(() {});
  }

  // Hàm để thay đổi chỉ mục của màn hình hiện tại
  void SetIndex(int value) {
    // Lấy thông tin mới cho giao diện thông báo khi thay đổi chỉ mục
    layThongTinChoGiaoDienThongBao();

    // Cập nhật lại giá trị của chỉ mục và gọi lại setState để render lại giao diện
    setState(() {
      _slectedIndex = value;
    });
  }

  // Hàm khởi tạo khi màn hình được tạo
  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy thông tin ngay khi màn hình được khởi tạo
    layThongTinChoGiaoDienThongBao();
  }

  // Khai báo màu sắc cho icon (có thể sử dụng trong các phần khác của UI)
  Color clIcon = Colors.green; // Màu xanh cho icon

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          listScreen != null && listScreen!.isNotEmpty
              ? listScreen![_slectedIndex]
              : Center(
                child: Container(
                  width: double.infinity,
                  height: 60,
                  child: Align(
                    alignment: Alignment.center,
                    child: Marquee(
                      direction: Axis.horizontal,
                      animationDuration: Duration(
                        milliseconds: 2000,
                      ), // tốc độ vừa phải
                      backDuration: Duration(milliseconds: 20),
                      pauseDuration: Duration(seconds: 0),
                      child: Row(
                        children: [
                          SizedBox(width: 450),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi), // Lật theo trục Y
                            child: Icon(
                              Icons.local_shipping,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                          Text(
                            '........................................................................................',
                            style: TextStyle(color: Colors.green),
                          ),
                          // SizedBox(width: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          if (listScreen != null && listScreen!.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              bottom: 5,
              child: SafeArea(
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(30),

                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: LinearGradient(
                        colors: [Colors.grey, Colors.grey], // nhiều màu
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: NavigationBarTheme(
                      data: NavigationBarThemeData(
                        height: 70,
                        indicatorColor: Colors.purple.shade50,
                    
                        indicatorShape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: SalomonBottomBar(
                        currentIndex: _slectedIndex,
                        onTap: (i) => SetIndex(i),
                        items: [
                          SalomonBottomBarItem(
                            icon: Icon(Icons.home),
                            title: Text("Home"),
                            selectedColor: Colors.white,
                          ),
                          SalomonBottomBarItem(
                            icon:Icon(Icons.sell),
                       
                            title: Text("Sản phẩm"),
                            selectedColor: Colors.white,
                          ),
                          SalomonBottomBarItem(
                            icon: Icon(Icons.notifications),
                            title: Text("Thông báo"),
                            selectedColor: Colors.white,
                          ),
                          SalomonBottomBarItem(
                            icon: Icon(Icons.person),
                            title: Text("Tài khoản"),
                            selectedColor: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),

      backgroundColor: AppStyle.backgroundColor,
    );
  }
}
