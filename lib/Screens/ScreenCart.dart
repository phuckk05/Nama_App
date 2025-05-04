import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Screens/ScreeenBuy.dart';
import 'package:nama_app/Screens/ScreenAccount.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienGioHang extends StatefulWidget {
  final String? email;
  final String? id;
  const GiaoDienGioHang({Key? Key, this.email, this.id}) : super(key: Key);

  @override
  State<GiaoDienGioHang> createState() => _GiaoDienGioHangState();
}

class _GiaoDienGioHangState extends State<GiaoDienGioHang> {
  Firebauth _firebauth = Firebauth();
  bool isCheckBox = false;
  bool isAny = false;
  bool _offStateContener = true;
  String textSua = "Sửa";
  int setFlex = 1;
  int flexConter = 3;
  //list danh sách sản phẩm được add vào giỏ hàng
  List<Map<String, dynamic>> items = [];
  //list danh sách sản phẩm được add vào giỏ hàng
  List<Map<String, dynamic>> itemsbuy = [];
  List<Map<String, dynamic>> itemsCheck = [];
  List<Map<String, dynamic>> itemsSl = [];
  void truSoluong(int index) {
    int? a = int.tryParse(itemsSl[index]['sl$index'].toString());
    if (a != null && a > 1) {
      a = a - 1;
      itemsSl[index] = {"sl$index": a.toString()};
      setState(() {});
    }
  }

  void congSoluong(int index) {
    int? a = int.tryParse(itemsSl[index]['sl$index'].toString());
    if (a != null) {
      a = a + 1;
      itemsSl[index] = {"sl$index": a.toString()};
      setState(() {});
    }
  }

  void CheckBox(bool value, List<Map<String, dynamic>> list) {
    list.clear();
    for (int i = 0; i < items.length; i++) {
      list.add({"check$i": value});
    }
    setState(() {
      isCheckBox = value;
    });
  }

  //hàm check box
  void CheckBoxAny(bool value, int index, List<Map<String, dynamic>> list) {
    // Nếu danh sách rỗng, khởi tạo với false
    if (list.length != items.length) {
      list.clear();
      for (int i = 0; i < items.length; i++) {
        list.add({"check$i": false});
      }
    }

    // Cập nhật giá trị checkbox tại vị trí index
    list[index] = {"check$index": value};

    setState(() {});
  }

