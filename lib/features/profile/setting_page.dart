import 'package:flutter/material.dart';
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';
import 'package:myapp/widgets/custom_button.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE966A0),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(1.0),
                children: [
                  const SectionHeader(title: 'บัญชีของฉัน'),
                  const SizedBox(height: 8.0),
                  _buildListTile(
                    context,
                    icon: Icons.security,
                    title: 'บัญชีและความปลอดภัยของบัญชี',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.shopping_bag_outlined,
                    title: 'ที่อยู่ของฉัน',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.access_time,
                    title: 'ข้อมูลบัญชีธนาคาร/บัตร',
                    onTap: () {},
                  ),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  const SectionHeader(title: 'การตั้งค่า'),
                  const SizedBox(height: 8.0),
                  _buildListTile(
                    context,
                    icon: Icons.chat,
                    title: 'ตั้งค่าการแชท',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.notifications,
                    title: 'ตั้งค่าการแจ้งเตือน',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.privacy_tip,
                    title: 'ตั้งค่าความเป็นส่วนตัว',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.language,
                    title: 'ภาษา',
                    onTap: () {},
                  ),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  const SectionHeader(title: 'ช่วยเหลือ'),
                  const SizedBox(height: 8.0),
                  _buildListTile(
                    context,
                    icon: Icons.help_outline,
                    title: 'ศูนย์ช่วยเหลือ',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.rule,
                    title: 'ข้อกำหนดและการใช้บริการ',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.policy,
                    title: 'นโยบายความเป็นส่วนตัว',
                    onTap: () {},
                  ),
                  const Divider(),
                  _buildListTile(
                    context,
                    icon: Icons.info_outline,
                    title: 'เกี่ยวกับ',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            /*const SizedBox(height: 15,),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: CustomButton(
                  title: 'เปลี่ยนบัญชีผู้ใช้',
                  onPressed: (BuildContext context) {
                  },
                ),
              ),*/

            const SizedBox(height: 15),
            SizedBox(
              height: 45,
              width: double.infinity,
              child: CustomButton(
                title: 'ออกจากระบบ',
                onPressed: (BuildContext context) {
                   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE966A0)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({required this.title, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
