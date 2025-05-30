import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:nama_app/Models/Carts.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Models/Review.dart';

class Firebauth {
  String generateVerificationCode(int length) {
    const chars = '0123456789';
    Random random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<void> sendVerificationEmail(
    String recipientEmail,
    String verificationCode,
  ) async {
    String username = '23211TT4425@mail.tdc.edu.vn';
    String password = 'drvh lhel chui kfga';

    final smtpServer = gmail(username, password); // Sử dụng server Gmail

    final message =
        Message()
          ..from = Address(username, 'Nama') // Tên của ứng dụng bạn
          ..recipients.add(recipientEmail)
          ..subject = 'Mã xác thực của bạn'
          ..text = 'Mã xác thực của bạn là: $verificationCode';

    try {
      final sendReport = await send(message, smtpServer);
      print('Email gửi thành công: ' + sendReport.toString());
    } catch (e) {
      print('Lỗi khi gửi email: $e');
    }
  }

  Future<int> checkUsers(String email) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get();

    if (result.docs.isNotEmpty) {
      // Email đã tồn tại
      return 1;
    } else {
      // Email chưa tồn tại
      return 0;
    }
  }

  Future<void> registerWithEmail(String email, BuildContext context) async {
    try {
      // Tạo mã xác nhận ngẫu nhiên
      String verificationCode = generateVerificationCode(6);

      // Gửi mã xác thực qua email
      await sendVerificationEmail(email, verificationCode);

      // Lưu mã vào Firestore (tuỳ chọn)
      await FirebaseFirestore.instance.collection('verification_codes').add({
        'email': email,
        'code': verificationCode,
        'createdAt': Timestamp.now(),
      });

      print('Mã xác thực tồn tại 60 giây đã được gửi tới email');
    } catch (e) {
      print('Lỗi đăng ký: $e');
    }
  }

