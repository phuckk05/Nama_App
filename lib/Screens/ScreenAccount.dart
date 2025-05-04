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
  SQLiteService _sqLiteService = SQLiteService();
  Firebauth _firebauth = Firebauth();
  List<Map<String, dynamic>> items = [];
  int? _selectedIndex;
  int? Index;
  String? _result;
  List<String> _split = [];
  List<DonHang> listDonHang = [];
  List<DonHang> listDonHangChoGiao = [];
  List<DonHang> listDonHangDaGiao = [];
  List<DonHang> listDuyetDonHang = [];
  List<Map<String, dynamic>> address = [];
  List<Map<String, dynamic>> addressDaGiao = [];
  List<String> index2 = [];
  List<String> index3 = [];
  //on created
  @override
  void initState() {
    super.initState();
    _Lay_Thong_Tin_User();
    LayThonTinDonHang();
  }

  //lấy thông tin users
  // ignore: non_constant_identifier_names
  void _Lay_Thong_Tin_User() async {
    _result = await _firebauth.GetAllUser(widget.email.toString());
    if (mounted) {
      setState(() {
        _split = _result.toString().split('+');
      });
    }
  }

  //xóa user khỏi sqlite
  // ignore: non_constant_identifier_names
  void _XoaUser() async {
    _sqLiteService.DeleteUser(widget.email.toString());
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DangNhap()),
    );
  }

  //set color
  void SetColor(int index) async {
    if (index == 1) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GiaoDienThongTin(email: widget.email.toString()),
        ),
      );
      if (result == true) {
        _Lay_Thong_Tin_User();
        setState(() {});
      }
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GiaoDienThanhToan()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GiaoDienDiaChi(email: widget.email.toString()),
        ),
      );
    } else if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => GiaoDienCaiDat()),
      );
    } else if (index == 5) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GiaoDienDonHang(
                email: widget.email.toString(),
                listDonHang: listDonHangDaGiao,
              ),
        ),
      );
      if (result == true) {
        LayThonTinDonHang();
        setState(() {});
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => GiaoDienQuanLyDonHang(
                email: widget.email.toString(),
                listDonHang: listDuyetDonHang,
                address: address,
                addressDaGiao: index2,
                addressDaGiao2: index3,
              ),
        ),
      );
      if (result == true) {
        LayThonTinDonHang();
        setState(() {});
      }
    }
  }

  void LayThonTinDonHang() async {
    listDonHang = await _firebauth.GetOrderByEmailBuyChoXacNhan(
      widget.email.toString(),
    );
    listDonHangChoGiao = await _firebauth.GetOrderByEmailBuyChoGiao(
      widget.email.toString(),
    );
    listDonHangDaGiao = await _firebauth.GetOrderByEmailBuyDaGiao(
      widget.email.toString(),
    );
    listDuyetDonHang = await _firebauth.getOrderSell(widget.email.toString());

    List<String> index = [];

    for (int i = 0; i < listDuyetDonHang.length; i++) {
      if (listDuyetDonHang[i].status == "Chờ xác nhận") {
        index.add(listDuyetDonHang[i].address.toString());
      }
      if (listDuyetDonHang[i].status == "Chờ giao") {
        index2.add(listDuyetDonHang[i].address.toString());
      }
      if (listDuyetDonHang[i].status == "Đã giao") {
        index2.add(listDuyetDonHang[i].address.toString());
      }
    }

    // address = await _firebauth.getAddressById(index);

    if (mounted) {
      setState(() {});
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // PHẦN AVATAR NGƯỜI DÙNG
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child:
                                _split.isNotEmpty
                                    ? Image.network(
                                      _split[1],
                                      fit: BoxFit.cover,
                                    )
                                    : CircularProgressIndicator(),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 50,
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () async {
                              final reslut = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => GiaoDienThongTin(
                                        email: widget.email.toString(),
                                      ),
                                ),
                              );
                              if (reslut == true) {
                                _Lay_Thong_Tin_User();
                                setState(() {});
                              }
                            },
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints(),
                            icon: Icon(Icons.camera_alt, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          _split.isNotEmpty
                              ? _split[2].toString()
                              : "Đang tải lên...",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.email ?? 'Đang tải lên...',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            buildTile(6, Icons.production_quantity_limits, "Quản lý đơn hàng"),
            Divider(height: 1, indent: 55),
            buildTile(5, Icons.production_quantity_limits, "Đơn hàng của bạn"),
            Divider(height: 1, indent: 55),
            buildTile(1, Icons.edit, "Thông tin cá nhân"),
            Divider(height: 1, indent: 55),
            buildTile(2, Icons.payment, "Phương thức thanh toán"),
            Divider(height: 1, indent: 55),
            buildTile(3, Icons.location_on, "Địa chỉ"),
            Divider(height: 1, indent: 55),

            buildTile(4, Icons.settings, "Cài đặt"),
            Divider(height: 1, indent: 55),

            // thông báo về đăng xuất
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return _Warning(context);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //build title
  Widget buildTile(int index, IconData icon, String title) {
    return InkWell(
      onTap: () {
        SetColor(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        color: _selectedIndex == index ? Colors.grey[300] : Colors.white,
        child: ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Icon(Icons.arrow_forward_ios, size: 20),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  Widget _Warning(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.question_mark, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(
              'Bạn có chắc chắn muốn đăng xuất?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: AppStyle.fontFamily,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Quay lại',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _XoaUser();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Đồng ý',
                      style: TextStyle(fontWeight: FontWeight.bold),
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
