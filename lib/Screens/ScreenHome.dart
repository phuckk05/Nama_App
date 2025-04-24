import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Screens/ScreenCart.dart';
import 'package:nama_app/Screens/ScreenProducts.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:nama_app/Widgets/Seach.dart';
import 'package:nama_app/Widgets/Type.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GiaoDienHome extends StatefulWidget {
  final String? email;
  const GiaoDienHome({Key? key, this.email}) : super(key: key);

  @override
  State<GiaoDienHome> createState() => _GiaoDienHomeState();
}

class _GiaoDienHomeState extends State<GiaoDienHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Firebauth _firebauth = Firebauth();
  final List<Map<String, dynamic>> itemType = [
    {
      'name': 'Thời trang',
      'image':
          'https://img.lovepik.com/free-png/20210923/lovepik-t-shirt-png-image_401190055_wh1200.png', // Đường dẫn đến ảnh áo thun
    },
    {
      'name': 'Đồ gia dụng',
      'image':
          'https://aaajeans.com/wp-content/uploads/2019/07/quan-jeans-nu-AG.jpg', // Đường dẫn đến ảnh quần jean
    },
    {
      'name': 'Trang sức',
      'image':
          'https://sakurafashion.vn/upload/a/1594-sakura-fashion-5166.jpg', // Đường dẫn đến ảnh áo khoác
    },
    {
      'name': 'Thiết bị điện',
      'image':
          'https://www.chuphinhsanpham.vn/wp-content/uploads/2021/06/chup-hinh-giay-dincox-shoes-c-photo-studio-5.jpg', // Đường dẫn đến ảnh giày sneaker
    },
    {
      'name': 'Khác...',
      'image':
          'https://www.chuphinhsanpham.vn/wp-content/uploads/2021/06/chup-hinh-giay-dincox-shoes-c-photo-studio-5.jpg', // Đường dẫn đến ảnh giày sneaker
    },
  ];
  final List<Map<String, dynamic>> items = [];
  FocusNode searchFocus = FocusNode();
  int _selectedDropBox = 2;
  int Index = 1;
  int selectedItemTypeIndex = 0;
  final _textTimKiem = TextEditingController();
  Timer? _deXuatTimer;
  List<String> listDeXuat = ["Áo", "Quần", "Giày", "Dép"];
  void fetchProducts() async {
    items.clear();
    _firebauth.getAllProducts(items);
  }

  @override
  void initState() {
    super.initState();
    DeXuat();
      fetchProducts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  
  }

  @override
  void dispose() {
    _deXuatTimer?.cancel(); 
    super.dispose();
  }

  void DeXuat() {
    int i = 0;
    _deXuatTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _textTimKiem.text = listDeXuat[i];
        i++;
        if (i == listDeXuat.length) {
          i = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.green,
        title: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 330,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    searchFocus.unfocus();
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      focusNode: searchFocus,
                      readOnly: true,
                      controller: _textTimKiem,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        prefixIcon: Icon(Icons.search),
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
                        suffixIcon: IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.camera_alt_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GiaoDienGioHang(email: widget.email.toString(),)));
                },
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Flexible(
            flex: 7,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  color: Colors.green,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
                  child: Container(
                    width: double.infinity,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        AppStyle.borderRadius,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => print('hello'),
                            child: Text(
                              'Đăng sản \nphẩm mới',
                              style: TextStyle(
                                color: AppStyle.textGreenColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStyle.fontFamily,
                              ),
                            ),
                          ),
                          VerticalDivider(indent: 10, endIndent: 10),
                          GestureDetector(
                            child: Text(
                              'Quản lý sản \nphẩm đang bán',
                              style: TextStyle(
                                color: AppStyle.textGreenColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStyle.fontFamily,
                              ),
                            ),
                          ),
                          VerticalDivider(indent: 10, endIndent: 10),
                          GestureDetector(
                            child: Text(
                              'Xem thống kê\nbán hàng',
                              style: TextStyle(
                                color: AppStyle.textGreenColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: AppStyle.fontFamily,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Flexible(
            flex: 13,
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth:
                      MediaQuery.of(context).size.width, // Giới hạn chiều rộng
                  maxHeight:
                      MediaQuery.of(context).size.height, // Giới hạn chiều cao
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        itemType.map((item) {
                          return Type(name: item['name'], image: item['image']);
                        }).toList(),
                  ),
                ),
              ),
            ),
          ),

          Flexible(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                width: double.infinity,
                height: 150,
                color: Colors.white,
                child: Image.asset(
                  'lib/Image/nen.png',
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text(
                    'Số lượng sản phẩm trên hàng ',
                    style: TextStyle(
                      fontSize: AppStyle.paddingMedium,
                      fontFamily: AppStyle.fontFamily,
                    ),
                  ),
                  SizedBox(width: 10),
                  DropdownButton<int>(
                    dropdownColor: Colors.amber,
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    value: _selectedDropBox,
                    items:
                        [1, 2].map((int value) {
                          return DropdownMenuItem<int>(
                            value: value,
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                fontSize: AppStyle.paddingMedium,
                              ),
                            ), //  Chuyển int thành String
                          );
                        }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDropBox = newValue!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            flex: 40,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Container(
                  width: double.infinity,

                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.all(5),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _selectedDropBox,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 5,
                      mainAxisExtent: 270,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GiaoDienSanPham(
                                    id: items[index]['id'],
                                    email: widget.email.toString(),
                                  ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppStyle.borderRadius,
                            ),
                          ),
                          elevation: 5,

                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: items[index]["imageUrl"],
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
                                ),
                              ),

                              SizedBox(
                                height: 55,
                                width: double.infinity,
                                child: Align(
                                  heightFactor: 1,
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Text(
                                      items[index]["name"]!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 30,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text:
                                                "${items[index]["price"].toString()} VND",
                                            style: TextStyle(
                                              fontSize: 22,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 20,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 10,
                                    bottom: 0,
                                  ),
                                  child: Text(
                                    'Số lượng : ${items[index]["total"]!}',
                                    style: TextStyle(
                                      fontSize: AppStyle.textSizeMedium,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      backgroundColor: Color.fromARGB(49, 245, 245, 245),
      drawer: Search(email: widget.email.toString()),
    );
  }
}
