import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienThanhToan extends StatefulWidget {
  const GiaoDienThanhToan({super.key});

  @override
  State<GiaoDienThanhToan> createState() => _GiaoDienThanhToanState();
}

class _GiaoDienThanhToanState extends State<GiaoDienThanhToan> {
  List<Map<String, String>> linkedBanks = [];

  List<Map<String, String>> availableBanks = [
    {'name': 'Vietcombank', 'account': '037672589', 'owner': 'Nguyen Van A'},
    {'name': 'Sacombank', 'account': '123456789a', 'owner': 'Tran Thi B'},
    {'name': 'TPBank', 'account': '9988776655', 'owner': 'Le Van C'},
    {'name': 'BIDV', 'account': '1122334455', 'owner': 'Pham D'},
  ];

  void _showAddBankSheet() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Tính năng đang phát triển')))
      );
  }

  void _removeLinkedBank(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hủy liên kết'),
        content: Text('Bạn có chắc muốn hủy liên kết ngân hàng này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Không'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                availableBanks.add(linkedBanks[index]);
                linkedBanks.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Có'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            ),
            SizedBox(width: 8),
            Text(
              'Phương thức thanh toán',
              style: GoogleFonts.robotoSlab(
                    fontSize: AppStyle.textSizeTitle,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSectionTitle('Các phướng thức thanh toán'),
           
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Thanh toán khi nhận hàng'),
                  ),
                  Icon(Icons.check, color: Colors.green,)
                ],
                
              ),
            
            Divider(thickness: 1, height: 32),
            _buildSectionTitle('Thêm phương thức'),
            ListTile(
              leading: Icon(Icons.add_card, color: Colors.blueAccent),
              title: Text("Thêm ngân hàng liên kết"),
              onTap: _showAddBankSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
    );
  }
}
