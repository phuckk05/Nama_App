import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienQuanLyDonHang extends StatefulWidget {
  final String? email;
  const GiaoDienQuanLyDonHang({super.key, this.email});

  @override
  State<GiaoDienQuanLyDonHang> createState() => _GiaoDienQuanLyDonHangState();
}

class _GiaoDienQuanLyDonHangState extends State<GiaoDienQuanLyDonHang> with SingleTickerProviderStateMixin {
   late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'Đơn hàng',
                style: GoogleFonts.robotoSlab(
                    fontSize: AppStyle.textSizeTitle,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.black,
              labelStyle: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold
              ),
              tabs: [
                Tab(text: 'Xác nhận'),
                Tab(text: 'Chờ giao hàng'),
                Tab(text: 'Đã giao'),
                Tab(text: 'Đánh giá'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                 Center(child: Text('Hello 4')),
                Center(child: Text('Hello 4')),
             Center(child: Text('Hello 4')),
                Center(child: Text('Hello 4')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}