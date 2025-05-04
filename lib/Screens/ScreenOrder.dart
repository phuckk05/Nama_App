import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Screens/ScreenDetail.dart';
import 'package:nama_app/Screens/ScreenEvaluate.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDonHang extends StatefulWidget {
  final String? email;
  final List<DonHang>? listDonHang;

  GiaoDienDonHang({super.key, this.email, this.listDonHang});

  @override
  State<GiaoDienDonHang> createState() => _GiaoDienDonHangState();
}

class _GiaoDienDonHangState extends State<GiaoDienDonHang>
    with SingleTickerProviderStateMixin {
  Firebauth _firebauth = Firebauth();
  int tienThanhToan = 0;
  String? nameUser;
  List<String> name = [];
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> itemproducts = [];
  List<DonHang> listChoXacNhan = [];
  List<DonHang> listChoGiao = [];
  List<DonHang> listDanhGia = [];
  List<DonHang> listDonHangDaGiao = [];

  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    doDaNhanDuocHang();
  }

  //lay thong tin thanh toan
  void nhanHangThanhCong(String id) async {
    // Tìm đơn hàng có id tương ứng trong listDonHangDaGiao
    DonHang donHang = listDonHangDaGiao.firstWhere(
      (item) => item.id == id,
      orElse: () => null as DonHang,
    );

    if (donHang != null) {
      // Cập nhật trạng thái của đơn hàng
      donHang.status = "Đã nhận hàng";

      // Thêm đơn hàng vào danh sách đánh giá
      listDanhGia.add(donHang);

      // Xóa khỏi danh sách đã giao
      listDonHangDaGiao.removeWhere((item) => item.id == id);

      // Cập nhật Firestore
      await _firebauth.updateDonHangdaDuocNhan(id);

      // Đóng dialog, cập nhật giao diện và hiển thị thông báo
      if (mounted) {
        Navigator.of(context).pop();
        setState(() {});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Nhận hàng thành công'))),
      );
    } else {
      // Nếu không tìm thấy đơn hàng theo id
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Không tìm thấy đơn hàng'))),
      );
    }
  }

  //lấy thông tin đơn đã nhận được hàng
  void doDaNhanDuocHang() {
    listChoXacNhan =
        widget.listDonHang
            ?.where((itemss) => itemss.status == "Chờ xác nhận")
            .toList() ??
        [];
    listChoGiao =
        widget.listDonHang
            ?.where((itemss) => itemss.status == "Chờ giao")
            .toList() ??
        [];
    listDanhGia =
        widget.listDonHang
            ?.where(
              (itemss) =>
                  itemss.status == "Đã nhận hàng" ||
                  itemss.status == "Đã đánh giá",
            )
            .toList() ??
        [];

    listDonHangDaGiao =
        widget.listDonHang
            ?.where((itemss) => itemss.status == "Đã giao")
            .toList() ??
        [];
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: 
    Scaffold(
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
                  Navigator.pop(context, true);
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
                'Đơn hàng của bạn',
                style: GoogleFonts.robotoSlab(
                  fontSize: AppStyle.textSizeTitle,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Lưu',
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
      backgroundColor: Colors.grey[300],
      body: Column(
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
                Tab(text: 'Xác nhận'),
                Tab(text: 'Chờ giao hàng'),
                Tab(text: 'Đã giao'),
                Tab(text: 'Đánh giá'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                giaoDienChoXacNhan(),
                giaoDienChoGiao(),
                giaoDienDaGiao(),
                giaoDaNhanHang(),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget giaoDienChoXacNhan() {
    return SingleChildScrollView(
      child: Column(
        children: [
          listChoXacNhan.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  top: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),

                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listChoXacNhan.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GiaoDienChiTietDonHang(email: widget.email, items:listChoXacNhan[index],i: 0,)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                ),
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
                                        widget.listDonHang!.isNotEmpty
                                            ? Text(
                                              '${listChoXacNhan[index].nameShop}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              'Đang tải lên...',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              top: 10,
                                              right: 10,
                                              bottom: 10,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ), // Bo tròn ảnh
                                              child:
                                                  listChoXacNhan.isNotEmpty
                                                      ? Image.network(
                                                        '${listChoXacNhan[index].imageUrl}',
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                          listChoXacNhan
                                                                  .isNotEmpty
                                                              ? Text(
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                '${listChoXacNhan[index].name}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              )
                                                              : Text(
                                                                'Đang tải lên...',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'x${listChoXacNhan[index].soLuong}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    listChoXacNhan.isNotEmpty
                                                        ? Text(
                                                          '${listChoXacNhan[index].price} đ',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
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
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    // Text('x${widget.soLuong}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Tổng số tiền (${listChoXacNhan[index].soLuong} sản phẩm):',
                                          ),
                                          Text(
                                            ' ${listChoXacNhan[index].priceAll} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppStyle.textSizeMedium,
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Trạng thái đơn hàng',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 1,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              '${listChoXacNhan[index].status}',
                                              style: TextStyle(
                                                fontSize:
                                                    AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có đơn hàng nào cả ! ',
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
              ),

          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            child: Text(
              '',
              style: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //tab chờ giao
  Widget giaoDienChoGiao() {
    return SingleChildScrollView(
      child: Column(
        children: [
          listChoGiao.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  top: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),

                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listChoGiao.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                             onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GiaoDienChiTietDonHang(email: widget.email, items:listChoGiao[index],i: 1,)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                ),
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
                                        listChoGiao.isNotEmpty
                                            ? Text(
                                              '${listChoGiao[index].nameShop}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              'Đang tải lên...',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              top: 10,
                                              right: 10,
                                              bottom: 10,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ), // Bo tròn ảnh
                                              child:
                                                  listChoGiao.isNotEmpty
                                                      ? Image.network(
                                                        '${listChoGiao[index].imageUrl}',
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                          listChoGiao.isNotEmpty
                                                              ? Text(
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                '${listChoGiao[index].name}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              )
                                                              : Text(
                                                                'Đang tải lên...',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'x${listChoGiao[index].soLuong}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    listChoGiao.isNotEmpty
                                                        ? Text(
                                                          '${listChoGiao[index].price} đ',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
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
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    // Text('x${widget.soLuong}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Tổng số tiền (${listChoGiao[index].soLuong} sản phẩm):',
                                          ),
                                          Text(
                                            ' ${listChoGiao[index].priceAll} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppStyle.textSizeMedium,
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Trạng thái đơn hàng',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: Colors.black,
                                                width: 1,
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Text(
                                              '${listChoGiao[index].status}',
                                              style: TextStyle(
                                                fontSize:
                                                    AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có đơn hàng nào cả ! ',
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
              ),

          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            child: Text(
              '',
              style: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget giaoDienDaGiao() {
    return SingleChildScrollView(
      child: Column(
        children: [
          listDonHangDaGiao.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  top: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),

                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listDonHangDaGiao.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GiaoDienChiTietDonHang(email: widget.email, items:listDonHangDaGiao[index], i: 2,)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                ),
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
                                        listDonHangDaGiao.isNotEmpty
                                            ? Text(
                                              '${listDonHangDaGiao[index].nameShop}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              'Đang tải lên...',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              top: 10,
                                              right: 10,
                                              bottom: 10,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ), // Bo tròn ảnh
                                              child:
                                                  listDonHangDaGiao.isNotEmpty
                                                      ? Image.network(
                                                        '${listDonHangDaGiao[index].imageUrl}',
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                          listDonHangDaGiao
                                                                  .isNotEmpty
                                                              ? Text(
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                '${listDonHangDaGiao[index].name}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              )
                                                              : Text(
                                                                'Đang tải lên...',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'x${listDonHangDaGiao[index].soLuong}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    listDonHangDaGiao.isNotEmpty
                                                        ? Text(
                                                          '${listDonHangDaGiao[index].price} đ',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
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
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    // Text('x${widget.soLuong}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Tổng số tiền (${listDonHangDaGiao[index].soLuong} sản phẩm):',
                                          ),
                                          Text(
                                            ' ${listDonHangDaGiao[index].price} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppStyle.textSizeMedium,
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Cập nhật đơn hàng',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return ThongBaoDaNhanDuocHang(
                                                      context,
                                                      listDonHangDaGiao[index]
                                                          .id,
                                                    );
                                                  },
                                                );
                                              },
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.green,
                                              ),
                                              child: Text(
                                                'Đã nhận được hàng',
                                                style: TextStyle(
                                                  fontSize:
                                                      AppStyle.textSizeMedium,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
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
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có đơn hàng nào cả ! ',
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
              ),

          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            child: Text(
              '',
              style: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //tab đã giao
  Widget giaoDaNhanHang() {
    return SingleChildScrollView(
      child: Column(
        children: [
          listDanhGia.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: 0,
                  top: 10,
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),

                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: listDanhGia.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => GiaoDienChiTietDonHang(email: widget.email, items:listDanhGia[index], i: 3,)));
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                ),
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
                                        listDanhGia.isNotEmpty
                                            ? Text(
                                              '${listDanhGia[index].nameShop}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              'Đang tải lên...',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              top: 10,
                                              right: 10,
                                              bottom: 10,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ), // Bo tròn ảnh
                                              child:
                                                  listDanhGia.isNotEmpty
                                                      ? Image.network(
                                                        '${listDanhGia[index].imageUrl}',
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                          listDanhGia.isNotEmpty
                                                              ? Text(
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                '${listDanhGia[index].name}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              )
                                                              : Text(
                                                                'Đang tải lên...',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'x${listDanhGia[index].soLuong}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    listDanhGia.isNotEmpty
                                                        ? Text(
                                                          '${listDanhGia[index].price} đ',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
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
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    // Text('x${widget.soLuong}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Tổng số tiền (${listDanhGia[index].soLuong} sản phẩm):',
                                          ),
                                          Text(
                                            ' ${listDanhGia[index].price} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppStyle.textSizeMedium,
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Phản hồi đơn hàng',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.green,
                                            ),
                                            child: FutureBuilder<bool>(
                                              future: _firebauth.checkReview(
                                                listDanhGia[index].id,
                                              ),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  );
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                    'Lỗi',
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  );
                                                } else if (snapshot.hasData &&
                                                    snapshot.data == true) {
                                                  return Text(
                                                    'Đã đánh giá',
                                                    style: TextStyle(
                                                      fontSize:
                                                          AppStyle
                                                              .textSizeMedium,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                    ),
                                                  );
                                                } else {
                                                  return InkWell(
                                                    onTap: () async {
                                                      final result = await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                context,
                                                              ) => GiaoDienDanhGia(
                                                                listDanhGia:
                                                                    listDanhGia,
                                                                index: index,
                                                                email:
                                                                    widget.email
                                                                      .toString(),
                                                                
                                                           

                                                              ),
                                                        ),
                                                      );
                                                      if (result == true) {
                                                        setState(() {});
                                                      }
                                                    },
                                                    child: Text(
                                                      'Đánh giá',
                                                      style: TextStyle(
                                                        fontSize:
                                                            AppStyle
                                                                .textSizeMedium,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có đơn hàng nào cả ! ',
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
              ),

          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            child: Text(
              '',
              style: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //Xác nhận duyệt đơn hàng
  Widget ThongBaoDaNhanDuocHang(BuildContext context, String id) {
    return StatefulBuilder(
      builder: (context, setStateFul) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check, color: Colors.green, size: 100),
                Text(
                  'Bạn đã nhận được đơn đặt hàng ?',
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
                          Navigator.pop(context);
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
                          nhanHangThanhCong(id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Xác nhận',
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
      },
    );
  }
}
