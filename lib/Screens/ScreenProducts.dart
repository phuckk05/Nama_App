import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Carts.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Models/Review.dart';
import 'package:nama_app/Screens/ScreeenBuy.dart';
import 'package:nama_app/Screens/ScreenCart.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:nama_app/Widgets/Seach.dart';

class GiaoDienSanPham extends StatefulWidget {
  final List<Product>? itemProducts;
  GiaoDienSanPham({super.key, this.id, this.email, this.itemProducts});
  final String? id;
  final String? email;

  @override
  State<GiaoDienSanPham> createState() => _GiaoDienSanPhamState();
}

class _GiaoDienSanPhamState extends State<GiaoDienSanPham> {
  // Khai báo các biến cần thiết
  Firebauth _firebauth =
      Firebauth(); // Đối tượng Firebauth để tương tác với Firebase
  FocusNode searchFocus = FocusNode(); // Focus node cho ô tìm kiếm
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // GlobalKey cho Scaffold
  // ignore: unused_field
  final _textTimKiem = TextEditingController(); // Controller cho ô tìm kiếm
  double _tienDo = 0.1; // Tiến độ cho một quá trình nào đó, giá trị khởi tạo
  Timer? timer; // Timer để cập nhật tiến độ
  bool offstateReview = false; // Trạng thái review (ẩn hay hiển thị)
  String? name; // Tên sản phẩm hoặc người dùng
  String? total; // Tổng số lượng hoặc tổng giá trị
  String? decription; // Mô tả sản phẩm
  int _soLuong = 1; // Số lượng sản phẩm
  double tyleTot = 0; // Tỷ lệ đánh giá tốt
  double tyleTB = 0; // Tỷ lệ đánh giá trung bình
  double tylet = 0; // Tỷ lệ đánh giá xấu
  // ignore: unused_field
  Color _colorIconTru = Colors.black45; // Màu icon trừ (giảm số lượng)
  List<Color> listColor = [
    // Danh sách màu sắc cho các đánh giá
    Colors.lightGreenAccent,
    Colors.green,
    Colors.greenAccent,
    Colors.blueGrey,
  ];
  final List<Map<String, dynamic>> items = []; // Danh sách sản phẩm
  List<Map<String, Color>> listColorStar =
      []; // Danh sách màu sắc các ngôi sao đánh giá
  List<Review> listReview = []; // Danh sách các đánh giá
  int selectedStar = 0; // Số sao đã chọn
  int tongTart = 0; // Tổng số đánh giá
  int diem = 0; // Điểm trung bình của sản phẩm
  String? imageUrl; // URL của hình ảnh sản phẩm

  // Hàm để thay đổi màu sắc của các sao đánh giá dựa trên số sao đã chọn
  void SetColor(int i, int starCount) {
    Map<String, Color> starColors =
        {}; // Tạo một Map để lưu màu sắc của các sao

    // Đặt màu cho các sao: nếu sao được chọn thì sẽ có màu vàng, ngược lại sẽ là màu xám
    for (int j = 1; j <= 5; j++) {
      starColors["colorGrey$j"] =
          j <= starCount ? Colors.amberAccent : Colors.grey;
    }

    listColorStar[i] = starColors; // Cập nhật lại màu sắc sao của sản phẩm
    setState(() {}); // Gọi lại setState để cập nhật giao diện
  }

  // Hàm lấy thông tin sản phẩm từ Firestore
  void LaySanPham() async {
    String nameUser = await _firebauth.showProducts(
      widget.id.toString(),
      items,
    );
    if (mounted) {
      setState(() {
        // Lấy thông tin sản phẩm và tách chuỗi để lấy các thông tin như tên, hình ảnh, và tổng
        List<String> list = nameUser.split('+');
        imageUrl = list[1];
        name = list[0];
        total = list[2];
      });
    }
  }

  // Hàm được gọi khi widget được khởi tạo
  @override
  void initState() {
    super.initState();
    LoadTienDo(); // Khởi động quá trình cập nhật tiến độ
    LaySanPham(); // Lấy thông tin sản phẩm
    layReview(); // Lấy danh sách các đánh giá của sản phẩm
  }

