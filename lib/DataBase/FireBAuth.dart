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
  //Hàm random số nguyên
  String generateVerificationCode(int length) {
    const chars = '0123456789';
    Random random = Random();
    return List.generate(
      length,
      (index) => chars[random.nextInt(chars.length)],
    ).join();
  }

  //Hàm gửi mã code về tài khoản email người dùng
  Future<void> sendVerificationEmail(
    //email người dùng
    String recipientEmail,
    //Code
    String verificationCode,
  ) async {
    //Thông tin tài khoản
    String username = '23211TT4425@mail.tdc.edu.vn';
    String password = 'drvh lhel chui kfga';

    // Sử dụng server Gmail
    final smtpServer = gmail(username, password);

    //Phần nội dung
    final message =
        Message()
          ..from = Address(username, 'Nama') // Tên của ứng dụng bạn
          ..recipients.add(recipientEmail)
          ..subject =
              'Mã xác thực của bạn' //tiêu đề
          ..text = 'Mã xác thực của bạn là: $verificationCode'; //body

    try {
      //Send thông báo
      final sendReport = await send(message, smtpServer);
    } catch (e) {
      //Bắt lỗi
      print('Lỗi khi gửi email: $e');
    }
  }

  //Hàm kiểm tra tài khoản người dùng đã tồn tại hay chưa!
  Future<int> checkUsers(String email) async {
    //Truy cập vào table users firebase
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .limit(1)
            .get(); //lấy

    //kiểm tra email tồn tại hay không
    if (result.docs.isNotEmpty) {
      // Email đã tồn tại
      return 1;
    } else {
      // Email chưa tồn tại
      return 0;
    }
  }

  //Hàm gửi mã
  Future<void> registerWithEmail(String email, BuildContext context) async {
    try {
      // Tạo mã xác nhận ngẫu nhiên
      String verificationCode = generateVerificationCode(6);

      // Gửi mã xác thực qua email
      await sendVerificationEmail(email, verificationCode);

      // Lưu mã vào table verification_codes Firebase
      await FirebaseFirestore.instance.collection('verification_codes').add({
        'email': email,
        'code': verificationCode,
        'createdAt': Timestamp.now(),
      });
    } catch (e) {
      //Bắt lỗi
      print('Lỗi đăng ký: $e');
    }
  }

  //Hàm xóa code
  Future<void> TimeCode(String email) async {
    //Truy xuất vào table verification_codes Firebase
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('verification_codes')
            .where('email', isEqualTo: email)
            .get();

    //kiểm tra nếu có xóa
    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        //Xóa
        await doc.reference.delete();
      }
    }
  }

  //Hàm kiểm tra code
  Future<void> checkCode(
    //email người dùng
    String email,
    //Mã code nhập vào
    String code,
    //lấy Context để thông báo lỗi luôn trong này
    BuildContext context,
  ) async {
    //Truy xuất vào table verification_codes Firebase
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('verification_codes')
            .where('email', isEqualTo: email)
            .where('code', isEqualTo: code)
            .limit(1)
            .get();

    //Kiểm tra nếu Đúng thì add thông tin users vào table users
    if (result.docs.isNotEmpty) {
      //random id
      String code = generateVerificationCode(5);
      //thêm user
      await FirebaseFirestore.instance.collection('users').add({
        'email': email,
        'image':
            "https://i.pinimg.com/736x/c6/e5/65/c6e56503cfdd87da299f72dc416023d4.jpg",
        'name': "user_${code.toString()}",
        'createdAt': Timestamp.now(),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Sai code , thử lại !'))),
      );
    }
  }

  //Hàm thêm lịch sử tìm kiếm
  Future<void> ThemHistory(String email, String nameSearch) async {
    //thêm thông tin tìm kiếm vào table history Firebase
    await FirebaseFirestore.instance.collection('history').add({
      "name": nameSearch,
      "email": email,
    });
  }

  //Hàm lấy lịch sử tìm kiếm
  Future<void> LayHistory(String email, List<Map<String, dynamic>> list) async {
    //Truy xuất vào table history trên Firebase
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('history')
            .where('email', isEqualTo: email)
            .get();
    //Kiểm tra nếu tồn tai thì thêm vào list
    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        list.addAll([
          {"name": doc['name']},
        ]);
      }
    }
  }

  //Hàm kiểm tra code để đăng nhập
  Future<int> checkCodeLogin(String email, String code) async {
    //Truy xuất vào table verification_codes Firebase
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('verification_codes')
            .where('email', isEqualTo: email)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();

    //Nếu tồn tại
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
  //Hàm kiểm tra đăng nhập bằng code
  Future<int> CheckLoGin(String email, BuildContext context) async {
    //Truy xuất vào table users trên Firebase
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();
    //Nếu tồn tại gửi thông báo kiểm tra hộp thư
    if (result.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Kiểm tra hộp thư mã tồn tại 60 giây')),
        ),
      );
      //gửi code
      await registerWithEmail(email, context);

      return 1;
    } else {
      return 0;
    }
  }

  //Hàm xóa lịch sử tìm kiếm
  Future<void> XoaHistory(String email) async {
    //Truy xuất vào table history trên Firebase
    final result =
        await FirebaseFirestore.instance
            .collection('history')
            .where('email', isEqualTo: email)
            .get();

    //nếu tồn tại xóa hết lịch sử
    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        //Xóa tất cả
        await doc.reference.delete();
      }
    }
  }

  //Hàm lấy tát cả sản phẩm
  Future<List<Product>> getAllProducts() async {
    //New list type Product
    List<Product> listProducts = [];
    int count = 0;

    //Truy xuất vào table products trên Firebase
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('hiden', isEqualTo: false)
            .get();
    //Nếu tồn tại add vào list rồi trả Về
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        //list add products
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
    //trả về listProdut
    return listProducts;
  }

  //hàm set lại Sản phẩm
  Future<void> UpdatedInforProducts(
    String id,
    String email,
    Product products,
  ) async {
    //Truy xuất vào table products rên Firebase
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: id)
            .where('email', isEqualTo: email)
            .get();
    //Nếu tồn tại set lại
    if (_query.docs.isNotEmpty) {
      final id = _query.docs.first.id;
      await FirebaseFirestore.instance.collection('products').doc(id).set({
        "name": products.name.toString(),
        "id": products.id,
        "price": products.price,
        "total": products.total,
        "email": products.email,
        "address": products.address,
        "type": products.type,
        "imageUrl": products.imageUrl,
        "createdAt": products.createdAt,
        "description": products.description.toString(),
        "hiden": false,
      });
    }
  }

  //Lấy sản phẩm theo email người dùng
  Future<List<Product>> getAllProductsUser(String email) async {
    //New list Product
    List<Product> listProducts = [];
    int count = 0;

    //Truy xuất vào table products trên FireBase
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .where('hiden', isEqualTo: false)
            .get();
    //Nếu tồn tại add vào list
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

    //Trả về list<Product>
    return listProducts;
  }

  //Lấy sản phẩm theo email người dùng có trong đơn hàng
  Future<List<Product>> getAllProductsUseSell(String email) async {
    //New list
    List<Product> listProducts = [];
    int count = 0;
    //Truy xuất vào table product trên FireBase
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .where('hiden', isEqualTo: false)
            .get();
    //nếu tồn tại
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        //truy xuất vào table Order trên Firebase
        final QuerySnapshot _query2 =
            await FirebaseFirestore.instance
                .collection('Order')
                .where('idProduct', isEqualTo: doc['id'])
                .get();
        //Nếu không rỗng
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
    //Trả về list<product>
    return listProducts;
  }

  //Hàm ẩn sản phẩm nếu sản phẩm đó có đơn hàng ngược lại xóa
  Future<void> hidenProducts(String id) async {
    bool check = false;
    //Truy xuất vào table products Trên Firebase
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: id)
            .get();
    //Nếu tồn tại
    if (_query.docs.isNotEmpty) {
      //Truy xuất vào table Order bằng id
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

  // Function to display product details based on product ID
  Future<String> showProducts(
    String id,
    List<Map<String, dynamic>> items,
  ) async {
    String? nameUser; // Stores the name of the user
    String? total; // Stores the total number of products
    String? result; // Final result containing user name and total products
    String? decription; // Product description
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: id)
            .get(); // Fetch product by ID
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        // Add product details to the 'items' list
        items.addAll([
          {
            "name": doc['name'],
            "id": doc['id'],
            "price": doc['price'],
            "total": doc['total'],
            "email":
                doc['email'] ??
                'khong-co-email', // Use default value if email is null
            "address": doc['address'],
            "type": doc['type'],
            "imageUrl": doc['imageUrl'],
            "createdAt": doc['createdAt'],
            "description": doc['description'],
          },
        ]);
      }

      // Fetch user details based on email and total product count
      nameUser = await getName(items[0]['email']);
      total = await getToTalProducts(items[0]['email']);

      result =
          "${nameUser.toString()}+${total.toString()}"; // Combine user name and total
      print(decription.toString());
    }
    return result.toString(); // Return combined result
  }

  // Function to fetch the name of the user based on their email
  Future<String> getName(String email) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email.toString())
            .get();
    if (_query.docs.isNotEmpty) {
      String resultName = _query.docs.first.get('name');
      String resultImage = _query.docs.first.get('image');
      return "${resultName}+${resultImage}"; // Return name and image URL
    }
    return "NO"; // Return "NO" if user not found
  }

  // Function to fetch the total number of products based on user email
  Future<String> getToTalProducts(String email) async {
    int i = 0; // Counter for products
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        i++; // Increment count for each product
      }
      return i.toString(); // Return total count of products
    }

    return "0"; // Return "0" if no products found
  }

  // Function to save cart item
  Future<void> saveCarts(CartItem cartItem) async {
    String reslut = await UpdatedTotal(
      cartItem.idProduct,
    ); // Check if product already exists in the cart
    List<String> tach = reslut.split(
      ':',
    ); // Split result into total and document ID
    String? totalOut = tach[0].toString();
    String? uId = tach[1].toString();
    print(reslut);
    print(totalOut.toString());

    if (totalOut == "0") {
      // If product is not in the cart, add it
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
      // If product already in the cart, update quantity
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

  // Function to display products in the cart for a user
  Future<void> getSaveCarts(
    List<Map<String, dynamic>> items,
    String email,
  ) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('carts')
            .where('emailAdd', isEqualTo: email)
            .get(); // Fetch cart items based on user email

    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        // Add cart items to 'items' list
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

  // Function to check and update total quantity of a product in the cart
  Future<String> UpdatedTotal(String id) async {
    String? reslut;
    String? docID = "0"; // Default docID
    int _count;
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('carts')
            .where('idProduct', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      docID = _query.docs.first.id;
      _count = int.tryParse(_query.docs.first.get('total').toString())!;
      reslut = "${_count}:${docID}"; // Return count and document ID
    } else {
      reslut = "0:0"; // Return "0:0" if product not found
    }

    return reslut.toString(); // Return result as string
  }

  // Function to fetch the UID of a product based on its ID
  Future<String> UID(String id) async {
    String? reslut;
    String? docID = "0"; // Default document ID
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      docID = _query.docs.first.id; // Get document ID for the product
      reslut = "${docID}"; // Return document ID
    } else {
      reslut = "0:0"; // Return default value if not found
    }

    return reslut.toString(); // Return result as string
  }

  // Function to delete an item from the cart
  Future<void> DeleteCarts(String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('carts')
            .where('idCart', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        await item.reference.delete(); // Delete item from cart
      }
    }
  }

  // Function to check if a product is ordered by the same user
  Future<int> CheckOrder(String email, String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('email', isEqualTo: email)
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      return 0; // Return 0 if product exists in user's orders
    }
    return 1; // Return 1 if product is not found in user's orders
  }

  // Function to fetch all user information based on email
  Future<String> GetAllUser(String email) async {
    String? _docID = "0"; // Default document ID
    String? _result;
    String? _imageUrl;
    String? _name;
    Timestamp _timeStamp;

    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get(); // Fetch user data by email
    if (_query.docs.isNotEmpty) {
      _docID = _query.docs.first.id;
      _imageUrl = _query.docs.first.get('image');
      _name = _query.docs.first.get('name');
      _timeStamp = _query.docs.first.get('createdAt');

      _result =
          "${_docID}+${_imageUrl}+${_name}+${_timeStamp}"; // Combine all user details into a result
      return _result.toString(); // Return the combined result
    }
    return "0"; // Return "0" if user not found
  }

  // Thêm địa chỉ giao hàng mới vào Firestore
  Future<void> SaveAddress(
    String email, // Email của người dùng
    String name, // Tên người nhận
    String address, // Địa chỉ giao hàng
    String telephone, // Số điện thoại người nhận
  ) async {
    String? _id = generateVerificationCode(10); // Tạo mã ID cho địa chỉ

    // Kiểm tra xem đã có địa chỉ nào với email này chưa
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      // Nếu đã có địa chỉ, thêm một địa chỉ mới với select = false
      await FirebaseFirestore.instance.collection('address').add({
        "id": _id,
        "email": email,
        "address": address,
        "name": name,
        "telephone": telephone,
        "select": false, // Địa chỉ này chưa được chọn
      });
    } else {
      // Nếu chưa có địa chỉ, thêm một địa chỉ mới với select = true (địa chỉ mặc định)
      await FirebaseFirestore.instance.collection('address').add({
        "id": _id,
        "email": email,
        "address": address,
        "name": name,
        "telephone": telephone,
        "select": true, // Địa chỉ này được chọn mặc định
      });
    }
  }

  // Lấy danh sách địa chỉ từ Firebase theo email
  Future<List<Map<String, dynamic>>> GetAddress(String email) async {
    List<Map<String, dynamic>> items = [];
    // Truy vấn tất cả địa chỉ của người dùng theo email
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      // Thêm các địa chỉ vào danh sách items
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
    return items; // Trả về danh sách địa chỉ
  }

  // Lấy danh sách địa chỉ từ Firebase với thông tin về trường 'select'
  Future<List<Map<String, dynamic>>> GetAddress2(String email) async {
    List<Map<String, dynamic>> items = [];
    // Truy vấn tất cả địa chỉ của người dùng theo email
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      // Thêm các địa chỉ vào danh sách items, bao gồm trường 'select'
      for (var doc in _query.docs) {
        items.addAll([
          {
            "id": doc['id'],
            "email": doc['email'],
            "address": doc['address'],
            "name": doc['name'],
            "telephone": doc['telephone'],
            "select": doc['select'], // Thêm trường 'select' vào kết quả
          },
        ]);
      }
    }
    return items; // Trả về danh sách địa chỉ
  }

  // Xóa một địa chỉ khỏi Firestore theo ID
  Future<void> DeleteAddress(String id) async {
    // Truy vấn địa chỉ có ID trùng khớp
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('id', isEqualTo: id)
            .get();
    if (_query.docs.isNotEmpty) {
      // Xóa địa chỉ khỏi Firestore
      for (var item in _query.docs) {
        await item.reference.delete();
      }
    }
  }

  // Lấy địa chỉ giao hàng được chọn (select = true)
  Future<List<Map<String, dynamic>>> GetAddressSelected(String email) async {
    List<Map<String, dynamic>> items = [];
    bool select = true; // Truy vấn địa chỉ đã được chọn (select = true)
    // Truy vấn địa chỉ có email và select = true
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .where('select', isEqualTo: select)
            .get();
    if (_query.docs.isNotEmpty) {
      // Thêm các địa chỉ vào danh sách items
      for (var doc in _query.docs) {
        items.addAll([
          {
            "id": doc['id'],
            "email": doc['email'],
            "address": doc['address'],
            "name": doc['name'],
            "telephone": doc['telephone'],
            "select": doc['select'], // Thêm trường 'select' vào kết quả
          },
        ]);
      }
    }
    return items; // Trả về danh sách địa chỉ đã chọn
  }

  // Cập nhật trường 'select' của địa chỉ (địa chỉ được chọn làm địa chỉ giao hàng)
  Future<void> UpdateSelectedAddress(String email, String idItem) async {
    // Truy vấn tất cả địa chỉ của người dùng theo email
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .get();
    if (_query.docs.isNotEmpty) {
      // Cập nhật địa chỉ đã chọn thành select = true và các địa chỉ khác thành select = false
      for (var item in _query.docs) {
        String _id = item['id'];
        if (_id == idItem) {
          // Cập nhật địa chỉ được chọn
          await FirebaseFirestore.instance
              .collection('address')
              .doc(item.id)
              .update({'select': true});
        } else {
          // Cập nhật địa chỉ không được chọn
          await FirebaseFirestore.instance
              .collection('address')
              .doc(item.id)
              .update({'select': false});
        }
      }
    }
  }

  // Lưu đơn hàng mới vào Firestore
  Future<void> saveOrder(DonHang _donhang) async {
    // Thêm đơn hàng mới vào Firestore
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

  // Lưu đơn hàng mới vào Firestore (phiên bản thứ hai, giống phiên bản đầu)
  Future<void> saveOrder2(DonHang _donhang) async {
    // Thêm đơn hàng mới vào Firestore
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

  // Lấy danh sách đơn hàng theo email người bán
  Future<List<DonHang>> getOrderSell(String emailSell) async {
    List<DonHang> items = [];
    // Truy vấn đơn hàng trong Firestore có trường emailSell = emailSell
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailSell', isEqualTo: emailSell)
            .get();

    // Nếu có dữ liệu thì thêm vào danh sách
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

  // Lấy danh sách đơn hàng theo email người bán và chưa bị ẩn (hidenSell = false)
  Future<List<Map<String, dynamic>>> getOrderByEmailSell(
    String emailSell,
  ) async {
    bool hidenSell = false;
    List<Map<String, dynamic>> items = [];

    // Truy vấn đơn hàng có emailSell và hidenSell = false
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

        // Truy vấn thông tin người mua từ bảng users
        final QuerySnapshot _query2 =
            await FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: email)
                .get();

        // Lấy tên người mua nếu tồn tại
        if (_query2.docs.isNotEmpty) {
          userNameBuy = _query2.docs.first.get('name');
        }

        // Thêm thông tin đơn hàng và người mua vào danh sách
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

  // Lấy danh sách đơn hàng theo email người mua và chưa bị ẩn (hidenBuy = false)
  Future<List<Map<String, dynamic>>> GetOrderByEmailBuy(String emailBuy) async {
    bool hidenBuy = false;
    List<Map<String, dynamic>> items = [];

    // Truy vấn đơn hàng có emailBuy và hidenBuy = false
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

        // Thêm thông tin đơn hàng vào danh sách
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

  // Lấy danh sách đơn hàng theo email người mua, dạng đối tượng DonHang
  Future<List<DonHang>> GetOrderByEmailSell(String emailBuy) async {
    List<DonHang> items = [];

    // Truy vấn đơn hàng có emailBuy
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailBuy', isEqualTo: emailBuy)
            .get();

    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        // Tạo đối tượng DonHang và thêm vào danh sách
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

  // Lấy danh sách đơn hàng theo email người bán (bản sao khác của getOrderSell)
  Future<List<DonHang>> getOrderSell2(String emailSell) async {
    List<DonHang> items = [];

    // Truy vấn đơn hàng có emailSell
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailSell', isEqualTo: emailSell)
            .get();

    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        // Tạo đối tượng DonHang và thêm vào danh sách
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

  // Cập nhật lại số lượng sản phẩm trong kho sau khi đặt hàng
  Future<String> upDateProduct(
    String idPro, // ID sản phẩm cần cập nhật
    String soLuongDat, // Số lượng đặt
    BuildContext context, // Context để hiển thị thông báo nếu cần
  ) async {
    // Truy vấn sản phẩm theo id
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

        // Kiểm tra nếu còn đủ hàng
        if (slDat <= total) {
          if (_id == idPro) {
            // Cập nhật lại số lượng sản phẩm
            await FirebaseFirestore.instance
                .collection('products')
                .doc(item.id)
                .update({'total': (total - slDat).toString()});
            return "ok"; // Thành công
          } else {
            print('Sai id'); // Không trùng id
          }
        } else {
          // Nếu không đủ hàng thì hiển thị thông báo
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(child: Text('Số lượng sản phẩm không đủ !')),
            ),
          );
        }
      }
    }

    return "no"; // Cập nhật thất bại
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

  // Lấy danh sách đơn hàng theo email người mua, lọc theo các đơn có trạng thái "Đã giao"
  Future<List<DonHang>> GetOrderByEmailBuyDaGiao(String emailBuy) async {
    List<DonHang> items = [];

    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('Order')
            .where('emailBuy', isEqualTo: emailBuy)
            .get();

    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        // Kiểm tra trạng thái là "Đã giao"
        if (doc['status'] == "Đã giao") {
          items.add(
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
          );
        }
      }
    }

    return items;
  }

  // Lấy thông tin địa chỉ người dùng dựa theo id địa chỉ
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

  // Cập nhật đơn hàng sang trạng thái "Chờ giao"
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
              'status': "Chờ giao", // Trạng thái sau khi duyệt
              'createdAt': now.toString(), // Cập nhật thời gian
              'hidenBuy': false, // Hiển thị thông báo cho người mua
            });
      }
    }
  }

  // Cập nhật đơn hàng sang trạng thái "Đã giao"
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
              'status': "Đã giao", // Trạng thái sau khi giao hàng
              'createdAt': now.toString(), // Cập nhật thời gian
              'hidenBuy': false, // Hiển thị thông báo cho người mua
            });
      }
    }
  }

  // Cập nhật đơn hàng sang trạng thái "Hủy"
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
              'status': "Hủy", // Trạng thái sau khi bị hủy
              'createdAt': now.toString(), // Cập nhật thời gian
              'hidenBuy': false, // Hiển thị thông báo cho người mua
            });
      }
    }
  }

  // Cập nhật trạng thái đơn hàng thành "Đã nhận hàng"
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
              'status': "Đã nhận hàng", // cập nhật trạng thái
              'createdAt': now.toString(), // cập nhật thời gian
              'hidenBuy': false, // hiển thị thông báo bên phía người mua
            });
      }
    }
  }

  // Cập nhật trạng thái đơn hàng thành "Đã đánh giá"
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
              'status': "Đã đánh giá", // cập nhật trạng thái
              'createdAt': now.toString(), // cập nhật thời gian
              'hidenBuy': false, // hiển thị thông báo bên phía người mua
            });
      }
    }
  }

  // Thêm đánh giá sản phẩm vào Firestore
  Future<void> SaveReview(Review review) async {
    // Lấy tên người mua từ bảng users dựa theo email
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: review.email)
            .get();

    if (_query.docs.isNotEmpty) {
      final name = _query.docs.first.get('name');

      // Lưu đánh giá vào collection 'review'
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

  // Lấy danh sách đánh giá theo id sản phẩm
  Future<List<Review>> getReview(String id) async {
    List<Review> items = [];

    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('review')
            .where('idProducts', isEqualTo: id)
            .get();

    if (_query.docs.isNotEmpty) {
      for (var item in _query.docs) {
        items.add(
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
        );
      }
    }

    return items;
  }

  // Kiểm tra đơn hàng đã được đánh giá chưa (dựa theo id đơn hàng)
  Future<bool> checkReview(String id) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('review')
            .where('idOrder', isEqualTo: id)
            .get();

    if (_query.docs.isNotEmpty) {
      return true; // Đã đánh giá
    }
    return false; // Chưa đánh giá
  }

  // Cập nhật trạng thái ẩn thông báo đặt hàng (ẩn bên phía người mua)
  Future<void> updateHidenBuy(String id) async {
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
            .update({'hidenBuy': true});
      }
    }
  }

  // Cập nhật trạng thái ẩn thông báo bán hàng (ẩn bên phía người bán)
  Future<void> updateHidenSell(String id) async {
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
            .update({'hidenSell': true});
      }
    }
  }

  // Cập nhật thông tin người dùng (ảnh và tên)
  Future<void> UpdateInforUser(String email, String image, String name) async {
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    if (_query.docs.isNotEmpty) {
      final item = _query.docs.first.id;

      // Cập nhật lại ảnh và tên người dùng
      await FirebaseFirestore.instance.collection('users').doc(item).update({
        'image': image,
        'name': name,
      });
    }
  }

  // Xóa địa chỉ người dùng dựa theo id và email
  Future<void> DeleteDiaChi(String id, String email) async {
    final QuerySnapshot result =
        await FirebaseFirestore.instance
            .collection('address')
            .where('email', isEqualTo: email)
            .where('id', isEqualTo: id)
            .get();

    if (result.docs.isNotEmpty) {
      for (var doc in result.docs) {
        await doc.reference.delete(); // Xóa document địa chỉ
      }
    }
  }

  // Hàm lấy số lượng sản phẩm đang bán và số lượng đã bán của người dùng theo email
  Future<String> GetCountProducts(String email) async {
    String result = "";
    int count = 0; // Tổng số lượng sản phẩm đang có
    int count2 = 0; // Tổng số lượng sản phẩm đã bán (từ đơn hàng)

    try {
      // Lấy danh sách sản phẩm của người dùng từ collection 'products'
      final QuerySnapshot query1 =
          await FirebaseFirestore.instance
              .collection('products')
              .where('email', isEqualTo: email)
              .get();

      // Tính tổng số lượng sản phẩm từ dữ liệu lấy được
      if (query1.docs.isNotEmpty) {
        for (var item in query1.docs) {
          count += int.tryParse(item['total'].toString()) ?? 0;
        }
      }

      // Lấy danh sách đơn hàng mà người dùng là người bán từ collection 'Order'
      final QuerySnapshot query2 =
          await FirebaseFirestore.instance
              .collection('Order')
              .where('emailSell', isEqualTo: email)
              .get();

      // Tính tổng số lượng sản phẩm đã bán từ dữ liệu đơn hàng
      if (query2.docs.isNotEmpty) {
        for (var item in query2.docs) {
          count2 += int.tryParse(item['soLuong'].toString()) ?? 0;
        }
      }

      // Gộp hai giá trị lại thành chuỗi "đang có:đã bán"
      result = "$count:$count2";
    } catch (e) {
      // Bắt lỗi và trả về giá trị mặc định
      print("Error: $e");
      result = "0:0";
    }

    return result;
  }

  // Hàm lấy danh sách tất cả sản phẩm đang hiển thị (hiden == false)
  Future<List<Product>> getAllProduct() async {
    List<Product> items = [];

    // Lấy danh sách sản phẩm chưa bị ẩn (hiden = false)
    final QuerySnapshot _query =
        await FirebaseFirestore.instance
            .collection('products')
            .where('hiden', isEqualTo: false)
            .get();

    // Chuyển dữ liệu từ Firestore thành danh sách đối tượng Product
    if (_query.docs.isNotEmpty) {
      for (var doc in _query.docs) {
        items.add(
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
        );
      }
    }

    return items;
  }

  // Hàm kiểm tra xem số lượng sản phẩm đặt có vượt quá số lượng tồn kho hay không
  Future<String> checkTotal(List<Map<String, dynamic>> itemsbuy) async {
    // Duyệt qua từng sản phẩm được đặt
    for (int i = 0; i < itemsbuy.length; i++) {
      // Tìm sản phẩm theo id trong Firestore
      final QuerySnapshot query =
          await FirebaseFirestore.instance
              .collection('products')
              .where('id', isEqualTo: itemsbuy[i]['idProduct'])
              .get();

      if (query.docs.isNotEmpty) {
        // Lấy số lượng tồn kho từ dữ liệu Firestore
        int firestoreTotal =
            int.tryParse(query.docs.first['total'].toString())!;
        // Số lượng mà người dùng muốn mua
        int requestedTotal = int.tryParse(itemsbuy[i]['total'].toString()) ?? 0;

        // Nếu số lượng muốn mua vượt quá tồn kho hoặc tồn kho bằng 0 thì trả về 'no'
        if (requestedTotal > firestoreTotal || firestoreTotal == 0) {
          return 'no';
        }
      } else {
        // Nếu không tìm thấy sản phẩm thì cũng coi như không đủ hàng
        return 'no';
      }
    }

    // Nếu tất cả sản phẩm đều đủ hàng thì trả về 'ok'
    return 'ok';
  }

  // Hàm xóa các sản phẩm trong giỏ hàng sau khi đặt hàng thành công
  Future<void> deleteCarts(List<Map<String, dynamic>> items) async {
    for (int i = 0; i < items.length; i++) {
      // Tìm giỏ hàng theo idCart
      final QuerySnapshot _query =
          await FirebaseFirestore.instance
              .collection('carts')
              .where('idCart', isEqualTo: items[i]['idCart'])
              .get();

      // Xóa từng document nếu tìm thấy
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

  // Hàm cập nhật lại số lượng tồn kho của sản phẩm sau khi đặt hàng
  Future<void> updateTotal(List<Map<String, dynamic>> items) async {
    for (int i = 0; i < items.length; i++) {
      // Tìm sản phẩm trong Firestore theo idProduct
      final QuerySnapshot _query =
          await FirebaseFirestore.instance
              .collection('products')
              .where('id', isEqualTo: items[i]['idProduct'])
              .get();

      if (_query.docs.isNotEmpty) {
        final doc = _query.docs.first.id; // Lấy document ID
        int tongBefore =
            int.tryParse(_query.docs.first.get('total').toString())!;
        int tongMua = int.tryParse(items[i]['total'].toString())!;

        // Cập nhật lại số lượng tồn kho = tồn kho cũ - số lượng mua
        await FirebaseFirestore.instance.collection('products').doc(doc).update(
          {'total': (tongBefore - tongMua)},
        );
      }
    }
  }
}
