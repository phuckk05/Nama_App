import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Screens/ScreenProducts.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class Search extends StatefulWidget {
  final String? email;
  final List<Product>? itemProducts;

  Search({super.key, this.email, this.itemProducts});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final _textTimKiem = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final Firebauth _firebauth = Firebauth();

  List<Map<String, dynamic>> itemSearch = [];
  List<Product>? _filteredProducts;

  bool _offstate = false;
  bool _offstateLichSu = true;
  bool _offstateListview = false;
  bool _offstategridview = false;
  bool _offStateNofi = true;

  @override
  void initState() {
    super.initState();
    XuatItemSearch();
    _filteredProducts = widget.itemProducts ?? [];
  }

  void CheckValue(String value) {
    setState(() {
      _offstate = value.isNotEmpty;
      _offstateListview = value.isNotEmpty;
      _offstategridview = value.isNotEmpty;
      _offstateLichSu = value.isNotEmpty;
    });
  }

  void SearchValue() {
    String keyword = _textTimKiem.text.toLowerCase();
    if (keyword.isNotEmpty) {
      _filteredProducts =
          widget.itemProducts!
              .where((product) => product.name.toLowerCase().contains(keyword))
              .toList();
      if (_filteredProducts!.isEmpty) {
        _offStateNofi = false;
        _filteredProducts!.clear();
      } else {
        setState(() {
          _offstate = true;
          _offstateListview = true;
          _offstategridview = false;
          _offstateLichSu = true;
          _offStateNofi = true;
        });
      }
    }
  }

  void XuatItemSearch() async {
    await _firebauth.LayHistory(widget.email.toString(), itemSearch);
    setState(() {});
    KiemTra();
  }

  void XuatItemSearchonChange() async {
    itemSearch.clear();
    _filteredProducts!.clear();
    _firebauth.LayHistory(widget.email.toString(), itemSearch);
  }

  void KiemTra() {
    if (_textTimKiem.text.isEmpty) {
      setState(() {
        _offstateLichSu = itemSearch.isNotEmpty ? false : true;
      });
    }
  }

  void ThemHistory() async {
    if (_textTimKiem.text.isNotEmpty) {
      _firebauth.ThemHistory(
        widget.email.toString(),
        _textTimKiem.text.toString(),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Vui lòng nhập từ khóa!'))),
      );
    }
  }

  void XoaLichSu() async {
    if (itemSearch.isNotEmpty) {
      itemSearch.clear();
      _firebauth.XoaHistory(widget.email.toString());
      setState(() {
        _offstateLichSu = true;
      });
    }
  }

  void setText(String value) {
    setState(() {
      _textTimKiem.text = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        actions: [
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 5),
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: TextField(
                controller: _textTimKiem,
                focusNode: _searchFocus,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(top: 10, left: 10),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "Tìm kiếm",
                  hintStyle: TextStyle(
                    fontSize: AppStyle.paddingMedium,
                    color: AppStyle.textGreenColor,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.camera_alt_outlined),
                  ),
                ),
                onChanged: (value) {
                  CheckValue(value);
                  if (value.isEmpty) {
                    _offStateNofi = true;
                    XuatItemSearchonChange();
                  }
                },
              ),
            ),
          ),
          Expanded(
            flex: 15,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                onPressed: () {
                  SearchValue();
                  ThemHistory();
                },
                icon: Icon(Icons.search, size: 30, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Offstage(
              offstage: _offstate,
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 10, bottom: 10),
                child: Text(
                  'Kiếm đồ hay cùng Nama - Đặt hàng ngay',
                  style: TextStyle(
                    fontSize: AppStyle.textSizeMedium,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Divider(color: AppStyle.textGreenColor, height: 1),
            Offstage(
              offstage: _offStateNofi,
              child: Container(
                height: 100,
                child: Center(child: Text('Không có sản phẩm đó !')),
              ),
            ),
            Offstage(
              offstage: _offstateListview,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: itemSearch.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setText(itemSearch[index]['name'].toString());
                          SearchValue();
                        },
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          title: Text(itemSearch[index]['name']),
                          trailing: Icon(Icons.history),
                        ),
                      ),
                      Divider(color: AppStyle.textGreenColor, height: 1),
                    ],
                  );
                },
              ),
            ),
            Offstage(
              offstage: _offstateLichSu,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: GestureDetector(
                  onTap: () {
                    XoaLichSu();
                  },
                  child: Center(
                    child: Text(
                      "Xóa Lịch Sử Tìm Kiếm",
                      style: TextStyle(
                        color: AppStyle.textGreenColor,
                        fontSize: AppStyle.textSizeMedium,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Offstage(
              offstage: _offstate,
              child: Container(
                height: 10,
                color: const Color.fromARGB(28, 0, 0, 0),
              ),
            ),
            Offstage(
              offstage: _offstate,
              child: Container(
                height: 30,
                width: double.infinity,
                padding: EdgeInsets.only(left: 10, top: 5),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Gợi ý cho bạn',
                    style: TextStyle(
                      fontSize: AppStyle.textSizeLarge,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
            Offstage(
              offstage: _offstategridview,
              child: Container(
                width: double.infinity,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(5),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 1,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 220,
                  ),
                  itemCount:
                      _filteredProducts!.isNotEmpty
                          ? _filteredProducts!.take(4).length
                          : widget.itemProducts!.take(4).length,
                  itemBuilder: (context, index) {
                  
                    final product =
                        _filteredProducts!.isNotEmpty
                            ? _filteredProducts![index]
                            : widget.itemProducts![index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppStyle.borderRadius,
                        ),
                      ),
                      elevation: 5,
                      child: InkWell(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => GiaoDienSanPham(
                                    email: widget.email,
                                    id:
                                        _filteredProducts!.isNotEmpty
                                            ? _filteredProducts![index].id
                                            : widget.itemProducts![index].id,
                                  ),
                            ),
                          );
                          if (result == true) {
                            Navigator.pop(context);
                          }
                        },
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Image.network(
                                product.imageUrl,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.fill,
                              ),
                            ),
                            SizedBox(
                              height: 55,
                              width: double.infinity,
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