  Future<void> TimeCode(String email) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('verification_codes')
            .where('email', isEqualTo: email)
            .get();

    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        await doc.reference.delete();
      }
    }
  }

  Future<void> checkCode(
    String email,
    String code,
    BuildContext context,
  ) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('verification_codes')
            .where('email', isEqualTo: email)
            .where('code', isEqualTo: code)
            .limit(1)
            .get();

    if (result.docs.isNotEmpty) {
      String code = generateVerificationCode(5);
      await FirebaseFirestore.instance.collection('users').add({
        'email': email,
        'image':
            "https://i.pinimg.com/736x/c6/e5/65/c6e56503cfdd87da299f72dc416023d4.jpg",
        'name': "user_${code.toString()}",
        'createdAt': Timestamp.now(),
      });

      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Center(child: Text('Đăng kí thành công!'))),
      // );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Sai code , thử lại !'))),
      );
    }
  }

  //them lich su tim kiem
  Future<void> ThemHistory(String email, String nameSearch) async {
    await FirebaseFirestore.instance.collection('history').add({
      "name": nameSearch,
      "email": email,
    });
  }

  //lay lich su tim kiem
  Future<void> LayHistory(String email, List<Map<String, dynamic>> list) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('history')
            .where('email', isEqualTo: email)
            .get();
    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        list.addAll([
          {"name": doc['name']},
        ]);
      }
    }
  }

  //kiem tra code
  Future<int> checkCodeLogin(String email, String code) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('verification_codes')
            .where('email', isEqualTo: email)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

    if (result.docs.isNotEmpty) {
      final data = result.docs.first.data() as Map<String, dynamic>;
      final latestCode = data['code'];

      if (latestCode == code) {
        return 1; // Đúng mã mới nhất
      } else {
        return 0; // Sai mã
      }
    } else {
      return 0; // Không tìm thấy mã nào
    }
  }

  // Future<void> verifyCode(String enteredCode, String email) async {
  //   // Lấy mã xác thực từ Firestore
  //   var snapshot =
  //       await FirebaseFirestore.instance
  //           .collection('verification_codes')
  //           .where('email', isEqualTo: email)
  //           .orderBy('createdAt', descending: true)
  //           .limit(1)
  //           .get();

  //   if (snapshot.docs.isNotEmpty) {
  //     String storedCode = snapshot.docs.first['code'];
  //     if (enteredCode == storedCode) {
  //       print('Mã xác thực đúng!');
  //       // Tiến hành đăng nhập hoặc xác nhận
  //     } else {
  //       print('Mã xác thực sai!');
  //     }
  //   } else {
  //     print('Không tìm thấy mã xác thực cho email này');
  //   }
  // }
  //kiem tra dang nhap
  Future<int> CheckLoGin(String email, BuildContext context) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    if (result.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Kiểm tra hộp thư mã tồn tại 60 giây')),
        ),
      );
      await registerWithEmail(email, context);

      return 1;
    } else {
      return 0;
    }
  }

  //xoa lich su tim kiem
  Future<void> XoaHistory(String email) async {
    final result =
        await FirebaseFirestore.instance
            .collection('history')
            .where('email', isEqualTo: email)
            .get();

    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        await doc.reference.delete();
      }
    }
  }

  //lay tat cả sản phẩm
   Future<List<Product>> getAllProducts() async {
    List<Product> listProducts = [];
    int count = 0;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('hiden', isEqualTo: false)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        listProducts.addAll([
          Product(
            id: doc['id'],
            name: doc['name'],
            description: doc['description'],
            address: doc['address'],
            email: doc['email'],
            imageUrl: doc['imageUrl'],
            type: doc['type'],
            price: doc['price'],
            total: doc['total'].toString(),
            createdAt: doc['createdAt'],
            hiden: doc['hiden'],
          ),
        ]);
      }
    }
    return listProducts;
  }

  //update all products
  Future<void> UpdatedInforProducts(String id,String email, Product _products) async {
    // String reslut = await UID(id.toString());
    // print(uId.toString());
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id',isEqualTo: id)
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      final id = _query.docs.first.id;
      await FirebaseFirestore.instance.collection('products').doc(id).set({
        "name": _products.name.toString(),
        "id": _products.id,
        "price": _products.price,
        "total": _products.total,
        "email": _products.email,
        "address": _products.address,
        "type": _products.type,
        "imageUrl": _products.imageUrl,
        "createdAt": _products.createdAt,
        "description": _products.description.toString(),
        "hiden": false,
      });
    }
  }

  //lay san pham theo user
  Future<List<Product>> getAllProductsUser(String email) async {
    List<Product> listProducts = [];
    int count = 0;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .where('hiden', isEqualTo: false)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        listProducts.addAll([
          Product(
            id: doc['id'],
            name: doc['name'],
            description: doc['description'],
            address: doc['address'],
            email: doc['email'],
            imageUrl: doc['imageUrl'],
            type: doc['type'],
            price: doc['price'],
            total: doc['total'].toString(),
            createdAt: doc['createdAt'],
            hiden: doc['hiden'],
          ),
        ]);
      }
    }
    return listProducts;
  }

  //lay san pham theo user
  Future<List<Product>> getAllProductsUseSell(String email) async {
    List<Product> listProducts = [];
    int count = 0;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .where('hiden', isEqualTo: false)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        final QuerySnapshot _query2 =
            await FirebaseFirestore.instance
                .collection('Order')
                .where('idProduct', isEqualTo: doc['id'])
                .get();
        if (_query2.docs.isNotEmpty) {
          listProducts.addAll([
            Product(
              id: doc['id'],
              name: doc['name'],
              description: doc['description'],
              address: doc['address'],
              email: doc['email'],
              imageUrl: doc['imageUrl'],
              type: doc['type'],
              price: doc['price'],
              total: doc['total'].toString(),
              createdAt: doc['createdAt'],
              hiden: doc['hiden'],
            ),
          ]);
        }
      }
    }
    return listProducts;
  }

  //an di producst
  Future<void> hidenProducts(String id) async {
    bool check = false;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      final QuerySnapshot _query2 =
          await FirebaseFirestore.instance
              .collection('Order')
              .where('idProduct', isEqualTo: id)
              .get();
      if (_query2.docs.isNotEmpty) {
        check = true;
      }
      final idu = _query.docs.first.id;
      if (check == true) {
        await FirebaseFirestore.instance.collection('products').doc(idu).update(
          {'hiden': true},
        );
      } else {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(idu)
            .delete();
      }
    }
  }

  //lay san pham trong xem san pham
  Future<String> showProducts(
    String id,
    List<Map<String, dynamic>> items,
  ) async {
    String? nameUser;
    String? total;
    String? result;
    String? decription;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          {
            "name": doc['name'],
            "id": doc['id'],
            "price": doc['price'],
            "total": doc['total'],
            "email": doc['email'] ?? 'khong-co-email',
            "address": doc['address'],
            "type": doc['type'],
            "imageUrl": doc['imageUrl'],
            "createdAt": doc['createdAt'],
            "description": doc['description'],
          },
        ]);
      }

      nameUser = await getName(items[0]['email']);
      total = await getToTalProducts(items[0]['email']);

      result = "${nameUser.toString()}+${total.toString()}";
      print(decription.toString());
    }
    return result.toString();
  }

  //lay name user
  Future<String> getName(String email) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email.toString())
            .get();
    if (_query.docs.isNotEmpty) {
      String resultName = _query.docs.first.get('name');
       String resultImage = _query.docs.first.get('image');
      return "${resultName}+${resultImage}";
    }
    return "NO";
  }

  //lay tong so san pham
  Future<String> getToTalProducts(String email) async {
    int i = 0;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        i++;
      }
      return i.toString();
    }

    return "0";
  }

  //theo vao carts
  Future<void> saveCarts(CartItem cartItem) async {
    String reslut = await UpdatedTotal(cartItem.idProduct);
    List<String> tach = reslut.split(':');
    String? totalOut = tach[0].toString();
    String? uId = tach[1].toString();
    print(reslut);
    print(totalOut.toString());
    // print(uId.toString());
    if (totalOut == "0") {
      await FirebaseFirestore.instance.collection('carts').add({
        "name": cartItem.name,
        "idCart": cartItem.idCart,
        "idProduct": cartItem.idProduct,
        "price": cartItem.price,
        "total": 1,
        "email": cartItem.email,
        "address": cartItem.address,
        "type": cartItem.type,
        "imageUrl": cartItem.imageUrl,
        "createdAt": cartItem.createdAt,
        "description": cartItem.description,
        "emailAdd": cartItem.emailAdd,
      });
    } else {
      int tong = int.parse(totalOut) + 1;
      await FirebaseFirestore.instance.collection('carts').doc(tach[1]).set({
        "name": cartItem.name,
        "idCart": cartItem.idCart,
        "idProduct": cartItem.idProduct,
        "price": cartItem.price,
        "total": tong.toString(),
        "email": cartItem.email,
        "address": cartItem.address,
        "type": cartItem.type,
        "imageUrl": cartItem.imageUrl,
        "createdAt": cartItem.createdAt,
        "description": cartItem.description,
        "emailAdd": cartItem.emailAdd,
      });
    }
  }

  //show sản phẩm vào giỏ hàng
  Future<void> getSaveCarts(
    List<Map<String, dynamic>> items,
    String email,
  ) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('carts')
            .where('emailAdd', isEqualTo: email)
            .get();

    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          {
            "name": doc['name'],
            "idCart": doc['idCart'],
            "idProduct": doc['idProduct'],
            "price": doc['price'],
            "total": doc['total'],
            "email": doc['email'],
            "address": doc['address'],
            "type": doc['type'],
            "imageUrl": doc['imageUrl'],
            "createdAt": doc['createdAt'],
            "description": doc['description'],
            "emailAdd": doc['emailAdd'],
          },
        ]);
      }
    }
  }

  //su ly them nhieu lan 1 san pham
  Future<String> UpdatedTotal(String id) async {
    String? reslut;
    String? docID = "0";
    int _count;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('carts')
            .where('idProduct', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      docID = _query.docs.first.id;
      _count = int.tryParse(_query.docs.first.get('total').toString())!;
      reslut = "${_count}:${docID}";
    } else {
      reslut = "0:0";
    }

    return reslut.toString();
  }

  //lay UID products by user
  Future<String> UID(String id) async {
    String? reslut;
    String? docID = "0";
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      docID = _query.docs.first.id;
      reslut = "${docID}";
    } else {
      reslut = "0:0";
    }

    return reslut.toString();
  }

  //xử lý sự kiện xóa sản phẩm trong giỏ hàng

  Future<void> DeleteCarts(String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('carts')
            .where('idCart', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await item.reference.delete();
      }
    }
  }

  //kiểm tra tự đặt hàng , có cùng người dùng hay không ?

  Future<int> CheckOrder(String email, String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      return 0;
    }
    return 1;
  }

  //lấy tất cả thông tin user bằng email

  Future<String> GetAllUser(String email) async {
    String? _docID = "0";
    String? _result;
    String? _imageUrl;
    String? _name;
    Timestamp _timeStamp;

    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      _docID = _query.docs.first.id;
      _imageUrl = _query.docs.first.get('image');
      _name = _query.docs.first.get('name');
      _timeStamp = _query.docs.first.get('createdAt');

      _result = "${_docID}+${_imageUrl}+${_name}+${_timeStamp}";

      return _result.toString();
    }
    return "0";
  }

  //thêm địa chỉ giao hàng
  Future<void> SaveAddress(
    String email,
    String name,
    String address,
    String telephone,
  ) async {
    String? _id = generateVerificationCode(10);

    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      await FirebaseFirestore.instance.collection('address').add({
        "id": _id,
        "email": email,
        "address": address,
        "name": name,
        "telephone": telephone,
        "select": false,
      });
    } else {
      await FirebaseFirestore.instance.collection('address').add({
        "id": _id,
        "email": email,
        "address": address,
        "name": name,
        "telephone": telephone,
        "select": true,
      });
    }
  }

  //lấy địa chiwr từ firebase

  Future<List<Map<String, dynamic>>> GetAddress(String email) async {
    List<Map<String, dynamic>> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          {
            "id": doc['id'],
            "email": doc['email'],
            "address": doc['address'],
            "name": doc['name'],
            "telephone": doc['telephone'],
          },
        ]);
      }
    }
    return items;
  }

  //lay địa chỉ
  Future<List<Map<String, dynamic>>> GetAddress2(String email) async {
    List<Map<String, dynamic>> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          {
            "id": doc['id'],
            "email": doc['email'],
            "address": doc['address'],
            "name": doc['name'],
            "telephone": doc['telephone'],
            "select": doc['select'],
          },
        ]);
      }
    }
    return items;
  }

  //xóa địa chỉ
  Future<void> DeleteAddress(String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await item.reference.delete();
      }
    }
  }

  //lấy địa chỉ giao hàng có true
  Future<List<Map<String, dynamic>>> GetAddressSelected(String email) async {
    List<Map<String, dynamic>> items = [];
    bool select = true;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .where('select', isEqualTo: select)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          {
            "id": doc['id'],
            "email": doc['email'],
            "address": doc['address'],
            "name": doc['name'],
            "telephone": doc['telephone'],
            "select": doc['select'],
          },
        ]);
      }
    }
    return items;
  }

  //update select address
  Future<void> UpdateSelectedAddress(String email, String idItem) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        String _id = item['id'];
        if (_id == idItem) {
          await FirebaseFirestore.instance
              .collection('address')
              .doc(item.id)
              .update({'select': true});
        } else {
          await FirebaseFirestore.instance
              .collection('address')
              .doc(item.id)
              .update({'select': false});
        }
      }
    }
  }

  //đơn hàng

  Future<void> saveOrder(DonHang _donhang) async {
    await FirebaseFirestore.instance.collection('Order').add({
      "id": _donhang.id,
      "idProduct": _donhang.idProducts,
      "name": _donhang.name,
      "nameShop": _donhang.nameShop,
      "soLuong": _donhang.soLuong,
      "imageUrl": _donhang.imageUrl,
      "address": _donhang.address,
      "emailSell": _donhang.emailSell,
      "emailBuy": _donhang.emailBuy,
      "createdAt": _donhang.createdAt,
      "price": _donhang.price,
      "priceAll": _donhang.priceAll,
      "status": _donhang.status,
      "hidenBuy": _donhang.hidenBuy,
      "hidenSell": _donhang.hidenSell,
    });
  }

  Future<void> saveOrder2(DonHang _donhang) async {
    await FirebaseFirestore.instance.collection('Order').add({
      "id": _donhang.id,
      "idProduct": _donhang.idProducts,
      "name": _donhang.name,
      "nameShop": _donhang.nameShop,
      "soLuong": _donhang.soLuong,
      "imageUrl": _donhang.imageUrl,
      "address": _donhang.address,
      "emailSell": _donhang.emailSell,
      "emailBuy": _donhang.emailBuy,
      "createdAt": _donhang.createdAt,
      "price": _donhang.price,
      "priceAll": _donhang.priceAll,
      "status": _donhang.status,
      "hidenBuy": _donhang.hidenBuy,
      "hidenSell": _donhang.hidenSell,
    });
  }

  //lấy đươn hàng
  Future<List<DonHang>> getOrderSell(String emailSell) async {
    List<DonHang> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailSell', isEqualTo: emailSell)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          DonHang(
            id: doc['id'],
            idProducts: doc['idProduct'],
            name: doc['name'],
            nameShop: doc['nameShop'],
            soLuong: doc['soLuong'],
            imageUrl: doc['imageUrl'],
            address: doc['address'],
            emailSell: doc['emailSell'],
            emailBuy: doc['emailBuy'],
            createdAt: doc['createdAt'],
            price: doc['price'],
            priceAll: doc['priceAll'],
            status: doc['status'],
            hidenBuy: doc['hidenBuy'],
            hidenSell: doc['hidenSell'],
          ),
        ]);
      }
    }
    return items;
  }

  //Lấy đơn hàng theo email sell
  Future<List<Map<String, dynamic>>> getOrderByEmailSell(
    String emailSell,
  ) async {
    bool hidenSell = false;
    List<Map<String, dynamic>> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailSell', isEqualTo: emailSell)
            .where('hidenSell', isEqualTo: hidenSell)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        String? userNameBuy;
        String? createdAt = doc['createdAt'];
        String email = doc['emailBuy'];
        final QuerySnapshot _query2 =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: email)
                .get();
        if (_query2.docs.isNotEmpty) {
          userNameBuy = _query2.docs.first.get('name');
        }
        String id = doc['id'];
        items.addAll([
          {
            "idOrder": id,
            "userNameBuy": userNameBuy,
            "createdAt": createdAt,
            "name": doc['name'],
            "soluong": doc['soLuong'],
            "price": doc['price'],
            "priceAll": doc['priceAll'],
            "status": doc['status'],
            "imageUrl": doc['imageUrl'],
            "address": doc['address'],
            "hidenBuy": doc['hidenBuy'],
            "hidenSell": doc['hidenSell'],
          },
        ]);
      }
    }
    return items;
  }

  Future<List<Map<String, dynamic>>> GetOrderByEmailBuy(String emailBuy) async {
    bool hidenBuy = false;
    List<Map<String, dynamic>> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailBuy', isEqualTo: emailBuy)
            .where('hidenBuy', isEqualTo: hidenBuy)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        String? createdAt = doc['createdAt'];
        String email = doc['emailBuy'];
        String status = doc['status'];
        String name = doc['name'];
        String soLuong = doc['soLuong'];
        String id = doc['id'];
        items.addAll([
          {
            "idOrder": id,
            "emailBuy": email,
            "createdAt": createdAt,
            "status": status,
            "name": name,
            "soLuong": soLuong,
            "hidenBuy": doc['hidenBuy'],
            "hidenSell": doc['hidenSell'],
          },
        ]);
      }
    }
    return items;
  }

  //Lấy đơn hàng theo email sell
  Future<List<DonHang>> GetOrderByEmailSell(String emailBuy) async {
    List<DonHang> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailBuy', isEqualTo: emailBuy)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          DonHang(
            id: doc['id'],
            idProducts: doc['idProduct'],
            name: doc['name'],
            nameShop: doc['nameShop'],
            soLuong: doc['soLuong'],
            imageUrl: doc['imageUrl'],
            address: doc['address'],
            emailSell: doc['emailSell'],
            emailBuy: doc['emailBuy'],
            createdAt: doc['createdAt'],
            price: doc['price'],
            priceAll: doc['priceAll'],
            status: doc['status'],
            hidenBuy: doc['hidenBuy'],
            hidenSell: doc['hidenSell'],
          ),
        ]);
      }
    }
    return items;
  }

  //Lấy đơn hàng theo email sell
  Future<List<DonHang>> getOrderSell2(String emailSell) async {
    List<DonHang> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailSell', isEqualTo: emailSell)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          DonHang(
            id: doc['id'],
            idProducts: doc['idProduct'],
            name: doc['name'],
            nameShop: doc['nameShop'],
            soLuong: doc['soLuong'],
            imageUrl: doc['imageUrl'],
            address: doc['address'],
            emailSell: doc['emailSell'],
            emailBuy: doc['emailBuy'],
            createdAt: doc['createdAt'],
            price: doc['price'],
            priceAll: doc['priceAll'],
            status: doc['status'],
            hidenBuy: doc['hidenBuy'],
            hidenSell: doc['hidenSell'],
          ),
        ]);
      }
    }
    return items;
  }

  //update products
  Future<String> upDateProduct(
    String idPro,
    String soLuongDat,
    BuildContext context,
  ) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: idPro)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        String _id = item['id'];
        int slDat = int.tryParse(soLuongDat)!;
        int total = int.tryParse(item['total'].toString())!;

        if (slDat <= total) {
          if (_id == idPro) {
            await FirebaseFirestore.instance
                .collection('products')
                .doc(item.id)
                .update({'total': (total - slDat).toString()});
            return "ok";
          } else {
            print('Sai id');
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Số lượng sản phẩm không đủ !')),
            ),
          );
        }
      }
    }
    return "no";
  }

  //Lấy đơn hàng theo email buy , status chờ xác nhận
  Future<List<DonHang>> GetOrderByEmailBuyChoXacNhan(String emailBuy) async {
    List<DonHang> items = [];
    final statusR = "Chờ xác nhận";
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailBuy', isEqualTo: emailBuy)
            .where('status', isEqualTo: statusR)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          DonHang(
            id: doc['id'],
            idProducts: doc['idProduct'],
            name: doc['name'],
            nameShop: doc['nameShop'],
            soLuong: doc['soLuong'],
            imageUrl: doc['imageUrl'],
            address: doc['address'],
            emailSell: doc['emailSell'],
            emailBuy: doc['emailBuy'],
            createdAt: doc['createdAt'],
            price: doc['price'],
            priceAll: doc['priceAll'],
            status: doc['status'],
            hidenBuy: doc['hidenBuy'],
            hidenSell: doc['hidenSell'],
          ),
        ]);
      }
    }
    return items;
  }

  //Lấy đơn hàng theo email buy , status Chờ giao
  Future<List<DonHang>> GetOrderByEmailBuyChoGiao(String emailBuy) async {
    List<DonHang> items = [];
    final statusR = "Chờ giao";
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailBuy', isEqualTo: emailBuy)
            .where('status', isEqualTo: statusR)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          DonHang(
            id: doc['id'],
            idProducts: doc['idProduct'],
            name: doc['name'],
            nameShop: doc['nameShop'],
            soLuong: doc['soLuong'],
            imageUrl: doc['imageUrl'],
            address: doc['address'],
            emailSell: doc['emailSell'],
            emailBuy: doc['emailBuy'],
            createdAt: doc['createdAt'],
            price: doc['price'],
            priceAll: doc['priceAll'],
            status: doc['status'],
            hidenBuy: doc['hidenBuy'],
            hidenSell: doc['hidenSell'],
          ),
        ]);
      }
    }
    return items;
  }

  //Lấy đơn hàng theo email buy , status đã giao
  Future<List<DonHang>> GetOrderByEmailBuyDaGiao(String emailBuy) async {
    List<DonHang> items = [];
    // final statusR = "Đã giao";
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailBuy', isEqualTo: emailBuy)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          DonHang(
            id: doc['id'],
            idProducts: doc['idProduct'],
            name: doc['name'],
            nameShop: doc['nameShop'],
            soLuong: doc['soLuong'],
            imageUrl: doc['imageUrl'],
            address: doc['address'],
            emailSell: doc['emailSell'],
            emailBuy: doc['emailBuy'],
            createdAt: doc['createdAt'],
            price: doc['price'],
            priceAll: doc['priceAll'],
            status: doc['status'],
            hidenBuy: doc['hidenBuy'],
            hidenSell: doc['hidenSell'],
          ),
        ]);
      }
    }
    return items;
  }

  //lấy địa chỉ người mua bằng id address

  Future<List<Map<String, dynamic>>> getAddressById(String id) async {
    List<Map<String, dynamic>> items = [];
   
      final QuerySnapshot _query =
          await FirebaseFirestore.instance
              .collection('address')
              .where('id', isEqualTo: id)
              .get();
      if (_query.docs.isNotEmpty) {
        items.add({
          "name": _query.docs.first.get('name'),
          "telephone": _query.docs.first.get('telephone'),
          "address": _query.docs.first.get('address'),
        });
      }
    

    return items;
  }

  //Updated đơn hàng được duyệt
  Future<void> duyetDonHang(String id) async {
    final now = DateTime.now();
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await FirebaseFirestore.instance
            .collection('Order')
            .doc(item.id)
            .update({
              'status': "Chờ giao",
              'createdAt': now.toString(),
              'hidenBuy': false,
            });
      }
    }
  }

  //Updated đơn hàng được duyệt
  Future<void> updatedDaGiao(String id) async {
    final now = DateTime.now();
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await FirebaseFirestore.instance
            .collection('Order')
            .doc(item.id)
            .update({
              'status': "Đã giao",
              'createdAt': now.toString(),
              'hidenBuy': false,
            });
      }
    }
  }

  //Updated đơn hàng hủy duyệt
  Future<void> huyDonHang(String id) async {
    final now = DateTime.now();
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await FirebaseFirestore.instance
            .collection('Order')
            .doc(item.id)
            .update({
              'status': "Hủy",
              'createdAt': now.toString(),
              'hidenBuy': false,
            });
      }
    }
  }

  //Updated đơn hàng  ddax duoc nhan
  Future<void> updateDonHangdaDuocNhan(String id) async {
    final now = DateTime.now();
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await FirebaseFirestore.instance
            .collection('Order')
            .doc(item.id)
            .update({
              'status': "Đã nhận hàng",
              'createdAt': now.toString(),
              'hidenBuy': false,
            });
      }
    }
  }

  //Updated đơn hàng đã được đánh giá
  Future<void> updateDonHangdaDuocDanhGia(String id) async {
    final now = DateTime.now();
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await FirebaseFirestore.instance
            .collection('Order')
            .doc(item.id)
            .update({
              'status': "Đã đánh giá",
              'createdAt': now.toString(),
              'hidenBuy': false,
            });
      }
    }
  }

  // //thêm đánh giá
  Future<void> SaveReview(Review review) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: review.email)
            .get();
    if (_query.docs.isNotEmpty) {
      final name = _query.docs.first.get('name');
      await FirebaseFirestore.instance.collection('review').add({
        "id": review.id,
        "email": review.email,
        "idProducts": review.idProducts,
        "idOrder": review.idOrder,
        "star": review.start,
        "select": review.slelect,
        "review": review.review,
        "nameBuy": name,
      });
    }
  }

  // //Lấy đánh giá id producst
  Future<List<Review>> getReview(String id) async {
    List<Review> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('review')
            .where('idProducts', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        items.addAll([
          Review(
            id: item['id'],
            email: item['email'],
            idProducts: item['idProducts'],
            idOrder: item['idOrder'],
            start: item['star'],
            slelect: item['select'],
            review: item['review'],
            nameBuy: item['nameBuy'],
          ),
        ]);
      }
    }
    return items;
  }

  //kiểm tra sản phẩm đã đánh giá chưa

  // //Lấy đánh giá id producst
  Future<bool> checkReview(String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('review')
            .where('idOrder', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      return true;
    }
    return false;
  }

  //Update ẩn thông báo đặt sản phẩm
  Future<void> updateHidenBuy(String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      //updated hidenBuyy
      for (var item in _query.docs) {
        await FirebaseFirestore.instance
            .collection('Order')
            .doc(item.id)
            .update({'hidenBuy': true});
      }
    }
  }

  //Update ẩn thông báo bán sản phẩm
  Future<void> updateHidenSell(String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      //updated hidenSell
      for (var item in _query.docs) {
        await FirebaseFirestore.instance
            .collection('Order')
            .doc(item.id)
            .update({'hidenSell': true});
      }
    }
  }

  //updated information user
  Future<void> UpdateInforUser(String email, String image, String name) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      final item = _query.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(item).update({
        'image': image,
        'name': name,
      });
    }
  }

  //Xóa địa chỉ
  Future<void> DeleteDiaChi(String id, String email) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .where('id', isEqualTo: id)
            .get();

    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        await doc.reference.delete();
      }
    }
  }

  //lấy số lượng sản phẩm
  Future<String> GetCountProducts(String email) async {
    String result = "";
    int count = 0;
    int count2 = 0;

    try {
      final QuerySnapshot query1 =
          await FirebaseFirestore.instance
              .collection('products')
              .where('email', isEqualTo: email)
              .get();

      if (query1.docs.isNotEmpty) {
        for (var item in query1.docs) {
          count += int.tryParse(item['total'].toString()) ?? 0;
        }
      }

      final QuerySnapshot query2 =
          await FirebaseFirestore.instance
              .collection('Order')
              .where('emailSell', isEqualTo: email)
              .get();

      if (query2.docs.isNotEmpty) {
        for (var item in query2.docs) {
          count2 += int.tryParse(item['soLuong'].toString()) ?? 0;
        }
      }

      result = "$count:$count2";
    } catch (e) {
      print("Error: $e");
      result = "0:0";
    }

    return result;
  }

  //lấy tát cả sản phẩm
  Future<List<Product>> getAllProduct() async {
    List<Product> items = [];
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('hiden', isEqualTo: false)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.addAll([
          Product(
            id: doc['id'],
            name: doc['name'],
            description: doc['description'],
            address: doc['address'],
            email: doc['email'],
            imageUrl: doc['imageUrl'],
            type: doc['type'],
            price: doc['price'],
            total: doc['total'].toString(),
            createdAt: doc['createdAt'],
            hiden: doc['hiden'],
          ),
        ]);
      }
    }
    return items;
  }

  //kiểm tra số lượng đặt quá với số lượng bán hay không?

  Future<String> checkTotal(List<Map<String, dynamic>> itemsbuy) async {
    for (int i = 0; i < itemsbuy.length; i++) {
      final QuerySnapshot query =
          await FirebaseFirestore.instance
              .collection('products')
              .where('id', isEqualTo: itemsbuy[i]['idProduct'])
              .get();

      if (query.docs.isNotEmpty) {
        int firestoreTotal = int.tryParse(query.docs.first['total'].toString())!;
        int requestedTotal = int.tryParse(itemsbuy[i]['total'].toString()) ?? 0;
        
        if (requestedTotal > firestoreTotal || firestoreTotal == 0) {
          return 'no'; // Ngừng kiểm tra, có sản phẩm không đủ hàng
        }
      } else {
        return 'no'; // Không tìm thấy sản phẩm → cũng coi như lỗi
      }
    }

    return 'ok'; // Tất cả sản phẩm đều đủ hàng
  }

  //xóa giỏ hàng khi đặt hàng thành công
  Future<void> deleteCarts(List<Map<String, dynamic>> items) async {
    for (int i = 0; i < items.length; i++) {
      final QuerySnapshot _query =
          await FirebaseFirestore.instance
              .collection('carts')
              .where('idCart', isEqualTo: items[i]['idCart'])
              .get();
      if (_query.docs.isNotEmpty) {
        for (var doc in _query.docs) {
          await FirebaseFirestore.instance
              .collection('carts')
              .doc(doc.id)
              .delete();
        }
      }
    }
  }

  //Cập nhật lại số lượng đơn hàng 
   Future<void> updateTotal(List<Map<String, dynamic>> items) async {
    for (int i = 0; i < items.length; i++) {
      final QuerySnapshot _query =
          await FirebaseFirestore.instance
              .collection('products')
              .where('id', isEqualTo: items[i]['idProduct'])
              .get();
      if (_query.docs.isNotEmpty) {
        final doc= _query.docs.first.id;
        int tongBefore = int.tryParse(_query.docs.first.get('total').toString())!;
        int tongMua = int.tryParse(items[i]['total'].toString())!;
       await FirebaseFirestore.instance.collection('products').doc(doc).update({'total':(tongBefore - tongMua)});
      }
    }
  }
}