  //lấy giỏ hàng mua ngay
  void BuyNow() async {
    itemsbuy.clear();

    for (int i = 0; i < itemsCheck.length; i++) {
      if (itemsCheck[i]['check$i'] == true) {
        itemsbuy.add(items[i]);
        itemsbuy.last['total'] = itemsSl[i]["sl$i"];
        print('so luong :  ${itemsbuy.last['total']}');
      }
    }

    // Chỉ gọi 1 lần sau khi xử lý xong
    if (mounted) {
      setState(() {});
    }

    if (itemsbuy.isNotEmpty) {
      String checkTotal = await _firebauth.checkTotal(itemsbuy);
      if (checkTotal == "ok") {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    GiaoDienMuaSanPham(email: widget.email, listCart: itemsbuy),
          ),
        );
        if (result == true) {
          // Duyệt ngược để tránh lỗi khi xóa phần tử trong danh sách
          for (int i = items.length - 1; i >= 0; i--) {
            for (var item in itemsbuy) {
              if (item['idCart'] == items[i]['idcart']) {
                items.removeAt(i);
                itemsSl.removeAt(i);
                break; // thoát vòng lặp itemsbuy sau khi xóa để tránh lỗi
              }
            }
          }

          if (mounted) setState(() {});
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Center(child: Text('Số lượng sản phẩm có hạn !'))),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Vui lòng chọn sản phẩm !')));
    }
  }

  //xóa giỏ hàng
  void Sua() {
    setState(() {
      if (textSua == "Sửa") {
        textSua = "Xong";
        _offStateContener = false;
        setFlex = 7;
      } else {
        textSua = "Sửa";
        _offStateContener = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    laySanPham();
  }

  //lấy sản phẩm và số lượng đơn hàng
  void laySanPham() async {
    await _firebauth.getSaveCarts(items, widget.email.toString());
    setState(() {});
    for (int i = 0; i < items.length; i++) {
      itemsSl.addAll([
        {"sl$i": items[i]['total']},
      ]);
    }
    setState(() {});
  }

  //xáo sản phẩm
  void XoaSanPham(int i) async {
    if (i < 0 || i >= items.length || i >= itemsSl.length) return;

    String id = items[i]['idCart'].toString();

    items.removeAt(i);
    itemsSl.removeAt(i);
    // itemsCheck.removeAt(i); // nếu có danh sách check

    await _firebauth.DeleteCarts(id);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        title: Text(
          'Giỏ hàng',
          style: GoogleFonts.robotoSlab(
            fontSize: AppStyle.textSizeTitle,
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(213, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 100),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: isCheckBox,
                          onChanged: (value) {
                            CheckBox(value!, itemsCheck);
                          },
                        ),
                        Text(
                          'Chọn tất cả',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: AppStyle.textSizeMedium,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 15),
                      child: GestureDetector(
                        onTap: () => Sua(),
                        child: Text(
                          textSua,
                          style: TextStyle(fontSize: AppStyle.textSizeMedium),
                        ),
                      ),
                    ),
                  ],
                ),

                // Danh sách sản phẩm
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      NeverScrollableScrollPhysics(), // để không chiếm scroll của màn hình cha
                  itemCount: items.isNotEmpty ? items.length : 0,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value:
                                itemsCheck.isNotEmpty
                                    ? itemsCheck[i]['check$i']
                                    : false,
                            onChanged: (value) {
                              CheckBoxAny(value!, i, itemsCheck);
                            },
                          ),
                          Container(
                            width: 90,
                            height: 90,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child:
                                  items.isNotEmpty
                                      ? Image.network(
                                        items[i]['imageUrl'],
                                        fit: BoxFit.cover,
                                      )
                                      : Image.asset(
                                        'lib/Image/nen.png',
                                        fit: BoxFit.cover,
                                      ),
                            ),
                          ),
                          Expanded(
                            flex: setFlex,
                            child: Row(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        items.isNotEmpty
                                            ? items[i]['name']
                                            : 'Đang tải lên...',
                                        style: TextStyle(
                                          fontSize: AppStyle.textSizeMedium,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: Text(
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        items.isNotEmpty
                                            ? '${items[i]['price']} đ'
                                            : 'Đang tải lên...',
                                        style: TextStyle(
                                          fontSize: AppStyle.textSizeLarge,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            truSoluong(i);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: Colors.black54,
                                                  width: 2,
                                                ),
                                                top: BorderSide(
                                                  color: Colors.black54,
                                                  width: 2,
                                                ),
                                                bottom: BorderSide(
                                                  color: Colors.black54,
                                                  width: 2,
                                                ),
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(10),
                                                topLeft: Radius.circular(10),
                                              ),
                                            ),
                                            child: Icon(Icons.remove, size: 20),
                                          ),
                                        ),
                                        Container(
                                          constraints: BoxConstraints(
                                            minWidth: 50,
                                          ),
                                          padding: EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.black54,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              itemsSl[i]['sl$i'].toString(),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            congSoluong(i);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: Colors.black54,
                                                  width: 2,
                                                ),
                                                top: BorderSide(
                                                  color: Colors.black54,
                                                  width: 2,
                                                ),
                                                bottom: BorderSide(
                                                  color: Colors.black54,
                                                  width: 2,
                                                ),
                                              ),
                                              borderRadius: BorderRadius.only(
                                                bottomRight: Radius.circular(
                                                  10,
                                                ),
                                                topRight: Radius.circular(10),
                                              ),
                                            ),
                                            child: Icon(Icons.add, size: 20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Offstage(
                                      offstage: _offStateContener,
                                      child: Container(
                                        height: 90,
                                        width: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              XoaSanPham(i);
                                            },
                                            child: Text(
                                              'Xóa',
                                              style: TextStyle(
                                                fontSize:
                                                    AppStyle.textSizeMedium,
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
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
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      // Thanh mua hàng dưới cùng
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      BuyNow();
                    },
                    child: Container(
                      color: Colors.green,
                      child: Center(
                        child: Text(
                          'Mua Ngay',
                          style: TextStyle(
                            fontSize: AppStyle.textSizeMedium,
                            color: Colors.white,
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
}
