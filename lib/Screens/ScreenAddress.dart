import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDiaChi extends StatefulWidget {
  final String? email;
  const GiaoDienDiaChi({super.key, this.email});

  @override
  State<GiaoDienDiaChi> createState() => _GiaoDienDiaChiState();
}

class _GiaoDienDiaChiState extends State<GiaoDienDiaChi> {
  // Khởi tạo đối tượng Firebauth và FocusNode, cùng các TextEditingController để nhập thông tin.
  Firebauth _firebauth = Firebauth();
  late FocusNode _focusNode; // FocusNode dùng để theo dõi trạng thái focus của các trường nhập liệu.
  late FocusNode _focusNode2;
  late FocusNode _focusNode3;
  final _diachiText = TextEditingController(); // Controller cho trường nhập địa chỉ.
  final _tenText = TextEditingController(); // Controller cho trường nhập tên.
  final _sdt = TextEditingController(); // Controller cho trường nhập số điện thoại.
  double chieuCao = 400; // Biến này lưu chiều cao của giao diện, sẽ thay đổi khi trường nhập liệu được focus.

  // Hàm bất đồng bộ để thêm địa chỉ vào cơ sở dữ liệu
  void ThemDiaChiNhanHang() async {
    // Kiểm tra độ dài của số điện thoại, nếu không đúng thì hiển thị thông báo lỗi
    if (_sdt.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Số điện thoại không đúng !'))),
      );
    }
    // Kiểm tra nếu cả địa chỉ và tên đều trống thì hiển thị thông báo lỗi
    else if (_diachiText.text.isEmpty && _tenText.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Vui lòng đủ thông tin !'))),
      );
    }
    // Nếu thông tin đầy đủ, thực hiện lưu địa chỉ vào Firestore và thông báo thành công
    else {
      await _firebauth.SaveAddress(
        widget.email.toString(),
        _tenText.text.toString(),
        _diachiText.text.toString(),
        _sdt.text.toString(),
      );
      // Xóa các trường nhập liệu sau khi lưu
      _diachiText.clear();
      _sdt.clear();
      _tenText.clear();
      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          content: Center(
            child: Text(
              'Thêm thành công !',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      );
      Navigator.pop(context); // Đóng màn hình hiện tại sau khi thêm thành công
    }
  }

  // Hàm bất đồng bộ để xóa địa chỉ
  void XoaDiaChi(String id) async {
    // Xóa địa chỉ từ Firestore bằng id
    await _firebauth.DeleteAddress(id);
    // Hiển thị thông báo xóa thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Center(
          child: Text(
            'Xóa thành công !',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
    setState(() {}); // Cập nhật lại giao diện sau khi xóa
  }

  // Hàm khởi tạo (on created)
  @override
  void initState() {
    super.initState();
    SetChieuCao(); // Gọi hàm để thiết lập các FocusNode và xử lý chiều cao màn hình.
  }

  // Thiết lập chiều cao của giao diện khi các trường nhập liệu nhận focus
  void SetChieuCao() {
    // Khởi tạo các FocusNode để theo dõi các trường nhập liệu
    _focusNode = FocusNode();
    _focusNode2 = FocusNode();
    _focusNode3 = FocusNode();

    // Lắng nghe sự kiện focus của _focusNode
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          chieuCao =
              700; // Nếu trường nhập liệu được focus, tăng chiều cao giao diện.
        });
      } else {
        setState(() {
          chieuCao =
              400; // Nếu trường nhập liệu mất focus, giảm chiều cao giao diện.
        });
      }
    });

    // Lắng nghe sự kiện focus của _focusNode2
    _focusNode2.addListener(() {
      if (_focusNode2.hasFocus) {
        setState(() {
          chieuCao = 700; // Tăng chiều cao nếu trường nhập liệu được focus.
        });
      } else {
        setState(() {
          chieuCao = 400; // Giảm chiều cao khi trường nhập liệu mất focus.
        });
      }
    });

    // Lắng nghe sự kiện focus của _focusNode3
    _focusNode3.addListener(() {
      if (_focusNode3.hasFocus) {
        setState(() {
          chieuCao = 700; // Tăng chiều cao khi trường nhập liệu được focus.
        });
      } else {
        setState(() {
          chieuCao = 400; // Giảm chiều cao khi trường nhập liệu mất focus.
        });
      }
    });
  }

  // Hàm hủy các FocusNode khi không còn sử dụng
  @override
  void dispose() {
    super.dispose();
    _focusNode
        .dispose(); // Giải phóng bộ nhớ của _focusNode khi không sử dụng nữa.
    _focusNode2
        .dispose(); // Giải phóng bộ nhớ của _focusNode2 khi không sử dụng nữa.
    _focusNode3
        .dispose(); // Giải phóng bộ nhớ của _focusNode3 khi không sử dụng nữa.
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
                  Navigator.pop(context);
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
                'Địa chỉ',
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
              child: IconButton(
                onPressed: () {},
                icon: Icon(Icons.search, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: body(),
      // Widget bottomSheet - Được sử dụng để hiển thị một nút và bottom sheet khi nhấn vào nút.
      bottomSheet: Visibility(
        // Điều kiện hiển thị nút "Thêm địa chỉ mới" khi không có bàn phím trên màn hình.
        visible:
            MediaQuery.of(context).viewInsets.bottom ==
            0, // Kiểm tra nếu không có bàn phím trên màn hình (viewInsets.bottom == 0).
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 40,
          ), // Khoảng cách dưới cùng của nút khỏi đáy màn hình.
          child: Container(
            height: 50, // Đặt chiều cao của container chứa nút.
            child: Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,

              ), // Padding để tạo khoảng cách bên trái và bên phải cho nút.
              child: ElevatedButton(
                // Khi nhấn vào nút, sẽ hiển thị Modal Bottom Sheet để thêm địa chỉ mới.
                onPressed: () {
                  showModalBottomSheet(
                    context: context, // Đặt context cho Modal Bottom Sheet.
                    isScrollControlled:
                        true, // Đảm bảo chiều cao của bottom sheet có thể điều chỉnh.
                    builder: (BuildContext context) {
                      return ThemDiaChi(
                        context,
                      ); // Gọi widget ThemDiaChi để hiển thị giao diện thêm địa chỉ.
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    double.infinity,
                    50,
                  ), // Đặt kích thước tối thiểu cho nút, rộng đầy đủ màn hình và cao 50.
                  elevation: 5, // Thêm hiệu ứng bóng đổ cho nút.
                  backgroundColor: Colors.cyan, // Màu nền của nút.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // Bo tròn các góc của nút.
                  ),
                ),
                child: Text(
                  'Thêm địa chỉ mới', // Văn bản hiển thị trên nút.
                  style: TextStyle(
                    color: Colors.white, // Màu chữ của nút.
                    fontSize:
                        AppStyle.textSizeMedium, // Kích thước chữ cho nút.
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget body() - Đây là phần thân chính của giao diện, hiển thị danh sách địa chỉ người dùng.
  Widget body() {
    return SingleChildScrollView(
      // SingleChildScrollView giúp cho người dùng có thể cuộn màn hình khi nội dung dài.
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 100,
        ), // Giới hạn phần padding dưới cùng của màn hình.
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch, // Căn các widget trong Column theo chiều ngang.
          children: [
            Container(
              height: 10,
              color: Colors.grey,
            ), // Dòng ngang chia phần giao diện.
            // Tiêu đề "Danh sách địa chỉ"
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Danh sách địa chỉ',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize:
                      AppStyle
                          .textSizeMedium, // Kích thước chữ được định nghĩa trong AppStyle.
                ),
              ),
            ),

            // Mảng chứa danh sách địa chỉ, được tải bất đồng bộ từ Firebase.
            Column(
              children: [
                // FutureBuilder giúp lấy dữ liệu bất đồng bộ và hiển thị UI dựa trên trạng thái của dữ liệu.
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _firebauth.GetAddress(
                    widget.email.toString(),
                  ), // Gọi phương thức GetAddress từ Firebauth để lấy danh sách địa chỉ.
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // Hiển thị vòng tròn tải trong khi chờ dữ liệu từ Firebase.
                      return CircularProgressIndicator();
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      // Nếu không có dữ liệu hoặc dữ liệu trống, hiển thị thông báo không có dữ liệu.
                      return Center(child: Text('Không có dữ liệu !'));
                    } else {
                      // Nếu có dữ liệu, hiển thị danh sách địa chỉ.
                      final items = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap:
                            true, // Đảm bảo danh sách không chiếm quá nhiều không gian.
                        physics:
                            BouncingScrollPhysics(), // Hiệu ứng cuộn mềm mại.
                        itemCount:
                            items.length, // Số lượng mục trong danh sách.
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 10,
                            ),
                            child: Container(
                              width:
                                  double
                                      .infinity, // Đảm bảo container chiếm toàn bộ chiều ngang.
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  10,
                                ), // Bo tròn các góc của container.
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .stretch, // Căn các widget trong Column theo chiều ngang.
                                children: [
                                  // Hiển thị số điện thoại người nhận.
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Số điện thoại : ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                items.isNotEmpty
                                                    ? items[index]['telephone']
                                                    : CircularProgressIndicator(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 5,
                                  ), // Khoảng cách giữa các mục.
                                  // Hiển thị tên người nhận.
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Tên người nhận : ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                items.isNotEmpty
                                                    ? items[index]['name']
                                                    : CircularProgressIndicator(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  SizedBox(
                                    height: 5,
                                  ), // Khoảng cách giữa các mục.
                                  // Hiển thị địa chỉ.
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      bottom: 10,
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "Địa chỉ : ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                items.isNotEmpty
                                                    ? items[index]['address']
                                                    : CircularProgressIndicator(),
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Nút xóa địa chỉ
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 0,
                                      right: 0,
                                      bottom: 0,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: IconButton(
                                        onPressed: () {
                                          // Gọi hàm XoaDiaChi để xóa địa chỉ khỏi Firebase.
                                          XoaDiaChi(items[index]['id']);
                                        },
                                        icon: Icon(
                                          Icons.delete_forever,
                                        ), // Biểu tượng xóa.
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget ThemDiaChi - Đây là widget dùng để hiển thị giao diện "Thêm địa chỉ nhận hàng"
  Widget ThemDiaChi(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        16,
      ), // Padding giúp tạo khoảng cách giữa các phần tử trong container.
      height:
          chieuCao, // Chiều cao của container thay đổi theo giá trị của biến `chieuCao`.
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start, // Căn các widget trong Column từ phía trái.
        children: [
          // Tiêu đề và nút hủy
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween, // Đảm bảo các phần tử trong Row cách nhau đều.
            children: [
              Text(
                "Thêm địa chỉ nhận hàng", // Tiêu đề phần nhập địa chỉ.
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ), // Định dạng chữ tiêu đề.
              ),
              GestureDetector(
                // GestureDetector giúp nhận diện các thao tác chạm của người dùng.
                onTap: () {
                  Navigator.pop(
                    context,
                  ); // Quay lại màn hình trước khi nhấn vào nút hủy.
                },
                child: Text(
                  'Hủy', // Văn bản hiển thị trên nút hủy.
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ), // Định dạng chữ cho nút hủy.
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ), // Khoảng cách giữa tiêu đề và các trường nhập liệu.
          // Trường nhập "Tên người nhận"
          TextField(
            controller:
                _tenText, // Controller giúp quản lý nội dung nhập vào trong trường "Tên người nhận".
            focusNode:
                _focusNode, // FocusNode để điều khiển trạng thái của trường (focus hay không).
            decoration: InputDecoration(
              labelText: 'Tên người nhận', // Đặt nhãn cho trường nhập liệu.
              border: OutlineInputBorder(), // Đặt viền cho trường nhập liệu.
            ),
          ),
          SizedBox(height: 5), // Khoảng cách giữa các trường nhập liệu.
          // Trường nhập "Số điện thoại"
          TextField(
            controller: _sdt, // Controller cho trường nhập "Số điện thoại".
            focusNode: _focusNode2, // FocusNode cho trường "Số điện thoại".
            decoration: InputDecoration(
              labelText:
                  'Số điện thoại', // Đặt nhãn cho trường "Số điện thoại".
              border: OutlineInputBorder(), // Viền cho trường nhập liệu.
            ),
            keyboardType:
                TextInputType
                    .phone, // Thiết lập bàn phím là loại số điện thoại.
            inputFormatters: [
              LengthLimitingTextInputFormatter(
                10,
              ), // Giới hạn số lượng ký tự là 10 (số điện thoại).
              FilteringTextInputFormatter.digitsOnly, // Chỉ cho phép nhập số.
            ],
          ),
          SizedBox(height: 5), // Khoảng cách giữa các trường nhập liệu.
          // Trường nhập "Địa chỉ"
          TextField(
            controller: _diachiText, // Controller cho trường nhập "Địa chỉ".
            minLines: 2, // Đặt tối thiểu 2 dòng cho trường nhập "Địa chỉ".
            focusNode: _focusNode3, // FocusNode cho trường "Địa chỉ".
            maxLines: 3, // Đặt tối đa 3 dòng cho trường "Địa chỉ".
            decoration: InputDecoration(
              labelText: 'Địa chỉ', // Đặt nhãn cho trường nhập liệu.
              border: OutlineInputBorder(), // Viền cho trường nhập liệu.
            ),
          ),
          SizedBox(height: 40), // Khoảng cách giữa trường nhập liệu và nút lưu.
          // Nút "Lưu"
          Center(
            child: Padding(
              padding: const EdgeInsets.all(
                10.0,
              ), // Padding để tạo khoảng cách cho nút.
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(
                    100,
                    40,
                  ), // Đặt kích thước tối thiểu cho nút.
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      10,
                    ), // Bo tròn các góc của nút.
                  ),
                  elevation: 5, // Tạo bóng cho nút để tạo độ sâu.
                ),
                onPressed: () {
                  ThemDiaChiNhanHang(); // Gọi hàm thêm địa chỉ khi người dùng nhấn vào nút "Lưu".
                },
                child: Text(
                  "Lưu", // Văn bản hiển thị trên nút "Lưu".
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium,
                  ), // Kích thước chữ cho nút.
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
