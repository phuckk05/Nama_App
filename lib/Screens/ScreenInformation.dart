import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nama_app/API/imageAPI.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienThongTin extends StatefulWidget {
  final String? email;
  GiaoDienThongTin({Key? key, this.email}) : super(key: key);

  @override
  State<GiaoDienThongTin> createState() => _GiaoDienThongTinState();
}

class _GiaoDienThongTinState extends State<GiaoDienThongTin> {
  Cloudinary _imageAPI = Cloudinary();
  Firebauth _firebauth = Firebauth();
  FocusNode _focusNode = FocusNode();
  File? _image;
  int? _selectedIndex;
  double chieuCao = 250;
  String? _result;
  List<String> _split = [];
  String? _url;
  bool isloading = false;

  final _text = TextEditingController();
  //ham lấy ảnh
  Future<void> pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      setState(() {
        _image = imageFile;
      });
      _url = await _imageAPI.getURL(_image);
      setState(() {});
    } else {
      print('Không chọn ảnh nào.');
    }
  }

  //update thông tin user
  void updateUser(String image, String name) async {
    setState(() {
      isloading = true;
    });
    await _firebauth.UpdateInforUser(widget.email.toString(), image, name);
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isloading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Center(child: Text('Cập nhật thành công'))),
    );
  }

  //set color
  void SetColor(int index) {
    _selectedIndex = index;
    Future.delayed(Duration(milliseconds: 50), () {
      _selectedIndex = null;
      if (index == 1) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return ChinhSuaThongTin(context);
          },
        );
      }
    });
  }

  //on created
  @override
  void initState() {
    super.initState();
    _Lay_Thong_Tin_User();
    SetChieuCao();
  }

  //bắt sự kiện khi focus vào textflied
  void SetChieuCao() {
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          chieuCao = 550;
        });
      } else {
        setState(() {
          chieuCao = 250;
        });
      }
    });
  }

  //lấy thông tin users
  // ignore: non_constant_identifier_names
  void _Lay_Thong_Tin_User() async {
    _result = await _firebauth.GetAllUser(widget.email.toString());
    setState(() {
      _split = _result.toString().split('+');
      _text.text = _split[2].toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                    Navigator.pop(context, true);
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
                  'Sửa thông tin',
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
                  onTap: () async {
                    if (_url != null && _text.text.isNotEmpty) {
                      updateUser(_url.toString(), _text.text.toString());
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(
                            child: Text('Vui lòng chọn thông tin'),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Lưu',
                    style: TextStyle(
                      fontSize: AppStyle.textSizeMedium,
                      color: Colors.green,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.green,

                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: FutureBuilder(
                                future: Future.delayed(Duration(seconds: 2)),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child:
                                          _image == null
                                              ? Image.network(
                                                _split[1],
                                                fit: BoxFit.cover,
                                              )
                                              : Image.file(
                                                _image!,
                                                fit: BoxFit.cover,
                                              ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 25,
                            left: 25,

                            child: GestureDetector(
                              onTap: () {
                                print('hello Ưolrd');
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                ),

                                child: GestureDetector(
                                  onTap: () {
                                    pickImageFromGallery();
                                  },
                                  child: Text(
                                    'Sửa',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: AppStyle.textSizeMedium,
                                      fontWeight: FontWeight.w500,
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
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [buildTile(1, "Tên"), Divider(height: 1)],
                  ),
                ),
              ],
            ),

            if (isloading)
              Container(
                color: Colors.black54.withOpacity(0.5),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  //custmer listtite
  Widget buildTile(int index, String title) {
    return InkWell(
      onTap: () {
        SetColor(index);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        color: _selectedIndex == index ? Colors.grey[300] : Colors.white,
        child: ListTile(
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          trailing: Icon(Icons.arrow_forward_ios, size: 20),
        ),
      ),
    );
  }

  //show bottom sheet
  Widget ChinhSuaThongTin(BuildContext context) {
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
                "Chỉnh sửa thông tin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Xong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            focusNode: _focusNode,
            controller: _text,
            decoration: InputDecoration(labelText: 'Nhập Tên mới'),
          ),
          SizedBox(height: 40),
          // Center(
          //   child: ElevatedButton(
          //     style: ElevatedButton.styleFrom(
          //       minimumSize: Size(100, 40),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(10),
          //       ),
          //       elevation: 5,
          //     ),
          //     onPressed: () {
          //       Navigator.pop(context); // đóng bottom sheet
          //     },
          //     child: Text(
          //       "Lưu",
          //       style: TextStyle(fontSize: AppStyle.textSizeMedium),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
