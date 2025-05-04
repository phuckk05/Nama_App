import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Models/Review.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDanhGia extends StatefulWidget {
  final List<DonHang>? listDanhGia;
  final int? index;
  final String? email;
  const GiaoDienDanhGia({super.key, this.listDanhGia, this.index, this.email});

  @override
  State<GiaoDienDanhGia> createState() => _GiaoDienDanhGiaState();
}

class _GiaoDienDanhGiaState extends State<GiaoDienDanhGia> {
  Firebauth _firebauth = Firebauth();
  int selectedStar = 0;
  String selectedOption = 'Tốt';
  final feedbackController = TextEditingController();


  Color colorGrey1 = Colors.grey;
  Color colorGrey2 = Colors.grey;
  Color colorGrey3 = Colors.grey;
  Color colorGrey4 = Colors.grey;
  Color colorGrey5 = Colors.grey;

  void SetColor(int index) {
    setState(() {
      selectedStar = index;
      colorGrey1 = index >= 1 ? Colors.amberAccent : Colors.grey;
      colorGrey2 = index >= 2 ? Colors.amberAccent : Colors.grey;
      colorGrey3 = index >= 3 ? Colors.amberAccent : Colors.grey;
      colorGrey4 = index >= 4 ? Colors.amberAccent : Colors.grey;
      colorGrey5 = index >= 5 ? Colors.amberAccent : Colors.grey;
    });
  }

  void saveReview(Review review) async{
    if(selectedOption.isNotEmpty && feedbackController.text.isNotEmpty && selectedStar != 0){
      _firebauth.SaveReview(review);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Center(child: Text('Lưu đánh giá thành công')))
    );
    await _firebauth.updateDonHangdaDuocDanhGia(widget.listDanhGia![widget.index!].id);
    Navigator.pop(context, true);
    }else{
        ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Center(child: Text('Vui lòng nhập đánh giá')))
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Đánh giá',
          style: GoogleFonts.robotoSlab(
            fontSize: AppStyle.textSizeTitle,
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 10, 
              color: Colors.grey,
            ),
            Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Column(
                
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  // Tên sản phẩm
                  Row(
                    children: [
                      Text(
                        'Tên sản phẩm : ',
                        style: TextStyle(color: Colors.black54, fontSize: AppStyle.textSizeMedium),
                      ),
                                 
                     Expanded(child:  Text(
                      maxLines: 1, 
                      overflow: TextOverflow.ellipsis,
                        widget.listDanhGia![widget.index!].name,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: AppStyle.textSizeMedium,
                        ),
                      ),)
                    ],
                  ),
                  SizedBox(height: 20),
              
                  // Đánh giá sao
                  Text(
                    'Bạn đánh giá sản phẩm này mấy sao?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: AppStyle.textSizeMedium),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => SetColor(1),
                        icon: Icon(Icons.star, size: 32, color: colorGrey1),
                      ),
                      IconButton(
                        onPressed: () => SetColor(2),
                        icon: Icon(Icons.star, size: 32, color: colorGrey2),
                      ),
                      IconButton(
                        onPressed: () => SetColor(3),
                        icon: Icon(Icons.star, size: 32, color: colorGrey3),
                      ),
                      IconButton(
                        onPressed: () => SetColor(4),
                        icon: Icon(Icons.star, size: 32, color: colorGrey4),
                      ),
                      IconButton(
                        onPressed: () => SetColor(5),
                        icon: Icon(Icons.star, size: 32, color: colorGrey5),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
              
                  // Dropdown đánh giá
                  Text(
                    'Loại đánh giá:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedOption,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                    items: [
                      'Tốt',
                      'Trung bình',
                      'Tệ',
                    ].map((label) => DropdownMenuItem(
                      child: Text(label),
                      value: label,
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOption = value!;
                      });
                    },
                  ),
                  SizedBox(height: 20),
              
                  // Ô nhập phản hồi
                  Text(
                    'Phản hồi của bạn:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: feedbackController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung phản hồi...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      fillColor: Colors.white,
                      filled: true,
                    ),
                  ),
                  SizedBox(height: 30),
              
                  // Nút Lưu đánh giá
                  Center(
                    child: ElevatedButton.icon(
                      
                      onPressed: (){
                        String id = _firebauth.generateVerificationCode(5);
                        Review review = Review(id: id, email: widget.email.toString(), idProducts: widget.listDanhGia![widget.index!].idProducts,idOrder:widget.listDanhGia![widget.index!].id  , start: selectedStar,slelect: selectedOption.toString(),   review: feedbackController.text.toString(),nameBuy: "hello");
                        saveReview(review);
                      },
                      icon: Icon(Icons.save),
                      label: Text('Lưu đánh giá', style: TextStyle(
                        fontWeight: FontWeight.bold
                      ),),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
