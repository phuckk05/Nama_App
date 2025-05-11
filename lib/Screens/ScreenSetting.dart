import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienCaiDat extends StatefulWidget {
  final String? email;
  const GiaoDienCaiDat({super.key, this.email});

  @override
  State<GiaoDienCaiDat> createState() => _GiaoDienCaiDatState();
}

class _GiaoDienCaiDatState extends State<GiaoDienCaiDat> {
  

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
                'Tài khoản',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text('Cài đặt tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppStyle.textSizeMedium),),
          ),
          Column(
            children: [
              SizedBox(height: 10,),
              Divider(height: 1,),
             Container(
              padding: EdgeInsets.only(left: 30, right: 20, top: 0,bottom: 0),
              child:  _buildListile("Đổi tài khoản email"),
             ),
             Divider(height: 1,),
             Container(
              padding: EdgeInsets.only(left: 30, right: 20, top: 0),
              child:  _buildListile("Xóa tải khoản"),
             ),
             Divider(height: 1,),

            ],
          ),
           Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text('Phản hồi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppStyle.textSizeMedium),),
          ),
           Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Text('Version 1.0.0', style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppStyle.textSizeMedium, color: Colors.black54),),
          ),
        ],
      ),
    );
  }
  Widget _buildListile(String title){
    return InkWell(
      onTap: (){
        print('hello w');
      },
      child: ListTile(
        title:Text('$title'),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
