import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/DataBase/Sqlite.dart';
import 'package:nama_app/Screens/ScreenLogup.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class DangNhap extends StatefulWidget {
  @override
  State<DangNhap> createState() => _DangNhapState();
}

class _DangNhapState extends State<DangNhap> {
  Firebauth _auth = Firebauth();
  SQLiteService _sqLiteService = SQLiteService();
  int? lenghtText;
  final sdt = TextEditingController();
  final code = TextEditingController();
  bool isCheckSwich = false;
  Color clicon = Colors.white;
  Color isColor = Color.fromARGB(114, 220, 220, 220);
  bool _offStateCode = true;
 
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

  void CheckSuffi() {
    setState(() {
      sdt.clear();
      clicon = Colors.white;
      isColor = Color.fromARGB(114, 220, 220, 220);
      _offStateCode = true;
    });
  }

  void CheckValue2() async {
    if (_offStateCode == true) {
      final email = sdt.text.trim();
      final isGmail = RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(email);
      if (!isGmail) {
        setState(() {
          _offStateCode = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Center(
                child: Text(
                  'Vui lòng nhập đúng định dạng',
                  style: TextStyle(fontSize: AppStyle.paddingMedium),
                ),
              ),
            ),
          ),
        );
      } else {
        setState(() {
          lenghtText = sdt.text.length;
          _offStateCode = false;
        });
        int kq = await _auth.CheckLoGin(email, context);
        if (kq == 0) {
          setState(() {
            _offStateCode = true;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Center(child: Text('Email không tồn tại'))),
            );
          });
        } 
        XoaCode();
      }
    } else {
      if (code.text.isNotEmpty) {
        int ketQua = await _auth.checkCodeLogin(
          sdt.text.toString(),
          code.text.toString(),
        );
        if (ketQua == 1) {
          XoaCodeLuon();
          await _sqLiteService.insertUser({"email":sdt.text.toString()});
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProcessSccreen(email: sdt.text.toString(),)),
          );

        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Sai mã xác nhận !')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                'Vui lòng nhập mã',
                style: TextStyle(fontSize: AppStyle.textSizeSmall),
              ),
            ),
          ),
        );
      }
    }
  }

  void CheckValue3() {
    if (lenghtText != sdt.text.length) {
      _offStateCode = true;
    }
  }

  void XoaCode() async {
    Timer(Duration(seconds: 60), () {
      _auth.TimeCode(sdt.text.toString());
    });
  }

  void XoaCodeLuon() async {
    await _auth.TimeCode(sdt.text.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        centerTitle: true,
        leading: Icon(Icons.arrow_back_ios, color: Colors.white),
        title: Text(
          'Đăng Nhập',
          style: TextStyle(
            fontSize: AppStyle.textSizeTitle,
            color: AppStyle.textGreenColor,
            fontWeight: FontWeight.bold,
            fontFamily: AppStyle.fontFamily
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 50),
            Center(
              child: Image.asset('lib/Image/logo.jpg', width: 250, height: 60),
            ),
            SizedBox(height: 50),
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

                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                  // ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      CheckSuffi();
                    },
                    icon: Icon(Icons.close, color: clicon),
                  ),
                ),

                keyboardType: TextInputType.emailAddress,

                onChanged: (value) {
                  CheckValue();
                  CheckValue3();
                },
              ),
            ),

            Offstage(
              offstage: _offStateCode,
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
                      borderRadius: BorderRadius.circular(
                        AppStyle.borderRadius,
                      ),
                    ),
                    // suffixIcon: IconButton(
                    //   onPressed: () {
                    //     setState(() {
                    //       sdt.clear();
                    //       clicon = Colors.white;
                    //       isColor = Color.fromARGB(114, 220, 220, 220);
                    //     });
                    //   },
                    //   icon: Icon(Icons.close, color: clicon),
                    // ),
                  ),
                  onChanged: (value) {},
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,

                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppStyle.borderRadius,
                      ),
                      side: BorderSide(
                        color: Colors.black,
                        width: 2,
                        strokeAlign: 1.0,
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (sdt.text.isNotEmpty) {
                      CheckValue2();
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

            SizedBox(height: 50),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyle.textGreenColor,
                    shape: RoundedRectangleBorder(
                      
                      borderRadius: BorderRadius.circular(
                        AppStyle.borderRadius,
                      ),
                      side: BorderSide(
                        color: Colors.black,
                        width: 2,
                        strokeAlign: 1.0,
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FaIcon(FontAwesomeIcons.google, size: 25,),
                    
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Đăng nhập bằng Google',
                            style: TextStyle(
                              fontSize: AppStyle.paddingMedium,
                              color:Colors.white,
                                 fontFamily: AppStyle.fontFamily,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                            SizedBox(width: 40),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyle.textGreenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppStyle.borderRadius,
                      ),
                      side: BorderSide(
                        color: Colors.black,
                        width: 2,
                        strokeAlign: 1.0,
                      ),
                    ),
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FaIcon(FontAwesomeIcons.facebook, size: 25),
            
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Đăng nhập bằng Facebook',
                            style: TextStyle(
                              fontSize: AppStyle.paddingMedium,
                              color:Colors.white,
                                 fontFamily: AppStyle.fontFamily,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                            SizedBox(width: 25),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyle.textGreenColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppStyle.borderRadius,
                      ),
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
                      SizedBox(width: 35),
                      Text(
                        'Đăng nhập bằng Apple',
                        style: TextStyle(
                          fontSize: AppStyle.paddingMedium,
                          color: Colors.white,
                          fontFamily: AppStyle.fontFamily,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      backgroundColor: Colors.white,
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Container(
          height: 70,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GiaoDienDangKi()),
              );
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "Bạn chưa có tài khoản?",
                    style: TextStyle(
                      fontSize: AppStyle.paddingMedium,
                      color:AppStyle.textGreenColor,
                    ),
                  ),
                  TextSpan(
                    text: " Đăng kí ngay",
                    style: TextStyle(
                      fontSize: AppStyle.paddingMedium,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold
                      
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
}
