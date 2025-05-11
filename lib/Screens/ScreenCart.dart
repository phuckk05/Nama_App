import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Screens/ScreeenBuy.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienGioHang extends StatefulWidget {
  final String? email;
  final String? id;
  const GiaoDienGioHang({Key? Key, this.email, this.id}) : super(key: Key);

  @override
  State<GiaoDienGioHang> createState() => _GiaoDienGioHangState();
}

class _GiaoDienGioHangState extends State<GiaoDienGioHang> {
  // Khai báo các biến toàn cục để sử dụng trong widget
  Firebauth _firebauth = Firebauth(); // Khởi tạo đối tượng Firebauth để thao tác với Firebase
  bool isCheckBox = false; // Trạng thái checkbox "Chọn tất cả"
  bool isAny = false; // Kiểm tra có sản phẩm nào được chọn không
  bool _offStateContener = true; // Trạng thái chỉnh sửa giỏ hàng (Sửa/Xong)
  String textSua = "Sửa"; // Nội dung nút "Sửa" hoặc "Xong"
  int setFlex = 1; // Giá trị flex của layout khi chỉnh sửa
  int flexConter = 3; // Giá trị flex của layout khi xem
  List<Map<String, dynamic>> items = []; // Danh sách sản phẩm trong giỏ hàng
  List<Map<String, dynamic>> itemsbuy = []; // Danh sách sản phẩm đã chọn mua
  List<Map<String, dynamic>> itemsCheck =
      []; // Trạng thái checkbox của từng sản phẩm
  List<Map<String, dynamic>> itemsSl =
      []; // Số lượng từng sản phẩm trong giỏ hàng

  // Giảm số lượng sản phẩm tại index
  void truSoluong(int index) {
    int? a = int.tryParse(
      itemsSl[index]['sl$index'].toString(),
    ); // Lấy số lượng sản phẩm
    if (a != null && a > 1) {
      // Kiểm tra số lượng lớn hơn 1
      a = a - 1; // Giảm số lượng
      itemsSl[index] = {
        "sl$index": a.toString(),
      }; // Cập nhật số lượng trong danh sách
      setState(() {}); // Cập nhật giao diện
    }
  }

  // Tăng số lượng sản phẩm tại index
  void congSoluong(int index) {
    int? a = int.tryParse(
      itemsSl[index]['sl$index'].toString(),
    ); // Lấy số lượng sản phẩm
    if (a != null) {
      // Kiểm tra số lượng hợp lệ
      a = a + 1; // Tăng số lượng
      itemsSl[index] = {
        "sl$index": a.toString(),
      }; // Cập nhật số lượng trong danh sách
      setState(() {}); // Cập nhật giao diện
    }
  }

  // Cập nhật trạng thái checkbox "Chọn tất cả" cho toàn bộ sản phẩm
  void CheckBox(bool value, List<Map<String, dynamic>> list) {
    list.clear(); // Xóa trạng thái checkbox cũ
    for (int i = 0; i < items.length; i++) {
      list.add({
        "check$i": value,
      }); // Cập nhật trạng thái checkbox cho từng sản phẩm
    }
    setState(() {
      isCheckBox = value; // Cập nhật trạng thái của checkbox "Chọn tất cả"
    });
  }

  // Cập nhật trạng thái checkbox của từng sản phẩm cụ thể
  void CheckBoxAny(bool value, int index, List<Map<String, dynamic>> list) {
    if (list.length != items.length) {
      // Nếu danh sách chưa đủ
      list.clear();
      for (int i = 0; i < items.length; i++) {
        list.add({"check$i": false}); // Khởi tạo danh sách checkbox false
      }
    }
    list[index] = {
      "check$index": value,
    }; // Cập nhật trạng thái checkbox tại index
    setState(() {}); // Cập nhật giao diện
  }

