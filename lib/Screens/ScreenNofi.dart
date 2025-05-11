import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienThongBao extends StatefulWidget {
  final String? email;
  final List<Map<String, dynamic>>? items;
  final List<Map<String, dynamic>>? itemsBuy;
  GiaoDienThongBao({super.key, this.email, this.items, this.itemsBuy});

  @override
  State<GiaoDienThongBao> createState() => _GiaoDienThongBaoState();
}

class _GiaoDienThongBaoState extends State<GiaoDienThongBao> {
  // Khai báo đối tượng Firebauth để sử dụng các phương thức của Firebase
  Firebauth _firebauth = Firebauth();
  int flexTren = 1; // Biến để điều chỉnh flex cho widget ở trên
  int flexDuoi = 9; // Biến để điều chỉnh flex cho widget ở dưới
  bool offstateXoa = true; // Biến trạng thái để bật/tắt chức năng xóa
  String textXoa = 'Xóa'; // Chữ hiển thị cho nút xóa

  // Hàm thiết lập giá trị flex cho các widget dựa trên số lượng item
  void SetFlex() {
    // Kiểm tra số lượng item trong widget.items và thay đổi giá trị flex tương ứng
    if (widget.items!.length == 1) {
      setState(() {
        flexTren = 1; // Flex cho phần trên khi có 1 item
        flexDuoi = 7; // Flex cho phần dưới khi có 1 item
      });
    } else if (widget.items!.length == 2) {
      setState(() {
        flexTren = 3; // Flex cho phần trên khi có 2 item
        flexDuoi = 9; // Flex cho phần dưới khi có 2 item
      });
    } else if (widget.items!.length == 3) {
      setState(() {
        flexTren = 3; // Flex cho phần trên khi có 3 item
        flexDuoi = 5; // Flex cho phần dưới khi có 3 item
      });
    } else if (widget.items!.length >= 4) {
      setState(() {
        flexTren = 5; // Flex cho phần trên khi có 4 hoặc nhiều hơn
        flexDuoi = 5; // Flex cho phần dưới khi có 4 hoặc nhiều hơn
      });
    } else {
      setState(() {
        flexTren = 1; // Mặc định flex cho phần trên khi không có item
        flexDuoi = 9; // Mặc định flex cho phần dưới khi không có item
      });
    }
  }

  // Hàm cập nhật trạng thái "ẩn thông báo bán sản phẩm" khi xóa sản phẩm
  void updateHidenSell(String id) async {
    _firebauth.updateHidenSell(
      id,
    ); // Gọi phương thức từ Firebauth để ẩn thông báo bán
    widget.items!.removeWhere(
      (item) => item['idOrder'] == id,
    ); // Xóa sản phẩm khỏi danh sách
    SetFlex(); // Cập nhật lại flex khi sản phẩm bị xóa
    setState(() {}); // Cập nhật lại giao diện
  }

  // Hàm cập nhật trạng thái "ẩn thông báo mua sản phẩm" khi xóa sản phẩm
  void updateHidenBuy(String id) async {
    _firebauth.updateHidenBuy(
      id,
    ); // Gọi phương thức từ Firebauth để ẩn thông báo mua
    widget.itemsBuy!.removeWhere(
      (item) => item['idOrder'] == id,
    ); // Xóa sản phẩm khỏi danh sách mua
    SetFlex(); // Cập nhật lại flex khi sản phẩm bị xóa
    setState(() {}); // Cập nhật lại giao diện
  }

