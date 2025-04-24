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
  final sdt = TextEditingController();
  final code = TextEditingController();
  bool _offStateCode = true;
  int? lenghtText;
  Firebauth _auth = Firebauth();

  void sendEmailVerification() async {
    String email = sdt.text.toString();
    int check = await _auth.checkUsers(email);
    if (check != 1) {
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
        _offStateCode = false;
      });
      _auth.registerWithEmail(email, context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Email đã tồn tại !'))),
      );
    }
  }

  bool isCheckSwich = false;
  Color clicon = Colors.white;
  Color isColor = Color.fromARGB(114, 220, 220, 220);

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

  void CheckTiepTheo() {
    final email = sdt.text.trim();

    // Regex kiểm tra có phải Gmail không
    final isGmail = RegExp(r'^[\w-\.]+@gmail\.com$').hasMatch(email);

    if (_offStateCode == true) {
      if (!isGmail) {
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
        setState(() {
          lenghtText = sdt.text.length;
        });
        sendEmailVerification();
        XoaCode();
      }
    } else {
      if (code.text.isNotEmpty) {
        _auth.checkCode(email, code.text.toString(), context);
        Navigator.pop(context);
      }
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

  void CheckValue2() {
    if (lenghtText != sdt.text.length) {
      _offStateCode = true;
    }
  }

  void XoaCode() {
    Timer(Duration(seconds: 60), () {
      _auth.TimeCode(sdt.text.toString());
    });
  }

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
          child: Icon(Icons.arrow_back_ios, color: Colors.green,),
        ),
        title: Text(
          'Đăng Kí',
          style: TextStyle(
            fontSize: AppStyle.textSizeTitle,
            color:AppStyle.textGreenColor,
            fontWeight: FontWeight.bold,
            fontFamily: AppStyle.fontFamily
          ),
        ),
      ),
      backgroundColor: Colors.white,
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
                onChanged: (value) {
                  CheckValue();
                  CheckValue2();
                },
                keyboardType: TextInputType.emailAddress,
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
                      color:AppStyle.textGreenColor,
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
                    if(sdt.text.isNotEmpty){
                     isCheckSwich? CheckTiepTheo() : ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Center(child: Text('Vui lòng checkbox !'))),
                     );
                    }
                    else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Center(child: Text('Vui lòng nhập thông tin !')))
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  Checkbox(value: isCheckSwich, onChanged: (value) {
                    CheckBox(value!);
                  }),
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
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      FaIcon(FontAwesomeIcons.google, size: 25,),
                      SizedBox(width: 40),
                      Text(
                        'Đăng nhập bằng Google',
                        style: TextStyle(
                          fontSize: AppStyle.paddingMedium,
                          color:Colors.white,
                            fontFamily: AppStyle.fontFamily,
                          fontWeight: FontWeight.bold
                        ),
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
                      FaIcon(FontAwesomeIcons.facebook, size: 25),
                      SizedBox(width: 30),
                      Text(
                        'Đăng nhập bằng Facebook',
                        style: TextStyle(
                          fontSize: AppStyle.paddingMedium,
                          color:Colors.white,
                          fontFamily: AppStyle.fontFamily,
                          fontWeight: FontWeight.bold
                        ),
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
                      SizedBox(width: 43),
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
            SizedBox(height: 10),
            
          ],
        ),
      ),

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
                      color:AppStyle.textGreenColor,
                    ),
                  ),
                  TextSpan(
                    text: " Đăng nhập ngay",
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
