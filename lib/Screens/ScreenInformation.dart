import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nama_app/API/imageAPI.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienThongTin extends StatefulWidget {
  final String? email;
  GiaoDienThongTin({Key? key, this.email}) : super(key: key);

  @override
  State<GiaoDienThongTin> createState() => _GiaoDienThongTinState();
}

class _GiaoDienThongTinState extends State<GiaoDienThongTin> {
  Cloudinary _imageAPI =
      Cloudinary(); // Khởi tạo đối tượng Cloudinary để quản lý ảnh
  Firebauth _firebauth =
      Firebauth(); // Khởi tạo đối tượng Firebauth để quản lý thông tin người dùng Firebase
  FocusNode _focusNode =
      FocusNode(); // FocusNode để theo dõi trạng thái của các TextField
  File? _image; // Biến lưu trữ ảnh người dùng đã chọn
  int? _selectedIndex; // Biến lưu trữ chỉ số của phần tử đang được chọn
  double chieuCao =
      250; // Chiều cao mặc định của widget, thay đổi khi TextField được focus
  String? _result; // Biến lưu trữ kết quả trả về khi lấy thông tin người dùng
  List<String> _split =
      []; // Danh sách lưu các phần của kết quả người dùng đã phân tách
  String? _url; // Biến lưu trữ URL của ảnh sau khi tải lên Cloudinary
  bool isloading = false; // Cờ xác định trạng thái loading (đang tải)

  final _text = TextEditingController(); // Controller để điều khiển TextField

