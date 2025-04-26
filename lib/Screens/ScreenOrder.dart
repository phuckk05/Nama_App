import 'package:flutter/material.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDonHang extends StatefulWidget {
  const GiaoDienDonHang({super.key});

  @override
  State<GiaoDienDonHang> createState() => _GiaoDienDonHangState();
}

class _GiaoDienDonHangState extends State<GiaoDienDonHang> {
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
                style: TextStyle(
                  fontSize: AppStyle.textSizeTitle,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: (){
                  Navigator.pop(context);
                },
                child: Text(
                'Lưu',
                style: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  color: Colors.white,
                ),
              ),
              )
            ),
          ),
        ],
      ),
      body: Column(
        children: [
           Container(height: 10, color: Colors.blueGrey),
           
        ],
      ),
    );
    
    
  }
}