  // Hàm lấy danh sách đánh giá cho sản phẩm
  void layReview() async {
    listReview = await _firebauth.getReview(
      widget.id.toString(),
    ); // Lấy đánh giá từ Firestore
    setState(() {});

    // Khởi tạo màu sắc sao cho từng đánh giá
    for (int i = 0; i < listReview.length; i++) {
      listColorStar.add({
        "colorGrey1": Colors.grey,
        "colorGrey2": Colors.grey,
        "colorGrey3": Colors.grey,
        "colorGrey4": Colors.grey,
        "colorGrey5": Colors.grey,
      });
    }

    setState(() {});

    // Tính tổng điểm và các tỷ lệ đánh giá (Tốt, Trung bình, Xấu)
    for (int i = 0; i < listReview.length; i++) {
      diem += listReview[i].start; // Cộng điểm của từng đánh giá
      tongTart++; // Tăng tổng số đánh giá
      if (listReview[i].slelect == "Tốt") {
        tyleTot++; // Cộng số lượng đánh giá "Tốt"
      } else if (listReview[i].slelect == "Trung bình") {
        tyleTB++; // Cộng số lượng đánh giá "Trung bình"
      } else {
        tylet++; // Cộng số lượng đánh giá "Xấu"
      }
      SetColor(
        i,
        listReview[i].start,
      ); // Cập nhật màu sắc cho sao của mỗi đánh giá
    }

    // Tính tỷ lệ phần trăm của từng loại đánh giá
    double tong = tyleTot + tyleTB + tylet;
    tyleTot = (tyleTot / tong) * 100;
    tyleTot = double.parse(tyleTot.toStringAsFixed(1)); // Làm tròn tỷ lệ
    tyleTB = (tyleTB / tong) * 100;
    tyleTB = double.parse(tyleTB.toStringAsFixed(1)); // Làm tròn tỷ lệ
    tylet = (tylet / tong) * 100;
    tylet = double.parse(tylet.toStringAsFixed(1)); // Làm tròn tỷ lệ

    setState(() {}); // Cập nhật lại giao diện
  }

