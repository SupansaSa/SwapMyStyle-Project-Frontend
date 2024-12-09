import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:myapp/features/admin/admin_report_page.dart';
import 'package:myapp/features/admin/user_table_page.dart';
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/features/admin/admin_all_product.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  List<dynamic> activityLogs = [];
  bool isLoading = true;
  MyIP myIP = MyIP();


  @override
  void initState() {
    super.initState();
    _fetchActivityLogs();
  }

  Future<void> _fetchActivityLogs() async {
    try {
      final response =
          await http.get(Uri.parse('${myIP.domain}:3000/getActivityLogs'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          setState(() {
            activityLogs = data;
            activityLogs.sort((a, b) => a['id'].compareTo(b['id']));
            isLoading = false;
          });
        } else {
          print('Unexpected data format');
        }
      } else {
        print('Failed to fetch activity logs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error parsing activity logs: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
Future<void> _logActivity(String activityName, String details) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/logActivity'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'activityName': activityName,
        'details': details,
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );

    if (response.statusCode != 200) {
      print('Failed to log activity: ${response.statusCode}');
    }
  } catch (e) {
    print('Error logging activity: $e');
  }
}


  Future<void> _logout() async {
  setState(() {
    isLoading = true;
  });

  // Log the logout activity
  await _logActivity('logout', 'User logged out');

  // Proceed with logout
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('userId');
  
  setState(() {
    isLoading = false;
  });

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginScreen()),
    (route) => false,
  );
}


  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ออกจากระบบ'),
          content: const Text(
              'คุณแน่ใจหรือไม่ว่าต้องการออกจากระบบบัญชีผู้ใช้ของคุณ?'),
          actions: [
            TextButton(
              onPressed: () {
                _logout();
              },
              child: const Text('ตกลง'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('ยกเลิก'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE966A0),
        title: const Text(
          'Admin',
          style: TextStyle(
            color: Colors.white,  // เปลี่ยนสีตัวอักษรให้เป็นสีขาว
            fontWeight: FontWeight.bold, // ทำให้ตัวอักษรหนา
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // เปลี่ยนสีไอคอนให้เป็นสีขาว
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_2_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserTablePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminReportPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.production_quantity_limits),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminAllProduct()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _showLogoutConfirmation,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16.0,
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('User ID')),
                    DataColumn(label: Text('Activity Name')),
                    DataColumn(label: Text('Activity Time')),
                    DataColumn(label: Text('Details')),
                  ],
                  rows: activityLogs.map<DataRow>((log) {
                    String detailsText = 'N/A';
                    if (log['details'] is String) {
                      detailsText = log['details'];
                    } else if (log['details'] is Map<String, dynamic>) {
                      final detailsMap = log['details'] as Map<String, dynamic>;
                      detailsText = detailsMap['item_name'] ?? 'N/A';
                    } else {
                      try {
                        final details = jsonDecode(log['details'] ?? '{}');
                        detailsText = details['item_name'] ?? 'N/A';
                      } catch (e) {
                        print('Error decoding JSON in details: $e');
                      }
                    }

                    return DataRow(cells: [
                      DataCell(Text(log['id']?.toString() ?? 'N/A')),
                      DataCell(Text(log['user_id']?.toString() ?? 'N/A')),
                      DataCell(Text(log['activity_name'] ?? 'N/A')),
                      DataCell(Text(log['activity_time']?.toString() ?? 'N/A')),
                      DataCell(Text(detailsText)),
                    ]);
                  }).toList(),
                ),
              ),
            ),
    );
  }

}