import 'package:flutter/material.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class NotificationItem {
  final String title;
  final String time;
  final String category;
  bool isRead;
  final IconData icon;

  NotificationItem({
    required this.title,
    required this.time,
    required this.category,
    required this.isRead,
    required this.icon,
  });
}

class GiaoDienThongBao extends StatefulWidget {
  final String? email;
  const GiaoDienThongBao({Key? key, this.email}):super(key: key);

  @override
  State<GiaoDienThongBao> createState() => _GiaoDienThongBaoState();
}

class _GiaoDienThongBaoState extends State<GiaoDienThongBao> with SingleTickerProviderStateMixin {
   late TabController _tabController;

  List<NotificationItem> allNotifications = [
    NotificationItem(
      title: "Bạn có đơn hàng mới",
      time: "2 phút trước",
      category: "Giao dịch",
      isRead: false,
      icon: Icons.shopping_cart,
    ),
    NotificationItem(
      title: "Ưu đãi 50% hôm nay!",
      time: "1 giờ trước",
      category: "Khuyến mãi",
      isRead: true,
      icon: Icons.local_offer,
    ),
    NotificationItem(
      title: "Sản phẩm của bạn sắp hết hạn",
      time: "Hôm qua",
      category: "Giao dịch",
      isRead: false,
      icon: Icons.timer,
    ),
    NotificationItem(
      title: "Chào mừng đến với app!",
      time: "2 ngày trước",
      category: "Hệ thống",
      isRead: true,
      icon: Icons.info,
    ),
  ];
  final List<String> categories = ["Tất cả", "Giao dịch", "Khuyến mãi", "Hệ thống"];
   @override
  void initState() {
    super.initState();
    _tabController = TabController(length: categories.length, vsync: this);
  }
   List<NotificationItem> filterNotifications(String category) {
    if (category == "Tất cả") return allNotifications;
    return allNotifications.where((n) => n.category == category).toList();
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
                  
                },
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 70,
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Text(
                'Thông báo',
                style: TextStyle(
                  fontSize: AppStyle.textSizeTitle,
                  color: Colors.white,
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
                icon: Icon(Icons.search, size: 30, color: Colors.green),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: AppStyle.backgroundColor,
       body: TabBarView(
        controller: _tabController,
        children: categories.map((category) {
          final list = filterNotifications(category);
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final notification = list[index];
              return ListTile(
                leading: Stack(
                  children: [
                    Icon(notification.icon, size: 30),
                    if (!notification.isRead)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Text(notification.time),
                onTap: () {
                  setState(() {
                    notification.isRead = true; // Đánh dấu đã đọc khi bấm
                  });
                },
              );
            },
          );
        }).toList(),
      ),


    );
  }
}