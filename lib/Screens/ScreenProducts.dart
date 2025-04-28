import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/DataBase/Sqlite.dart';
import 'package:nama_app/Screens/ScreeenBuy.dart';
import 'package:nama_app/Screens/ScreenCart.dart';
import 'package:nama_app/Screens/ScreenPayment.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:nama_app/Widgets/Seach.dart';

class GiaoDienSanPham extends StatefulWidget {
  const GiaoDienSanPham({Key? key, this.id, this.email}) : super(key: key);
  final String? id;
  final String? email;

  @override
  State<GiaoDienSanPham> createState() => _GiaoDienSanPhamState();
}

class _GiaoDienSanPhamState extends State<GiaoDienSanPham> {
  Firebauth _firebauth = Firebauth();
  FocusNode searchFocus = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _textTimKiem = TextEditingController();
  double _tienDo = 0.1;
  Timer? timer;
  String? name;
  String? total;
  String? decription;
  int _soLuong = 1;
  Color _colorIconTru = Colors.black45;
  List<Color> listColor = [
    Colors.lightGreenAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.blueGrey,
  ];
  final List<Map<String, dynamic>> items = [];

  void LaySanPham() async {
    String nameUser = await _firebauth.showProducts(
      widget.id.toString(),
      items,
    );

    setState(() {
      List<String> list = nameUser.split(':');
      name = list[0];
      total = list[1];
    });
  }

  @override
  void initState() {
    super.initState();
    LoadTienDo();
    LaySanPham();
  }

