import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';

class UserTablePage extends StatefulWidget {
  const UserTablePage({Key? key}) : super(key: key);

  @override
  _UserTablePageState createState() => _UserTablePageState();
}

class _UserTablePageState extends State<UserTablePage> {
  List<dynamic> users = [];
  bool isLoading = true;
  final MyIP myIP = MyIP();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      final response =
          await http.get(Uri.parse('${myIP.domain}:3000/getUsers'));
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body);
        setState(() {
          // กรองผู้ใช้ที่ไม่ใช่ admin โดยตรวจสอบ id ที่มีอยู่ใน users
          users = (decodedResponse['users'] ?? []).where((user) {
            // ตรวจสอบว่า user มี id ของ admin หรือไม่ (สมมุติว่า admin id = 22)
            return user['id'] !=
                36; // เปลี่ยน 22 เป็น id ของ admin ที่ต้องการกรอง
          }).toList();
          isLoading = false;
        });
      } else {
        print('Failed to load users: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  void toggleBanStatus(int userId, bool isBanned) async {
    try {
      final response = await http.put(
        Uri.parse('${myIP.domain}:3000/banUser'),
        body: jsonEncode({'userId': userId, 'isBanned': !isBanned}),
        headers: {"Content-Type": "application/json"},
      );

      if (response.statusCode == 200) {
        setState(() {
          users = users.map((user) {
            if (user['id'] == userId) {
              user['is_banned'] = !isBanned;
            }
            return user;
          }).toList();
        });
      } else {
        print('Failed to update ban status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating ban status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('User ID')),
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('First Name')),
                    DataColumn(label: Text('Last Name')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: users.map((user) {
                    return DataRow(cells: [
                      DataCell(Text(user['id'].toString())),
                      DataCell(Text(user['username'] ?? 'N/A')),
                      DataCell(Text(user['firstname'] ?? 'N/A')),
                      DataCell(Text(user['lastname'] ?? 'N/A')),
                      DataCell(
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () => toggleBanStatus(
                                  user['id'], user['is_banned'] ?? false),
                              child: Text(user['is_banned'] ? 'Unban' : 'Ban'),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              ),
            ),
    );
  }
}