import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienChonDiaChi extends StatefulWidget {
  final String? email;
  const GiaoDienChonDiaChi({super.key, this.email});

  @override
  State<GiaoDienChonDiaChi> createState() => _GiaoDienChonDiaChiState();
}

class _GiaoDienChonDiaChiState extends State<GiaoDienChonDiaChi> {
  Firebauth _firebauth = Firebauth();
  int? selected;
  List<Map<String, dynamic>> listRadio = [];
  List<Map<String, dynamic>> items = [];

  //set value radio
  SetValueRadio(int value) async {
     String  idItem = value.toString();
    setState(() {
      selected = value;
    });
     _firebauth.UpdateSelectedAddress(widget.email.toString(), idItem);
     await Future.delayed(Duration(milliseconds: 200), () {
        Navigator.pop(context, true);
     });
  }

  //Selected
  void SetSelected(int index){

  }

  //lấy dữ liệu address từ database
  void LayDuLieu() async {
    items = await _firebauth.GetAddress2(widget.email.toString());
    for(int i = 0; i < items.length; i++){
      listRadio.addAll([{
        "value$i" : int.tryParse(items[i]['id'])
      }]);

      if(items[i]['select'] == true){
        selected = int.tryParse(items[i]['id']);
      }
    }
    
   if(mounted){
     setState(() {});
   }
  }

  @override
  void initState() {
    super.initState();
   
    LayDuLieu();
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
                'Chọn địa chỉ nhận hàng',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Text(
                  'Địa chỉ',
                  style: TextStyle(
                    color: Colors.brown,
                    fontSize: AppStyle.textSizeMedium,
                  ),
                ),
              ),
            ),

            ListView.builder(
              shrinkWrap:
                  true, // Để nó chỉ chiếm chỗ cần thiết nếu nằm trong Column
              physics:
                  NeverScrollableScrollPhysics(), // Nếu muốn scroll toàn trang, ko scroll riêng list
              itemCount: items.length,
              itemBuilder: (context, i) {
                return Padding(
                  padding: EdgeInsets.only(left: 0, right: 0, bottom: 1),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                      boxShadow: [
                        BoxShadow(blurRadius: 100, color: Colors.grey),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Radio(
                              value: listRadio[i]['value$i'],
                              groupValue: selected,
                              onChanged: (value) {
                                SetValueRadio(value!);
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 9,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    items.isNotEmpty
                                        ? Text(
                                          '${items[i]['name']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppStyle.textSizeMedium,
                                          ),
                                        )
                                        : Text(
                                          'Đang tải lên...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppStyle.textSizeMedium,
                                          ),
                                        ),

                                    SizedBox(width: 10),
                                    items.isNotEmpty
                                        ? Text(
                                          '${items[i]['telephone']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey,
                                            fontSize: 13,
                                          ),
                                        )
                                        : Text(
                                          'Đang tải lên...',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: AppStyle.textSizeMedium,
                                          ),
                                        ),
                                  ],
                                ),
                                items.isNotEmpty
                                    ? Text(
                                      '${items[i]['address']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    )
                                    : Text(
                                      'Đang tải lên...',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: AppStyle.textSizeMedium,
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
