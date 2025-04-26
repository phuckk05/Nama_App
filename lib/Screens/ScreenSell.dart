import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nama_app/API/imageAPI.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Pemisstion/PermissionHandler.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class GiaoDienBan extends StatefulWidget {
  final String? email;
  const GiaoDienBan({Key? key, this.email}) : super(key: key);

  @override
  State<GiaoDienBan> createState() => _GiaoDienBanState();
}

class _GiaoDienBanState extends State<GiaoDienBan> {
  Cloudinary _imageAPI = Cloudinary();
  PermisstionHandler _permission = PermisstionHandler();
  File? _image;
  bool load = true;
  String? selectedCategory;
  Icon iconsLoc = Icon(Icons.filter_alt_off, size: 25);
  List<String> categories = [
    'Thời trang',
    'Đồ gia dụng',
    'Trang sức',
    'Thiết bị điện',
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
  bool isFilterOn = false;
  int? soLuong;
  bool control = true;

  double chieuCao = 200;
  String text = "Chỉnh sửa";

  final List<Map<String, dynamic>> item = [];
  List<Map<String, double>> listChieuCao = [];
  List<Map<String, dynamic>> ListChinhSua = [];
  List<Map<String, TextEditingController>> ListControler = [];

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

      String _code = _au.generateVerificationCode(6);
      String _url = await _imageAPI.getURL(_image);
      await FirebaseFirestore.instance.collection('products').add({
        'name': name.text.trim(),
        'id': _code.toString(),
        'price': price.text.toString(),
        'total': total.text.trim(),
        'email': widget.email ?? 'khong-co-email',
        'address': address.text.trim(),
        'type': selectedCategory.toString(),
        'imageUrl': _url,
        'createdAt': Timestamp.now(),
        'description': decription.text.trim(),
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

  void ShowColor1() {
    setState(() {
      isBottom = Colors.green;
      isColorTab = Colors.green;
      isBottom2 = Colors.white;
      isColorTab2 = const Color.fromARGB(255, 160, 185, 197);
      isBottom3 = Colors.white;
      isColorTab3 = const Color.fromARGB(255, 160, 185, 197);
      _offStateDNSP = false;
      _offStateQLSP = true;
      _offStateXTK = true;
    });
  }

  void ShowColor2() {
    setState(() {
      isBottom2 = Colors.green;
      isColorTab2 = Colors.green;
      isBottom = Colors.white;
      isColorTab = const Color.fromARGB(255, 160, 185, 197);
      isBottom3 = Colors.white;
      isColorTab3 = const Color.fromARGB(255, 160, 185, 197);
      _offStateDNSP = true;
      _offStateQLSP = false;
      _offStateXTK = true;
    });

    setState(() {});
  }

  void ShowColor3() {
    setState(() {
      isBottom3 = Colors.green;
      isColorTab3 = Colors.green;
      isBottom2 = Colors.white;
      isColorTab2 = const Color.fromARGB(255, 160, 185, 197);
      isBottom = Colors.white;
      isColorTab = const Color.fromARGB(255, 160, 185, 197);
      _offStateDNSP = true;
      _offStateQLSP = true;
      _offStateXTK = false;
    });
  }

  void fetchProducts() async {
    item.clear();
    if (item.isEmpty) {
      CircularProgressIndicator();
    }
    soLuong = await _au.getAllProductsUser(item, widget.email.toString());
    SetChieuCao();
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

  void SetChieuCao() {
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

      textName.text = item[i]['name'].toString();
      textGia.text = item[i]['price'].toString();
      textSoLuong.text = item[i]['total'].toString();
      textDiachi.text = item[i]['address'].toString();
      textMota.text = item[i]['description'].toString();

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

  @override
  void initState() {
    super.initState();
    fetchProducts();
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
        backgroundColor: Colors.green,
        actions: [
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              ProcessSccreen(email: widget.email.toString()),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'Sản phẩm',
                style: TextStyle(
                  fontSize: AppStyle.textSizeTitle,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                icon: Icon(Icons.search, size: 30, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  tabItem(
                    title: 'Đăng bán sản phẩm',
                    color: isColorTab,
                    borderColor: isBottom,
                    onTap: ShowColor1,
                  ),
                  tabItem(
                    title: 'Quản lý sản phẩm',
                    color: isColorTab2,
                    borderColor: isBottom2,
                    onTap: ShowColor2,
                  ),
                  tabItem(
                    title: 'Đã bán',
                    color: isColorTab3,
                    borderColor: isBottom3,
                    onTap: ShowColor3,
                  ),
                ],
              ),
            ),
          ),

          // PHẦN CUỘN TOÀN BỘ NỘI DUNG
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // PHẦN ĐĂNG BÁN SẢN PHẨM
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
                                          : Center(
                                            child: Text('Không có ảnh nào cả!'),
                                          ),
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
                            icon: Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                            ),
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
                            menuMaxHeight: 200,
                            decoration: InputDecoration(
                              labelText: 'Loại sản phẩm',
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
                        _DanhSachSanPham(),
                      ],
                    ),
                  ),
                ],
              ),
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
      print('hello wolrd2');
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

