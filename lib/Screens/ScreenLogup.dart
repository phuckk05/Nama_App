import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDangKi extends StatefulWidget {
  @override
  State<GiaoDienDangKi> createState() => _GiaoDienDangKiState();
}

class _GiaoDienDangKiState extends State<GiaoDienDangKi> {
  // Controller cho TextField nhập email
  final sdt = TextEditingController();

  // Controller cho TextField nhập mã xác thực
  final code = TextEditingController();

  // Trạng thái ẩn/hiện ô nhập mã xác thực
  bool _offStateCode = true;

  // Lưu độ dài của email ban đầu
  int? lenghtText;

  // Đối tượng xử lý xác thực (được tạo riêng trong class Firebauth)
  Firebauth _auth = Firebauth();

  /// Gửi email xác thực đến người dùng
  void sendEmailVerification() async {
    String email = sdt.text.toString();

    // Kiểm tra email đã tồn tại chưa (1 = tồn tại, khác 1 = chưa)
    int check = await _auth.checkUsers(email);

    if (check != 1) {
      // Nếu chưa tồn tại: gửi email xác thực
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              'Kiểm tra hộp thư của bạn',
              style: TextStyle(fontSize: AppStyle.paddingMedium),
            ),
          ),
        ),
      );

      setState(() {
        _offStateCode = false; // Hiện ô nhập mã
      });

      _auth.registerWithEmail(email, context); // Gửi email xác thực
    } else {
      // Nếu email đã tồn tại
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Email đã tồn tại !'))),
      );
    }
  }

  // Trạng thái của switch (checkbox) để điều chỉnh màu nút
  bool isCheckSwich = false;

  // Màu icon bên trong TextField
  Color clicon = Colors.white;

  // Màu nền của nút "Tiếp theo"
  Color isColor = Color.fromARGB(114, 220, 220, 220);

  /// Cập nhật màu nút và icon khi có dữ liệu trong TextField
  void CheckColor() {
    if (sdt.text.isNotEmpty) {
      setState(() {
        clicon = Colors.black;
        isColor = Colors.green;
      });
    } else {
      setState(() {
        clicon = Colors.white;
        isColor = Color.fromARGB(114, 220, 220, 220);
      });
    }
  }

  /// Giống như CheckColor, dùng để cập nhật màu động khi thay đổi giá trị
  void CheckValue() {
    if (sdt.text.isNotEmpty) {
      setState(() {
        clicon = Colors.black;
        isColor = Colors.green;
      });
    } else {
      setState(() {
        clicon = Colors.white;
        isColor = Color.fromARGB(114, 220, 220, 220);
      });
    }
  }

  /// Kiểm tra điều kiện trước khi gửi email hoặc xác thực code
  void CheckTiepTheo() {
    final email = sdt.text.trim();

    // Regex kiểm tra có phải Gmail không
    final isGmail = RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(email);

    if (_offStateCode == true) {
      if (!isGmail) {
        // Nếu không đúng định dạng Gmail thì báo lỗi
        setState(() {
          _offStateCode = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Vui lòng nhập đúng định dạng !',
                style: TextStyle(fontSize: AppStyle.paddingMedium),
              ),
            ),
          ),
        );
      } else {
        // Nếu đúng định dạng thì gửi email xác thực
        setState(() {
          lenghtText = sdt.text.length;
        });
        sendEmailVerification();
        XoaCode();
      }
    } else {
      // Nếu đã hiện ô nhập mã thì xác thực mã code
      if (code.text.isNotEmpty) {
        _auth.checkCode(email, code.text.toString(), context);
        Navigator.pop(context); // Trở về sau khi xác thực xong
      }
    }
  }

  /// Xử lý nút clear trong TextField email
  void CheckSuffi() {
    setState(() {
      sdt.clear();
      clicon = Colors.white;
      isColor = Color.fromARGB(114, 220, 220, 220);
      _offStateCode = true; // Ẩn ô nhập mã
    });
  }

  /// Kiểm tra nếu người dùng thay đổi email khác, thì ẩn lại ô nhập code
  void CheckValue2() {
    if (lenghtText != sdt.text.length) {
      _offStateCode = true;
    }
  }

  /// Gọi hàm xóa code sau 60 giây (timeout cho mã xác thực)
  void XoaCode() {
    Timer(Duration(seconds: 60), () {
      _auth.TimeCode(sdt.text.toString()); // Gọi hàm để hết hạn code
    });
  }

  /// Hàm xử lý checkbox/switch đổi màu nút xác nhận
  void CheckBox(bool value) {
    setState(() {
      isCheckSwich = value;
      isColor =
          isCheckSwich ? Colors.green : Color.fromARGB(114, 220, 220, 220);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios, color: Colors.green),
        ),
        title: Text(
          'Đăng Kí',
          style: TextStyle(
            fontSize: AppStyle.textSizeTitle,
            color: AppStyle.textGreenColor,
            fontWeight: FontWeight.bold,
            fontFamily: AppStyle.fontFamily,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: body(),

      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Container(
          height: 70,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Bạn đã có tài khoản?",
                    style: TextStyle(
                      fontSize: AppStyle.paddingMedium,
                      color: AppStyle.textGreenColor,
                    ),
                  ),
                  TextSpan(
                    text: " Đăng nhập ngay",
                    style: TextStyle(
                      fontSize: AppStyle.paddingMedium,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget hiển thị toàn bộ nội dung màn hình đăng ký/xác thực email
  Widget body() {
    return SingleChildScrollView(
      // Cho phép cuộn khi bàn phím hoặc nội dung vượt quá màn hình
      child: Column(
        children: [
          SizedBox(height: 50),

          // Logo chính của ứng dụng
          Center(
            child: Image.asset('lib/Image/logo.jpg', width: 250, height: 60),
          ),

          SizedBox(height: 50),

          // Ô nhập email
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: TextField(
              controller: sdt,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 15),
                prefixIcon: Icon(Icons.email),
                hintText: "Email",
                hintStyle: TextStyle(
                  fontSize: AppStyle.paddingMedium,
                  color: Colors.black,
                ),
                // Nút clear nội dung email
                suffixIcon: IconButton(
                  onPressed: () {
                    CheckSuffi(); // Hàm xử lý clear email + reset trạng thái
                  },
                  icon: Icon(Icons.close, color: clicon),
                ),
              ),
              onChanged: (value) {
                CheckValue(); // Cập nhật màu khi người dùng nhập
                CheckValue2(); // Kiểm tra nếu thay đổi email thì ẩn ô code
              },
              keyboardType: TextInputType.emailAddress,
            ),
          ),

          // Ô nhập mã xác thực (ẩn hiện tùy theo trạng thái)
          Offstage(
            offstage: _offStateCode, // ẩn nếu = true
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40, top: 20),
              child: TextField(
                controller: code,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 15),
                  prefixIcon: Icon(Icons.verified),
                  hintText: "Nhập code",
                  hintStyle: TextStyle(
                    fontSize: AppStyle.paddingMedium,
                    color: AppStyle.textGreenColor,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                  ),
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Chỉ cho nhập số
                  LengthLimitingTextInputFormatter(6), // Giới hạn 6 ký tự
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          // Nút "Tiếp theo"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2,
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {
                  if (sdt.text.isNotEmpty) {
                    isCheckSwich
                        ? CheckTiepTheo() // Nếu đã check đồng ý điều khoản thì tiếp tục
                        : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Center(child: Text('Vui lòng checkbox !')),
                          ),
                        );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text('Vui lòng nhập thông tin !'),
                        ),
                      ),
                    );
                  }
                },
                child: Text(
                  'Tiếp theo',
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Checkbox đồng ý điều khoản
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Checkbox(
                  value: isCheckSwich,
                  onChanged: (value) {
                    CheckBox(value!); // Cập nhật màu khi check
                  },
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Đồng ý với các",
                        style: TextStyle(
                          fontSize: AppStyle.textSizeMedium,
                          color: AppStyle.textGreenColor,
                        ),
                      ),
                      TextSpan(
                        text: " điều khoản",
                        style: TextStyle(
                          fontSize: AppStyle.paddingMedium,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Divider "Hoặc"
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 1,
                  child: Container(color: Colors.blueGrey),
                ),
                Text(
                  ' Hoặc ',
                  style: TextStyle(
                    color: AppStyle.textGreenColor,
                    fontSize: AppStyle.paddingMedium,
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 1,
                  child: Container(color: Colors.blueGrey),
                ),
              ],
            ),
          ),

          // Nút đăng nhập bằng Google
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.textGreenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2,
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    FaIcon(FontAwesomeIcons.google, size: 25),
                    SizedBox(width: 40),
                    Text(
                      'Đăng nhập bằng Google',
                      style: TextStyle(
                        fontSize: AppStyle.paddingMedium,
                        color: Colors.white,
                        fontFamily: AppStyle.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          // Nút đăng nhập bằng Facebook
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.textGreenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2,
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.facebook, size: 25),
                    SizedBox(width: 30),
                    Text(
                      'Đăng nhập bằng Facebook',
                      style: TextStyle(
                        fontSize: AppStyle.paddingMedium,
                        color: Colors.white,
                        fontFamily: AppStyle.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10),

          // Nút đăng nhập bằng Apple
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppStyle.textGreenColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    side: BorderSide(
                      color: Colors.black,
                      width: 2,
                      strokeAlign: 1.0,
                    ),
                  ),
                ),
                onPressed: () {},
                child: Row(
                  children: [
                    FaIcon(FontAwesomeIcons.apple, size: 30),
                    SizedBox(width: 43),
                    Text(
                      'Đăng nhập bằng Apple',
                      style: TextStyle(
                        fontSize: AppStyle.paddingMedium,
                        color: Colors.white,
                        fontFamily: AppStyle.fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
