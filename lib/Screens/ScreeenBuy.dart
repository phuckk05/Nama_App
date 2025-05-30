import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Screens/ScreenSelectAddress.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienMuaSanPham extends StatefulWidget {
  final String? email;
  final String? idProducts;
  final int? soLuong;
  final List<Map<String, dynamic>>? listCart;
  GiaoDienMuaSanPham({
    super.key,
    this.email,
    this.idProducts,
    this.soLuong,
    this.listCart,
  });

  @override
  State<GiaoDienMuaSanPham> createState() => _GiaoDienMuaSanPhamState();
}

class _GiaoDienMuaSanPhamState extends State<GiaoDienMuaSanPham> {
  Firebauth _firebauth = Firebauth();
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> itemproducts = [];
  String? nameUser;
  List<String> name = [];
  int tienThanhToan = 0;
  bool loading = false;
  int deLay = 3;
  bool offStateLaoding = false;
  bool offStateOrder = true;
  int tongTienHang = 0;
  int tongThanhToan = 0;
  bool isloading = false;
  bool back = false;
  @override
  void initState() {
    super.initState();
    LayDiaChi();
    LayThonTinDonHang();
  }

  //lấy địa chỉ được chọn
  void LayDiaChi() async {
    items = await _firebauth.GetAddressSelected(widget.email.toString());
    setState(() {});
  }

  //lây thông tin đơn hàng
  void LayThonTinDonHang() async {
    if (widget.listCart == null || widget.listCart!.isEmpty) {
      nameUser = await _firebauth.showProducts(
        widget.idProducts.toString(),
        itemproducts,
      );
      name = nameUser!.split(':');

      for (int i = 0; i < itemproducts.length; i++) {
        tienThanhToan = int.tryParse(itemproducts[i]['price'].toString())!;
        tongTienHang =
            int.tryParse(itemproducts[i]['price'].toString())! *
            widget.soLuong!;
      }
      tienThanhToan = (tienThanhToan * widget.soLuong!) + 30000;

      setState(() {});
    } else {}
  }

  //set offstate
  void setOffState1() async {
    setState(() {
      offStateLaoding = true;
      offStateOrder = false;
    });
  }

