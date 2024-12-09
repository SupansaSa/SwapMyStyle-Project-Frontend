import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class SwapDetailPage extends StatefulWidget {
  final int exchangeId;

  SwapDetailPage({required this.exchangeId});

  @override
  _SwapDetailPageState createState() => _SwapDetailPageState();
}

class _SwapDetailPageState extends State<SwapDetailPage> {
  Map<String, dynamic>? swapsDetails;
  MyIP myIP = MyIP();
  bool ownerConfirmed = false;
  bool exchangerConfirmed = false;
  String? userId;
  bool isConfirmedOrCancelled = false; 
  

  @override
  void initState() {
    super.initState();
    _loadUserId();
    fetchSwapsDetails();
    checkExchangeStatus();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
  }

  Future<void> fetchSwapsDetails() async {
  final url = Uri.parse('${myIP.domain}:3000/swapsDetails/${widget.exchangeId}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    if (data != null) {
      setState(() {
        swapsDetails = data;

        if (swapsDetails!['exchange_result'] == 'completed' || swapsDetails!['exchange_result'] == 'cancelled') {
          isConfirmedOrCancelled = true;
        } else {
          isConfirmedOrCancelled = false; 
        }
      });

      print('Swaps Details: $swapsDetails');
      print('Is Confirmed or Cancelled: $isConfirmedOrCancelled');
    }
  } else {
    print('Error fetching swaps details: ${response.body}');
  }
}


  String formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'ไม่ระบุเวลา';
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd-MM-yyyy  HH:mm ').format(dateTime);
  }

  Future<void> fetchExchangeDetails() async {
  await fetchSwapsDetails(); 
  await checkExchangeStatus(); 
  setState(() {
    
    print('Exchange Result: ${swapsDetails!['exchange_result']}'); 
  });
}




  Future<void> checkExchangeStatus() async {
  final response = await http.get(Uri.parse('${myIP.domain}:3000/exchange_status/${widget.exchangeId}'));
  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    
    
    if (swapsDetails == null) {
      swapsDetails = {}; 
    }

    setState(() {
      ownerConfirmed = data['ownerConfirmed'];
      exchangerConfirmed = data['exchangerConfirmed'];
      swapsDetails!['exchange_result'] = data['exchangeResult']; 
    });
    print('Updated Exchange Result: ${swapsDetails!['exchange_result']}'); 
  } else {
    print('Error fetching exchange status: ${response.body}'); 
  }
}



  Future<void> confirmReceipt() async {
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('กรุณาลงชื่อเข้าใช้เพื่อยืนยันการรับสินค้า')));
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/confirm/${widget.exchangeId}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': int.parse(userId!)}),
    );

    if (response.statusCode == 200) {
      setState(() {
        swapsDetails!['exchange_result'] = 'completed';
        isConfirmedOrCancelled = true; 
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Confirmed receipt!')));
      await fetchSwapsDetails(); 
      print('Updated Exchange Result: ${swapsDetails!['exchange_result']}');
    } else {
      
      final errorMessage = jsonDecode(response.body)['message'] ?? 'เกิดข้อผิดพลาด';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      print('Error: ${response.body}');
    }
  } catch (error) {
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์')));
    print('Exception: $error');
  }
}



 Future<void> showCancelDialog(BuildContext context) async {
  String? selectedReason;
  TextEditingController otherReasonController = TextEditingController();

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'ยกเลิกการรับสินค้า ?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: selectedReason,
              hint: Text('เลือกเหตุผลการยกเลิก'),
              items: <String>[
                'อีกฝ่ายไม่มาตามนัด',
                'สถานที่นัดรับไกลเกินไป',
                'สินค้าชำรุด',
                'ไม่ตรงตามคำอธิบาย',
                'เปลี่ยนใจ',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? value) {
                setState(() {
                  selectedReason = value;
                });
              },
            ),
            TextField(
              controller: otherReasonController,
              decoration: InputDecoration(labelText: 'เหตุผลอื่น ๆ (ถ้ามี)'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'ยกเลิก',
              style: TextStyle(color: Colors.pink),
            ),
          ),
          TextButton(
            onPressed: () {
              cancelReceipt(selectedReason, otherReasonController.text);
              Navigator.of(context).pop();
            },
            child: Text(
              'ยืนยัน',
              style: TextStyle(color: Colors.pink),
            ),
          ),
        ],
      );
    },
  );
}



 Future<void> cancelReceipt(String? selectedReason, String otherReason) async {
  if (userId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('กรุณาลงชื่อเข้าใช้เพื่อยกเลิกการรับสินค้า')),
    );
    return;
  }

  final response = await http.post(
    Uri.parse('${myIP.domain}:3000/cancel/${widget.exchangeId}'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'userId': int.parse(userId!),
      'reason': selectedReason ?? otherReason, 
    }),
  );

  if (response.statusCode == 200) {
    setState(() {
      swapsDetails!['exchange_result'] = 'cancelled'; 
      isConfirmedOrCancelled = true; 
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cancelled receipt!')));
    await fetchSwapsDetails(); 
  } else {
    print('Error: ${response.body}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'รายละเอียดการแลกเปลี่ยน',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE966A0),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: swapsDetails == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: NetworkImage(
                          '${myIP.domain}:3000/uploads/${swapsDetails!['exchanger_profile_photo'] ?? ''}',
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          swapsDetails!['exchanger_username'] ?? 'ไม่ระบุชื่อ',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                     
                    ],
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'สินค้าที่ต้องการแลก',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 4,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: (() {
                                      try {
                                        final photos = json.decode(swapsDetails!['exchange_item_photo'] ?? '');
                                        if (photos is List && photos.isNotEmpty) {
                                          return NetworkImage('${myIP.domain}:3000/uploads/items/${photos[0]}');
                                        }
                                      } catch (e) {
                                        print('Error decoding exchange item photos: $e');
                                      }
                                      return const AssetImage('assets/image/noimage.png') as ImageProvider;
                                    })(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Text(
                                swapsDetails!['exchange_item_name'] ?? 'ไม่ระบุชื่อสินค้า',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${swapsDetails!['exchange_item_price'] ?? 0}฿',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'สินค้าที่ ${swapsDetails!['exchanger_username'] ?? 'ไม่ระบุ'} นำมาแลก',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 100,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      elevation: 4,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: (() {
                                      try {
                                        final photos = json.decode(swapsDetails!['selected_item_photo'] ?? '');
                                        if (photos is List && photos.isNotEmpty) {
                                          return NetworkImage('${myIP.domain}:3000/uploads/items/${photos[0]}');
                                        }
                                      } catch (e) {
                                        print('Error decoding selected item photos: $e');
                                      }
                                      return const AssetImage('assets/image/noimage.png') as ImageProvider;
                                    })(),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start, 
                            mainAxisAlignment: MainAxisAlignment.center, 
                            children: [
                              Text(
                                swapsDetails!['selected_item_name'] ?? 'ไม่ระบุชื่อสินค้า',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                '${swapsDetails!['selected_item_price'] ?? 0}฿',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                 Divider(thickness: 2, color: Colors.grey[400], ),
                 const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'เวลาที่ขอแลกสินค้า  : ',
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatDateTime(swapsDetails!['created_at']),
                        style: TextStyle(fontSize: 15,),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'เวลาที่ยืนยันคำขอแลกสินค้า  : ',
                        style: TextStyle(fontSize: 15,fontWeight: FontWeight.bold),
                      ),
                      Text(
                        formatDateTime(swapsDetails!['owner_confirmed_at']),
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min, 
                    children: [
                      Text(
                        swapsDetails!['exchange_result'] == 'completed'
                            ? 'เวลาที่แลกเปลี่ยนสำเร็จ: '
                            : (swapsDetails!['exchange_result'] == 'cancelled'
                                ? 'เวลาที่แลกเปลี่ยนไม่สำเร็จ: '
                                : 'สถานะไม่ทราบ'),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      
                      const Spacer(flex: 1), 
                      Text(
                        swapsDetails!['exchange_result'] == 'completed'
                            ? (swapsDetails!['credited_at'] != null
                                ? formatDateTime(swapsDetails!['credited_at'])
                                : 'ไม่พบข้อมูล')
                            : (swapsDetails!['exchange_result'] == 'cancelled'
                                ? (swapsDetails!['discredited_at'] != null
                                    ? formatDateTime(swapsDetails!['discredited_at'])
                                    : 'ไม่พบข้อมูล')
                                : ''),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),
                  if (!isConfirmedOrCancelled) ...[
                  const Center(
                    child: Text(
                      '"กรุณายืนยันการรับสินค้าเมื่อทำการแลกเปลี่ยนสำเร็จ"', 
                      textAlign: TextAlign.center, 
                      style: TextStyle(
                        color: Colors.red, 
                        fontWeight: FontWeight.bold, 
                        fontSize: 14, 
                      ),
                    ),
                  ),
                ],

                  const SizedBox(height: 10),
                  
                  if (swapsDetails!['exchange_result'] != null) ...[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center, 
                      children: [
                        Center(
                          child: Text(
                            swapsDetails!['exchange_result'] == 'completed' 
                              ? 'การแลกเปลี่ยนสำเร็จ' 
                              : 'การแลกเปลี่ยนไม่สำเร็จ',
                            style: TextStyle(
                              fontSize: 20,
                              color: swapsDetails!['exchange_result'] == 'completed' 
                                ? Colors.green 
                                : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        
                        if (swapsDetails!['exchange_result'] == 'cancelled') ...[
                          Center( 
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  const TextSpan(
                                    text: 'เนื่องจาก: ',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold, 
                                      color: Colors.red, 
                                    ),
                                  ),
                                  TextSpan(
                                    text: '${swapsDetails!['discredit_reason'] ?? 'ไม่มีข้อมูล'}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.red, 
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10), 
                        ],
                      ],
                    ),
                  ],

                  if (swapsDetails!['exchange_result'] == null || swapsDetails!['exchange_result'] == 'accepted') ...[
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 45,
                          width: 150,
                          child: CustomButton(
                            title: 'ยกเลิก',
                            onPressed: (BuildContext context) {
                              showCancelDialog(context); 
                            },
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(
                          height: 45,
                          width: 150,
                          child: CustomButton(
                            title: 'ยืนยันการรับสินค้า',
                            onPressed: (BuildContext context) async {
                              await confirmReceipt(); 
                              await fetchExchangeDetails(); 
                              setState(() {}); 
                            },
                            color: Colors.greenAccent[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