  // Mua ngay các sản phẩm đã chọn
  void BuyNow() async {
    itemsbuy.clear(); // Xóa danh sách sản phẩm mua ngay

    // Lọc ra các sản phẩm đã được chọn để mua
    for (int i = 0; i < itemsCheck.length; i++) {
      if (itemsCheck[i]['check$i'] == true) {
        // Kiểm tra nếu sản phẩm được chọn
        itemsbuy.add(items[i]); // Thêm vào danh sách mua ngay
        itemsbuy.last['total'] =
            itemsSl[i]["sl$i"]; // Cập nhật số lượng sản phẩm
        print('so luong :  ${itemsbuy.last['total']}');
      }
    }

    if (itemsbuy.isNotEmpty) {
      // Kiểm tra xem có sản phẩm nào được chọn không
      String checkTotal = await _firebauth.checkTotal(
        itemsbuy,
      ); // Kiểm tra số lượng sản phẩm với Firebase
      if (checkTotal == "ok") {
        // Nếu số lượng hợp lệ
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    GiaoDienMuaSanPham(email: widget.email, listCart: itemsbuy),
          ),
        );

        if (result == true) {
          // Nếu người dùng đã thanh toán thành công
          // Duyệt ngược để xóa các sản phẩm đã mua
          for (int i = items.length - 1; i >= 0; i--) {
            for (var item in itemsbuy) {
              if (item['idCart'] == items[i]['idcart']) {
                items.removeAt(i); // Xóa sản phẩm khỏi giỏ hàng
                itemsSl.removeAt(i); // Xóa số lượng sản phẩm khỏi giỏ hàng
                break; // Thoát vòng lặp sau khi xóa
              }
            }
          }
          setState(() {}); // Cập nhật giao diện
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Số lượng sản phẩm có hạn !'))),
        ); // Thông báo nếu số lượng không đủ
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn sản phẩm !'),
        ), // Thông báo nếu không có sản phẩm được chọn
      );
    }
  }

  // Chế độ "Sửa" hoặc "Xong" để thay đổi trạng thái giỏ hàng
  void Sua() {
    setState(() {
      if (textSua == "Sửa") {
        // Nếu đang ở chế độ xem giỏ hàng
        textSua = "Xong"; // Đổi thành "Xong"
        _offStateContener = false; // Cho phép chỉnh sửa giỏ hàng
        setFlex = 7; // Thay đổi flex layout
      } else {
        textSua = "Sửa"; // Đổi lại thành "Sửa"
        _offStateContener = true; // Vô hiệu hóa chỉnh sửa giỏ hàng
      }
    });
  }

  // Lấy danh sách sản phẩm trong giỏ hàng từ Firebase
  void laySanPham() async {
    await _firebauth.getSaveCarts(
      items,
      widget.email.toString(),
    ); // Lấy giỏ hàng từ Firebase
    setState(() {}); // Cập nhật giao diện
    // Thêm số lượng cho từng sản phẩm vào danh sách
    for (int i = 0; i < items.length; i++) {
      itemsSl.addAll([
        {"sl$i": items[i]['total']},
      ]);
    }
    setState(() {}); // Cập nhật giao diện
  }

  // Xóa sản phẩm khỏi giỏ hàng
  void XoaSanPham(int i) async {
    if (i < 0 || i >= items.length || i >= itemsSl.length)
      return; // Kiểm tra index hợp lệ

    String id = items[i]['idCart'].toString(); // Lấy id sản phẩm

    items.removeAt(i); // Xóa sản phẩm khỏi danh sách giỏ hàng
    itemsSl.removeAt(i); // Xóa số lượng sản phẩm khỏi danh sách
    await _firebauth.DeleteCarts(id); // Xóa sản phẩm khỏi Firebase

    setState(() {}); // Cập nhật giao diện
  }

  @override
  void initState() {
    super
        .initState(); // Gọi hàm initState của lớp cha (State) để thực hiện các khởi tạo ban đầu
    laySanPham(); // Lấy sản phẩm từ Firebase khi app bắt đầu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: Text(
          'Giỏ hàng',
          style: GoogleFonts.robotoSlab(
            fontSize: AppStyle.textSizeTitle,
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(213, 255, 255, 255),
      body: body(),

      // Thanh mua hàng dưới cùng
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      BuyNow();
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
    );
  }

  // Phần body của widget, dùng để hiển thị nội dung giỏ hàng
  Widget body() {
    return SingleChildScrollView(
      // Bao bọc toàn bộ body trong SingleChildScrollView để có thể scroll được nếu nội dung quá dài
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          10,
          10,
          10,
          100,
        ), // Thêm khoảng cách padding xung quanh nội dung
        child: Container(
          width:
              double
                  .infinity, // Chiều rộng container bằng toàn bộ chiều rộng màn hình
          decoration: BoxDecoration(
            color: Colors.white, // Màu nền của container
            borderRadius: BorderRadius.circular(10), // Bo góc của container
          ),
          child: Column(
            children: [
              // Row đầu tiên chứa Checkbox chọn tất cả và nút "Sửa" hoặc "Xong"
              Row(
                mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween, // Căn chỉnh các phần tử trong row sao cho chúng cách đều
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value:
                            isCheckBox, // Trạng thái checkbox: true hoặc false
                        onChanged: (value) {
                          CheckBox(
                            value!,
                            itemsCheck,
                          ); // Gọi hàm CheckBox để chọn hoặc bỏ chọn tất cả
                        },
                      ),
                      Text(
                        'Chọn tất cả',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: AppStyle.textSizeMedium,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 15,
                    ), // Thêm padding bên phải
                    child: GestureDetector(
                      onTap:
                          () =>
                              Sua(), // Khi nhấn vào "Sửa" sẽ thay đổi trạng thái
                      child: Text(
                        textSua, // Tùy thuộc vào trạng thái, hiển thị "Sửa" hoặc "Xong"
                        style: TextStyle(fontSize: AppStyle.textSizeMedium),
                      ),
                    ),
                  ),
                ],
              ),

              // Danh sách sản phẩm trong giỏ hàng
              ListView.builder(
                shrinkWrap:
                    true, // Đảm bảo rằng listview không chiếm không gian quá lớn
                physics:
                    NeverScrollableScrollPhysics(), // Vô hiệu hóa scroll của listview vì đã có scroll của parent
                itemCount:
                    items.isNotEmpty
                        ? items.length
                        : 0, // Kiểm tra xem danh sách có sản phẩm không
                itemBuilder: (context, i) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ), // Thêm khoảng cách giữa các item
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .center, // Căn chỉnh các phần tử theo chiều dọc
                      children: [
                        Checkbox(
                          value:
                              itemsCheck.isNotEmpty
                                  ? itemsCheck[i]['check$i']
                                  : false, // Trạng thái checkbox của từng sản phẩm
                          onChanged: (value) {
                            CheckBoxAny(
                              value!,
                              i,
                              itemsCheck,
                            ); // Cập nhật trạng thái checkbox cho sản phẩm cụ thể
                          },
                        ),
                        // Hiển thị ảnh sản phẩm
                        Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Bo góc ảnh sản phẩm
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child:
                                items.isNotEmpty
                                    ? Image.network(
                                      items[i]['imageUrl'], // Hiển thị ảnh sản phẩm từ URL
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      'lib/Image/nen.png', // Hiển thị ảnh mặc định nếu không có ảnh sản phẩm
                                      fit: BoxFit.cover,
                                    ),
                          ),
                        ),
                        // Cột chứa thông tin sản phẩm và số lượng
                        Expanded(
                          flex:
                              setFlex, // Chiếm phần không gian còn lại trong row
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start, // Căn chỉnh cột con theo chiều ngang
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis, // Nếu văn bản quá dài, ẩn bớt phần không vừa
                                      items.isNotEmpty
                                          ? items[i]['name']
                                          : 'Đang tải lên...',
                                      style: TextStyle(
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      items.isNotEmpty
                                          ? '${items[i]['price']} đ'
                                          : 'Đang tải lên...',
                                      style: TextStyle(
                                        fontSize: AppStyle.textSizeLarge,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Colors
                                                .redAccent, // Màu đỏ cho giá sản phẩm
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // Các nút tăng giảm số lượng
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          truSoluong(i); // Giảm số lượng
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black54,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              topLeft: Radius.circular(10),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            size: 20,
                                          ), // Biểu tượng giảm số lượng
                                        ),
                                      ),
                                      Container(
                                        constraints: BoxConstraints(
                                          minWidth: 50,
                                        ),
                                        padding: EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.black54,
                                            width: 2,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            itemsSl[i]['sl$i']
                                                .toString(), // Hiển thị số lượng sản phẩm
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          congSoluong(i); // Tăng số lượng
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black54,
                                              width: 2,
                                            ),
                                            borderRadius: BorderRadius.only(
                                              bottomRight: Radius.circular(10),
                                              topRight: Radius.circular(10),
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            size: 20,
                                          ), // Biểu tượng tăng số lượng
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Nút "Xóa" hiển thị khi chế độ "Sửa" được kích hoạt
                              Expanded(
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Offstage(
                                    offstage:
                                        _offStateContener, // Nếu chế độ "Sửa" chưa được kích hoạt thì ẩn nút "Xóa"
                                    child: Container(
                                      height: 90,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                        ),
                                      ),
                                      child: Center(
                                        child: GestureDetector(
                                          onTap: () {
                                            XoaSanPham(
                                              i,
                                            ); // Xóa sản phẩm khỏi giỏ hàng
                                          },
                                          child: Text(
                                            'Xóa',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              color:
                                                  Colors.white, // Màu chữ trắng
                                              fontWeight: FontWeight.bold,
                                            ),
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
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
