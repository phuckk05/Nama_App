import 'package:flutter/material.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
class Type extends StatefulWidget {
  final String name;
  final String image;
   const Type({
    super.key, required this.name, required this.image
  });

  @override
  State<Type> createState() => _TypeState();
}

class _TypeState extends State<Type> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 100, // Kích thước của SizedBox
            height: 100,
            child: Column(
              
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[

              
                // Đặt ảnh lên trên
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom:5 ),
                    child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.black54, // Màu viền
                        width: 1, // Độ rộng viền
                      ),
                    ),
                    child: ClipOval(
                      child: Image.network(widget.image, 
                      width: 40,
                      height: 40,
                      fit: BoxFit.fill,
                    ),
                    ),
                                    ),
                  ),),
                // Đặt tiêu đề dưới ảnh
               
               Expanded(
                flex: 4,
                child: Container(
                  width: 70,
                  // height: 40,
                  child: Center(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),)
              ],
            ),
          ),
       
        ],
      ),
    );
  }
}
