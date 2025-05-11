import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Screens/ScreenSelectAddress.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienMuaSanPham extends StatefulWidget {
  final String? email;
  final String? idProducts;
  final int? soLuong;
  final List<Map<String, dynamic>>? listCart;
  const GiaoDienMuaSanPham({
    super.key,
    this.email,
    this.idProducts,
    this.soLuong,
    this.listCart,
  });

  @override
  State<GiaoDienMuaSanPham> createState() => _GiaoDienMuaSanPhamState();
}

class _GiaoDienMuaSanPhamState extends State<GiaoDienMuaSanPham> {
  // Biến
  Firebauth _firebauth =
      Firebauth(); // Khởi tạo đối tượng Firebauth để tương tác với Firebase
  List<Map<String, dynamic>> items =
      []; // Danh sách chứa các địa chỉ người dùng đã chọn
  List<Map<String, dynamic>> itemproducts =
      []; // Danh sách chứa thông tin sản phẩm
  String? nameUser; // Biến lưu tên người dùng sau khi lấy từ Firebase
  List<String> name =
      []; // Danh sách chứa tên người dùng và các thông tin phân tách (ví dụ: tên, ảnh)
  int tienThanhToan =
      0; // Tổng số tiền thanh toán cho đơn hàng (bao gồm giá trị sản phẩm và phí vận chuyển)
  bool loading = false; // Cờ kiểm tra trạng thái loading (đang tải)
  int deLay = 3; // Thời gian trễ (dùng cho việc xử lý tác vụ hoặc chờ)
  bool offStateLaoding =
      false; // Cờ kiểm tra trạng thái loading (sử dụng để ẩn/hiện loading spinner)
  bool offStateOrder =
      true; // Cờ kiểm tra trạng thái của đơn hàng (hiển thị hoặc không hiển thị đơn hàng)
  int tongTienHang = 0; // Tổng tiền của sản phẩm (chưa bao gồm phí vận chuyển)
  int tongThanhToan = 0; // Tổng tiền thanh toán (bao gồm phí vận chuyển)
  bool isloading = false; // Cờ trạng thái loading khác
  bool back =
      false; // Cờ kiểm tra có quay lại hay không (ví dụ, quay về màn hình trước đó)

  // Các hàm

  @override
  void initState() {
    super.initState();
    LayDiaChi(); // Lấy địa chỉ người dùng đã chọn
    LayThonTinDonHang(); // Lấy thông tin đơn hàng (sản phẩm, giá trị đơn hàng, v.v.)
  }

  // Lấy địa chỉ được chọn
  void LayDiaChi() async {
    items = await _firebauth.GetAddressSelected(
      widget.email.toString(),
    ); // Lấy địa chỉ từ Firebase
    setState(() {}); // Cập nhật lại giao diện khi có dữ liệu
  }

  // Lấy thông tin đơn hàng
  void LayThonTinDonHang() async {
    if (widget.listCart == null || widget.listCart!.isEmpty) {
      // Kiểm tra xem giỏ hàng có trống hay không
      nameUser = await _firebauth.showProducts(
        widget.idProducts.toString(),
        itemproducts,
      ); // Lấy thông tin sản phẩm từ Firebase
      name = nameUser!.split(
        '+',
      ); // Tách thông tin người dùng (ví dụ: tên và ảnh)

      for (int i = 0; i < itemproducts.length; i++) {
        // Tính toán tổng tiền thanh toán cho sản phẩm
        tienThanhToan = int.tryParse(itemproducts[i]['price'].toString())!;
        tongTienHang =
            int.tryParse(itemproducts[i]['price'].toString())! *
            widget.soLuong!; // Tính tổng tiền sản phẩm (giá x số lượng)
      }
      tienThanhToan =
          (tienThanhToan * widget.soLuong!) +
          30000; // Thêm phí vận chuyển 30,000 VND

      setState(() {}); // Cập nhật lại giao diện sau khi tính toán xong
    } else {
      // Xử lý nếu giỏ hàng không trống (đang bỏ qua phần này trong ví dụ)
    }
  }

