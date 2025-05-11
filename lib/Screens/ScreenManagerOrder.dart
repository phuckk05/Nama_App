import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Screens/ScreenDetail.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

// ignore: must_be_immutable
class GiaoDienQuanLyDonHang extends StatefulWidget {
  final String? email;
  List<DonHang>? listDonHang;
  List<Map<String, dynamic>>? address;
  List<String>? addressDaGiao;
  List<String>? addressDaGiao2;
  GiaoDienQuanLyDonHang({
    super.key,
    this.email,
    this.listDonHang,
    this.address,
    this.addressDaGiao,
    this.addressDaGiao2,
  });

  @override
  State<GiaoDienQuanLyDonHang> createState() => _GiaoDienQuanLyDonHangState();
}

class _GiaoDienQuanLyDonHangState extends State<GiaoDienQuanLyDonHang>
    with SingleTickerProviderStateMixin {
  // Khai báo controller cho TabBar gồm 4 tab
  late TabController _tabController;

  // Khởi tạo đối tượng để thao tác với Firebase Authentication hoặc Firestore (Firebauth là class custom)
  Firebauth _firebauth = Firebauth();

  // Các danh sách đơn hàng theo trạng thái
  List<DonHang> listChoXacNhan = []; // Đơn hàng chờ xác nhận
  List<DonHang> listChoGiao = []; // Đơn hàng đã duyệt, chờ giao hàng
  List<DonHang> listDaGiao = []; // Đơn hàng đã giao, người dùng đã nhận
  List<DonHang> listChuaNhan = []; // Đơn hàng đã giao nhưng chưa xác nhận đã nhận

  // Tương lai sẽ chứa thông tin địa chỉ (có thể dùng để fetch từ Firestore hoặc xử lý async khác)
  // ignore: unused_field
  late Future<List<Map<String, dynamic>>> _addressFuture;
  // ignore: unused_field
  late Future<List<Map<String, dynamic>>> _addressFutureDaGiao;

  // Hàm lọc danh sách đơn hàng dựa trên trạng thái (status)
  void locStatus() {
    // Lọc các đơn hàng có trạng thái "Chờ xác nhận"
    listChoXacNhan =
        widget.listDonHang
            ?.where((item) => item.status == "Chờ xác nhận")
            .toList() ??
        [];

    // Lọc đơn hàng có trạng thái "Chờ giao"
    listChoGiao =
        widget.listDonHang
            ?.where((item) => item.status == "Chờ giao")
            .toList() ??
        [];

    // Lọc đơn hàng đã giao nhưng chưa xác nhận nhận hàng
    listChuaNhan =
        widget.listDonHang
            ?.where((item) => item.status == "Đã giao")
            .toList() ??
        [];

    // Lọc đơn hàng đã giao và người nhận xác nhận đã nhận
    listDaGiao =
        widget.listDonHang
            ?.where((item) => item.status == "Đã nhận hàng")
            .toList() ??
        [];
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với 4 tab
    _tabController = TabController(length: 4, vsync: this);

    // Gọi hàm lọc trạng thái đơn hàng ban đầu
    locStatus();

    // Cập nhật lại UI
    if (mounted) setState(() {});
    print("sl :  ${widget.listDonHang!.length}");
  }

  // Hàm cập nhật đơn hàng từ "Chờ xác nhận" => "Chờ giao"
  void capNhatDonHangDuyet(String id) async {
    // Tạo danh sách địa chỉ mới
    // ignore: unused_local_variable
    List<String> idAdress = [];

    // Tìm đơn hàng trong danh sách chờ xác nhận
    for (var item in listChoXacNhan) {
      if (item.id == id) {
        item.status = 'Chờ giao'; // Cập nhật trạng thái
        listChoGiao.add(item); // Thêm vào danh sách chờ giao
        widget.addressDaGiao!.add(item.address); // Cập nhật địa chỉ đơn giao
      }
    }

    // Xóa đơn đã duyệt khỏi danh sách chờ xác nhận
    listChoXacNhan.removeWhere((element) => element.id == id);

    // Cập nhật UI
    setState(() {});

    // Gọi hàm xử lý cập nhật trạng thái trong Firestore
    await _firebauth.duyetDonHang(id);

    // Cập nhật lại UI sau khi cập nhật Firebase
    setState(() {});
  }

  // Hàm cập nhật đơn hàng từ "Chờ giao" => "Đã giao"
  void capNhatDonDaGiao(String id) async {
    for (var item in listChoGiao) {
      if (item.id == id) {
        // Thêm địa chỉ vào danh sách đơn đã giao (nhưng chưa xác nhận đã nhận)
        widget.addressDaGiao2!.add(item.address);

        // Thêm đơn hàng vào danh sách đã giao
        listChuaNhan.add(item);
      }
    }

    // Xóa đơn khỏi danh sách chờ giao
    listChoGiao.removeWhere((element) => element.id == id);

    // Cập nhật UI
    setState(() {});

    // Gọi hàm cập nhật trạng thái trong Firestore
    await _firebauth.updatedDaGiao(id);

    // Cập nhật lại UI sau khi cập nhật Firebase
    setState(() {});
  }

  // Hàm xử lý hủy đơn hàng (xóa khỏi danh sách chờ xác nhận)
  void capNhatDonHangHuy(String id) async {
    // Xóa đơn hàng bị hủy khỏi danh sách chờ xác nhận
    listChoXacNhan.removeWhere((element) => element.id == id);

    // Cập nhật UI
    setState(() {});

    // Gọi Firebase để cập nhật trạng thái đơn hàng bị hủy
    await _firebauth.huyDonHang(id);

    // Cập nhật UI lần nữa sau khi cập nhật Firebase
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                  'Đơn hàng',
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
        body: body(),
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        // Phần header chứa TabBar để chuyển giữa các trạng thái đơn hàng
        Container(
          color: Colors.white, // Nền trắng cho tab
          child: TabBar(
            isScrollable: false, // Không cho cuộn tab, hiển thị cố định
            controller:
                _tabController, // Sử dụng controller đã khai báo ở initState
            labelPadding: EdgeInsets.symmetric(
              horizontal: 0.0,
            ), // Không padding ngang
            labelColor: Colors.black, // Màu của tab đang chọn
            unselectedLabelColor: Colors.black54, // Màu của tab chưa được chọn
            indicatorColor: Colors.black, // Màu thanh gạch chân bên dưới tab
            labelStyle: TextStyle(
              fontSize: AppStyle.textSizeMedium, // Kích thước chữ của tab
              fontWeight: FontWeight.bold, // In đậm
            ),
            tabs: [
              Tab(text: 'Duyệt đơn'), // Tab 1: Danh sách đơn cần duyệt
              Tab(text: 'Gửi hàng'), // Tab 2: Danh sách đơn đã duyệt, chờ giao
              Tab(text: 'Chưa nhận'), // Tab 3: Đơn hàng đã giao, chưa xác nhận
              Tab(text: 'Đã Nhận'), // Tab 4: Đơn hàng đã nhận xong
            ],
          ),
        ),

        // Phần nội dung dưới TabBar, mỗi Tab tương ứng với một Widget hiển thị danh sách đơn
        Expanded(
          child: TabBarView(
            controller:
                _tabController, // Controller để điều khiển TabBarView đồng bộ với TabBar
            children: [
              duyetonHang(), // Widget hiển thị danh sách đơn chờ duyệt
              guiDonHangDi(), // Widget hiển thị danh sách đơn chờ giao
              guiChuaNhan(), // Widget hiển thị đơn đã giao nhưng chưa xác nhận nhận hàng
              guiDaGiao(), // Widget hiển thị đơn đã xác nhận nhận hàng
            ],
          ),
        ),
      ],
    );
  }

  //tab duyệt đơn hàng
  Widget duyetonHang() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
           listChoXacNhan.isNotEmpty
                ? Padding(
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
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
                           print(' sl1 : ${listChoXacNhan.length}');
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => GiaoDienChiTietDonHang(
                                          email: widget.email,
                                          items: listChoXacNhan[index],
                                          i: 0,
                                        ),
                                  ),
                                );
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
                                          Text(
                                            'Đơn hàng  : ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Divider(),

                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Người mua  :',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              listChoXacNhan.isNotEmpty
                                                  ? Text(
                                                    '${listChoXacNhan[index].nameShop}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : Text(
                                                    'Đang tải lên...',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 120,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                            Alignment
                                                                .centerLeft,
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
                                                            Alignment
                                                                .centerRight,
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
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            '${listChoXacNhan[index].price} đ',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontFamily:
                                                                  AppStyle
                                                                      .fontFamily,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                                  FontWeight
                                                                      .bold,
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
                                            Expanded(
                                              child: Text(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                ' ${listChoXacNhan[index].priceAll} đ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      AppStyle.textSizeMedium,
                                                  color: Colors.red,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
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
                                            Container(
                                              width: 100,
                                              height: 50,
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return ThongBaoHuy(
                                                        context,
                                                        listChoXacNhan[index].id
                                                            .toString(),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  'Hủy',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppStyle.textSizeMedium,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 50,
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  print(
                                                    listChoXacNhan[index].id
                                                        .toString(),
                                                  );
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return ThongBao(
                                                        context,
                                                        listChoXacNhan[index].id
                                                            .toString(),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  'Duyệt đơn hàng',
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
                ' - Có thể bạn cũng thích - ',
                style: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //tab duyệt gửi đơn hàng đi
  Widget guiDonHangDi() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            listChoGiao.isNotEmpty
                ? Padding(
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => GiaoDienChiTietDonHang(
                                          email: widget.email,
                                          items: listChoGiao[index],
                                          i: 1,
                                        ),
                                  ),
                                );
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
                                          Text(
                                            'Đơn hàng  : ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Divider(),

                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Người mua  :',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              listChoGiao.isNotEmpty
                                                  ? Text(
                                                    '${listChoGiao[index].nameShop}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : Text(
                                                    'Đang tải lên...',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 120,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                            Alignment
                                                                .centerLeft,
                                                        child:
                                                            listChoGiao
                                                                    .isNotEmpty
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
                                                            Alignment
                                                                .centerRight,
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
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            '${listChoGiao[index].price} đ',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontFamily:
                                                                  AppStyle
                                                                      .fontFamily,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                                  FontWeight
                                                                      .bold,
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
                                            Expanded(
                                              child: Text(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                ' ${listChoGiao[index].priceAll} đ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      AppStyle.textSizeMedium,
                                                  color: Colors.red,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(height: 5),
                                      Divider(),
                                      SizedBox(height: 5),
                                      SizedBox(height: 5),
                                      Text(
                                        'Hàng đã gửi đi vui lòng bấm "Hàng đã gửi đi"',
                                        style: TextStyle(
                                          fontSize: AppStyle.textSizeMedium,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                      SizedBox(height: 5),
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
                                                fontSize:
                                                    AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 50,
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                color: Colors.white,
                                              ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.green,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  // print(listChoXacNhan[index]['idOrder'].toString());
                                                  showDialog(
                                                    barrierDismissible: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return ThongBaoDaGiao(
                                                        context,
                                                        listChoGiao[index].id
                                                            .toString(),
                                                      );
                                                    },
                                                  );
                                                },
                                                child: Text(
                                                  'Hàng đã gủi đi',
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
                ' - Có thể bạn cũng thích - ',
                style: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //tab Chua nhan
  Widget guiChuaNhan() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            listChuaNhan.isNotEmpty
                ? Padding(
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),

                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap:
                              true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: listChuaNhan.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => GiaoDienChiTietDonHang(
                                          email: widget.email,
                                          items: listChoXacNhan[index],
                                          i: 2,
                                        ),
                                  ),
                                );
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
                                    //  boxShadow: [
                                    //   BoxShadow(
                                    //     blurRadius: 12,
                                    //     color: Colors.black54,
                                    //     offset: Offset(0, 0)
                                    //   )
                                    // ],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Đơn hàng  : ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Divider(),

                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Người mua  :',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              listChuaNhan.isNotEmpty
                                                  ? Text(
                                                    '${listChuaNhan[index].nameShop}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : Text(
                                                    'Đang tải lên...',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 120,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                    listChuaNhan.isNotEmpty
                                                        ? Image.network(
                                                          '${listChuaNhan[index].imageUrl}',
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
                                                            Alignment
                                                                .centerLeft,
                                                        child:
                                                            listChuaNhan
                                                                    .isNotEmpty
                                                                ? Text(
                                                                  maxLines: 3,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  '${listChuaNhan[index].nameShop}',
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
                                                            Alignment
                                                                .centerRight,
                                                        child: Text(
                                                          'x${listChuaNhan[index].soLuong}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      listChuaNhan.isNotEmpty
                                                          ? Text(
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            '${listChuaNhan[index].price} đ',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontFamily:
                                                                  AppStyle
                                                                      .fontFamily,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                                  FontWeight
                                                                      .bold,
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
                                              'Tổng số tiền (${listChuaNhan[index].soLuong} sản phẩm):',
                                            ),
                                            Expanded(
                                              child: Text(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                ' ${listChuaNhan[index].priceAll} đ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      AppStyle.textSizeMedium,
                                                  color: Colors.red,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(height: 5),
                                      Divider(),
                                      // SizedBox(height: 5),
                                      // SizedBox(height: 5),
                                      // Text(
                                      //   'Hàng đã gửi đi vui lòng bấm "Hàng đã gửi đi"',
                                      //   style: TextStyle(
                                      //     fontSize: AppStyle.textSizeMedium,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.red,
                                      //   ),
                                      // ),
                                      // SizedBox(height: 5),
                                      // SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Cập nhật đơn hàng',
                                              style: TextStyle(
                                                fontSize:
                                                    AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 50,
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Chưa nhận hàng',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppStyle.textSizeMedium,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
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
                ' - Có thể bạn cũng thích - ',
                style: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //tab đã giao
  Widget guiDaGiao() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: SingleChildScrollView(
        child: Column(
          children: [
            listDaGiao.isNotEmpty
                ? Padding(
                  padding: EdgeInsets.only(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 0),

                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap:
                              true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: listDaGiao.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => GiaoDienChiTietDonHang(
                                          email: widget.email,
                                          items: listDaGiao[index],
                                          i: 3,
                                        ),
                                  ),
                                );
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
                                          Text(
                                            'Đơn hàng  : ${index + 1}',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Divider(),

                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'Người mua  :',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              listDaGiao.isNotEmpty
                                                  ? Text(
                                                    '${listDaGiao[index].nameShop}',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                  : Text(
                                                    'Đang tải lên...',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            height: 120,
                                            width: 120,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                                    listDaGiao.isNotEmpty
                                                        ? Image.network(
                                                          '${listDaGiao[index].imageUrl}',
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
                                                            Alignment
                                                                .centerLeft,
                                                        child:
                                                            listDaGiao
                                                                    .isNotEmpty
                                                                ? Text(
                                                                  maxLines: 3,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  '${listDaGiao[index].nameShop}',
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
                                                            Alignment
                                                                .centerRight,
                                                        child: Text(
                                                          'x${listDaGiao[index].soLuong}',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      listDaGiao.isNotEmpty
                                                          ? Text(
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            '${listDaGiao[index].price} đ',
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontFamily:
                                                                  AppStyle
                                                                      .fontFamily,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                                                  FontWeight
                                                                      .bold,
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
                                              'Tổng số tiền (${listDaGiao[index].soLuong} sản phẩm):',
                                            ),
                                            Expanded(
                                              child: Text(
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                ' ${listDaGiao[index].priceAll} đ',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      AppStyle.textSizeMedium,
                                                  color: Colors.red,
                                                  fontFamily:
                                                      AppStyle.fontFamily,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      SizedBox(height: 5),
                                      Divider(),
                                      // SizedBox(height: 5),
                                      // SizedBox(height: 5),
                                      // Text(
                                      //   'Hàng đã gửi đi vui lòng bấm "Hàng đã gửi đi"',
                                      //   style: TextStyle(
                                      //     fontSize: AppStyle.textSizeMedium,
                                      //     fontWeight: FontWeight.bold,
                                      //     color: Colors.red,
                                      //   ),
                                      // ),
                                      // SizedBox(height: 5),
                                      // SizedBox(height: 5),
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Cập nhật đơn hàng',
                                              style: TextStyle(
                                                fontSize:
                                                    AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              width: 200,
                                              height: 50,
                                              padding: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  'Hàng đã được nhận',
                                                  style: TextStyle(
                                                    fontSize:
                                                        AppStyle.textSizeMedium,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
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
                ' - Có thể bạn cũng thích - ',
                style: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Xác nhận duyệt đơn hàng
  Widget ThongBao(BuildContext context, String id) {
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
                  'Bạn chắc chắn duyệt đơn hàng',
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
                          capNhatDonHangDuyet(id);
                          Navigator.of(context).pop();
                          setStateFul(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text('Duyệt thành công đơn hàng'),
                              ),
                            ),
                          );
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

  //Hủy duyệt đơn hàng
  Widget ThongBaoHuy(BuildContext context, String id) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.green, size: 100),
            Text(
              'Bạn chắc chắn hủy đơn hàng',
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
                      capNhatDonHangHuy(id);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text('Hủy thành công đơn hàng'),
                          ),
                        ),
                      );
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
  }

  //xác nhận đã giao
  Widget ThongBaoDaGiao(BuildContext context, String id) {
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
                  'Chắc chắn đơn hàng đã gửi đi',
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
                          capNhatDonDaGiao(id);
                          Navigator.of(context).pop();
                          setStateFul(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Center(
                                child: Text('Cập nhật thành công'),
                              ),
                            ),
                          );
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
