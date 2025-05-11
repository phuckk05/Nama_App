import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nama_app/Screens/ScreenProcessScreen.dart';
import 'package:nama_app/Screens/ScreenStart.dart';

// Hàm main() là điểm bắt đầu của ứng dụng Flutter
void main() async {
  // Đảm bảo rằng Flutter đã được khởi tạo đầy đủ trước khi thực hiện các thao tác bất đồng bộ
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase. Lệnh này giúp bạn sử dụng các dịch vụ của Firebase trong ứng dụng
  await Firebase.initializeApp();

  // Cài đặt màn hình chỉ hiển thị ở chế độ dọc
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Chỉ cho phép chế độ dọc (portrait)
  ]);

  // Chạy ứng dụng MaterialApp, bắt đầu từ màn hình GiaoDienBatDau
  runApp(
    MaterialApp(
      // Cài đặt màn hình đầu tiên mà ứng dụng hiển thị
      home:  ProcessSccreen(email: "ctai40293@gmail.com",), // GiaoDienBatDau là màn hình đầu tiên khi ứng dụng được mở
      debugShowCheckedModeBanner: false, // Tắt banner debug trên góc phải màn hình khi chạy ứng dụng
    ),
  );
}