      await _au.UpdatedInforProducts(
        widget.email.toString(),
        item[index]['id'],
        ListControler[index]['soluong$index']?.text.toString(),
        item[index]['imageUrl'],
        ListControler[index]['ten$index']?.text.toString(),
        ListControler[index]['gia$index']?.text.toString(),
        item[index]['type'],
        ListControler[index]['diachi$index']?.text.toString(),
        ListControler[index]['mota$index']?.text.toString(),
      );
      setState(() {
        control = true;
      });
    }
  }

  int setFlex = 7;
  bool _offStateImage = true;
  bool _offStateImage2 = false;
  Widget _DanhSachSanPham() {
    return ListView.builder(
      itemCount: item.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                offset: Offset(1, 5)
               )
              ]
            ),
            child: Column(
              children: [
                Expanded(
                  flex: ListChinhSua[index]['setflextop$index'],
                  child: Offstage(
                    offstage:
                        ListChinhSua[index]['offStateImage$index'] as bool,
                    child: buildRich(
                      "Tên ",
                      item[index]['name'],
                      Colors.black,
                      ListChinhSua[index]['setpaddingleft$index'],
                      ListChinhSua[index]['setpaddingright$index'],
                      index,
                      ListControler[index]['ten$index']
                          as TextEditingController,
                    ),
                  ),
                ),
                Expanded(
                  flex: ListChinhSua[index]['setflexdown$index'],
                  child: Row(
                    children: [
                      Expanded(
                        flex: ListChinhSua[index]['setflexImage$index'] as int,
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
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // Bo tròn ảnh
                                child:
                                    item.isNotEmpty
                                        ? CachedNetworkImage(
                                          imageUrl: item[index]["imageUrl"],
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit:
                                              BoxFit
                                                  .cover, // dùng cover nhìn đẹp hơn fill
                                          placeholder:
                                              (context, url) => Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  Icon(Icons.error),
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
                        flex: ListChinhSua[index]['setflex$index'] as int,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,

                            children: [
                              Offstage(
                                offstage:
                                    ListChinhSua[index]['offStateImage2$index']
                                        as bool,
                                child: Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      right: 35,
                                      top: 10,
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        10,
                                      ), // Bo tròn ảnh
                                      child:
                                          item.isNotEmpty
                                              ? CachedNetworkImage(
                                                imageUrl:
                                                    item[index]["imageUrl"],
                                                width: double.infinity,
                                                height: double.infinity,
                                                fit:
                                                    BoxFit
                                                        .cover, // dùng cover nhìn đẹp hơn fill
                                                placeholder:
                                                    (context, url) => Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              )
                                              : Image.asset(
                                                'lib/Image/nen.png',
                                                fit: BoxFit.cover,
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
                                  item[index]['name'],
                                  Colors.black,
                                  ListChinhSua[index]['setpaddingleft$index'],
                                  ListChinhSua[index]['setpaddingright$index'],
                                  index,
                                  ListControler[index]['ten$index']
                                      as TextEditingController,
                                ),
                              ),

                              SizedBox(height: 3),

                              buildRich(
                                "Giá ",
                                '${item[index]['price']} VND',
                                Colors.black,
                                ListChinhSua[index]['setpaddingleft$index'],
                                ListChinhSua[index]['setpaddingright$index'],
                                index,
                                ListControler[index]['gia$index']
                                    as TextEditingController,
                              ),
                              SizedBox(height: 3),
                              buildRich(
                                "Số lượng ",
                                '${item[index]['total']}',
                                Colors.black,
                                ListChinhSua[index]['setpaddingleft$index'],
                                ListChinhSua[index]['setpaddingright$index'],
                                index,
                                ListControler[index]['soluong$index']
                                    as TextEditingController,
                              ),
                              Offstage(
                                offstage:
                                    ListChinhSua[index]['offStateETC$index']
                                        as bool,
                                child: buildRich(
                                  "Mô tả ",
                                  '${item[index]['description']}',
                                  Colors.black,
                                  ListChinhSua[index]['setpaddingleft$index'],
                                  ListChinhSua[index]['setpaddingright$index'],
                                  index,
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
                                  '${item[index]['address']}',
                                  Colors.black,
                                  ListChinhSua[index]['setpaddingleft$index'],
                                  ListChinhSua[index]['setpaddingright$index'],
                                  index,
                                  ListControler[index]['diachi$index']
                                      as TextEditingController,
                                ),
                              ),
                              Offstage(child: Column(children: [
                
                              ],
                            )),
                              SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(
                                  right: 10,
                                  top: 0,
                                ),
                                child: Align(
                                  alignment: Alignment.centerRight,

                                  child: GestureDetector(
                                    onTap: () {
                                      print(item[index]['id']);
                                      print(index);
                                      SetlaiChieuCao(index);
                                    },
                                    child: Text(
                                      ListChinhSua[index]['type$index']
                                          .toString(),
                                      style: TextStyle(
                                        fontSize: AppStyle.textSizeMedium,
                                        color: Color.fromARGB(255, 233, 184, 7),
                                      ),
                                    ),
                                  ),
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
    );
  }
}
