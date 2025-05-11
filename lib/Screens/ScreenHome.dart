import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Products.dart';
import 'package:nama_app/Screens/ScreenCart.dart';
import 'package:nama_app/Screens/ScreenProducts.dart';
import 'package:nama_app/Style_App/StyleApp.dart';
import 'package:nama_app/Widgets/Seach.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marquee_widget/marquee_widget.dart';

// ignore: must_be_immutable
class GiaoDienHome extends StatefulWidget {
  final String? email;
  List<Product>? itemProducts;
  GiaoDienHome({super.key, this.email, this.itemProducts});

  @override
  State<GiaoDienHome> createState() => _GiaoDienHomeState();
}

class _GiaoDienHomeState extends State<GiaoDienHome>
    with SingleTickerProviderStateMixin {
  // Khai báo GlobalKey cho ScaffoldState để dễ dàng điều khiển Scaffold trong ứng dụng.
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Khai báo đối tượng Firebauth để sử dụng các phương thức Firebase như getAllProducts và các thao tác khác.
  Firebauth _firebauth = Firebauth();

  // Khai báo TabController để điều khiển các Tab trong giao diện, với tổng cộng 6 tab.
  late TabController _tabController;

  // Khai báo danh sách các loại sản phẩm và hình ảnh tương ứng với từng loại.
  final List<Map<String, dynamic>> itemType = [
    // Các sản phẩm và hình ảnh liên quan đến mỗi loại sản phẩm.
    {
      'name': 'Tất cả',
      'image':
          'https://watermark.lovepik.com/photo/20211124/large/lovepik-fashion-womens-summer-shopping-image-picture_500961844.jpg',
    },
    {
      'name': 'Thời trang',
      'image':
          'https://watermark.lovepik.com/photo/20211124/large/lovepik-fashion-womens-summer-shopping-image-picture_500961844.jpg',
    },
    {
      'name': 'Đồ gia dụng',
      'image':
          'https://suno.vn/blog/wp-content/uploads/2020/06/boxme-kinh-doanh-hang-gia-dung-1250x800.jpg',
    },
    {
      'name': 'Trang sức',
      'image':
          'https://lavenderstudio.com.vn/wp-content/uploads/2017/03/chup-anh-trang-suc-dep.jpg',
    },
    {
      'name': 'Thiết bị điện',
      'image':
          'https://tse2.mm.bing.net/th?id=OIP.Pk2GhF6GzEUpx11UG4agqgHaHa&pid=Api&P=0&h=220',
    },
    {
      'name': 'Khác...',
      'image': 'https://blog.dktcdn.net/files/ban-hang-online-khac-biet.jpg',
    },
  ];

  // Các danh sách sản phẩm được chia theo từng loại sản phẩm.
  List<Product> items = [];
  List<Product> items2 = [];
  List<Product> items3 = [];
  List<Product> items4 = [];
  List<Product> items5 = [];
  List<Product> items6 = [];

  // FocusNode để quản lý sự kiện khi ô tìm kiếm được chọn.
  FocusNode searchFocus = FocusNode();

  // Chỉ số của ô dropdown được chọn.
  int _selectedDropBox = 2;

  // Chỉ số của tab hiện tại.
  int Index = 1;

  // Chỉ số của loại sản phẩm được chọn từ itemType.
  int selectedItemTypeIndex = 0;

  // Controller cho ô nhập tìm kiếm.
  final _textTimKiem = TextEditingController();

  // Biến Timer dùng để hiển thị gợi ý tìm kiếm.
  Timer? _deXuatTimer;

  // Danh sách các từ gợi ý tìm kiếm.
  List<String> listDeXuat = ["Áo", "Quần", "Giày", "Dép"];

  // Hàm lấy dữ liệu sản phẩm từ Firebase và phân loại các sản phẩm theo loại.
  void fetchProducts() async {
    // Lấy tất cả sản phẩm từ Firebase
    final fetchedItems = await _firebauth.getAllProducts();

    // Cập nhật các danh sách sản phẩm theo từng loại

    items = fetchedItems;
    items2 = items.where((element) => element.type == "Thời trang").toList();
    items3 = items.where((element) => element.type == "Đồ gia dụng").toList();
    items4 = items.where((element) => element.type == "Trang sức").toList();
    items5 = items.where((element) => element.type == "Thiết bị điện").toList();
    items6 = items.where((element) => element.type == "Khác..").toList();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo TabController với 6 tab
    _tabController = TabController(length: 6, vsync: this);

    // Lấy danh sách sản phẩm ngay khi màn hình được khởi tạo
    fetchProducts();

    // Bắt đầu việc hiển thị gợi ý tìm kiếm sau mỗi 1 giây
    DeXuat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    // Hủy Timer khi widget bị hủy
    _deXuatTimer?.cancel();
    super.dispose();
  }

  // Hàm hiển thị gợi ý tìm kiếm, thay đổi nội dung của ô tìm kiếm mỗi giây.
  void DeXuat() {
    int i = 0;
    // Thực hiện thay đổi nội dung tìm kiếm theo thời gian mỗi giây
    _deXuatTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      // Kiểm tra xem widget còn được sử dụng không trước khi thay đổi state
      if (!mounted) {
        timer.cancel(); // Nếu không còn được sử dụng thì hủy timer
        return;
      }

      // Cập nhật text trong ô tìm kiếm với giá trị trong danh sách listDeXuat
      setState(() {
        _textTimKiem.text = listDeXuat[i];
        i++;
        // Quay lại chỉ số đầu tiên của danh sách khi hết các giá trị
        if (i == listDeXuat.length) {
          i = 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,

        backgroundColor: Colors.green[600],
        title: Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 330,
                height: 40,
                child: GestureDetector(
                  onTap: () {
                    searchFocus.unfocus();
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      focusNode: searchFocus,
                      readOnly: true,
                      controller: _textTimKiem,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(top: 10),
                        prefixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
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
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              GiaoDienGioHang(email: widget.email.toString()),
                    ),
                  );
                },
                icon: Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      body: body(),

      backgroundColor: Colors.white,
      drawer: Search(
        email: widget.email.toString(),
        itemProducts: widget.itemProducts,
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        // Stack cho phần đầu trang, chứa một thanh màu xanh và container bao bọc bên dưới
        Expanded(
          flex: 10,
          child: Stack(
            children: [
              // Thanh màu xanh phía trên cùng, chiều cao là 40
              Container(
                width: double.infinity,
                height: 40,
                color: Colors.green[600],
                
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10, top: 5,),
                child: Container(
                  width: double.infinity,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 5)
                    )],
                    borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Marquee(
                      direction: Axis.horizontal, // Chạy ngang
                      animationDuration: Duration(seconds: 2), // Tốc độ cuộn
                      backDuration: Duration(seconds: 1), // Thời gian quay lại
                      pauseDuration: Duration(seconds: 0), // Không tạm dừng

                      child: Row(
                        children: [
                          SizedBox(width: 300),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.rotationY(pi), // Lật theo trục Y
                            child: Icon(
                              Icons.local_shipping,
                              color: Colors.green,
                              size: 40,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Chào mừng đến với ứng dụng Nama',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: AppStyle.fontFamily,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // TabBar được sử dụng để hiển thị các tab với danh mục sản phẩm

        // Hình ảnh banner cho phần dưới TabBar
        Expanded(
          flex: 25,
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: double.infinity,
              height: 150,
              color: Colors.white,
              child: Image.asset(
                'lib/Image/nen.png', // Hình ảnh được hiển thị dưới dạng asset
                width: double.infinity,
                height: 150,
                fit:
                    BoxFit
                        .fill, // Fit ảnh vào chiều rộng và chiều cao của container
              ),
            ),
          ),
        ),
        Expanded(
          flex: 10,
          child: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 10,
                left: 10,
                top: 0,
                bottom: 0,
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: true, // Cho phép cuộn khi có nhiều tab
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: Colors.black,
                tabAlignment: TabAlignment.start,

                indicatorWeight: 3,
                labelStyle: TextStyle(
                  fontSize: AppStyle.textSizeMedium,
                  fontWeight: FontWeight.bold,
                ),
                tabs: List.generate(
                  itemType.length, // Tạo các tab từ danh sách itemType
                  (index) => Tab(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 5),
                          Text(
                            itemType[index]['name'], // Hiển thị tên loại sản phẩm trong tab
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Phần hiển thị số lượng sản phẩm trên mỗi hàng với Dropdown
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Text(
                  'Số lượng sản phẩm trên hàng ',
                  style: TextStyle(
                    fontSize: AppStyle.paddingMedium,
                    fontFamily: AppStyle.fontFamily,
                  ),
                ),
                SizedBox(width: 10),

                // DropdownButton cho phép chọn số lượng sản phẩm trên hàng
                DropdownButton<int>(
                  dropdownColor: Colors.amber,
                  borderRadius: BorderRadius.circular(AppStyle.borderRadius),
                  value: _selectedDropBox, // Giá trị hiện tại của dropdown
                  items:
                      [1, 2].map((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            value.toString(), // Hiển thị số lượng
                            style: TextStyle(fontSize: AppStyle.paddingMedium),
                          ),
                        );
                      }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedDropBox =
                          newValue!; // Cập nhật giá trị khi người dùng chọn mới
                    });
                  },
                ),
              ],
            ),
          ),
        ),

        // TabBarView chứa các màn hình nội dung cho từng tab
        Expanded(
          flex: 75,
          child: TabBarView(
            controller: _tabController,
            children: [
              danhSachSanPham(
                items,
              ), // Màn hình hiển thị danh sách sản phẩm chung
              danhSachSanPham(
                items2,
              ), // Màn hình cho loại sản phẩm "Thời trang"
              danhSachSanPham(
                items3,
              ), // Màn hình cho loại sản phẩm "Đồ gia dụng"
              danhSachSanPham(items4), // Màn hình cho loại sản phẩm "Trang sức"
              danhSachSanPham(
                items5,
              ), // Màn hình cho loại sản phẩm "Thiết bị điện"
              danhSachSanPham(items6), // Màn hình cho loại sản phẩm "Khác"
            ],
          ),
        ),
      ],
    );
  }

  Widget danhSachSanPham(List<Product> itemsAll) {
    return itemsAll.isNotEmpty
        // Kiểm tra nếu danh sách sản phẩm không rỗng
        ? SingleChildScrollView(
          // Bao bọc toàn bộ giao diện trong SingleChildScrollView để cuộn khi nội dung dài
          child: Padding(
            padding: const EdgeInsets.only(
              top: 0,
            ), // Padding cho toàn bộ container
            child: Container(
              width: double.infinity, // Container chiếm hết chiều rộng màn hình
              child: GridView.builder(
                // GridView.builder để tạo lưới sản phẩm
                shrinkWrap:
                    true, // Giúp GridView không chiếm hết chiều cao và cuộn trong ScrollView
                physics:
                    NeverScrollableScrollPhysics(), // Không cho phép cuộn bên trong GridView
                padding: EdgeInsets.all(5), // Padding cho GridView
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      _selectedDropBox, // Số cột trong GridView, được quyết định từ Dropdown
                  crossAxisSpacing: 1, // Khoảng cách giữa các cột
                  mainAxisSpacing: 5, // Khoảng cách giữa các hàng
                  mainAxisExtent:
                      270, // Chiều cao của mỗi phần tử trong GridView
                ),
                itemCount: itemsAll.length, // Số lượng phần tử trong GridView
                itemBuilder: (context, index) {
                  // Hàm xây dựng mỗi item trong GridView
                  return GestureDetector(
                    onTap: () {
                      // Khi người dùng nhấn vào sản phẩm, chuyển tới trang chi tiết sản phẩm
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GiaoDienSanPham(
                                id: itemsAll[index].id, // Truyền id sản phẩm
                                email:
                                    widget.email
                                        .toString(), // Truyền email từ widget cha
                                itemProducts:
                                    widget
                                        .itemProducts, // Truyền danh sách sản phẩm
                              ),
                        ),
                      );
                    },
                    child: Card(
                      // Card để hiển thị từng sản phẩm
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16), // Bo góc card
                      ),
                      elevation: 5, // Độ nổi của Card
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16), // Bo góc trên của ảnh
                            ),
                            child: CachedNetworkImage(
                              imageUrl:
                                  itemsAll[index]
                                      .imageUrl, // URL của ảnh sản phẩm
                              width: double.infinity,
                              height: 175, // Chiều cao của ảnh
                              fit: BoxFit.fill, // Cách ảnh fill vào trong khuôn
                              placeholder:
                                  (context, url) => Center(
                                    child:
                                        CircularProgressIndicator(), // Loading indicator khi ảnh đang tải
                                  ),
                              errorWidget:
                                  (context, url, error) => Icon(
                                    Icons.error,
                                  ), // Nếu có lỗi khi tải ảnh, hiển thị biểu tượng lỗi
                            ),
                          ),

                          // Hiển thị tên sản phẩm
                          Align(
                            heightFactor: 1,
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 5),
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                '${itemsAll[index].name}gffffffffffffffffffffffff', // Tên sản phẩm
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold, // Định dạng chữ
                                ),
                                textAlign:
                                    TextAlign.center, // Căn giữa tên sản phẩm
                              ),
                            ),
                          ),

                          // Hiển thị giá sản phẩm
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                "${itemsAll[index].price.toString()} đ", // Giá sản phẩm
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red, // Màu đỏ cho giá
                                ),
                              ),
                            ),
                          ),

                          // Hiển thị số lượng sản phẩm
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 10,
                                bottom: 0,
                                right: 10
                              ),
                              child: Text(
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis, // Cắt bớt nội dung nếu quá dài
                                'số lượng : ${itemsAll[index].total}', // Hiển thị số lượng sản phẩm
                                style: TextStyle(
                                  fontSize:
                                      AppStyle.textSizeMedium, // Định dạng chữ
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
        )
        // Nếu danh sách sản phẩm rỗng, hiển thị thông báo "Không có dữ liệu!"
        : Center(child: Text('Không có dữ liệu !'));
  }
}