  // Hàm khởi tạo trạng thái ban đầu khi widget được tạo
  @override
  void initState() {
    super.initState();
    // Cập nhật flex khi widget được khởi tạo
    SetFlex();
    setState(() {}); // Cập nhật lại giao diện
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.email);
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
                  'Thông báo',
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
      body: body(),
    );
  }

  // Widget body chính chứa giao diện của màn hình
  Widget body() {
    return Column(
      children: [
        // Tiêu đề phần thông báo sản phẩm đăng bán
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[400]), // Màu nền xám
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn lề giữa
              children: [
                Text(
                  'Thông báo sản phẩm đăng bán', // Tiêu đề
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54, // Màu chữ xám đậm
                  ),
                ),
              ],
            ),
          ),
        ),
        // Phần hiển thị danh sách thông báo sản phẩm
        Expanded(flex: flexTren, child: _danhSachThongBaoSanPham()),

        // Tiêu đề phần cập nhật đơn đặt hàng
        Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[400]), // Màu nền xám
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Căn lề giữa
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Cập nhật đơn đặt hàng', // Tiêu đề
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54, // Màu chữ xám đậm
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    InkWell(
                      onTap: () {
                        // Đổi trạng thái của nút xóa khi nhấn
                        setState(() {
                          textXoa =
                              textXoa == "Xóa"
                                  ? "Xong"
                                  : "Xóa"; // Toggle giữa "Xóa" và "Xong"
                          offstateXoa = !offstateXoa; // Chuyển trạng thái xóa
                        });
                      },
                      child: Text(
                        '$textXoa', // Hiển thị chữ "Xóa" hoặc "Xong"
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Màu chữ xanh
                          fontSize:
                              AppStyle
                                  .textSizeMedium, // Kích thước chữ từ AppStyle
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Phần hiển thị thông tin đơn đặt hàng
        Expanded(flex: flexDuoi, child: _ThongTinDonDatHang()),
      ],
    );
  }

  // Widget danh sách thông báo sản phẩm
  Widget _danhSachThongBaoSanPham() {
    return widget.items!.isNotEmpty
        ? ListView.builder(
          itemCount: widget.items!.length, // Số lượng item trong danh sách
          itemBuilder: (context, index) {
            // Lấy thời gian tạo đơn hàng từ item và chuyển đổi chuỗi thành DateTime
            String createdAtString = widget.items![index]['createdAt'];
            DateTime createdAt = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).parse(createdAtString);
            DateTime currentDateTime = DateTime.now();
            Duration difference = currentDateTime.difference(createdAt);

            // Tính toán thời gian đã trôi qua kể từ khi đơn hàng được tạo
            String displayTime;
            if (difference.inMinutes < 60) {
              displayTime =
                  "${difference.inMinutes} phút trước"; // Nếu chưa đủ 1 giờ
            } else if (difference.inHours < 24) {
              displayTime =
                  "${difference.inHours} giờ trước"; // Nếu chưa đủ 1 ngày
            } else {
              displayTime =
                  "${difference.inDays} ngày trước"; // Nếu đã qua nhiều ngày
            }

            // Hiển thị thông báo sản phẩm đăng bán
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white, // Màu nền trắng
                      borderRadius: BorderRadius.circular(5), // Bo góc
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54, // Màu bóng
                          blurRadius: 10, // Độ mờ của bóng
                          offset: Offset(0, 2), // Vị trí bóng
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal, // Cuộn ngang
                        child: InkWell(
                          onTap: () {
                            // Hàm xử lý khi người dùng nhấn vào thông báo, có thể mở chi tiết đơn hàng
                          },
                          child: Row(
                            children: [
                              // Hiển thị thông tin người mua và thời gian
                              RichText(
                                text: TextSpan(
                                  children: [
                                    widget.items!.isNotEmpty
                                        ? TextSpan(
                                          text:
                                              "${widget.items![index]['userNameBuy']}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        )
                                        : TextSpan(
                                          text: "Đang tải lên...",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                    TextSpan(
                                      text: " đã đặt sản phẩm của bạn ",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    widget.items!.isNotEmpty
                                        ? TextSpan(
                                          text:
                                              " $displayTime", // Hiển thị thời gian
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        )
                                        : TextSpan(
                                          text: "Đang tải lên...",
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              // Nút "Xóa" để ẩn thông báo khi người dùng nhấn vào
                              SizedBox(
                                width: 100,
                                child: FloatingActionButton(
                                  mini: true, // Nút nhỏ
                                  elevation: 5, // Độ cao bóng
                                  onPressed: () {
                                    // Xử lý xóa thông báo
                                    updateHidenSell(
                                      widget.items![index]['idOrder'],
                                    );
                                  },
                                  child: Text('Xóa'), // Chữ "Xóa"
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )
        : Container(
          height: 100,
          child: Center(
            child: Text('Không có thông báo !'),
          ), // Thông báo khi không có item
        );
  }

  // Widget hiển thị thông tin đơn đặt hàng
  Widget _ThongTinDonDatHang() {
    // Kiểm tra nếu có đơn hàng để hiển thị
    return widget.itemsBuy!.isNotEmpty
        ? ListView.builder(
          itemCount:
              widget.itemsBuy!.length, // Số lượng đơn hàng trong danh sách
          itemBuilder: (context, index) {
            // Lấy thời gian tạo đơn hàng từ item và chuyển chuỗi thành DateTime
            String createdAtString = widget.itemsBuy![index]['createdAt'];
            DateTime createdAt = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).parse(createdAtString);
            DateTime currentDateTime = DateTime.now();
            Duration difference = currentDateTime.difference(createdAt);

            // Tính toán thời gian đã trôi qua kể từ khi đơn hàng được tạo
            String displayTime;
            if (difference.inMinutes < 60) {
              displayTime =
                  "${difference.inMinutes} phút trước"; // Nếu chưa đủ 1 giờ
            } else if (difference.inHours < 24) {
              displayTime =
                  "${difference.inHours} giờ trước"; // Nếu chưa đủ 1 ngày
            } else {
              displayTime =
                  "${difference.inDays} ngày trước"; // Nếu đã qua nhiều ngày
            }

            return Column(
              children: [
                InkWell(
                  onTap: () {
                    // In ID của đơn hàng khi nhấn vào
                    print(widget.itemsBuy![index]['idOrder']);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, left: 0, right: 0),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white, // Màu nền trắng
                        borderRadius: BorderRadius.circular(0), // Không bo góc
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54, // Màu bóng
                            blurRadius: 1, // Độ mờ của bóng
                            offset: Offset(0, 1), // Đẩy bóng xuống dưới
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch, // Căn lề trái phải
                          children: [
                            // Hiển thị thông tin sản phẩm
                            Row(
                              children: [
                                Text(
                                  'Sản phẩm : ',
                                  style: TextStyle(
                                    fontSize: AppStyle.textSizeMedium,
                                    color: Colors.black54, // Màu chữ xám đậm
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Expanded(
                                  flex: 9,
                                  child: Text(
                                    maxLines: 1, // Chỉ hiển thị 1 dòng
                                    overflow:
                                        TextOverflow
                                            .ellipsis, // Hiển thị "..." nếu dài
                                    '${widget.itemsBuy![index]['name']} ',
                                    style: TextStyle(
                                      fontSize: AppStyle.textSizeMedium,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    '(x${widget.itemsBuy![index]['soLuong']})', // Số lượng sản phẩm
                                    style: TextStyle(
                                      fontSize: AppStyle.textSizeSmall,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Hiển thị trạng thái đơn hàng và thời gian
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween, // Căn lề 2 đầu
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      // Kiểm tra và hiển thị trạng thái của đơn hàng
                                      if (widget.itemsBuy![index]['status'] ==
                                          "Chờ xác nhận")
                                        TextSpan(
                                          text: "Đang chờ xác nhận",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      else if (widget
                                              .itemsBuy![index]['status'] ==
                                          "Chờ giao")
                                        TextSpan(
                                          text:
                                              "Đơn hàng của bạn đang vận chuyển",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      else if (widget
                                              .itemsBuy![index]['status'] ==
                                          "Hủy")
                                        TextSpan(
                                          text: "Đơn hàng của bạn đã bị hủy",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      else if (widget
                                              .itemsBuy![index]['status'] ==
                                          "Đã giao")
                                        TextSpan(
                                          text: "Đơn hàng của bạn đã được giao",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      else if (widget
                                              .itemsBuy![index]['status'] ==
                                          "Đã nhận hàng")
                                        TextSpan(
                                          text: "Đã nhận sản phẩm",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      else if (widget
                                              .itemsBuy![index]['status'] ==
                                          "Đã đánh giá")
                                        TextSpan(
                                          text: "Đã đánh giá sản phẩm",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Hiển thị thời gian đã trôi qua từ khi đơn hàng được tạo
                                Text(
                                  '$displayTime', // Hiển thị thời gian đã trôi qua
                                  style: TextStyle(
                                    color: Colors.black26,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            // Phần để hiển thị nút "Xóa" (ẩn nếu offstateXoa là true)
                            Offstage(
                              offstage:
                                  offstateXoa, // Kiểm tra trạng thái ẩn hay hiện
                              child: InkWell(
                                onTap: () {
                                  // Xử lý xóa đơn hàng khi nhấn vào nút "Xóa"
                                  updateHidenBuy(
                                    widget.itemsBuy![index]['idOrder'],
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Container(
                                    width: double.infinity,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Xóa', // Chữ "Xóa"
                                        style: TextStyle(
                                          color: Colors.red, // Màu chữ đỏ
                                          fontSize: AppStyle.textSizeTitle,
                                          fontWeight: FontWeight.bold,
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
                ),
              ],
            );
          },
        )
        : Container(
          height: 100,
          child: Center(
            child: Text('Không có thông báo !'),
          ), // Thông báo khi không có đơn hàng
        );
  }
}
