import 'package:flutter/material.dart';
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
  //lits kiểu widget chưa các screens
 late final  List<Widget> listScreen = [
    GiaoDienHome(email: widget.email),
    GiaoDienBan(email: widget.email),
    GiaoDienThongBao(email: widget.email),
    GiaoDienTaiKhoan(email: widget.email),
  ];
  int _slectedIndex = 0;
  void SetIndex(int value) {
    setState(() {
      _slectedIndex = value;
    });
  }

  Color clIcon = Colors.green;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: listScreen[_slectedIndex],
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