  // Hàm chọn ảnh từ thư viện
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker(); // Khởi tạo đối tượng ImagePicker để chọn ảnh
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    ); // Mở thư viện ảnh

    if (pickedFile != null) {
      // Kiểm tra nếu người dùng đã chọn ảnh
      File imageFile = File(
        pickedFile.path,
      ); // Chuyển đổi ảnh đã chọn thành đối tượng File

      setState(() {
        _image = imageFile; // Cập nhật ảnh vào state
      });

      // Lấy URL ảnh từ Cloudinary
      _url = await _imageAPI.getURL(_image);
      setState(() {}); // Cập nhật lại UI sau khi có URL
    } else {
      print(
        'Không chọn ảnh nào.',
      ); // In ra thông báo nếu người dùng không chọn ảnh
    }
  }

  // Hàm cập nhật thông tin người dùng
  void updateUser(String image, String name) async {
    setState(() {
      isloading = true; // Bắt đầu quá trình loading
    });

    // Cập nhật thông tin người dùng vào Firebase
    await _firebauth.UpdateInforUser(widget.email.toString(), image, name);

    await Future.delayed(Duration(seconds: 2)); // Đợi 2 giây để cập nhật
    setState(() {
      isloading = false; // Kết thúc quá trình loading
    });

    // Hiển thị thông báo cập nhật thành công
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Center(child: Text('Cập nhật thành công'))),
    );
  }

  // Hàm thay đổi màu sắc khi chọn phần tử
  void SetColor(int index) {
    _selectedIndex = index; // Cập nhật chỉ số phần tử đã chọn

    Future.delayed(Duration(milliseconds: 50), () {
      _selectedIndex = null; // Reset lại chỉ số sau một khoảng thời gian ngắn
      if (index == 1) {
        // Kiểm tra nếu phần tử chọn là index 1
        // Hiển thị modal bottom sheet để chỉnh sửa thông tin
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return ChinhSuaThongTin(
              context,
            ); // Gọi màn hình chỉnh sửa thông tin người dùng
          },
        );
      }
    });
  }

  // Hàm khởi tạo trạng thái ban đầu
  @override
  void initState() {
    super.initState();
    _Lay_Thong_Tin_User(); // Lấy thông tin người dùng khi khởi tạo
    SetChieuCao(); // Cài đặt chiều cao ban đầu cho TextField
  }

  // Hàm theo dõi sự kiện focus vào TextField
  void SetChieuCao() {
    _focusNode = FocusNode(); // Khởi tạo FocusNode
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // Kiểm tra nếu TextField có focus
        setState(() {
          chieuCao = 550; // Thay đổi chiều cao khi TextField được focus
        });
      } else {
        setState(() {
          chieuCao = 250; // Đặt lại chiều cao khi TextField mất focus
        });
      }
    });
  }

  // Hàm lấy thông tin người dùng từ Firebase
  void _Lay_Thong_Tin_User() async {
    _result = await _firebauth.GetAllUser(
      widget.email.toString(),
    ); // Lấy thông tin người dùng từ Firebase
    setState(() {
      // Tách chuỗi trả về từ Firebase và lưu vào biến _split
      _split = _result.toString().split('+');
      _text.text =
          _split[2]
              .toString(); // Cập nhật TextEditingController với tên người dùng
    });
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
                  'Sửa thông tin',
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
                  onTap: () async {
                    if (_url != null && _text.text.isNotEmpty) {
                      updateUser(_url.toString(), _text.text.toString());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text('Vui lòng chọn thông tin'),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: AppStyle.textSizeMedium,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: body(),
      ),
    );
  }

  Widget body() {
    return Stack(
      children: [
        // Phần chính của widget với Column chứa các phần tử con
        Column(
          children: [
            Expanded(
              flex: 3, // Chỉ định rằng phần này chiếm 3 phần không gian
              child: Container(
                width:
                    double
                        .infinity, // Chiều rộng của container chiếm toàn bộ màn hình
                height:
                    double
                        .infinity, // Chiều cao của container chiếm toàn bộ màn hình
                color: Colors.green, // Đặt màu nền của container

                child: Center(
                  child: Stack(
                    // Stack để đặt các widget chồng lên nhau
                    children: [
                      // Widget để hiển thị ảnh người dùng
                      Container(
                        width: 80, // Đặt kích thước của container chứa ảnh
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            50,
                          ), // Làm tròn các góc của container
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            50,
                          ), // Làm tròn ảnh bên trong container
                          child: FutureBuilder(
                            future: Future.delayed(
                              Duration(seconds: 2),
                            ), // Delay 2 giây trước khi hiển thị ảnh
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(); // Hiển thị loading khi đang chờ kết quả
                              } else {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    50,
                                  ), // Làm tròn ảnh khi hiển thị
                                  child:
                                      _image == null
                                          ? Image.network(
                                            _split[1], // Nếu không có ảnh từ người dùng, sử dụng ảnh mặc định từ URL
                                            fit:
                                                BoxFit
                                                    .cover, // Đảm bảo ảnh không bị méo
                                          )
                                          : Image.file(
                                            _image!, // Nếu có ảnh từ người dùng, hiển thị ảnh từ File
                                            fit: BoxFit.cover,
                                          ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                      // Nút sửa ảnh, được đặt ở phía dưới bên phải của ảnh
                      Positioned(
                        bottom: 0,
                        right: 25,
                        left: 25,
                        child: GestureDetector(
                          onTap: () {
                            print(
                              'hello Ưolrd',
                            ); // In ra thông báo khi nhấn nút
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                10,
                              ), // Bo tròn các góc của nút
                              color: Colors.white,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                pickImageFromGallery(); // Chọn ảnh từ thư viện khi nhấn nút
                              },
                              child: Text(
                                'Sửa', // Chữ trên nút sửa
                                style: TextStyle(
                                  color: Colors.black, // Màu chữ
                                  fontSize:
                                      AppStyle.textSizeMedium, // Kích thước chữ
                                  fontWeight: FontWeight.w500, // Độ đậm của chữ
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
            Expanded(
              flex: 7, // Phần này chiếm 7 phần không gian còn lại
              child: Column(
                children: [
                  buildTile(1, "Tên"),
                  Divider(height: 1),
                ], // Hiển thị tên và một divider
              ),
            ),
          ],
        ),

        // Nếu đang loading, hiển thị một overlay mờ và loading indicator
        if (isloading)
          Container(
            color: Colors.black54.withOpacity(0.5), // Màu nền mờ
            child: Center(
              child: CircularProgressIndicator(),
            ), // Hiển thị loading spinner
          ),
      ],
    );
  }

  // Tạo một widget tùy chỉnh cho các mục danh sách
  Widget buildTile(int index, String title) {
    return InkWell(
      onTap: () {
        SetColor(index); // Khi nhấn vào mục, gọi hàm SetColor
      },
      child: AnimatedContainer(
        duration: Duration(
          milliseconds: 200,
        ), // Hiệu ứng hoạt hình khi thay đổi màu nền
        color:
            _selectedIndex == index
                ? Colors.grey[300]
                : Colors.white, // Đổi màu khi phần tử được chọn
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600),
          ), // Hiển thị tiêu đề
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 20,
          ), // Hiển thị icon mũi tên ở cuối
        ),
      ),
    );
  }

  // Widget BottomSheet cho việc chỉnh sửa thông tin người dùng
  Widget ChinhSuaThongTin(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16), // Padding cho nội dung bên trong
      height:
          chieuCao, // Chiều cao của BottomSheet, có thể thay đổi khi TextField có focus
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Căn lề bên trái
        children: [
          // Tiêu đề và nút đóng BottomSheet
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Chỉnh sửa thông tin", // Tiêu đề chỉnh sửa thông tin
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Đóng BottomSheet khi nhấn nút Xong
                },
                child: Text(
                  'Xong', // Chữ "Xong" để người dùng hoàn thành chỉnh sửa
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          // TextField cho việc nhập tên người dùng mới
          TextField(
            focusNode: _focusNode, // Gán FocusNode để theo dõi trạng thái focus
            controller: _text, // Gán controller để quản lý nội dung TextField
            decoration: InputDecoration(
              labelText: 'Nhập Tên mới',
            ), // Gợi ý cho người dùng nhập tên mới
          ),
          SizedBox(height: 40),
          // Phần này là comment, nếu cần có thể tạo một nút lưu thông tin
          // Center(
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       minimumSize: Size(100, 40),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       elevation: 5,
          //     ),
          //     onPressed: () {
          //       Navigator.pop(context);  // Đóng bottom sheet khi nhấn nút lưu
          //     },
          //     child: Text(
          //       "Lưu",  // Chữ trên nút lưu
          //       style: TextStyle(fontSize: AppStyle.textSizeMedium),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
