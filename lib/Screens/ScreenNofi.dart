import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienThongBao extends StatefulWidget {
  final String? email;
  final  List<Map<String, dynamic>>? items ;
   final List<Map<String, dynamic>>? itemsBuy;
    const GiaoDienThongBao({Key? key, this.email, this.items, this.itemsBuy}) : super(key: key);

  @override
  State<GiaoDienThongBao> createState() => _GiaoDienThongBaoState();
}

class _GiaoDienThongBaoState extends State<GiaoDienThongBao> {
  Firebauth _firebauth = Firebauth();
  int flexTren = 1;
  int flexDuoi = 9;

  //set flex
  void SetFlex() {
    // print(widget.items.length);
    if (widget.items!.length == 1) {
      setState(() {
        flexTren =1;
        flexDuoi =7;
      });
    }else if(widget.items!.length == 2){
     setState(() {
        flexTren =3;
        flexDuoi =9;
      });
    } 
    else if(widget.items!.length == 3){
       setState(() {
        flexTren = 3;
        flexDuoi = 5;
      });
    } else if (widget.items!.length >= 4){
       setState(() {
        flexTren = 5;
        flexDuoi = 5;
      });
    }
    else{
       setState(() {
        flexTren = 1;
        flexDuoi = 9;
      });
    }
   
  }

  @override
  void initState() {
    super.initState();
    // layThongTin();
       SetFlex();
       setState(() { });
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.email);
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
                  // Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text(
                  'Thông báo',
                   style: GoogleFonts.robotoSlab(
                    fontSize: AppStyle.textSizeTitle,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
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
        children: [
          Container(
            width: double.infinity,
            height: 40,

            decoration: BoxDecoration(color: Colors.grey[400]),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Thông báo sản phẩm đăng bán',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    'Xem đơn đặt hàng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(flex: flexTren, child: _danhSachThongBaoSanPham()),
          Container(
            width: double.infinity,
            height: 40,

            decoration: BoxDecoration(color: Colors.grey[400]),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Cập nhật đơn đặt hàng',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    children: [
                      // Text(
                      //   'Quản lý',
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.blue,
                      //   ),
                      // ),
                      SizedBox(width: 20),
                      Text(
                        'Xem đơn hàng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: flexDuoi, child: _ThongTinDonDatHang()),
        ],
      ),
    );
  }

  //danh sach sản phẩm
  Widget _danhSachThongBaoSanPham() {
    return widget.items!.isNotEmpty
        ? ListView.builder(
          itemCount: widget.items!.length,
          itemBuilder: (context, index) {
            String createdAtString = widget.items![index]['createdAt'];

            // Chuyển đổi chuỗi createdAt thành DateTime
            DateTime createdAt = DateFormat(
              'yyyy-MM-dd HH:mm:ss',
            ).parse(createdAtString);
            DateTime currentDateTime = DateTime.now();
            Duration difference = currentDateTime.difference(createdAt);

            // Kiểm tra thời gian khác biệt
            String displayTime;
            if (difference.inMinutes < 60) {
              displayTime = "${difference.inMinutes} phút trước";
            } else if (difference.inHours < 24) {
              displayTime = "${difference.inHours} giờ trước";
            } else {
              displayTime = "${difference.inDays} ngày trước";
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 10, right: 10),
                  child: Container(
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black54, // màu đổ bóng
                          blurRadius: 10, // độ mờ của bóng
                          offset: Offset(0, 2), // đẩy bóng xuống dưới
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: InkWell(
                          onTap: () {
                            // print(items[index]['idOrder']);
                          },
                          child: Row(
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    widget.items!.isNotEmpty
                                        ? TextSpan(
                                          text:
                                              "${widget.items![index]['userNameBuy']}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        )
                                        : TextSpan(
                                          text: "Đang tải lên...",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                    TextSpan(
                                      text: " đã đặt sản phẩm của bạn ",
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    widget.items!.isNotEmpty
                                        ? TextSpan(
                                          text: " $displayTime",
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        )
                                        : TextSpan(
                                          text: "Đang tải lên...",
                                          style: TextStyle(
                                            color: Colors.black26,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              SizedBox(
                                width: 100,
                                child: FloatingActionButton(
                                  mini: true,
                                  elevation: 5,
                                  onPressed: () {
                                    // print(items[index]['createdAt']);
                                  },
                                  child: Text('Xóa'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        )
        : Container(
          height: 100,
          child: Center(child: Text('Không có thông báo !')),
        );
  }

  Widget _ThongTinDonDatHang() {
    return ListView.builder(
      itemCount: widget.itemsBuy!.length,
      itemBuilder: (context, index) {
        String createdAtString = widget.itemsBuy![index]['createdAt'];

        // Chuyển đổi chuỗi createdAt thành DateTime
        DateTime createdAt = DateFormat(
          'yyyy-MM-dd HH:mm:ss',
        ).parse(createdAtString);
        DateTime currentDateTime = DateTime.now();
        Duration difference = currentDateTime.difference(createdAt);

        // Kiểm tra thời gian khác biệt
        String displayTime;
        if (difference.inMinutes < 60) {
          displayTime = "${difference.inMinutes} phút trước";
        } else if (difference.inHours < 24) {
          displayTime = "${difference.inHours} giờ trước";
        } else {
          displayTime = "${difference.inDays} ngày trước";
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5, left: 0, right: 0),
              child: Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black54, // màu đổ bóng
                      blurRadius: 1, // độ mờ của bóng
                      offset: Offset(0, 1), // đẩy bóng xuống dưới
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Sản phẩm : ',
                            style: TextStyle(
                              fontSize: AppStyle.textSizeMedium,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Expanded(
                            flex: 9,
                            child: Text(
                               maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              '${widget.itemsBuy![index]['name']} ',
                              style: TextStyle(
                                fontSize: AppStyle.textSizeMedium,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                         Expanded(
                          flex: 1,
                            child: Text(
                               maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              '(x${widget.itemsBuy![index]['soLuong']})',
                              style: TextStyle(fontSize: AppStyle.textSizeSmall),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                if (widget.itemsBuy![index]['status'] == "Chờ xác nhận")
                                  TextSpan(
                                    text: "Đang chờ xác nhận",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else if (widget.itemsBuy![index]['status'] ==
                                    "Chờ giao")
                                  TextSpan(
                                    text: "Đơn hàng của bạn đang vận chuyển",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else if (widget.itemsBuy![index]['status'] == "Hủy")
                                  TextSpan(
                                    text: "Đơn hàng của bạn đã bị hủy",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else if (widget.itemsBuy![index]['status'] == "Đã giao")
                                  TextSpan(
                                    text: "Đơn hàng của bạn đã được giao",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // SizedBox(width: 10),
                          // SizedBox(
                          //   width: 100,
                          //   child: FloatingActionButton(
                          //     mini: true,
                          //     elevation: 5,
                          //     onPressed: () {},
                          //     child: Text('Xóa'),
                          //   ),
                          // ),
                          Text(
                            '$displayTime',
                            style: TextStyle(
                              color: Colors.black26,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
