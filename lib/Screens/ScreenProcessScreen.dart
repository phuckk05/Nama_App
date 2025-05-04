import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Screens/ScreenAccount.dart';
import 'package:nama_app/Screens/ScreenHome.dart';
import 'package:nama_app/Screens/ScreenNofi.dart';
import 'package:nama_app/Screens/ScreenSell.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class ProcessSccreen extends StatefulWidget {
  final String? email;
  const ProcessSccreen({Key? key, this.email}) : super(key: key);

  @override
  State<ProcessSccreen> createState() => _ProcessSccreenState();
}

class _ProcessSccreenState extends State<ProcessSccreen> {
  Firebauth firebaseAuth = Firebauth();
  int _slectedIndex = 0;
  List<Widget>? listScreen = [];

 

  //hiện thị dữ liệu trước cho giao diện thông báo 
  void layThongTinChoGiaoDienThongBao() async {
    List<Map<String, dynamic>>? itemsSell = [];
    List<Map<String, dynamic>>? itemsBuy = [];
    List<Product>itemProducts =[];
    itemsSell = await firebaseAuth.getOrderByEmailSell(widget.email.toString());
    itemsBuy = await firebaseAuth.GetOrderByEmailBuy(widget.email.toString());
    itemProducts = await firebaseAuth.getAllProduct();
    itemsBuy.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });
    itemsSell.sort((a, b) {
      DateTime dateA = DateTime.parse(a['createdAt']);
      DateTime dateB = DateTime.parse(b['createdAt']);
      return dateB.compareTo(dateA);
    });

    setState(() {
      listScreen = [
        GiaoDienHome(email: widget.email, itemProducts: itemProducts),
        GiaoDienBan(email: widget.email),
        GiaoDienThongBao(email: widget.email, items: itemsSell, itemsBuy: itemsBuy),
        GiaoDienTaiKhoan(email: widget.email),
      ];
    });
  }

  void SetIndex(int value) {
    layThongTinChoGiaoDienThongBao();
    setState(() {
      _slectedIndex = value;
    });
  }

  @override
  void initState() {
    super.initState();
     layThongTinChoGiaoDienThongBao();
  }

  Color clIcon = Colors.green;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: listScreen != null && listScreen!.isNotEmpty
          ? listScreen![_slectedIndex]
          : const Center(child: CircularProgressIndicator()),
      backgroundColor: AppStyle.backgroundColor,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _slectedIndex,
        onDestinationSelected: (value) {
          SetIndex(value);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: "Home",
            selectedIcon: Icon(Icons.home, color: clIcon),
          ),
          NavigationDestination(
            icon: Icon(Icons.sell_outlined),
            label: "Sản phẩm",
            selectedIcon: Icon(Icons.sell, color: clIcon),
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_active_outlined),
            label: "Thông báo",
            selectedIcon: Icon(Icons.notifications_active, color: clIcon),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            label: "Tài khoản",
            selectedIcon: Icon(Icons.person, color: clIcon),
          ),
        ],
      ),
    );
  }
}