  // Hàm lưu sản phẩm vào giỏ hàng
  void LuuSanPham() async {
    // Kiểm tra xem người dùng đã đặt sản phẩm chưa
    int _checkOr = await _firebauth.CheckOrder(
      widget.email.toString(),
      items[0]['id'],
    );

    if (_checkOr == 0) {
      // Nếu người dùng không thể tự đặt sản phẩm của mình
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Bạn không thể tự đặt sản phẩm của mình'),
          ),
        ),
      );
    } else {
      // Tạo đối tượng CartItem và lưu vào giỏ hàng
      String id = _firebauth.generateVerificationCode(
        7,
      ); // Tạo mã giỏ hàng ngẫu nhiên
      CartItem cartItem = CartItem(
        idCart: id,
        idProduct: widget.id.toString(),
        name: items[0]['name'],
        description: items[0]['description'],
        address: items[0]['address'],
        email: items[0]['email'],
        imageUrl: items[0]['imageUrl'],
        type: items[0]['type'],
        price: items[0]['price'],
        total: items[0]['total'].toString(),
        createdAt: items[0]['createdAt'],
        emailAdd: widget.email.toString(),
      );

      // Lưu sản phẩm vào giỏ hàng
      _firebauth.saveCarts(cartItem);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Thêm vào giỏ hàng thành công !')),
        ),
      );
    }
  }

  // Hàm kiểm tra và mua sản phẩm
  void CheckMuaSanPham(List<Map<String, dynamic>> items) async {
    int _checkOr = await _firebauth.CheckOrder(
      widget.email.toString(),
      items[0]['id'],
    );

    if (_checkOr == 0) {
      // Nếu không thể đặt sản phẩm của chính mình
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text('Bạn không thể tự đặt sản phẩm của mình'),
          ),
        ),
      );
    } else {
      // Mở modal bottom sheet để chọn số lượng mua
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return _SoLuong(context, items); // Gọi hàm chọn số lượng
        },
      );
    }
  }

  // Hàm cập nhật tiến độ
  void LoadTienDo() {
    timer = Timer.periodic(Duration(milliseconds: 1), (timer) {
      setState(() {
        _tienDo += 0.1; // Tăng tiến độ
        if (_tienDo >= 1.0) {
          _tienDo = 0.0; // Nếu tiến độ đạt 100% thì reset lại
        }
      });
    });
  }

  // Giảm số lượng sản phẩm
  void TruSL() {
    if (_soLuong > 1) {
      setState(() {
        _soLuong = _soLuong - 1;
      });
    }
  }

  // Tăng số lượng sản phẩm
  void CongSL() {
    setState(() {
      _soLuong = _soLuong + 1;
    });
  }

  // Hàm huỷ Timer khi widget bị hủy
  @override
  void dispose() {
    timer?.cancel(); // Huỷ timer
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
      body: body(),
      // Hiển thị Bottom Sheet khi bàn phím không hiển thị
      bottomSheet: Visibility(
        // Kiểm tra nếu bàn phím không hiển thị (viewInsets.bottom == 0)
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 30,
          ), // Cung cấp khoảng cách dưới cho bottom sheet
          child: Container(
            height: 50, // Chiều cao của bottom sheet
            child: Row(
              children: [
                // Cột đầu tiên với 2 phần (màu xanh)
                Expanded(
                  flex: 5, // Chiếm 5 phần trong tổng 10 phần
                  child: Container(
                    color: Colors.blue, // Màu nền xanh cho phần này
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Canh giữa các widget con
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Canh giữa theo chiều dọc
                      children: [
                        // Nút Chat
                        IconButton(
                          onPressed:
                              () {}, // Hàm sự kiện khi nhấn (hiện tại không làm gì)
                          icon: Icon(
                            Icons.chat,
                            color: Colors.white,
                          ), // Biểu tượng chat với màu trắng
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 20,
                            left: 20,
                          ), // Khoảng cách giữa các nút
                          child: VerticalDivider(
                            indent: 10,
                            endIndent: 10,
                          ), // Phân cách giữa các nút
                        ),
                        // Nút Thêm vào giỏ hàng
                        IconButton(
                          onPressed: () {
                            LuuSanPham(); // Gọi hàm LuuSanPham khi nhấn nút
                          },
                          icon: Icon(
                            Icons
                                .add_shopping_cart_sharp, // Biểu tượng giỏ hàng
                            color: Colors.white,
                            size: 25, // Kích thước biểu tượng
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Cột thứ hai với nút "Mua Ngay"
                Expanded(
                  flex: 5, // Chiếm 5 phần trong tổng 10 phần
                  child: InkWell(
                    onTap: () {
                      CheckMuaSanPham(items); // Gọi hàm khi nhấn vào phần này
                    },
                    child: Container(
                      color: Colors.green, // Màu nền xanh cho phần này
                      child: Center(
                        child: Text(
                          'Mua Ngay', // Nội dung nút "Mua Ngay"
                          style: TextStyle(
                            fontSize: AppStyle.textSizeMedium, // Kích thước chữ
                            color: Colors.white, // Màu chữ trắng
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

      // Drawer bên trái hiển thị thanh tìm kiếm
      drawer: Search(
        email: widget.email.toString(), // Email của người dùng
        itemProducts: widget.itemProducts, // Danh sách sản phẩm
      ),
    );
  }

  //body
  Widget body() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            width: double.infinity, // Kích thước chiều rộng đầy đủ
            height: 350, // Chiều cao cố định của phần này
            child:
                items
                        .isNotEmpty // Kiểm tra xem danh sách items có chứa sản phẩm không
                    ? CachedNetworkImage(
                      imageUrl:
                          items[0]["imageUrl"], // Đường dẫn ảnh lấy từ server
                      width:
                          double.infinity, // Chiều rộng của ảnh chiếm đầy phần
                      height: 150, // Chiều cao ảnh
                      fit: BoxFit.fill, // Lấp đầy không gian với ảnh
                      placeholder:
                          (context, url) => Center(
                            child:
                                CircularProgressIndicator(), // Hiển thị loading trong lúc ảnh đang tải
                          ),
                      errorWidget:
                          (context, url, error) => Icon(
                            Icons.error,
                          ), // Nếu load ảnh lỗi, hiển thị biểu tượng lỗi
                    )
                    : Image.asset(
                      'lib/Image/nen.png',
                      fit: BoxFit.fill,
                    ), // Nếu không có ảnh, hiển thị ảnh mặc định từ thư mục assets
          ),

          // Hiển thị thông tin giá trị sản phẩm
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
            ), // Khoảng cách cho phần trên và trái
            child: Row(
              children: [
                Text(
                  'Giá trị sản phẩm : ', // Nội dung hiển thị
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium, // Kích thước chữ
                    fontWeight: FontWeight.w900, // Độ đậm chữ
                  ),
                ),
                if (items
                    .isNotEmpty) // Kiểm tra nếu có sản phẩm trong danh sách
                  Expanded(
                    child: Text(
                      '${items[0]['price'].toString()} đ', // Hiển thị giá trị sản phẩm
                      maxLines: 1, // Giới hạn số dòng của văn bản
                      overflow:
                          TextOverflow
                              .ellipsis, // Khi giá trị quá dài, sẽ hiển thị ba chấm
                      style: TextStyle(
                        fontSize: AppStyle.textSizeLarge, // Kích thước chữ lớn
                        fontWeight: FontWeight.bold, // Độ đậm chữ
                        color: Colors.red, // Màu chữ đỏ cho giá trị sản phẩm
                      ),
                    ),
                  )
                else
                  Text(
                    '0',
                  ), // Nếu không có sản phẩm, hiển thị giá trị mặc định là 0
              ],
            ),
          ),
          Divider(), // Chèn một đường phân cách giữa các phần
          // Hiển thị thông tin địa chỉ
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              top: 5,
              bottom: 5,
            ), // Khoảng cách cho phần trái, trên và dưới
            child: Align(
              alignment: Alignment.centerLeft, // Canh lề bên trái
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Địa chỉ : ", // Nội dung hiển thị là "Địa chỉ :"
                      style: TextStyle(
                        color: Colors.blueGrey,
                      ), // Màu chữ cho phần "Địa chỉ :"
                    ),
                    items
                            .isNotEmpty // Kiểm tra nếu có thông tin địa chỉ
                        ? TextSpan(
                          text:
                              "${items[0]['address'].toString()}", // Hiển thị địa chỉ nếu có
                          style: TextStyle(color: Colors.black), // Màu chữ đen
                        )
                        : TextSpan(
                          text: "??", // Hiển thị "??" nếu không có địa chỉ
                          style: TextStyle(color: Colors.black), // Màu chữ đen
                        ),
                  ],
                ),
              ),
            ),
          ),
          Divider(), // Đường phân cách giữa các phần
          // Hiển thị mô tả sản phẩm
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              left: 10,
              bottom: 5,
            ), // Khoảng cách cho phần trên, trái và dưới
            child: Align(
              alignment: Alignment.centerLeft, // Canh lề bên trái
              child: Text(
                'Mô tả sản phẩm', // Tiêu đề "Mô tả sản phẩm"
                style: TextStyle(
                  fontSize: AppStyle.textSizeMedium, // Kích thước chữ vừa phải
                  color: Colors.blueGrey, // Màu chữ xanh dương
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              bottom: 10,
              right: 10,
            ), // Khoảng cách cho phần trái, phải và dưới
            child: Align(
              alignment: Alignment.centerLeft, // Canh lề bên trái
              child:
                  items.isNotEmpty
                      ? Text(
                        '${items[0]['description'].toString()}', // Hiển thị mô tả sản phẩm
                        style: TextStyle(
                          fontSize:
                              AppStyle
                                  .textSizeMedium, // Kích thước chữ vừa phải
                          color: Colors.black, // Màu chữ đen
                        ),
                      )
                      : Text('...'), // Nếu không có mô tả, hiển thị dấu ba chấm
            ),
          ),

          // Hiển thị thanh tiến trình
          LinearProgressIndicator(
            value: _tienDo, // Giá trị tiến độ
            backgroundColor: Colors.green, // Màu nền của thanh tiến trình
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue,
            ), // Màu của tiến trình (xanh dương)
            minHeight: 10, // Chiều cao tối thiểu của thanh tiến trình
          ),
          // Kiểm tra nếu có đánh giá trong danh sách 'listReview'
          listReview.isNotEmpty
              ? Column(
                children: [
                  // Hiển thị tổng điểm và thông tin đánh giá
                  if (listReview.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 10, top: 5),
                      child: Row(
                        children: [
                          // Hiển thị điểm trung bình
                          Text(
                            '${diem / tongTart}', // Hiển thị điểm trung bình
                            style: TextStyle(fontSize: AppStyle.textSizeLarge),
                          ),
                          SizedBox(width: 5),
                          // Hiển thị biểu tượng sao
                          Icon(Icons.star, size: 20, color: Colors.amberAccent),
                          SizedBox(width: 5),
                          // Hiển thị văn bản "Đánh giá sản phẩm"
                          Text(
                            'Đánh giá sản phẩm',
                            style: TextStyle(fontSize: AppStyle.textSizeMedium),
                          ),
                          SizedBox(width: 5),
                          // Hiển thị tổng số lượt đánh giá
                          Text(
                            '(${tongTart})',
                            style: TextStyle(fontSize: AppStyle.textSizeMedium),
                          ),
                          // Hiển thị nút "Tất cả"
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text('Tất cả'),
                                    Icon(Icons.chevron_right),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Hiển thị phần đánh giá chi tiết
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Độ hài lòng', // Tiêu đề "Độ hài lòng"
                          style: TextStyle(
                            fontSize: AppStyle.textSizeMedium,
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 15),
                        // Hiển thị thanh tiến độ cho các mức đánh giá: "Tốt"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 2, child: Text('Tốt')),
                            Expanded(
                              flex: 6,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(),
                                child: LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(10),
                                  value:
                                      (tyleTot / 100), // Tiến độ cho mức "Tốt"
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
                                child: Text('${tyleTot}%'),
                              ),
                            ),
                          ],
                        ),
                        // Hiển thị thanh tiến độ cho các mức đánh giá: "Trung bình"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 2, child: Text('Trung bình')),
                            Expanded(
                              flex: 6,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(),
                                child: LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(10),
                                  value:
                                      (tyleTB /
                                          100), // Tiến độ cho mức "Trung bình"
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
                                child: Text('${tyleTB}%'),
                              ),
                            ),
                          ],
                        ),
                        // Hiển thị thanh tiến độ cho các mức đánh giá: "Tệ"
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 2, child: Text('Tệ')),
                            Expanded(
                              flex: 6,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(),
                                child: LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(10),
                                  value: (tylet / 100), // Tiến độ cho mức "Tệ"
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
                                child: Text('${tylet}%'),
                              ),
                            ),
                          ],
                        ),
                        // Hiển thị danh sách đánh giá sản phẩm
                        Container(
                          width: double.infinity,
                          height: 300,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemCount:
                                listReview
                                    .length, // Số lượng đánh giá trong danh sách
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Divider(),
                                    // Hiển thị thông tin người đánh giá
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          child: ClipOval(
                                            child: Image.asset(
                                              'lib/Image/nen.png', // Ảnh đại diện người đánh giá
                                              width: 30,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          '${listReview[index].nameBuy}', // Tên người đánh giá
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    // Hiển thị số sao đánh giá
                                    if (index < listColorStar.length)
                                      Row(
                                        children: List.generate(5, (indexx) {
                                          return Icon(
                                            Icons.star,
                                            size: 17,
                                            color:
                                                listColorStar[index]["colorGrey${indexx + 1}"] ??
                                                Colors.grey,
                                          );
                                        }),
                                      ),
                                    SizedBox(height: 5),
                                    // Hiển thị nội dung đánh giá
                                    Text(
                                      'Đánh giá ',
                                      style: TextStyle(
                                        fontSize: AppStyle.textSizeMedium,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      '${listReview[index].review} ',
                                    ), // Nội dung đánh giá
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Chưa có đánh giá',
                  ), // Nếu không có đánh giá, hiển thị thông báo này
                ),
              ),

          // Khoảng cách và phân cách giữa các phần
          SizedBox(height: 10),
          Container(
            height: 10,
            color: const Color.fromARGB(
              255,
              195,
              200,
              203,
            ), // Đường phân cách mỏng giữa các phần
          ),

          // Hiển thị thông tin shop
          Container(
            padding: EdgeInsets.only(bottom: 100),
            color: Colors.white,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 15),
                  child: Row(
                    children: [
                      // Hiển thị ảnh đại diện của shop
                      Container(
                        width: 70,
                        height: 70,
                        child: ClipOval(
                          child:
                              imageUrl != null
                                  ? Image.network(
                                    imageUrl.toString(),
                                    fit: BoxFit.fill,
                                    cacheWidth: 50,
                                    height: 50,
                                  )
                                  : Image.asset(
                                    'lib/Image/nen.png',
                                  ), // Nếu không có ảnh, hiển thị ảnh mặc định
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          children: [
                            // Hiển thị tên shop
                            Text(
                              name.toString(),
                              style: TextStyle(
                                fontSize: AppStyle.textSizeMedium,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 5),
                            // Nút "Xem shop"
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
                // Hiển thị thông tin tổng quan về shop và sản phẩm
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Hiển thị số lượng đánh giá
                      Column(
                        children: [
                          listReview.isNotEmpty
                              ? Text('${diem / tongTart}')
                              : Text('0'),
                          Text('Đánh giá'),
                        ],
                      ),
                      VerticalDivider(width: 2, color: Colors.black),
                      // Hiển thị số lượng sản phẩm
                      Column(
                        children: [Text(total.toString()), Text('Sản phẩm')],
                      ),
                      VerticalDivider(width: 2, color: Colors.black),
                      // Hiển thị phần trăm phản hồi
                      Column(children: [Text('100%'), Text('Phản hồi')]),
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
