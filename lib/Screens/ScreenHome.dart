import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Screens/ScreenCart.dart';
import 'package:nama_app/Screens/ScreenProducts.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:nama_app/Widgets/Seach.dart';
import 'package:nama_app/Widgets/Type.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GiaoDienHome extends StatefulWidget {
  final String? email;
  List<Product>? itemProducts;
  GiaoDienHome({super.key, this.email, this.itemProducts});

  @override
  State<GiaoDienHome> createState() => _GiaoDienHomeState();
}

class _GiaoDienHomeState extends State<GiaoDienHome>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Firebauth _firebauth = Firebauth();
  late TabController _tabController;
  final List<Map<String, dynamic>> itemType = [
    {
      'name': 'Tất cả',
      'image':
          'https://watermark.lovepik.com/photo/20211124/large/lovepik-fashion-womens-summer-shopping-image-picture_500961844.jpg',
    },
    {
      'name': 'Thời trang',
      'image':
          'https://watermark.lovepik.com/photo/20211124/large/lovepik-fashion-womens-summer-shopping-image-picture_500961844.jpg',
    },
    {
      'name': 'Đồ gia dụng',
      'image':
          'https://suno.vn/blog/wp-content/uploads/2020/06/boxme-kinh-doanh-hang-gia-dung-1250x800.jpg',
    },
    {
      'name': 'Trang sức',
      'image':
          'https://lavenderstudio.com.vn/wp-content/uploads/2017/03/chup-anh-trang-suc-dep.jpg',
    },
    {
      'name': 'Thiết bị điện',
      'image':
          'https://tse2.mm.bing.net/th?id=OIP.Pk2GhF6GzEUpx11UG4agqgHaHa&pid=Api&P=0&h=220',
    },
    {
      'name': 'Khác...',
      'image': 'https://blog.dktcdn.net/files/ban-hang-online-khac-biet.jpg',
    },
  ];
  List<Product> items = [];
  List<Product> items2 = [];
  List<Product> items3 = [];
  List<Product> items4 = [];
  List<Product> items5 = [];
  List<Product> items6 = [];
  FocusNode searchFocus = FocusNode();
  int _selectedDropBox = 2;
  int Index = 1;
  int selectedItemTypeIndex = 0;
  final _textTimKiem = TextEditingController();
  Timer? _deXuatTimer;
  List<String> listDeXuat = ["Áo", "Quần", "Giày", "Dép"];
  void fetchProducts() async {
  final fetchedItems = await _firebauth.getAllProducts();
  setState(() {
    items = fetchedItems;
    items2 = items.where((element) => element.type == "Thời trang").toList();
    items3 = items.where((element) => element.type == "Đồ gia dụng").toList();
    items4 = items.where((element) => element.type == "Trang sức").toList();
    items5 = items.where((element) => element.type == "Thiết bị điện").toList();
    items6 = items.where((element) => element.type == "Khác..").toList();
    
  });
}

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    fetchProducts();
    DeXuat();
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
    // setState(() {});
    _deXuatTimer = Timer.periodic(Duration(seconds: 1), (timer) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              GiaoDienGioHang(email: widget.email.toString()),
                    ),
                  );
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
          Stack(
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
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
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
          PreferredSize(
            preferredSize: const Size.fromHeight(120),
            child: Padding(
              padding: const EdgeInsets.only(right: 10, left: 10, top: 0),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.black,
                tabAlignment: TabAlignment.start,
                labelStyle: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
                tabs: List.generate(
                  itemType.length,
                  (index) => Tab(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         
                          const SizedBox(height: 5),
                          Text(
                            itemType[index]['name'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 0),
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
          Padding(
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
                            style: TextStyle(fontSize: AppStyle.paddingMedium),
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

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                danhSachSanPham(items),
                danhSachSanPham(items2),
                danhSachSanPham(items3),
                danhSachSanPham(items4),
                danhSachSanPham(items5),
                danhSachSanPham(items6),
              ],
            ),
          ),

          // )
        ],
      ),

      backgroundColor: Color.fromARGB(49, 245, 245, 245),
      drawer: Search(
        email: widget.email.toString(),
        itemProducts: widget.itemProducts,
      ),
    );
  }

  Widget danhSachSanPham(List<Product> itemsAll) {
    return itemsAll.isNotEmpty?SingleChildScrollView(
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
            itemCount: itemsAll.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GiaoDienSanPham(
                            id: itemsAll[index].id,
                            email: widget.email.toString(),
                            itemProducts: widget.itemProducts,
                          ),
                    ),
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                  ),
                  elevation: 5,

                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: itemsAll[index].imageUrl,
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
                              itemsAll[index].name,
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        "${itemsAll[index].price.toString()} đ",
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
                          padding: const EdgeInsets.only(left: 10, bottom: 0),
                          child: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            'Số lượng : ${itemsAll[index].total}',
                            style: TextStyle(fontSize: AppStyle.textSizeMedium),
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
    ) : Center(child: Text('Không có dữ liệu !'));
  }
}
