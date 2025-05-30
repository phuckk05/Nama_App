import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/Sqlite.dart';
import 'package:nama_app/Screens/ScreenLogin.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';

class GiaoDienBatDau extends StatelessWidget{
  SQLiteService _sqLiteService = SQLiteService();
  void checkUser(BuildContext context) async{
    String? reslut = await _sqLiteService.getUserEmail();
    if(reslut != null){
      Navigator.push(context, MaterialPageRoute(builder: (context) => ProcessSccreen(email: reslut)));
    }
    else{
       Navigator.push(context, MaterialPageRoute(builder: (context) => DangNhap()));
    }
  }
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 5),(){
       checkUser(context);
         
    });
   return Scaffold(
     body: Center(child: Image.asset('lib/Image/logonama.jpg', width: 200, height: 50,)),
   );
  }

}