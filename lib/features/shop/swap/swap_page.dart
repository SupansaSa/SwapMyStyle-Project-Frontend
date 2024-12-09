import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/features/shop/home/home_page.dart';
import 'package:myapp/features/shop/swap/swap_%20detail%20_page.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:myapp/screen/MyIP.dart';

class SwapPage extends StatefulWidget {
  @override
  _SwapPageState createState() => _SwapPageState();
}

class _SwapPageState extends State<SwapPage> {
  List<Map<String, dynamic>> swaps = [];
  MyIP myIP = MyIP();
  String? userId; 

  @override
  void initState() {
    super.initState();
    _loadUserId(); 
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId'); 
    });
    if (userId != null) {
      fetchSwaps(); 
    }
  }

  Future<void> fetchSwaps() async {
    if (userId == null) return; 
    final url = Uri.parse('${myIP.domain}:3000/swapsss/$userId'); 
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final List<dynamic> fetchedSwaps = json.decode(response.body);
      print('Fetched swaps: $fetchedSwaps'); 
      setState(() {
        swaps = fetchedSwaps.map((swap) {
          return {
            'id': swap['id'],
            'item_name': swap['itemName'],
            'item_price': swap['itemPrice'],
            'item_photo': swap['itemPhoto'],
            'created_at': swap['createdAt'],
            'exchange_result': swap['exchangeResult'],
          };
        }).toList();
        print('Mapped swaps: $swaps'); 
      });
    }
  }

  String formatDate(String dateString) {
    try {
      final utcDate = DateTime.parse(dateString).toUtc();
      final localDate = utcDate.toLocal();
      final formatter = DateFormat('dd MMMM yyyy, HH:mm');
      return formatter.format(localDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<void> _onRefresh() async {
    await fetchSwaps(); // เรียกใช้ฟังก์ชัน fetchSwaps เมื่อมีการดึงลงมา
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
  automaticallyImplyLeading: false,
  backgroundColor: const Color(0xFFE966A0),
  title: Text(
    'ประวัติการแลกเปลี่ยนสินค้า ',
    style: TextStyle(
      fontSize: 20,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  actions: [
    // ตรวจสอบว่าเส้นทางมาจากหน้าไหน
    if (ModalRoute.of(context)?.settings.name != '/home') ...[
      IconButton(
        icon: Icon(Icons.close, color: Colors.white), // ใช้ไอคอนปิด
        onPressed: () {
          // เปลี่ยนไปที่ HomePage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()), // เปลี่ยนไปที่ HomePage
          );
        },
      ),
    ],
  ],
),


      body: RefreshIndicator(
        onRefresh: _onRefresh, 
        child: ListView.builder(
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SwapDetailPage(
                      exchangeId: swap['id'] ?? 0, 
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Image(
                        image: (swap['item_photo'] != null && swap['item_photo'].isNotEmpty)
                            ? (() {
                                try {
                                  final photos = json.decode(swap['item_photo']);
                                  if (photos is List && photos.isNotEmpty) {
                                    return NetworkImage(
                                      '${myIP.domain}:3000/uploads/items/${photos[0]}',
                                    );
                                  }
                                } catch (e) {
                                  print('Error decoding item photos: $e');
                                }
                                return const AssetImage('assets/image/noimage.png') as ImageProvider;
                              })()
                            : const AssetImage('assets/image/noimage.png') as ImageProvider,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/image/noimage.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              swap['item_name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'ราคา: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${swap['item_price']}฿',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'สถานะการแลก: ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  TextSpan(
                                    text: swap['exchange_result'] == 'completed' 
                                        ? 'แลกเปลี่ยนสำเร็จ' 
                                        : swap['exchange_result'] == 'cancelled' 
                                            ? 'แลกเปลี่ยนไม่สำเร็จ' 
                                            : 'N/A',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: swap['exchange_result'] == 'completed' 
                                          ? Colors.green 
                                          : swap['exchange_result'] == 'cancelled' 
                                              ? Colors.red 
                                              : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