  void setOffState2() {
    setState(() {
      offStateLaoding = false;
      offStateOrder = true;
    });
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
                  if (back) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ProcessSccreen(email: widget.email.toString()),
                      ),
                      (route) => false,
                    );
                  } else {
                    Navigator.pop(context, true);
                  }
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
                'Thanh toán',
                style: TextStyle(
                  fontSize: AppStyle.textSizeTitle,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
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
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    final ketQua = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => GiaoDienChonDiaChi(
                              email: widget.email.toString(),
                            ),
                      ),
                    );
                    if (ketQua != null) {
                      LayDiaChi();
                      // items.clear();
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Row(
                        children: [
                          Expanded(
                            flex: 8,
                            child:
                                items.isNotEmpty
                                    ? Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 10),
                                            items.isNotEmpty
                                                ? Text(
                                                  '${items[0]['name']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                )
                                                : Text(
                                                  'Đang tải lên...',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                            SizedBox(width: 5),
                                            items.isNotEmpty
                                                ? Text(
                                                  '${items[0]['telephone']}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.grey,
                                                  ),
                                                )
                                                : Text(
                                                  'Đang tải lên...',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 35,
                                            right: 0,
                                          ),
                                          child:
                                              items.isNotEmpty
                                                  ? Text(
                                                    '${items[0]['address']}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  )
                                                  : Text(
                                                    'Đang tải lên...',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                        ),
                                      ],
                                    )
                                    : Center(
                                      child: Text(
                                        'Chưa có địa chỉ !',
                                        style: TextStyle(
                                          fontSize: AppStyle.textSizeMedium,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Container(
                    padding: EdgeInsets.all(10),
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
                            Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              'Danh sách đơn hàng',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        widget.listCart == null || widget.listCart!.isEmpty
                            ? ListView.builder(
                              shrinkWrap:
                                  true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
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
                                              itemproducts.isNotEmpty
                                                  ? Image.network(
                                                    itemproducts[index]['imageUrl'],
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
                                            itemproducts.isNotEmpty
                                                ? Text(
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  '${itemproducts[index]['description'].toString()}',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontFamily:
                                                        AppStyle.fontFamily,
                                                  ),
                                                )
                                                : Text(
                                                  'Đang tải lên...',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontFamily:
                                                        AppStyle.fontFamily,
                                                  ),
                                                ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                itemproducts.isNotEmpty
                                                    ? Text(
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      '${itemproducts[index]['price'].toString()}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontFamily:
                                                            AppStyle.fontFamily,
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
                                                            AppStyle.fontFamily,
                                                        fontSize:
                                                            AppStyle
                                                                .textSizeMedium,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                Text('x${widget.soLuong}'),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            )
                            : ListView.builder(
                              shrinkWrap:
                                  true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.listCart!.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: [
                                    Container(
                                      height: 120,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
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
                                              widget.listCart!.isNotEmpty
                                                  ? Image.network(
                                                    widget
                                                        .listCart![index]['imageUrl'],
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
                                            widget.listCart!.isNotEmpty
                                                ? Text(
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  '${widget.listCart![index]['description'].toString()}',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontFamily:
                                                        AppStyle.fontFamily,
                                                  ),
                                                )
                                                : Text(
                                                  'Đang tải lên...',
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontFamily:
                                                        AppStyle.fontFamily,
                                                  ),
                                                ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                widget.listCart!.isNotEmpty
                                                    ? Text(
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      '${widget.listCart![index]['price'].toString()}',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontFamily:
                                                            AppStyle.fontFamily,
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
                                                            AppStyle.fontFamily,
                                                        fontSize:
                                                            AppStyle
                                                                .textSizeMedium,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                Text(
                                                  'x${widget.listCart![index]['total']}',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Phương thức thanh toán',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: AppStyle.textSizeMedium,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Thanh toán khi nhận hàng',
                                style: TextStyle(color: Colors.black87),
                              ),
                              Icon(Icons.check, color: Colors.green),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10, right: 10, bottom: 100),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            'Chi tiết thanh toán',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: AppStyle.textSizeMedium,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),

                          child:
                              widget.listCart == null ||
                                      widget.listCart!.isEmpty
                                  ? Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              'Tổng tiền hàng',
                                              style: TextStyle(
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '${tienThanhToan} đ',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontFamily: AppStyle.fontFamily,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                  : Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Tổng tiền hàng',
                                          style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: ListView.builder(
                                          physics:
                                              AlwaysScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: widget.listCart!.length,
                                          itemBuilder: (context, index) {
                                            tongThanhToan +=
                                                (int.tryParse(
                                                      widget
                                                          .listCart![index]['price']
                                                          .toString(),
                                                    )! +
                                                    30000) *
                                                int.tryParse(
                                                  widget
                                                      .listCart![index]['total']
                                                      .toString(),
                                                )!;
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Sản phẩm ${index + 1}',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${(int.tryParse(widget.listCart![index]['price'].toString())! + 30000) * int.tryParse(widget.listCart![index]['total'].toString())!} đ',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                        fontFamily:
                                                            AppStyle.fontFamily,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Chi phí vận chuyển',
                              style: TextStyle(color: Colors.black87),
                            ),
                            Text(
                              '30000 đ/1 đơn hàng',
                              style: TextStyle(
                                color: Colors.red,
                                fontFamily: AppStyle.fontFamily,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tổng thanh toán',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              '${tongThanhToan + tienThanhToan} đ',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isloading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            color: Colors.white,
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Tổng cộng : ",
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text: "${tienThanhToan + tongThanhToan} đ",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: AppStyle.textSizeMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: () async {
                      if (items.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Bạn chưa có địa chỉ !')),
                        );
                      } else {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return _Warning(context);
                          },
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Đặt hàng',
                            style: TextStyle(
                              fontSize: AppStyle.textSizeMedium,
                              color: Colors.white,
                            ),
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
    );
  }

  Widget _Warning(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setStateFul) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isloading) Center(child: CircularProgressIndicator()),
                if (!isloading)
                  Icon(Icons.question_mark, color: Colors.green, size: 60),
                const SizedBox(height: 16),
                Text(
                  'vui lòng xác nhận đặt hàng!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppStyle.fontFamily,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Quay lại',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (widget.listCart == null ||
                              widget.listCart!.isEmpty) {
                            String result = await _firebauth.upDateProduct(
                              itemproducts[0]['id'],
                              widget.soLuong.toString(),
                              context,
                            );
                            if (result == "ok") {
                              setStateFul(() {
                                isloading = true;
                              });

                              await Future.delayed(Duration(seconds: 2));
                              String id = await _firebauth
                                  .generateVerificationCode(10);
                              final now = DateTime.now();
                              DonHang _donhang = DonHang(
                                id: id,
                                idProducts: itemproducts[0]['id'],
                                name: itemproducts[0]['name'],
                                nameShop: name[0].toString(),
                                soLuong: widget.soLuong.toString(),
                                imageUrl: itemproducts[0]['imageUrl'],
                                address: items[0]['id'],
                                emailSell: itemproducts[0]['email'],
                                emailBuy: widget.email.toString(),
                                createdAt: now.toString(),
                                price: itemproducts[0]['price'],
                                priceAll: tienThanhToan.toString(),
                                status: "Chờ xác nhận",
                                hidenBuy: false,
                                hidenSell: false,
                              );
                              await _firebauth.saveOrder(_donhang);

                              setOffState1();

                              setStateFul(() {
                                isloading = false;
                              });
                              Navigator.of(context).pop();
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return datHangThanhCong(context);
                                },
                              );
                            } else {
                              Navigator.of(context).pop();
                            }
                          } else {
                            setStateFul(() {
                              isloading = true;
                            });

                            for (int i = 0; i < widget.listCart!.length; i++) {
                              int tongTien =
                                  (int.tryParse(
                                        widget.listCart![i]['price'].toString(),
                                      )! +
                                      30000) *
                                  int.tryParse(
                                    widget.listCart![i]['total'].toString(),
                                  )!;
                              String id = await _firebauth
                                  .generateVerificationCode(10);
                              await _firebauth.deleteCarts(widget.listCart!);
                              await _firebauth.updateTotal(widget.listCart!);
                              final now = DateTime.now();
                              DonHang _donhang = DonHang(
                                id: id,
                                idProducts: widget.listCart![i]['idProduct'],
                                name: widget.listCart![i]['name'],
                                nameShop: "hello",
                                soLuong:
                                    widget.listCart![i]['total'].toString(),
                                imageUrl: widget.listCart![i]['imageUrl'],
                                address: items[0]['id'],
                                emailSell: widget.listCart![i]['email'],
                                emailBuy: widget.email.toString(),
                                createdAt: now.toString(),
                                price: widget.listCart![i]['price'],
                                priceAll: tongTien.toString(),
                                status: "Chờ xác nhận",
                                hidenBuy: false,
                                hidenSell: false,
                              );
                              await _firebauth.saveOrder(_donhang);
                            }

                            setOffState1();
                            setStateFul(() {
                              isloading = false;
                            });
                            setState(() {
                              back = true;
                            });
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) {
                                return datHangThanhCong(context);
                              },
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Xác nhận',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget datHangThanhCong(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Stack(
        children: [
          Offstage(
            offstage: offStateLaoding,
            child: Container(
              height: 210,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          Offstage(
            offstage: offStateOrder,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, color: Colors.green, size: 60),
                  const SizedBox(height: 16),
                  Text(
                    'Bạn đã đặt hàng thành công',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppStyle.fontFamily,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ProcessSccreen(
                                      email: widget.email.toString(),
                                    ),
                              ),
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Trang chủ',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setOffState2();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Xác nhận',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