  void LuuSanPham() async {
    int _checkOr = await _firebauth.CheckOrder(
      widget.email.toString(),
      items[0]['id'],
    );
    if (_checkOr == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Bạn không thể tự đặt sản phẩm của mình'),
          ),
        ),
      );
    } else {
      String totalSL = "1";
      _firebauth.saveCarts(
        widget.email.toString(),
        widget.id.toString(),
        totalSL,
        items[0]['imageUrl'],
        items[0]['name'].toString(),
        items[0]['price'],
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Thêm vào giỏ hàng thành công !')),
        ),
      );
    }
  }

  void CheckMuaSanPham(List<Map<String, dynamic>> items) async {
    int _checkOr = await _firebauth.CheckOrder(
      widget.email.toString(),
      items[0]['id'],
    );
    if (_checkOr == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Bạn không thể tự đặt sản phẩm của mình'),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return _SoLuong(context, items);
        },
      );
    }
  }

  void LoadTienDo() {
    timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        _tienDo += 0.1;
        if (_tienDo >= 1.0) {
          _tienDo = 0.0;
        }
      });
    });
  }

  void TruSL() {
    if (_soLuong > 1) {
      setState(() {
        _soLuong = _soLuong - 1;
      });
    }
  }

  void CongSL() {
    setState(() {
      _soLuong = _soLuong + 1;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.green,
        actions: [
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: GestureDetector(
                onTap: () {
                  searchFocus.unfocus();
                  _scaffoldKey.currentState?.openDrawer();
                },

                child: AbsorbPointer(
                  child: TextField(
                    readOnly: false,
                    focusNode: searchFocus,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(top: 10, left: 10),

                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyle.borderRadius,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      hintText: "Tìm kiếm",
                      hintStyle: TextStyle(
                        fontSize: AppStyle.paddingMedium,
                        color: AppStyle.textGreenColor,
                      ),
                      // suffixIcon: IconButton(
                      //   onPressed: () {},
                      //   icon: Icon(Icons.camera_alt_outlined),
                      // ),
                    ),
                    onChanged: (value) {},
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GiaoDienGioHang(
                            email: widget.email.toString(),
                            id: widget.id.toString(),
                          ),
                    ),
                  );
                },
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 350,
              child:
                  items.isNotEmpty
                      ? CachedNetworkImage(
                        imageUrl: items[0]["imageUrl"],
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.fill,
                        placeholder:
                            (context, url) => Center(
                              child:
                                  CircularProgressIndicator(), // Hiện loading trong lúc ảnh đang tải
                            ),
                        errorWidget:
                            (context, url, error) =>
                                Icon(Icons.error), // Nếu load lỗi
                      )
                      : Image.asset('lib/Image/nen.png', fit: BoxFit.fill),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10),
              child: Row(
                children: [
                  Text(
                    'Giá trị sản phẩm : ',
                    style: TextStyle(
                      fontSize: AppStyle.textSizeMedium,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (items.isNotEmpty)
                    Expanded(
                      child: Text(
                        '${items[0]['price'].toString()} đ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppStyle.textSizeLarge,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    )
                  else
                    Text('0'),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Địa chỉ : ",
                        style: TextStyle(color: Colors.blueGrey),
                      ),
                      items.isNotEmpty
                          ? TextSpan(
                            text: "${items[0]['address'].toString()}",
                            style: TextStyle(color: Colors.black),
                          )
                          : TextSpan(
                            text: "??",
                            style: TextStyle(color: Colors.black),
                          ),
                    ],
                  ),
                ),
              ),
            ),
            Divider(),
            // Divider(endIndent: 10, indent: 10),
            // ListTile(
            //   leading: Icon(Icons.local_shipping_outlined),
            //   title: Text('Địa chỉ giao hàng'),
            //   trailing: Icon(Icons.chevron_right, size: 25),
            // ),
            // Divider(indent: 10, endIndent: 10),
            // ListTile(
            //   leading: Icon(Icons.payment),
            //   title: Text('Phương thức thanh toán'),
            //   trailing: Icon(Icons.chevron_right, size: 25),
            // ),
            // Divider(indent: 10, endIndent: 10),
            // Container(
            //   height: 10,
            //   color: Colors.blue,
            // ),
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 10, bottom: 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mô tả sản phẩm',
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium,
                    color: Colors.blueGrey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child:
                    items.isNotEmpty
                        ? Text(
                          '${items[0]['description'].toString()}',
                          style: TextStyle(
                            fontSize: AppStyle.textSizeMedium,
                            color: Colors.black,
                          ),
                        )
                        : Text('...'),
              ),
            ),
            LinearProgressIndicator(
              value: _tienDo,
              backgroundColor: Colors.green,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),

              minHeight: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 5),
              child: Row(
                children: [
                  Text(
                    '4.7',
                    style: TextStyle(fontSize: AppStyle.textSizeLarge),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.star, size: 20, color: Colors.amberAccent),
                  SizedBox(width: 5),
                  Text(
                    'Đánh giá sản phẩm',
                    style: TextStyle(fontSize: AppStyle.textSizeMedium),
                  ),
                  SizedBox(width: 5),
                  Text(
                    '(32)',
                    style: TextStyle(fontSize: AppStyle.textSizeMedium),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Align(
                        alignment: Alignment.centerRight,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [Text('Tất cả'), Icon(Icons.chevron_right)],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Kích thước',
                    style: TextStyle(
                      fontSize: AppStyle.textSizeMedium,
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('Chật')),
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(),
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(10),

                            value: _tienDo,
                            backgroundColor: Colors.green,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('100%'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('Vừa vặn')),
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(),
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(10),

                            value: _tienDo,
                            backgroundColor: Colors.green,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('100%'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(flex: 2, child: Text('Rộng')),
                      Expanded(
                        flex: 6,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(),
                          child: LinearProgressIndicator(
                            borderRadius: BorderRadius.circular(10),

                            value: _tienDo,
                            backgroundColor: Colors.green,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue,
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('100%'),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: Column(
                      children: List.generate(2, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Divider(),
                              Row(
                                children: [
                                  CircleAvatar(
                                    child: ClipOval(
                                      child: Image.asset(
                                        'lib/Image/nen.png',
                                        width: 30,
                                        height: 30,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Nguyen Dình Phuc',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 17,
                                    color: const Color.fromARGB(
                                      255,
                                      242,
                                      190,
                                      4,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star,
                                    size: 17,
                                    color: const Color.fromARGB(
                                      255,
                                      242,
                                      190,
                                      4,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star,
                                    size: 17,
                                    color: const Color.fromARGB(
                                      255,
                                      242,
                                      190,
                                      4,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star,
                                    size: 17,
                                    color: const Color.fromARGB(
                                      255,
                                      242,
                                      190,
                                      4,
                                    ),
                                  ),
                                  Icon(
                                    Icons.star,
                                    size: 17,
                                    color: const Color.fromARGB(
                                      255,
                                      242,
                                      190,
                                      4,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Đánh giá ',
                                style: TextStyle(
                                  fontSize: AppStyle.textSizeMedium,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Đồ xấu vái chưởng ra, ước không mua đồ này sớm nhất có thể ',
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Container(
              height: 10,
              color: const Color.fromARGB(255, 195, 200, 203),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 100),
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 10,
                      right: 10,
                      top: 15,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          child: ClipOval(
                            child: Image.asset('lib/Image/nen.png'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              Text(
                                name.toString(),
                                style: TextStyle(
                                  fontSize: AppStyle.textSizeMedium,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),

                              SizedBox(height: 5),
                              Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                    color: Colors.green,
                                    width: 2,
                                  ),
                                ),
                                child: Center(child: Text('Xem shop')),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(children: [Text('4,5'), Text('Đánh giá')]),
                        VerticalDivider(width: 2, color: Colors.black),
                        Column(
                          children: [Text(total.toString()), Text('Sản phẩm')],
                        ),
                        VerticalDivider(width: 2, color: Colors.black),
                        Column(children: [Text('100%'), Text('Phẩn hồi')]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.blue,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.chat, color: Colors.white),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20, left: 20),
                          child: VerticalDivider(indent: 10, endIndent: 10),
                        ),
                        IconButton(
                          onPressed: () {
                            LuuSanPham();
                          },
                          icon: Icon(
                            Icons.add_shopping_cart_sharp,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: () {
                      CheckMuaSanPham(items);
                    },
                    child: Container(
                      color: Colors.green,
                      child: Center(
                        child: Text(
                          'Mua Ngay',
                          style: TextStyle(
                            fontSize: AppStyle.textSizeMedium,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: Search(email: widget.email.toString()),
    );
  }

  //so luong roi mua nay
  Widget _SoLuong(BuildContext context, List<Map<String, dynamic>> items) {
    return StatefulBuilder(
      builder: (context, setStateBottom) {
        return Container(
          height: 550,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            10,
                          ), // Bo tròn ảnh
                          child:
                              items.isNotEmpty
                                  ? Image.network(
                                    items[0]['imageUrl'],
                                    fit: BoxFit.fill,
                                  )
                                  : CircularProgressIndicator(),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Container(
                        height: 160, // Thêm height cho đều với bên trái
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child:
                                      items.isNotEmpty
                                          ? Text(
                                            '${items[0]['price']} đ',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                          : Text(
                                            '99999999 đ',
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),

                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child:
                                      items.isNotEmpty
                                          ? Text(
                                            'Kho : ${items[0]['total']}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                          : Text(
                                            'Kho : đang tải lên...',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.black54,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },

                                icon: Icon(Icons.close, size: 30),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Divider(height: 1),

              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 5,
                  bottom: 5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Số lượng ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.black54,
                      ),
                    ),
                    Row(
                      children: [
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            setStateBottom(() {
                              TruSL();
                            });
                          },
                          icon: Icon(Icons.remove),
                        ),

                        SizedBox(
                          height: 40,
                          width: 100,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text('$_soLuong'),
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setStateBottom(() {
                              CongSL();
                            });
                          },
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 10,
                color: Colors.grey[300],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sản phẩm khác của shop',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, top: 0, right: 0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 50,
                                offset: Offset(7, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Bo tròn ảnh
                              child: Image.asset(
                                'lib/Image/nen.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 50,
                                offset: Offset(7, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Bo tròn ảnh
                              child: Image.asset(
                                'lib/Image/nen.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 50,
                                offset: Offset(7, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Bo tròn ảnh
                              child: Image.asset(
                                'lib/Image/nen.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          height: 130,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black54,
                                blurRadius: 50,
                                offset: Offset(7, 5),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Bo tròn ảnh
                              child: Image.asset(
                                'lib/Image/nen.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GiaoDienMuaSanPham(
                                email: widget.email.toString(),
                                idProducts: items[0]['id'],
                                soLuong: _soLuong,
                              ),
                        ),
                      );
                    },
                    child: Text(
                      'Mua ngay',
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
        );
      },
    );
  }
}
