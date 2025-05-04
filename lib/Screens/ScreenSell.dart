import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/API/imageAPI.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Pemisstion/PermissionHandler.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:image_picker/image_picker.dart';

class GiaoDienBan extends StatefulWidget {
  final String? email;
  const GiaoDienBan({Key? key, this.email}) : super(key: key);

  @override
  State<GiaoDienBan> createState() => _GiaoDienBanState();
}

class _GiaoDienBanState extends State<GiaoDienBan>
    with SingleTickerProviderStateMixin {
  Cloudinary _imageAPI = Cloudinary();
  late TabController _tabController;
  PermisstionHandler _permission = PermisstionHandler();
  File? _image;
  bool load = true;
  bool isloading2 = false;
  String? selectedCategory;
  Icon iconsLoc = Icon(Icons.filter_alt_off, size: 25);
  List<String> categories = [
    'Thời trang',
    'Đồ gia dụng',
    'Trang sức',
    'Thiết bị điện',
    'Khác...',
  ];
  Firebauth _au = Firebauth();
  final name = TextEditingController();
  final price = TextEditingController();
  final total = TextEditingController();
  final email = TextEditingController();
  final address = TextEditingController();
  final decription = TextEditingController();
  Color isColorTab = Colors.green;
  Color isBottom = Colors.green;
  Color isColorTab2 = const Color.fromARGB(255, 160, 185, 197);
  Color isBottom2 = Colors.white;
  Color isColorTab3 = const Color.fromARGB(255, 160, 185, 197);
  Color isBottom3 = Colors.white;
  bool _offStateDNSP = false;
  bool _offStateQLSP = true;
  bool _offStateXTK = true;
  int selextedRadio = 1;
  bool isFilterOn = false;
  int soLuong = 0;
  int daBan = 0;
  bool control = true;
  bool isloading = false;
  int soLuongSanPham = 0;
  double chieuCao = 200;
  String text = "Chỉnh sửa";
  double rong = 150;
  double cao = 40;
  List<Product> item = [];
  List<Product> itemSell = [];
  List<DonHang> itemDonHang = [];
  List<String> listSoLuong = [];
  List<Map<String, double>> listChieuCao = [];
  List<Map<String, dynamic>> ListChinhSua = [];
  List<Map<String, TextEditingController>> ListControler = [];
  bool offStateCon = true;
  Future<void> pickImageFromGallery() async {
    // bool control = await _permission.requestGalleryPermission();
    // if (control) {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        _image = imageFile;
        SetOffState();
      });
    } else {
      setState(() {
        SetOffStateIconClose();
      });
      print('Không chọn ảnh nào.');
    }
    // } else {
    //   print('Người dùng không cấp quyền');
    // }
  }

  Future<void> DangBan() async {
    if (name.text.isEmpty ||
        price.text.isEmpty ||
        total.text.isEmpty ||
        address.text.isEmpty ||
        _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Vui lòng điền đầy đủ thông tin và chọn ảnh'),
          ),
        ),
      );
      return;
    }
    try {
      // Upload file ảnh
      if (_image == null || !_image!.existsSync()) {
        print("Ảnh không tồn tại hoặc chưa chọn ảnh");
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Vui lòng chọn ảnh hợp lệ")));
        return;
      }
      setState(() {
        isloading = true;
      });
      String _code = _au.generateVerificationCode(6);
      String _url = await _imageAPI.getURL(_image);
      final now = DateTime.now();

      Product products = Product(
        id: _code.toString(),
        name: name.text.trim(),
        description: decription.text.trim(),
        address: address.text.trim(),
        email: widget.email ?? 'khong-co-email',
        imageUrl: _url,
        type: selectedCategory.toString(),
        price: price.text.toString(),
        total: total.text.trim(),
        createdAt: now.toString(),
        hiden: false,
      );

      setState(() {
        item.add(products);
        SetChieuCao();
      });
      await FirebaseFirestore.instance.collection('products').add({
        'name': products.name,
        'id': products.id,
        'price': products.price,
        'total': products.total,
        'email': products.email,
        'address': products.address,
        'type': products.type,
        'imageUrl': products.imageUrl,
        'createdAt': products.createdAt,
        'description': products.description,
        'hiden': products.hiden,
      });
      setState(() {
        isloading = false;
      });
      // Hiện thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Đăng bán thành công'))),
      );

      // Reset form
      name.clear();
      price.clear();
      total.clear();
      address.clear();
      decription.clear();
      setState(() {
        selectedCategory = null;
      });
    } catch (e) {
      print('Lỗi upload ảnh hoặc lưu dữ liệu: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Đã xảy ra lỗi khi đăng bán'))),
      );
    }
  }

  bool _offState = true;
  void SetOffState() {
    setState(() {
      _offState = false;
    });
  }

  void SetOffStateIconClose() {
    setState(() {
      _offState = true;
      _image = null;
    });
  }

  void Choose(String value) {
    setState(() {
      selectedCategory = value;
    });
  }

  void fetchProducts() async {
    List<Product> items = [];
    items = await _au.getAllProductsUser(widget.email.toString());
    itemSell = await _au.getAllProductsUseSell(widget.email.toString());
    itemDonHang = await _au.getOrderSell2(widget.email.toString());
    item = items;
    SetChieuCao();
    if (mounted) {
      setState(() {});
    }
  }

  Icon get iconLoc =>
      isFilterOn
          ? Icon(Icons.filter_alt, size: 25)
          : Icon(Icons.filter_alt_off, size: 25);

  void ChangeIcon() {
    setState(() {
      isFilterOn = !isFilterOn;
    });
  }

  void SetContenaer() {
    setState(() {
      rong = rong == 150 ? double.infinity : 150;
      cao = cao == 40 ? 200 : 40;
      offStateCon = offStateCon ? false : true;
    });
  }

  void SetChieuCao() {
    listChieuCao.clear();
    ListChinhSua.clear();
    ListControler.clear();
    for (int i = 0; i < item.length; i++) {
      listChieuCao.addAll([
        {"chieucao$i": chieuCao},
      ]);
      ListChinhSua.addAll([
        {
          "type$i": "Chỉnh sửa",
          "offStateImage$i": false,
          "offStateImage2$i": true,
          "setflex$i": 7,
          "setflexImage$i": 3,
          "setpaddingleft$i": 10.0,
          "setpaddingright$i": 10.0,
          "offStateETC$i": true,
          "setflextop$i": 25,
          "setflexdown$i": 75,
        },
      ]);
      final textName = TextEditingController();
      final textGia = TextEditingController();
      final textSoLuong = TextEditingController();
      final textDiachi = TextEditingController();
      final textMota = TextEditingController();

      textName.text = item[i].name.toString();
      textGia.text = item[i].price.toString();
      textSoLuong.text = item[i].total.toString();
      textDiachi.text = item[i].address.toString();
      textMota.text = item[i].description.toString();

      ListControler.addAll([
        {
          "ten$i": textName,
          "gia$i": textGia,
          "soluong$i": textSoLuong,
          "mota$i": textMota,
          "diachi$i": textDiachi,
        },
      ]);
    }
  }

  //hầm số luuwojgn sản phẩm đã bán
  void LaySoLuong() async {
    String? result = await _au.GetCountProducts(widget.email.toString());

    if (result != null && result.contains(':')) {
      List<String> listSoLuong = result.split(':');

      if (listSoLuong.length == 2) {
        soLuongSanPham = int.tryParse(listSoLuong[0].toString())!;
        daBan = int.tryParse(listSoLuong[1].toString())!;
      } else {
        print("Lỗi: kết quả không đúng định dạng");
      }
    } else {
      print("Lỗi: kết quả rỗng hoặc sai định dạng");
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchProducts();
    LaySoLuong();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
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
                  'Sản phẩm',
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
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          Column(
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
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: [
                    Tab(text: 'Đăng bán sản phẩm'),
                    Tab(text: 'Quản lý sản phẩm'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [_tabDanBanSanPham(), _DanhSachSanPham()],
                ),
              ),
            ],
          ),
          if (isloading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  //tab 1
  Widget _tabDanBanSanPham() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Offstage(
            offstage: _offStateDNSP,
            child: Column(
              children: [
                Stack(
                  children: [
                    Offstage(
                      offstage: _offState,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          child:
                              _image != null
                                  ? ClipPath(
                                    child: Image.file(
                                      _image!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                  : Center(child: Text('Không có ảnh nào cả!')),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Offstage(
                        offstage: _offState,
                        child: IconButton(
                          onPressed: SetOffStateIconClose,
                          icon: Icon(
                            Icons.close,
                            size: 30,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton.icon(
                    onPressed: pickImageFromGallery,
                    icon: Icon(Icons.add_photo_alternate, color: Colors.white),
                    label: Text(
                      "Chọn ảnh",
                      style: TextStyle(
                        fontSize: AppStyle.textSizeMedium,
                        color: Colors.white,
                        fontFamily: AppStyle.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: name,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'Tên sản phẩm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: total,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'Số lượng',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: price,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            labelText: 'Giá (VNĐ)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    dropdownColor: Colors.green,
                    menuMaxHeight: 250,
                    decoration: InputDecoration(
                      labelText: 'Loại sản phẩm',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      String getValue = value.toString();
                      Choose(getValue);
                    },
                    items:
                        categories.map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: address,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'Địa chỉ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 10,
                    bottom: 0,
                  ),
                  child: TextField(
                    controller: decription,

                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      labelText: 'Mô tả sản phẩm',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      DangBan();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Đăng bán',
                      style: TextStyle(
                        fontSize: AppStyle.textSizeMedium,
                        color: Colors.white,
                        fontFamily: AppStyle.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // PHẦN QUẢN LÝ SẢN PHẨM
          Offstage(
            offstage: _offStateQLSP,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bộ lọc sản phẩm',
                        style: TextStyle(
                          fontSize: AppStyle.textSizeMedium,
                          fontFamily: AppStyle.fontFamily,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ChangeIcon();
                        },
                        icon: iconLoc,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget tabItem({
    required String title,
    required Color color,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            title,
            style: TextStyle(
              fontSize: AppStyle.paddingMedium,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRich(
    String label,
    String value,
    Color valueColor,
    double a,
    double b,
    int index,
    int line,
    TextEditingController textT,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.only(left: a, right: b, top: 10),
            height: 45,
            child: TextField(
              readOnly: control,
              controller: textT,
              maxLines: line,
              minLines: line,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(bottom: 10, left: 10),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),

                labelText: label,
                labelStyle: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void SetlaiChieuCao(int index) async {
    print(index);
    print(ListChinhSua.length);
    if (ListChinhSua[index]['type$index'].toString() == "Chỉnh sửa") {
      double chieuCao2 = 490;
      listChieuCao[index] = {"chieucao$index": chieuCao2};
      ListChinhSua[index] = {
        "type$index": "Xong",
        "offStateImage$index": true,
        "offStateImage2$index": false,
        "setflex$index": 9,
        "setflexImage$index": 1,
        "offStateETC$index": false,
        "setflextop$index": 0,
        "setflexdown$index": 100,
        "setpaddingleft$index": 0.0,
        "setpaddingright$index": 35.0,
      };
      setState(() {
        control = false;
      });
    } else {
      print(ListControler[index]['soluong$index']!.text.toString());
      double chieuCao2 = 200;
      listChieuCao[index] = {"chieucao$index": chieuCao2};
      ListChinhSua[index] = {
        "type$index": "Chỉnh sửa",
        "offStateImage$index": false,
        "offStateImage2$index": true,
        "setflex$index": 7,
        "setflexImage$index": 3,
        "offStateETC$index": true,
        "setflextop$index": 25,
        "setflexdown$index": 75,
        "setpaddingleft$index": 10.0,
        "setpaddingright$index": 10.0,
      };
      // print(ListControler[index]['ten$index']!.text.toString());
      final now = DateTime.now();
      Product _products = Product(
        id: item[index].id,
        name: ListControler[index]['ten$index']!.text.toString(),
        description: ListControler[index]['mota$index']!.text.toString(),
        address: ListControler[index]['diachi$index']!.text.toString(),
        email: item[index].email,
        imageUrl: item[index].imageUrl,
        type: item[index].type,
        price: ListControler[index]['gia$index']!.text.toString(),
        total: ListControler[index]['soluong$index']!.text.toString(),
        createdAt: now.toString(),
        hiden: false,
      );
      await _au.UpdatedInforProducts(
        item[index].id,
        widget.email.toString(),
        _products,
      );
      setState(() {
        control = true;
      });
    }
  }

  int setFlex = 7;
  bool _offStateImage = true;
  bool _offStateImage2 = false;
  //tab 2
  Widget _DanhSachSanPham() {
    Timer(Duration(seconds: 2), () {
      isloading2 = true;
      if (mounted) {
        setState(() {});
      }
    });
    return isloading2
        ? SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 10, right: 10),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          right: 10,
                          left: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Số loại sản phẩm : ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Expanded(
                              child: Text(
                                '${item.length}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: AppStyle.textSizeMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          right: 10,
                          left: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              'Tổng số lượng sản phẩm : ',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Expanded(
                              child: Text(
                                '${soLuongSanPham}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: AppStyle.textSizeMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(
                          top: 5,
                          right: 10,
                          left: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Kho : ',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  '${soLuongSanPham}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: AppStyle.textSizeMedium,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Đã bán : ',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                listChieuCao.isNotEmpty
                                    ? Text(
                                      '${daBan}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    )
                                    : Text(
                                      '0',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: () {
                        SetContenaer();
                      },
                      child: Container(
                        width: rong,
                        height: cao,
                        padding: EdgeInsets.only(
                          top: 10,
                          right: 10,
                          bottom: 5,
                          left: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(blurRadius: 10, color: Colors.black54),
                          ],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                'Lọc sản phẩm',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppStyle.textSizeMedium,
                                ),
                              ),
                            ),
                            Offstage(
                              offstage: offStateCon,
                              child: Row(
                                children: [
                                  Row(
                                    children: [
                                      Radio(
                                        value: 1,
                                        groupValue: selextedRadio,
                                        onChanged:
                                            (value) => setState(() {
                                              selextedRadio = value!;
                                            }),
                                      ),
                                      Text(
                                        'Đang bán',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio(
                                        value: 2,
                                        groupValue: selextedRadio,
                                        onChanged:
                                            (value) => setState(() {
                                              selextedRadio = value!;
                                            }),
                                      ),
                                      Text(
                                        'Có lượt bán',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Radio(
                                        value: 3,
                                        groupValue: selextedRadio,
                                        onChanged:
                                            (value) => setState(() {
                                              selextedRadio = value!;
                                            }),
                                      ),
                                      Text(
                                        'Đã bán',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (selextedRadio == 1)
                item.isNotEmpty
                    ? ListView.builder(
                      itemCount: item.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            top: 10,
                          ),
                          child: Container(
                            height:
                                listChieuCao.isNotEmpty
                                    ? listChieuCao[index]['chieucao$index']
                                    : 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: Offset(1, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: ListChinhSua[index]['setflextop$index'],
                                  child: Offstage(
                                    offstage:
                                        ListChinhSua[index]['offStateImage$index']
                                            as bool,
                                    child: buildRich(
                                      "Tên ",
                                      item[index].name,
                                      Colors.black,
                                      ListChinhSua[index]['setpaddingleft$index'],
                                      ListChinhSua[index]['setpaddingright$index'],
                                      index,
                                      2,
                                      ListControler[index]['ten$index']
                                          as TextEditingController,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:
                                      ListChinhSua[index]['setflexdown$index'],
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            ListChinhSua[index]['setflexImage$index']
                                                as int,
                                        child: Offstage(
                                          offstage:
                                              ListChinhSua[index]['offStateImage$index']
                                                  as bool,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              top: 10,
                                              right: 0,
                                              bottom: 10,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ), // Bo tròn ảnh
                                                child:
                                                    item.isNotEmpty
                                                        ? CachedNetworkImage(
                                                          imageUrl:
                                                              item[index]
                                                                  .imageUrl,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit:
                                                              BoxFit
                                                                  .cover, // dùng cover nhìn đẹp hơn fill
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => Icon(
                                                                Icons.error,
                                                              ),
                                                        )
                                                        : Image.asset(
                                                          'lib/Image/nen.png',
                                                          fit: BoxFit.fill,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            ListChinhSua[index]['setflex$index']
                                                as int,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,

                                            children: [
                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateImage2$index']
                                                        as bool,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 35,
                                                          top: 10,
                                                        ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ), // Bo tròn ảnh
                                                      child:
                                                          item.isNotEmpty
                                                              ? CachedNetworkImage(
                                                                imageUrl:
                                                                    item[index]
                                                                        .imageUrl,
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                height:
                                                                    double
                                                                        .infinity,
                                                                fit:
                                                                    BoxFit
                                                                        .cover, // dùng cover nhìn đẹp hơn fill
                                                                placeholder:
                                                                    (
                                                                      context,
                                                                      url,
                                                                    ) => Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      error,
                                                                    ) => Icon(
                                                                      Icons
                                                                          .error,
                                                                    ),
                                                              )
                                                              : Image.asset(
                                                                'lib/Image/nen.png',
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateETC$index']
                                                        as bool,
                                                child: buildRich(
                                                  "Tên ",
                                                  item[index].name,
                                                  Colors.black,
                                                  ListChinhSua[index]['setpaddingleft$index'],
                                                  ListChinhSua[index]['setpaddingright$index'],
                                                  index,
                                                  2,
                                                  ListControler[index]['ten$index']
                                                      as TextEditingController,
                                                ),
                                              ),

                                              SizedBox(height: 3),

                                              buildRich(
                                                "Giá ",
                                                '${item[index].price} VND',
                                                Colors.black,
                                                ListChinhSua[index]['setpaddingleft$index'],
                                                ListChinhSua[index]['setpaddingright$index'],
                                                index,
                                                1,
                                                ListControler[index]['gia$index']
                                                    as TextEditingController,
                                              ),
                                              SizedBox(height: 3),
                                              buildRich(
                                                "Số lượng ",
                                                '${item[index].total}',
                                                Colors.black,
                                                ListChinhSua[index]['setpaddingleft$index'],
                                                ListChinhSua[index]['setpaddingright$index'],
                                                index,
                                                1,
                                                ListControler[index]['soluong$index']
                                                    as TextEditingController,
                                              ),
                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateETC$index']
                                                        as bool,
                                                child: buildRich(
                                                  "Mô tả ",
                                                  '${item[index].description}',
                                                  Colors.black,
                                                  ListChinhSua[index]['setpaddingleft$index'],
                                                  ListChinhSua[index]['setpaddingright$index'],
                                                  index,
                                                  3,
                                                  ListControler[index]['mota$index']
                                                      as TextEditingController,
                                                ),
                                              ),
                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateETC$index']
                                                        as bool,
                                                child: buildRich(
                                                  "Địa chỉ ",
                                                  '${item[index].address}',
                                                  Colors.black,

                                                  ListChinhSua[index]['setpaddingleft$index'],
                                                  ListChinhSua[index]['setpaddingright$index'],
                                                  index,
                                                  2,
                                                  ListControler[index]['diachi$index']
                                                      as TextEditingController,
                                                ),
                                              ),
                                              Offstage(
                                                child: Column(children: [
                      
                                    ],
                                  ),
                                              ),
                                              SizedBox(height: 8),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                  top: 0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 20,
                                                          ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment
                                                                .centerRight,

                                                        child: InkWell(
                                                          onTap: () async {
                                                            final productId =
                                                                item[index].id;

                                                            // Hiển thị Dialog xác nhận xóa
                                                            final isDeleted = await showDialog<
                                                              bool
                                                            >(
                                                              barrierDismissible:
                                                                  false,
                                                              context: context,
                                                              builder:
                                                                  (
                                                                    dialogContext,
                                                                  ) => ThongBao(
                                                                    dialogContext,
                                                                    productId,
                                                                    index,
                                                                  ),
                                                            );

                                                            print(
                                                              'Kết quả: $isDeleted',
                                                            ); // Kiểm tra kết quả trả về từ Dialog

                                                            // Nếu xác nhận xóa, tiến hành xóa
                                                            if (isDeleted ==
                                                                true) {
                                                              // Hiển thị thông báo xóa thành công
                                                              ScaffoldMessenger.of(
                                                                context,
                                                              ).showSnackBar(
                                                                SnackBar(
                                                                  content: Center(
                                                                    child: Text(
                                                                      'Xóa thành công!',
                                                                    ),
                                                                  ),
                                                                ),
                                                              );

                                                              // Cập nhật UI sau khi xóa
                                                              setState(() {
                                                                item =
                                                                    item
                                                                        .where(
                                                                          (e) =>
                                                                              e.id !=
                                                                              productId,
                                                                        )
                                                                        .toList();
                                                              });
                                                            }
                                                          },
                                                          child: Text(
                                                            'Xóa',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  AppStyle
                                                                      .textSizeMedium,
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    233,
                                                                    184,
                                                                    7,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,

                                                      child: GestureDetector(
                                                        onTap: () {
                                                          SetlaiChieuCao(index);
                                                        },
                                                        child: Text(
                                                          ListChinhSua[index]['type$index']
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  233,
                                                                  184,
                                                                  7,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    : Container(
                      width: double.infinity,
                      height: 100,
                      child: Center(
                        child: Text(
                          'Không có dữ liệu',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),

              if (selextedRadio == 2)
                itemSell.isNotEmpty
                    ? ListView.builder(
                      itemCount: itemSell.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 10,
                            top: 10,
                          ),
                          child: Container(
                            height:
                                listChieuCao.isNotEmpty
                                    ? listChieuCao[index]['chieucao$index']
                                    : 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 10,
                                  color: Colors.black54,
                                  offset: Offset(1, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  flex: ListChinhSua[index]['setflextop$index'],
                                  child: Offstage(
                                    offstage:
                                        ListChinhSua[index]['offStateImage$index']
                                            as bool,
                                    child: buildRich(
                                      "Tên ",
                                      item[index].name,
                                      Colors.black,
                                      ListChinhSua[index]['setpaddingleft$index'],
                                      ListChinhSua[index]['setpaddingright$index'],
                                      index,
                                      2,
                                      ListControler[index]['ten$index']
                                          as TextEditingController,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex:
                                      ListChinhSua[index]['setflexdown$index'],
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex:
                                            ListChinhSua[index]['setflexImage$index']
                                                as int,
                                        child: Offstage(
                                          offstage:
                                              ListChinhSua[index]['offStateImage$index']
                                                  as bool,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              top: 10,
                                              right: 0,
                                              bottom: 10,
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ), // Bo tròn ảnh
                                                child:
                                                    item.isNotEmpty
                                                        ? CachedNetworkImage(
                                                          imageUrl:
                                                              itemSell[index]
                                                                  .imageUrl,
                                                          width:
                                                              double.infinity,
                                                          height:
                                                              double.infinity,
                                                          fit:
                                                              BoxFit
                                                                  .cover, // dùng cover nhìn đẹp hơn fill
                                                          placeholder:
                                                              (
                                                                context,
                                                                url,
                                                              ) => Center(
                                                                child:
                                                                    CircularProgressIndicator(),
                                                              ),
                                                          errorWidget:
                                                              (
                                                                context,
                                                                url,
                                                                error,
                                                              ) => Icon(
                                                                Icons.error,
                                                              ),
                                                        )
                                                        : Image.asset(
                                                          'lib/Image/nen.png',
                                                          fit: BoxFit.fill,
                                                        ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        flex:
                                            ListChinhSua[index]['setflex$index']
                                                as int,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 0,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,

                                            children: [
                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateImage2$index']
                                                        as bool,
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          right: 35,
                                                          top: 10,
                                                        ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ), // Bo tròn ảnh
                                                      child:
                                                          itemSell.isNotEmpty
                                                              ? CachedNetworkImage(
                                                                imageUrl:
                                                                    itemSell[index]
                                                                        .imageUrl,
                                                                width:
                                                                    double
                                                                        .infinity,
                                                                height:
                                                                    double
                                                                        .infinity,
                                                                fit:
                                                                    BoxFit
                                                                        .cover, // dùng cover nhìn đẹp hơn fill
                                                                placeholder:
                                                                    (
                                                                      context,
                                                                      url,
                                                                    ) => Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                errorWidget:
                                                                    (
                                                                      context,
                                                                      url,
                                                                      error,
                                                                    ) => Icon(
                                                                      Icons
                                                                          .error,
                                                                    ),
                                                              )
                                                              : Image.asset(
                                                                'lib/Image/nen.png',
                                                                fit:
                                                                    BoxFit
                                                                        .cover,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateETC$index']
                                                        as bool,
                                                child: buildRich(
                                                  "Tên ",
                                                  itemSell[index].name,
                                                  Colors.black,
                                                  ListChinhSua[index]['setpaddingleft$index'],
                                                  ListChinhSua[index]['setpaddingright$index'],
                                                  index,
                                                  2,
                                                  ListControler[index]['ten$index']
                                                      as TextEditingController,
                                                ),
                                              ),

                                              SizedBox(height: 3),

                                              buildRich(
                                                "Giá ",
                                                '${itemSell[index].price} VND',
                                                Colors.black,
                                                ListChinhSua[index]['setpaddingleft$index'],
                                                ListChinhSua[index]['setpaddingright$index'],
                                                index,
                                                1,
                                                ListControler[index]['gia$index']
                                                    as TextEditingController,
                                              ),
                                              SizedBox(height: 3),
                                              buildRich(
                                                "Số lượng ",
                                                '${itemSell[index].total}',
                                                Colors.black,
                                                ListChinhSua[index]['setpaddingleft$index'],
                                                ListChinhSua[index]['setpaddingright$index'],
                                                index,
                                                1,
                                                ListControler[index]['soluong$index']
                                                    as TextEditingController,
                                              ),
                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateETC$index']
                                                        as bool,
                                                child: buildRich(
                                                  "Mô tả ",
                                                  '${itemSell[index].description}',
                                                  Colors.black,
                                                  ListChinhSua[index]['setpaddingleft$index'],
                                                  ListChinhSua[index]['setpaddingright$index'],
                                                  index,
                                                  3,
                                                  ListControler[index]['mota$index']
                                                      as TextEditingController,
                                                ),
                                              ),
                                              Offstage(
                                                offstage:
                                                    ListChinhSua[index]['offStateETC$index']
                                                        as bool,
                                                child: buildRich(
                                                  "Địa chỉ ",
                                                  '${itemSell[index].address}',
                                                  Colors.black,

                                                  ListChinhSua[index]['setpaddingleft$index'],
                                                  ListChinhSua[index]['setpaddingright$index'],
                                                  index,
                                                  2,
                                                  ListControler[index]['diachi$index']
                                                      as TextEditingController,
                                                ),
                                              ),
                                              Offstage(
                                                child: Column(children: [
                      
                                    ],
                                  ),
                                              ),
                                              SizedBox(height: 8),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                  top: 0,
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 20,
                                                          ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment
                                                                .centerRight,

                                                        child: InkWell(
                                                          onTap: () async {
                                                            ScaffoldMessenger.of(
                                                              context,
                                                            ).showSnackBar(
                                                              SnackBar(
                                                                content: Center(
                                                                  child: Text(
                                                                    'Không thể xóa ở đây !',
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          child: Text(
                                                            'Xóa',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  AppStyle
                                                                      .textSizeMedium,
                                                              color:
                                                                  Color.fromARGB(
                                                                    255,
                                                                    233,
                                                                    184,
                                                                    7,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,

                                                      child: GestureDetector(
                                                        onTap: () {
                                                          SetlaiChieuCao(index);
                                                        },
                                                        child: Text(
                                                          ListChinhSua[index]['type$index']
                                                              .toString(),
                                                          style: TextStyle(
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            color:
                                                                Color.fromARGB(
                                                                  255,
                                                                  233,
                                                                  184,
                                                                  7,
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                    : Container(
                      width: double.infinity,
                      height: 100,
                      child: Center(
                        child: Text(
                          'Không có dữ liệu',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ),

              if (selextedRadio == 3) _daBan(),
            ],
          ),
        )
        : Container(
          color: Colors.black54.withOpacity(0.1),
          child: Center(child: CircularProgressIndicator()),
        );
  }

  //phần đã bán
  Widget _daBan() {
    return itemDonHang.isNotEmpty
        ? Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: 0,
              maxHeight: 480,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10)],
              borderRadius: BorderRadius.circular(5),
            ),
            child: ListView.builder(
              itemCount: itemDonHang.length,
              physics: AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10, top: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            'Tên sản phẩm : ',
                            style: TextStyle(fontSize: 13),
                          ),
                          Expanded(
                            child: Text(
                              '${itemDonHang[index].name}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: AppStyle.textSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      Row(
                        children: [
                          Text('Số lượng : ', style: TextStyle(fontSize: 13)),
                          Text(
                            '${itemDonHang[index].soLuong}',
                            style: TextStyle(
                              fontSize: AppStyle.textSizeMedium,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Giá : ', style: TextStyle(fontSize: 13)),
                          Text(
                            '${itemDonHang[index].price} đ',
                            style: TextStyle(
                              fontSize: AppStyle.textSizeMedium,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                    ],
                  ),
                );
              },
            ),
          ),
        )
        : Container(
          width: double.infinity,
          height: 100,
          child: Center(
            child: Text(
              'Không có dữ liệu',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        );
  }

  //Thông báo xóa sản phẩm
  Widget ThongBao(BuildContext context, String id, int index) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, color: Colors.red, size: 100),
            Text(
              'Chắc chắn xóa đơn hàng',
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
                      Navigator.pop(context, true); // đóng dialog, không xóa
                    },
                    child: Text('Quay lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      print('ĐÃ NHẤN XÁC NHẬN'); //
                      try {
                        await _au.hidenProducts(id);

                        Navigator.pop(context, true);
                      } catch (e, st) {
                        print('‼️ Lỗi khi showDialog: $e\n$st');
                      }
                    },
                    child: Text('Xác nhận'),
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
