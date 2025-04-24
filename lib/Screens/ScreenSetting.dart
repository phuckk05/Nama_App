import 'package:flutter/material.dart';
import 'package:nama_app/Style_App/StyleApp.dart';

class GiaoDienCaiDat extends StatefulWidget {
  const GiaoDienCaiDat({super.key});

  @override
  State<GiaoDienCaiDat> createState() => _GiaoDienCaiDatState();
}

class _GiaoDienCaiDatState extends State<GiaoDienCaiDat> {
  final List<_SettingSection> sections = [
    _SettingSection(
      title: 'Cài đặt tài khoản',
      item: ['Thông tin và liên hệ', 'Liên Hệ '],
    ),
    _SettingSection(
      title: 'Settings Applications',
      item: ['Điều khoản dịch vụ', 'Liên hệ & Góp ý'],
    ),
  ];

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
                  Navigator.pop(context);
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
                'Tài khoản',
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
      body: Padding(
        padding: EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    section.title,
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // List item trong section
                ...section.item.map(
                  (itemTitle) => _buildSettingItem(
                    title: itemTitle,
                    icon: Icons.settings,
                    onTap: () {
                      if (itemTitle == 'Liên hệ & Góp ý') {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => FeedbackScreen(),
                        //   ),
                        // );
                      } else if (itemTitle == 'Điều khoản dịch vụ') {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => TermsOfServiceScreen(),
                        //   ),
                        // );
                      } else if (itemTitle == 'Thông tin và liên hệ') {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => UserInfoScreen(),
                        //   ),
                        // );
                        
                      }
                      else if( itemTitle.trim() == 'Liên Hệ ' ){
                        //   Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => InfoContactScreen(),
                        //   ),
                        // );
                      }
                      // Thêm điều hướng khác nếu cần
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _SettingSection {
  final String title;
  final List<String> item;
  _SettingSection({required this.title, required this.item});
}
