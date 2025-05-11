import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class Cloudinary {
  //trao đổi ảnh bằng API => url
  Future<String> upLoadImage(File imageFile) async {

    //tai khoan CCloudinary
    final cloudName = 'ddqouziau';//name
    final uploadPreset = 'phuckk';//Upload

    //đây là request API
    var giveRequset = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload'),
    );

    giveRequset.fields['upload_preset'] = uploadPreset;
    giveRequset.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    //gửi request
    var response = await giveRequset.send();

    //kiểm tra reponse
    if (response.statusCode == 200) {
      var res = await http.Response.fromStream(response);
      var data = jsonDecode(res.body);

      //Trả về imagrUrl
      return data['secure_url'];
    } else {
      throw Exception("Upload ảnh lỗi: ${response.statusCode}");
    }
  }

  /*Hàm Futrue lấy image url*/
  Future<String> getURL(File? image) async {

    ///kiểm tra file ảnh
    if (image != null) {
      final url = await upLoadImage(image);

      //Trả vể image url
      return url;
    }
    
    //Nếu file ảnh null trả về 0
    return "0";
  }
}
