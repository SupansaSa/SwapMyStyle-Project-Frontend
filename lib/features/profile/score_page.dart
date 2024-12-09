import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/features/chat/Chat.dart'; // เพิ่มการนำเข้า

class ScorePage extends StatefulWidget {
  final String userId;

  const ScorePage({Key? key, required this.userId}) : super(key: key);

  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  List<Map<String, dynamic>> _creditPoints = [];
  List<Map<String, dynamic>> _discreditPoints = [];

  @override
  void initState() {
    super.initState();
    _fetchCreditPoints();
    _fetchDiscreditPoints();
  }

  Future<void> _fetchCreditPoints() async {
  try {
    final response = await http.get(Uri.parse('${myIP.domain}:3000/credit_points/${widget.userId}'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); 
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _creditPoints = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } else if (response.statusCode == 404) {
      // แสดงข้อความเมื่อไม่มีคะแนนเครดิต
      _showErrorDialog('ไม่มีคะแนนเครดิตในขณะนี้');
    } else {
      throw Exception('Failed to load credit points');
    }
  } catch (e) {
    _showErrorDialog('ไม่สามารถดึงคะแนนเครดิตได้: ${e.toString()}');
  }
}


  Future<void> _fetchDiscreditPoints() async {
  try {
    final response = await http.get(Uri.parse('${myIP.domain}:3000/discredit_points/${widget.userId}'));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); 
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _discreditPoints = data.map((e) => e as Map<String, dynamic>).toList();
      });
    } else if (response.statusCode == 404) {
      // แสดงข้อความเมื่อไม่มีคะแนนดิสเครดิต
      _showErrorDialog('ไม่มีคะแนนดิสเครดิตในขณะนี้');
    } else {
      throw Exception('Failed to load discredit points');
    }
  } catch (e) {
    _showErrorDialog('ไม่สามารถดึงคะแนนดิสเครดิตได้: ${e.toString()}');
  }
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
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

 @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text(
        'คะแนนของฉัน',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xFFE966A0),
      iconTheme: const IconThemeData(
        color: Colors.white,
      ),
    ),
    body: SingleChildScrollView(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('คะแนน Credit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _creditPoints.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('ไม่มีคะแนน Credit', style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
              : Column(
                  children: _creditPoints.map((credit) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.green, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            credit['item_photo'] != null
                                ? Image.network(
                                    '${myIP.domain}:3000/uploads/items/${json.decode(credit['item_photo'])[0]}',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return const Center(child: Icon(Icons.image, size: 50));
                                    },
                                  )
                                : const SizedBox(width: 80, height: 80),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Credit: ${credit['points']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('สินค้า: ${credit['item_name']}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('คะแนน Discredit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _discreditPoints.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('ไม่มีคะแนน Discredit', style: TextStyle(fontSize: 16, color: Colors.grey)),
                )
              : Column(
                  children: _discreditPoints.map((discredit) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            discredit['item_photo'] != null
                                ? Image.network(
                                    '${myIP.domain}:3000/uploads/items/${json.decode(discredit['item_photo'])[0]}',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return const Center(child: Icon(Icons.image, size: 50));
                                    },
                                  )
                                : const SizedBox(width: 80, height: 80),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Discredit: ${discredit['points']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text('สินค้า: ${discredit['item_name']}'),
                                  Text('เหตุผล: ${discredit['reason']}'),
                                  Text('วันที่: ${formatDate(discredit['created_at'])}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    ),
  );
}


}