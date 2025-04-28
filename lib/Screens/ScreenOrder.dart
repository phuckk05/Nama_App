import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDonHang extends StatefulWidget {
  final String? email;
  final List<DonHang>? listDonHang;
  final List<DonHang>? listDonHangChoGiao;
  final List<DonHang>? listDonHangDaGiao;

  GiaoDienDonHang({super.key, this.email, this.listDonHang, this.listDonHangChoGiao, this.listDonHangDaGiao});

  @override
  State<GiaoDienDonHang> createState() => _GiaoDienDonHangState();
}

class _GiaoDienDonHangState extends State<GiaoDienDonHang>
    with SingleTickerProviderStateMixin {
  Firebauth _firebauth = Firebauth();
  int tienThanhToan = 0;
  String? nameUser;
  List<String> name = [];
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> itemproducts = [];
 
  late TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  //lay thong tin thanh toan
 

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                'Đơn hàng của bạn',
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
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicatorColor: Colors.black,
              labelStyle: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold
              ),
              tabs: [
                Tab(text: 'Xác nhận'),
                Tab(text: 'Chờ giao hàng'),
                Tab(text: 'Đã giao'),
                Tab(text: 'Đánh giá'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                giaoDienChoXacNhan(),
                giaoDienChoGiao(),
                giaoDienDaGiao(), 
                Center(child: Text('Hello 4')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget giaoDienChoXacNhan() {
    return SingleChildScrollView(
      child: Column(
        children: [
          widget.listDonHang!.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
      
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:  widget.listDonHang!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              print( widget.listDonHang![index].id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.house_siding_sharp),
                                        SizedBox(width: 10),
                                         widget.listDonHang!.isNotEmpty
                                            ? Text(
                                              '${ widget.listDonHang![index].nameShop}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              'Đang tải lên...',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              top: 10,
                                              right: 10,
                                              bottom: 10,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ), // Bo tròn ảnh
                                              child:
                                                   widget.listDonHang!.isNotEmpty
                                                      ? Image.network(
                                                        '${ widget.listDonHang![index].imageUrl}',
                                                        fit: BoxFit.fill,
                                                      )
                                                      : Image.asset(
                                                        'lib/Image/nen.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 100,
      
                                            // color: Colors.yellow,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                           widget.listDonHang!.isNotEmpty
                                                              ? Text(
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                '${ widget.listDonHang![index].name}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              )
                                                              : Text(
                                                                'Đang tải lên...',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'x${ widget.listDonHang![index].soLuong}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    widget.listDonHang!.isNotEmpty
                                                        ? Text(
                                                          '${ widget.listDonHang![index].price} đ',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                        : Text(
                                                          'Đang tải lên...',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    // Text('x${widget.soLuong}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Tổng số tiền (${ widget.listDonHang![index].soLuong} sản phẩm):',
                                          ),
                                          Text(
                                            ' ${ widget.listDonHang![index].price} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppStyle.textSizeMedium,
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Trạng thái đơn hàng',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                              color: Colors.green,
                                            ),
                                            child: Text(
                                              '${ widget.listDonHang![index].status}',
                                              style: TextStyle(
                                                fontSize: AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có đơn hàng nào cả ! ',
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
              ),
      
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            child: Text(
              ' - Có thể bạn cũng thích - ',
              style: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
  //tab chờ giao
   Widget giaoDienChoGiao() {
    return SingleChildScrollView(
      child: Column(
        children: [
           widget.listDonHangChoGiao!.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
      
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:  widget.listDonHangChoGiao!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              print(widget.listDonHangChoGiao![index].id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.house_siding_sharp),
                                        SizedBox(width: 10),
                                         widget.listDonHangChoGiao!.isNotEmpty
                                            ? Text(
                                              '${widget.listDonHangChoGiao![index].nameShop}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              'Đang tải lên...',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              top: 10,
                                              right: 10,
                                              bottom: 10,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ), // Bo tròn ảnh
                                              child:
                                                   widget.listDonHangChoGiao!.isNotEmpty
                                                      ? Image.network(
                                                        '${widget.listDonHangChoGiao![index].imageUrl}',
                                                        fit: BoxFit.fill,
                                                      )
                                                      : Image.asset(
                                                        'lib/Image/nen.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 100,
      
                                            // color: Colors.yellow,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                           widget.listDonHangChoGiao!.isNotEmpty
                                                              ? Text(
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                '${widget.listDonHangChoGiao![index].name}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              )
                                                              : Text(
                                                                'Đang tải lên...',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'x${widget.listDonHangChoGiao![index].soLuong}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                     widget.listDonHangChoGiao!.isNotEmpty
                                                        ? Text(
                                                          '${widget.listDonHangChoGiao![index].price} đ',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                        : Text(
                                                          'Đang tải lên...',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    // Text('x${widget.soLuong}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Tổng số tiền (${widget.listDonHangChoGiao![index].soLuong} sản phẩm):',
                                          ),
                                          Text(
                                            ' ${widget.listDonHangChoGiao![index].price} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppStyle.textSizeMedium,
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Trạng thái đơn hàng',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                              color: Colors.green,
                                            ),
                                            child: Text(
                                              '${widget.listDonHangChoGiao![index].status}',
                                              style: TextStyle(
                                                fontSize: AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có đơn hàng nào cả ! ',
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
              ),
      
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            child: Text(
              ' - Có thể bạn cũng thích - ',
              style: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }


  //tab đã giao
   Widget giaoDienDaGiao() {
    return SingleChildScrollView(
      child: Column(
        children: [
           widget.listDonHangDaGiao!.isNotEmpty
              ? Padding(
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 0, top: 10),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 0),
      
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                        physics: NeverScrollableScrollPhysics(),
                        itemCount:  widget.listDonHangDaGiao!.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              print(widget.listDonHangDaGiao![index].id);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: 10,
                                  right: 10,
                                  top: 10,
                                  bottom: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.house_siding_sharp),
                                        SizedBox(width: 10),
                                         widget.listDonHangDaGiao!.isNotEmpty
                                            ? Text(
                                              '${widget.listDonHangDaGiao![index].nameShop}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                            : Text(
                                              'Đang tải lên...',
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Container(
                                          height: 120,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 0,
                                              top: 10,
                                              right: 10,
                                              bottom: 10,
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ), // Bo tròn ảnh
                                              child:
                                                   widget.listDonHangDaGiao!.isNotEmpty
                                                      ? Image.network(
                                                        '${ widget.listDonHangDaGiao![index].imageUrl}',
                                                        fit: BoxFit.fill,
                                                      )
                                                      : Image.asset(
                                                        'lib/Image/nen.png',
                                                        fit: BoxFit.cover,
                                                      ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 100,
      
                                            // color: Colors.yellow,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child:
                                                           widget.listDonHangDaGiao!.isNotEmpty
                                                              ? Text(
                                                                maxLines: 3,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                '${widget.listDonHangDaGiao![index].name}',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              )
                                                              : Text(
                                                                'Đang tải lên...',
                                                                style: TextStyle(
                                                                  color:
                                                                      Colors
                                                                          .black87,
                                                                  fontFamily:
                                                                      AppStyle
                                                                          .fontFamily,
                                                                ),
                                                              ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                        'x${widget.listDonHangDaGiao![index].soLuong}',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                     widget.listDonHangDaGiao!.isNotEmpty
                                                        ? Text(
                                                          '${widget.listDonHangDaGiao![index].price} đ',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        )
                                                        : Text(
                                                          'Đang tải lên...',
                                                          style: TextStyle(
                                                            color: Colors.red,
                                                            fontFamily:
                                                                AppStyle
                                                                    .fontFamily,
                                                            fontSize:
                                                                AppStyle
                                                                    .textSizeMedium,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                    // Text('x${widget.soLuong}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Tổng số tiền (${widget.listDonHangDaGiao![index].soLuong} sản phẩm):',
                                          ),
                                          Text(
                                            ' ${widget.listDonHangDaGiao![index].price} đ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: AppStyle.textSizeMedium,
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Divider(),
                                    SizedBox(height: 5),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Trạng thái đơn hàng',
                                            style: TextStyle(
                                              fontSize: AppStyle.textSizeMedium,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                              color: Colors.green,
                                            ),
                                            child: Text(
                                              '${widget.listDonHangDaGiao![index].status}',
                                              style: TextStyle(
                                                fontSize: AppStyle.textSizeMedium,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
              : Container(
                height: 200,
                child: Center(
                  child: Text(
                    'Không có đơn hàng nào cả ! ',
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                ),
              ),
      
          Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            child: Text(
              ' - Có thể bạn cũng thích - ',
              style: TextStyle(
                fontSize: AppStyle.textSizeMedium,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
