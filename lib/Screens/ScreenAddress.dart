import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienDiaChi extends StatefulWidget {
  final String? email;
  const GiaoDienDiaChi({super.key, this.email});

  @override
  State<GiaoDienDiaChi> createState() => _GiaoDienDiaChiState();
}

class _GiaoDienDiaChiState extends State<GiaoDienDiaChi> {
  Firebauth _firebauth = Firebauth();
  late FocusNode _focusNode;
  late FocusNode _focusNode2;
  late FocusNode _focusNode3;
  final _diachiText = TextEditingController();
  final _tenText = TextEditingController();
  final _sdt = TextEditingController();
  double chieuCao = 400;

  //hàm bất đồng bộ thêm địa chỉ
  void ThemDiaChiNhanHang() async {

    if(_sdt.text.length != 10){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Số điện thoại không đúng !')))
      );
    }else if(_diachiText.text.isEmpty && _tenText.text.isEmpty){
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Vui lòng đủ thông tin !')))
      );
    }
    else{
   await _firebauth.SaveAddress(
      widget.email.toString(),
      _tenText.text.toString(),
      _diachiText.text.toString(),
      _sdt.text.toString(),
    );
    _diachiText.clear();
    _sdt.clear();
    _tenText.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Center(
          child: Text(
            'Thêm thành công !',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
    Navigator.pop(context);
    }
 
  }

  //hàm bất đồng bộ xóa địa chỉ
  void XoaDiaChi(String id) async {
    await _firebauth.DeleteAddress(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Center(child: Text('Xóa thành công !', style: TextStyle(color: Colors.black),)),
      ),
    );
    setState(() {});
  }

  //on created
  @override
  void initState() {
    super.initState();
    // XuatDuLieu();
    SetChieuCao();
  }

  void SetChieuCao(){
    
     _focusNode = FocusNode();
    _focusNode2 = FocusNode();
    _focusNode3 = FocusNode();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          chieuCao = 700;
        });
      } else {
        setState(() {
          chieuCao = 400;
        });
      }
    });
     _focusNode2.addListener(() {
      if (_focusNode2.hasFocus) {
        setState(() {
          chieuCao = 700;
        });
      } else {
        setState(() {
          chieuCao = 400;
        });
      }
    });
     _focusNode3.addListener(() {
      if (_focusNode3.hasFocus) {
        setState(() {
          chieuCao = 700;
        });
      } else {
        setState(() {
          chieuCao = 400;
        });
      }
    });
  }
  



  @override
  void dispose() {
    super.dispose();
   _focusNode.dispose();
   _focusNode2.dispose();
   _focusNode3.dispose();
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
                'Địa chỉ',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 10, color: Colors.grey),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Danh sách địa chỉ',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: AppStyle.textSizeMedium,
                  ),
                ),
              ),
              Column(
                children: [
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _firebauth.GetAddress(widget.email.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('Không có dữ liệu !'));
                      } else {
                        final items = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                bottom: 10,
                              ),
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        top: 10,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Số điện thoại : ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  items.isNotEmpty
                                                      ? items[index]['telephone']
                                                      : CircularProgressIndicator(),
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Tên người nhận : ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  items.isNotEmpty
                                                      ? items[index]['name']
                                                      : CircularProgressIndicator(),
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 10,
                                        right: 10,
                                        bottom: 10,
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Địa chỉ : ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  items.isNotEmpty
                                                      ? items[index]['address']
                                                      : CircularProgressIndicator(),
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 0,
                                        right: 0,
                                        bottom: 0,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          onPressed: () {
                                            XoaDiaChi(items[index]['id']);
                                          },

                                          icon: Icon(Icons.delete_forever),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Visibility(
        visible: MediaQuery.of(context).viewInsets.bottom == 0,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            height: 50,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, 
                    builder: (BuildContext context) {
                      return ThemDiaChi(context);
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  elevation: 5,
                  backgroundColor: Colors.cyan,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Thêm địa chỉ mới',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppStyle.textSizeMedium,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ThemDiaChi(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: chieuCao,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thêm địa chỉ nhận hàng",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Hủy',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          TextField(
            controller: _tenText,
            focusNode: _focusNode,
            decoration: InputDecoration(
              labelText: 'Tên người nhận',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 5),
          TextField(
            controller: _sdt,
            focusNode: _focusNode2,
            decoration: InputDecoration(
              labelText: 'Số điện thoại',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
               LengthLimitingTextInputFormatter(10),
               FilteringTextInputFormatter.digitsOnly
    
            ],
          ),
          SizedBox(height: 5),
          TextField(
            controller: _diachiText,
            minLines: 2,
            focusNode: _focusNode3,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Địa chỉ',
              border: OutlineInputBorder(),
            ),
            
          ),
          SizedBox(height: 40),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(100, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  ThemDiaChiNhanHang();
                },
                child: Text(
                  "Lưu",
                  style: TextStyle(fontSize: AppStyle.textSizeMedium),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