  // Thiết lập trạng thái offState1 (đang tải và ẩn đơn hàng)
  void setOffState1() async {
    setState(() {
      offStateLaoding = true; // Hiển thị loading spinner
      offStateOrder = false; // Ẩn thông tin đơn hàng
    });
  }

  // Thiết lập trạng thái offState2 (hoàn tất tải và hiển thị đơn hàng)
  void setOffState2() {
    setState(() {
      offStateLaoding = false; // Ẩn loading spinner
      offStateOrder = true; // Hiển thị thông tin đơn hàng
    });
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
                  if (back) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProcessSccreen(email: widget.email.toString()),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.pop(context, true);
                  }
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.black),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'Thanh toán',
                style: TextStyle(
                  fontSize: AppStyle.textSizeTitle,
                  color: Colors.black,
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
                icon: Icon(Icons.search, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      //body
      body: chiTietSanPham(),
      //thanh mua ngay
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            color: Colors.white,
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Tổng cộng : ",
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text: "${tienThanhToan + tongThanhToan} đ",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: AppStyle.textSizeMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: () async {
                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bạn chưa có địa chỉ !')),
                        );
                      } else {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return _Warning(context);
                          },
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Đặt hàng',
                            style: TextStyle(
                              fontSize: AppStyle.textSizeMedium,
                              color: Colors.white,
                            ),
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
    );
  }

  Widget chiTietSanPham() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              InkWell(
                onTap: () async {
                  final ketQua = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GiaoDienChonDiaChi(
                            email: widget.email.toString(),
                          ),
                    ),
                  );
                  if (ketQua != null) {
                    LayDiaChi();
                    // items.clear();
                    setState(() {});
                  }
                },
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),

                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child:
                              items.isNotEmpty
                                  ? Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 10),
                                          items.isNotEmpty
                                              ? Text(
                                                '${items[0]['name']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              )
                                              : Text(
                                                'Đang tải lên...',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                          SizedBox(width: 5),
                                          items.isNotEmpty
                                              ? Text(
                                                '${items[0]['telephone']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.grey,
                                                ),
                                              )
                                              : Text(
                                                'Đang tải lên...',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          left: 35,
                                          right: 0,
                                        ),
                                        child:
                                            items.isNotEmpty
                                                ? Text(
                                                  '${items[0]['address']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                )
                                                : Text(
                                                  'Đang tải lên...',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                      ),
                                    ],
                                  )
                                  : Center(
                                    child: Text(
                                      'Chưa có địa chỉ !',
                                      style: TextStyle(
                                        fontSize: AppStyle.textSizeMedium,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.house_siding_sharp),
                          SizedBox(width: 10),
                          Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            'Danh sách đơn hàng',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      widget.listCart == null || widget.listCart!.isEmpty
                          ? ListView.builder(
                            shrinkWrap:
                                true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: 1,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 0,
                                        top: 10,
                                        right: 10,
                                        bottom: 10,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ), // Bo tròn ảnh
                                        child:
                                            itemproducts.isNotEmpty
                                                ? Image.network(
                                                  itemproducts[index]['imageUrl'],
                                                  fit: BoxFit.fill,
                                                )
                                                : Image.asset(
                                                  'lib/Image/nen.png',
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 100,

                                      // color: Colors.yellow,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          itemproducts.isNotEmpty
                                              ? Text(
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                '${itemproducts[index]['description'].toString()}',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
                                              )
                                              : Text(
                                                'Đang tải lên...',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
                                              ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              itemproducts.isNotEmpty
                                                  ? Text(
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    '${itemproducts[index]['price'].toString()}',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          AppStyle.fontFamily,
                                                      fontSize:
                                                          AppStyle
                                                              .textSizeMedium,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : Text(
                                                    'Đang tải lên...',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          AppStyle.fontFamily,
                                                      fontSize:
                                                          AppStyle
                                                              .textSizeMedium,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                              Text('x${widget.soLuong}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                          : ListView.builder(
                            shrinkWrap:
                                true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: widget.listCart!.length,
                            itemBuilder: (context, index) {
                              return Row(
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 0,
                                        top: 10,
                                        right: 10,
                                        bottom: 10,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          10,
                                        ), // Bo tròn ảnh
                                        child:
                                            widget.listCart!.isNotEmpty
                                                ? Image.network(
                                                  widget
                                                      .listCart![index]['imageUrl'],
                                                  fit: BoxFit.fill,
                                                )
                                                : Image.asset(
                                                  'lib/Image/nen.png',
                                                  fit: BoxFit.cover,
                                                ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 100,

                                      // color: Colors.yellow,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          widget.listCart!.isNotEmpty
                                              ? Text(
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                '${widget.listCart![index]['description'].toString()}',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
                                              )
                                              : Text(
                                                'Đang tải lên...',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
                                              ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              widget.listCart!.isNotEmpty
                                                  ? Text(
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    '${widget.listCart![index]['price'].toString()}',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          AppStyle.fontFamily,
                                                      fontSize:
                                                          AppStyle
                                                              .textSizeMedium,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : Text(
                                                    'Đang tải lên...',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          AppStyle.fontFamily,
                                                      fontSize:
                                                          AppStyle
                                                              .textSizeMedium,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                              Text(
                                                'x${widget.listCart![index]['total']}',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Phương thức thanh toán',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: AppStyle.textSizeMedium,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Thanh toán khi nhận hàng',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Icon(Icons.check, color: Colors.green),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 100),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Chi tiết thanh toán',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: AppStyle.textSizeMedium,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),

                        child:
                            widget.listCart == null || widget.listCart!.isEmpty
                                ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Tổng tiền hàng',
                                            style: TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${tienThanhToan} đ',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontFamily: AppStyle.fontFamily,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                                : Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Tổng tiền hàng',
                                        style: TextStyle(color: Colors.black87),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: ListView.builder(
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: widget.listCart!.length,
                                        itemBuilder: (context, index) {
                                          tongThanhToan +=
                                              (int.tryParse(
                                                    widget
                                                        .listCart![index]['price']
                                                        .toString(),
                                                  )! +
                                                  30000) *
                                              int.tryParse(
                                                widget.listCart![index]['total']
                                                    .toString(),
                                              )!;
                                          return Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Sản phẩm ${index + 1}',
                                                    style: TextStyle(
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${(int.tryParse(widget.listCart![index]['price'].toString())! + 30000) * int.tryParse(widget.listCart![index]['total'].toString())!} đ',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontFamily:
                                                          AppStyle.fontFamily,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chi phí vận chuyển',
                            style: TextStyle(color: Colors.black87),
                          ),
                          Text(
                            '30000 đ/1 đơn hàng',
                            style: TextStyle(
                              color: Colors.red,
                              fontFamily: AppStyle.fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tổng thanh toán',
                            style: TextStyle(color: Colors.black, fontSize: 15),
                          ),
                          Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            '${tongThanhToan + tienThanhToan} đ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isloading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  // Thông báo yêu cầu xác nhận đặt hàng
  Widget _Warning(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setStateFul) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              20,
            ), // Bo tròn các góc của hộp thoại
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              20,
            ), // Thêm khoảng cách cho các widget con trong Dialog
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Sử dụng không gian tối thiểu cho cột
              children: [
                // Nếu isloading là true, hiển thị vòng quay loading, nếu không thì hiển thị biểu tượng hỏi
                if (isloading) Center(child: CircularProgressIndicator()),
                if (!isloading)
                  Icon(
                    Icons.question_mark,
                    color: Colors.green,
                    size: 60,
                  ), // Biểu tượng câu hỏi
                const SizedBox(height: 16), // Khoảng cách giữa các phần tử
                Text(
                  'Vui lòng xác nhận đặt hàng!',
                  textAlign: TextAlign.center, // Canh giữa văn bản
                  style: TextStyle(
                    fontSize: 18, // Kích thước font chữ
                    fontWeight: FontWeight.bold, // Chữ in đậm
                    fontFamily: AppStyle.fontFamily, // Font gia đình
                  ),
                ),
                const SizedBox(height: 24), // Khoảng cách giữa các phần tử
                Row(
                  children: [
                    // Nút Quay lại
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Đóng hộp thoại
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.grey[300], // Màu nền của button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Bo tròn góc button
                          ),
                        ),
                        child: Text(
                          'Quay lại', // Văn bản của button
                          style: TextStyle(
                            color: Colors.black, // Màu chữ
                            fontWeight: FontWeight.bold, // Chữ in đậm
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // Khoảng cách giữa các nút
                    // Nút Xác nhận
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (widget.listCart == null ||
                              widget.listCart!.isEmpty) {
                            // Nếu giỏ hàng rỗng, cập nhật sản phẩm và tạo đơn hàng
                            String result = await _firebauth.upDateProduct(
                              itemproducts[0]['id'],
                              widget.soLuong.toString(),
                              context,
                            );
                            if (result == "ok") {
                              setStateFul(() {
                                isloading = true; // Hiển thị loading
                              });

                              await Future.delayed(
                                Duration(seconds: 2),
                              ); // Delay để giả lập quá trình tải

                              String id = await _firebauth
                                  .generateVerificationCode(
                                    10,
                                  ); // Tạo mã xác thực
                              final now = DateTime.now();
                              DonHang _donhang = DonHang(
                                id: id,
                                idProducts: itemproducts[0]['id'],
                                name: itemproducts[0]['name'],
                                nameShop: name[0].toString(),
                                soLuong: widget.soLuong.toString(),
                                imageUrl: itemproducts[0]['imageUrl'],
                                address: items[0]['id'],
                                emailSell: itemproducts[0]['email'],
                                emailBuy: widget.email.toString(),
                                createdAt: now.toString(),
                                price: itemproducts[0]['price'],
                                priceAll: tienThanhToan.toString(),
                                status: "Chờ xác nhận", // Trạng thái đơn hàng
                                hidenBuy: false,
                                hidenSell: false,
                              );
                              await _firebauth.saveOrder(
                                _donhang,
                              ); // Lưu đơn hàng vào cơ sở dữ liệu

                              setOffState1(); // Thay đổi trạng thái UI để ẩn các phần tử

                              setStateFul(() {
                                isloading = false; // Dừng loading
                              });
                              Navigator.of(context).pop(); // Đóng hộp thoại
                              // Hiển thị hộp thoại đặt hàng thành công
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return datHangThanhCong(context);
                                },
                              );
                            } else {
                              Navigator.of(
                                context,
                              ).pop(); // Nếu cập nhật không thành công, đóng hộp thoại
                            }
                          } else {
                            // Nếu giỏ hàng không rỗng, xử lý đơn hàng cho từng sản phẩm trong giỏ hàng
                            setStateFul(() {
                              isloading = true; // Hiển thị loading
                            });

                            for (int i = 0; i < widget.listCart!.length; i++) {
                              int tongTien =
                                  (int.tryParse(
                                        widget.listCart![i]['price'].toString(),
                                      )! +
                                      30000) *
                                  int.tryParse(
                                    widget.listCart![i]['total'].toString(),
                                  )!;
                              String id = await _firebauth
                                  .generateVerificationCode(10);
                              await _firebauth.deleteCarts(
                                widget.listCart!,
                              ); // Xóa các sản phẩm trong giỏ hàng
                              await _firebauth.updateTotal(
                                widget.listCart!,
                              ); // Cập nhật lại tổng tiền trong giỏ hàng
                              final now = DateTime.now();
                              DonHang _donhang = DonHang(
                                id: id,
                                idProducts: widget.listCart![i]['idProduct'],
                                name: widget.listCart![i]['name'],
                                nameShop: "hello", // Giả sử tên shop là "hello"
                                soLuong:
                                    widget.listCart![i]['total'].toString(),
                                imageUrl: widget.listCart![i]['imageUrl'],
                                address: items[0]['id'],
                                emailSell: widget.listCart![i]['email'],
                                emailBuy: widget.email.toString(),
                                createdAt: now.toString(),
                                price: widget.listCart![i]['price'],
                                priceAll: tongTien.toString(),
                                status: "Chờ xác nhận", // Trạng thái đơn hàng
                                hidenBuy: false,
                                hidenSell: false,
                              );
                              await _firebauth.saveOrder(
                                _donhang,
                              ); // Lưu đơn hàng vào cơ sở dữ liệu
                            }

                            setOffState1(); // Thay đổi trạng thái UI để ẩn các phần tử
                            setStateFul(() {
                              isloading = false; // Dừng loading
                            });
                            setState(() {
                              back = true; // Đánh dấu trạng thái quay lại
                            });
                            Navigator.of(context).pop(); // Đóng hộp thoại
                            // Hiển thị hộp thoại đặt hàng thành công
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return datHangThanhCong(context);
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Màu nền của button
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              12,
                            ), // Bo tròn góc button
                          ),
                        ),
                        child: Text(
                          'Xác nhận', // Văn bản của button
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ), // Chữ in đậm
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Thông báo đặt hàng thành công
  Widget datHangThanhCong(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ), // Định dạng giao diện của hộp thoại với góc bo tròn
      child: Stack(
        children: [
          // Offstage để ẩn hoặc hiển thị một widget (trạng thái loading)
          Offstage(
            offstage:
                offStateLaoding, // Nếu offStateLaoding = true, widget này bị ẩn
            child: Container(
              height: 210, // Đặt chiều cao cho vùng chứa
              child: Center(
                child: CircularProgressIndicator(),
              ), // Hiển thị vòng quay loading
            ),
          ),
          // Offstage để ẩn hoặc hiển thị phần thông báo khi đơn hàng được xác nhận
          Offstage(
            offstage:
                offStateOrder, // Nếu offStateOrder = true, widget này bị ẩn
            child: Padding(
              padding: const EdgeInsets.all(
                20,
              ), // Thêm padding xung quanh widget con
              child: Column(
                mainAxisSize:
                    MainAxisSize
                        .min, // Chỉ sử dụng không gian tối thiểu cho cột
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.green,
                    size: 60,
                  ), // Biểu tượng check màu xanh biểu thị thành công
                  const SizedBox(height: 16), // Khoảng cách giữa các phần tử
                  Text(
                    'Bạn đã đặt hàng thành công', // Văn bản thông báo thành công
                    textAlign: TextAlign.center, // Canh giữa văn bản
                    style: TextStyle(
                      fontSize: 18, // Kích thước font chữ
                      fontWeight: FontWeight.bold, // Chữ in đậm
                      fontFamily:
                          AppStyle
                              .fontFamily, // Sử dụng font gia đình đã định nghĩa trong AppStyle
                    ),
                  ),
                  const SizedBox(height: 24), // Khoảng cách giữa các phần tử
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Khi người dùng bấm vào "Trang chủ", chuyển đến màn hình ProcessSccreen và xóa tất cả các route trước đó
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProcessSccreen(
                                      email:
                                          widget.email
                                              .toString(), // Truyền email người dùng vào màn hình mới
                                    ),
                              ),
                              (route) =>
                                  false, // Xóa tất cả các màn hình trước đó trong stack
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.grey[300], // Màu nền của button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Góc bo tròn cho button
                            ),
                          ),
                          child: Text(
                            'Trang chủ', // Văn bản trên button
                            style: TextStyle(
                              color: Colors.black, // Màu chữ của button
                              fontWeight: FontWeight.bold, // Chữ in đậm
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12), // Khoảng cách giữa hai button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setOffState2(); // Cập nhật trạng thái để ẩn loading và hiển thị đơn hàng
                            Navigator.of(
                              context,
                            ).pop(); // Đóng hộp thoại thông báo
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white, // Màu nền của button
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                12,
                              ), // Góc bo tròn cho button
                            ),
                          ),
                          child: Text(
                            'Xác nhận', // Văn bản trên button
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ), // Chữ in đậm
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
