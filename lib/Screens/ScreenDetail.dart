import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nama_app/DataBase/FireBAuth.dart';
import 'package:nama_app/Models/Order.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienChiTietDonHang extends StatefulWidget {
  final String? idProducts;
  final String? email;
  final int? i; // Chỉ số trạng thái hiện tại của đơn hàng
  final DonHang? items; // Dữ liệu đơn hàng
  final int? index;

  const GiaoDienChiTietDonHang({
    super.key,
    this.i,
    this.email,
    this.idProducts,
    this.items,
    this.index,
  });

  @override
  State<GiaoDienChiTietDonHang> createState() => _GiaoDienChiTietDonHangState();
}

class _GiaoDienChiTietDonHangState extends State<GiaoDienChiTietDonHang> {
  // Danh sách các bước trạng thái đơn hàng
  final List<String> statusSteps = [
    'Chờ xác nhận',
    'Chờ giao',
    'Đã giao',
    'Đã nhận hàng',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Ngăn quay lại bằng nút back mặc định
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Không dùng nút back tự động
          backgroundColor: Colors.white,
          actions: [
            // Nút quay lại
            Expanded(
              flex: 15,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 5),
                child: IconButton(
                  onPressed: () => Navigator.pop(context, true),
                  icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                ),
              ),
            ),
            // Tiêu đề
            Expanded(
              flex: 70,
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10),
                child: Text(
                  'Chi tiết đơn hàng',
                  style: GoogleFonts.robotoSlab(
                    fontSize: AppStyle.textSizeTitle,
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            // Chỗ trống bên phải (có thể thêm nút chức năng)
            Expanded(
              flex: 15,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '',
                  style: TextStyle(fontSize: AppStyle.textSizeMedium),
                ),
              ),
            ),
          ],
        ),

        // Nội dung chính
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressSection(), // Thông tin địa chỉ
              SizedBox(height: 20),

              // Tiêu đề chi tiết sản phẩm
              Text(
                'Chi tiết sản phẩm',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),

              // Thông tin sản phẩm
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hình ảnh sản phẩm
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          '${widget.items!.imageUrl}',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 12),

                    // Tên sản phẩm
                    Text(
                      '${widget.items!.name}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Số lượng
                    Text(
                      'x${widget.items!.soLuong}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 12),

                    // Tổng thanh toán
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tổng thanh toán',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${widget.items!.priceAll} đ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.grey[300], thickness: 1, height: 20),
                  ],
                ),
              ),

              // Hiển thị trạng thái đơn hàng
              _buildStatusStepper(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
  Firebauth _firebauth = Firebauth();
  // Widget địa chỉ nhận hàng
  Widget _buildAddressSection() {
    print(widget.items!.address);
    return FutureBuilder<List<Map<String, dynamic>>> (
      future: _firebauth.getAddressById(widget.items!.address.toString()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Lỗi khi tải địa chỉ'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('Không có dữ liệu'));
        }

        final data = snapshot.data!;
        return Card(
          child: ListTile(
            title: Text('${data[0]['name']} - ${data[0]['telephone']}'),
            subtitle: Text(data[0]['address']!),
            leading: Icon(Icons.location_on, color: Colors.red),
          ),
        );
      },
    );
  }

  // Widget thanh trạng thái đơn hàng
  Widget _buildStatusStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trạng thái đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Stepper(
          type: StepperType.vertical,
          currentStep: widget.i!,
          physics: NeverScrollableScrollPhysics(), // Không cho cuộn
          controlsBuilder: (_, __) => SizedBox(), // Ẩn nút tiếp theo/mặc định
          steps:
              statusSteps.map((step) {
                int stepIndex = statusSteps.indexOf(step);
                return Step(
                  title: Text(step, style: TextStyle(fontSize: 12)),
                  content: Container(height: 20), // Chừa khoảng trống đều
                  isActive: stepIndex <= widget.i!,
                  state:
                      stepIndex < widget.i!
                          ? StepState.complete
                          : StepState.indexed,
                );
              }).toList(),
        ),
      ],
    );
  }
}
