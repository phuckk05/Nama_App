import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
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

  List<Map<String, dynamic>> items = [];
  List<Map<String, bool>> itemsCheck = [];
  int soLuong = 0;
  void truSoluong() {
    setState(() {
      if (soLuong > 0) {
        soLuong -= 1;
      }
    });
  }

  void CongSoluong() {
    setState(() {
      if (soLuong >= 0) {
        soLuong += 1;
      }
    });
  }

  void CheckBox(bool value, List<Map<String, bool>> list) {
    list.clear();
    for (int i = 0; i < items.length; i++) {
      list.add({"check$i": value});
    }
    setState(() {
      isCheckBox = value;
    });
  }

  //hàm check box
  void CheckBoxAny(bool value, int index, List<Map<String, bool>> list) {
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

  void laySanPham() async {
    await _firebauth.getSaveCarts(items, widget.email.toString());
    setState(() {});
  }

  void XoaSanPham(int i) {
    String id = items[i]['id'];
    _firebauth.DeleteCarts(id);
    laySanPham();
  }

  void ShowSoLuong(String? a) {
    int total = int.parse(a!);
    setState(() {
      soLuong = total;
    });
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
                  itemCount: items.isNotEmpty? items.length : 0,
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
                                    Text(
                                     items.isNotEmpty?  items[i]['name'] : 'Đang tải lên...',
                                      style: TextStyle(
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    ),
                                    Text(
                                      items.isNotEmpty?  items[i]['price'] : 'Đang tải lên...',
                                      style: TextStyle(
                                        fontSize: AppStyle.textSizeLarge,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Container(
                                      height: 30,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.black),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              truSoluong();
                                            },
                                            child: Container(
                                              width: 30,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '-',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 40,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.symmetric(
                                                vertical: BorderSide(
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            child: Text(
                                              items.isNotEmpty?  items[i]['total'] : '0',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              CongSoluong();
                                            },
                                            child: Container(
                                              width: 30,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
                  flex: 6,
                  child: Container(
                    color: Colors.white,
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Tổng thanh toán: ",
                              style: TextStyle(
                                fontSize: AppStyle.textSizeSmall,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "600000đ",
                              style: TextStyle(
                                fontSize: AppStyle.textSizeLarge,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
