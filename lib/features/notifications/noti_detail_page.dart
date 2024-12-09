import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/chat/Chat.dart';
import 'package:myapp/features/shop/swap/swap_page.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationDetailPage extends StatefulWidget {
  final String notificationId;
  final String myIP;
  final bool isOwner;
  final String userId;
  
  
  const NotificationDetailPage({Key? key,required this.userId, required this.notificationId, required this.myIP, required this.isOwner}) : super(key: key);

  @override
  _NotificationDetailPageState createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  Future<Map<String, dynamic>>? _notificationFuture;
  Future<List<Item>>? _itemsFuture;
  String? userId;
  bool isOwner = false; 
  Item? _selectedItem;
  Map<String, dynamic>? notificationData;
  

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

    
Future<void> saveExchangeId(String exchangeId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('exchangeId', exchangeId); 
  print('Saved exchangeId: $exchangeId'); 
}


  Future<void> _loadUserId() async {
  final prefs = await SharedPreferences.getInstance();
  
  setState(() {
    userId = prefs.getString('userId');
  });

  if (userId != null) {
    int notificationId = int.parse(widget.notificationId); 

    setState(() {
      _notificationFuture = _fetchNotificationDetails(notificationId); 
    });
  } else {
    print('User ID is null');
  }
}

Future<Map<String, dynamic>> _fetchNotificationDetails(int notificationId) async {
    final url = Uri.parse('${widget.myIP}:3000/notifications/id/$notificationId');
    try {
      final response = await http.get(url);
      print('Fetching notifications from: $url');
      print('Notification Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Notification Data: $jsonData');

        if (jsonData is Map<String, dynamic>) {
         if (jsonData['notification'] != null) {
          notificationData = jsonData['notification'];
          isOwner = jsonData['isOwner']; 

          if (notificationData!['exchanger_id'] != null) {
            _itemsFuture = fetchExchangedItems(notificationData!['exchanger_id']);
          }

          if (notificationData!['selected_item_id'] != null) {
            var selectedItem = await fetchSelectedItem(notificationData!['selected_item_id']);
          
            setState(() {
              _selectedItem = selectedItem; 
            });
          }

          return notificationData!;
        }
        else {
            throw Exception('Error: Notification data is null');
          }
        } else {
          throw Exception('Error: Data is not a Map');
        }
      } else {
        throw Exception('Error fetching notification details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }


  Future<Item?> fetchSelectedItem(int selectedItemId) async {
  final url = Uri.parse('${widget.myIP}:3000/items/$selectedItemId');
  try {
    final response = await http.get(url);
    print('Fetching selected item from: $url');
    print('Selected Item Response: ${response.body}');

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print('Selected Item Data: $jsonData');

      if (jsonData['success'] == true) {
        return Item.fromJson(jsonData['item']);
      } else {
        throw Exception('Error: Invalid data format for selected item');
      }
    } else {
      throw Exception('Error fetching selected item: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error: $e');
  }
}


  Future<List<Item>> fetchExchangedItems(int exchangerId) async {
    final url = Uri.parse('${widget.myIP}:3000/exchangedItems/$exchangerId');
    try {
      final response = await http.get(url);
      print('Fetching exchanged items from: $url');
      print('Exchanged Items Response: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Exchanged Items Data: $jsonData');

        if (jsonData['success'] == true && jsonData['items'] is List) {
          return (jsonData['items'] as List)
              .map((item) => Item.fromJson(item))
              .toList();
              
        } else {
          throw Exception('Error: Invalid data format');
        }
      } else {
        throw Exception('Error fetching exchanged items: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  
Future<void> acceptExchange(String exchangeId, String ownerId, String selectedItemId) async {
  
  if (notificationData == null) {
    print('Error: notificationData is null, cannot accept exchange.');
    return;
  }

  
  print('exchangeId (ที่จะส่ง): $exchangeId'); 
  print('ownerId: $ownerId');
  print('selectedItemId: $selectedItemId'); 

  // เช็คค่าที่ดึงมา
  if (exchangeId.isEmpty || ownerId.isEmpty || selectedItemId.isEmpty) {
    print('Error: One or more required IDs are empty.');
    return;
  }

  final url = Uri.parse('${widget.myIP}:3000/exchanges/accept');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'exchangeId': exchangeId,
        'ownerId': ownerId,
        'selectedItemId': selectedItemId,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        print('Exchange accepted successfully.');
        
      } else {
        print('Failed to accept exchange: ${jsonResponse['message']}');
      }
    } else {
      print('Error occurred: ${response.statusCode} - ${response.body}');
    }
  } catch (error) {
    print('Error occurred while accepting exchange: $error');
  }
}

Future<void> rejectExchange(String exchangeId, String ownerId, String selectedItemId) async {
  final url = Uri.parse('${widget.myIP}:3000/exchanges/reject');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'exchangeId': exchangeId,
        'ownerId': ownerId,
        'selectedItemId': selectedItemId,
      }),
    );

    if (response.statusCode == 200) {
      print('Exchange rejected successfully.');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('คำขอแลกเปลี่ยนถูกปฏิเสธแล้ว')),
      );
      Navigator.pop(context); // 
    } else {
      print('Failed to reject exchange: ${response.statusCode} - ${response.body}');
    }
  } catch (error) {
    print('Error occurred while rejecting exchange: $error');
  }
}


@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFE966A0),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: FutureBuilder<Map<String, dynamic>>(
          future: _notificationFuture,
          builder: (context, snapshot) {
             if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData) {
            return SizedBox(); 
          } else {
            // ignore: unused_local_variable
            final notificationData = snapshot.data!;
              final isOwnerTitle = isOwner ? 'คำขอแลกสินค้า ' : 'รายละเอียดการแลกสินค้า';
              return Text(
                isOwnerTitle,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _notificationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('ไม่มีข้อมูลการแจ้งเตือน'));
            } else {
              final notificationData = snapshot.data!;
              if (notificationData['exchanger_id'] != null && _itemsFuture == null) {
                _itemsFuture = fetchExchangedItems(notificationData['exchanger_id']);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                 Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector( 
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: Container(
                                  width: double.infinity,
                                  height: 300, 
                                  child: Image.network(
                                    '${widget.myIP}:3000/uploads/${notificationData['exchanger_profile_photo'] ?? 'default_profile_photo.png'}',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(
                            '${widget.myIP}:3000/uploads/${notificationData['exchanger_profile_photo'] ?? 'default_profile_photo.png'}',
                          ),
                        ),
                      ),
                          const SizedBox(width: 16),
                          Text(
                            notificationData['exchanger_username'] ?? 'Unknown User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.mail_outline),
                        color: Colors.black,
                        onPressed: () {
                          
                          print("Navigating to Chat with userId: ${widget.userId}, receiverId: ${notificationData['exchanger_id']}");

                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                            userId: widget.userId, 
                            receiverid: notificationData['exchanger_u_id'].toString(),
                          ),
                        ),
                      );
                    },
                  ),

                    ],
                  ),

                  const SizedBox(height: 30),
                  const Text(
                    'สินค้าที่ต้องการแลก',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<Item>>(
                    future: _itemsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('ไม่มีสินค้าที่นำมาแลก'));
                      } else {
                        final items = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            var exchangedItem = items[index];
                            List<dynamic> itemPhotos = [];

                            // Decode JSON หาก itemPhoto เก็บเป็น JSON ที่มีรูปภาพหลายภาพ
                            try {
                              itemPhotos = json.decode(exchangedItem.itemPhoto);
                            } catch (e) {
                              print('Error decoding item photos: $e');
                            }

                            String imageUrl = itemPhotos.isNotEmpty
                                ? '${myIP.domain}:3000/uploads/items/${itemPhotos[0]}'
                                : '';

                            return Container(
                              width: double.infinity,
                              height: 170,
                              margin: const EdgeInsets.symmetric(vertical: 8), 
                              child: Card(
                                elevation: 4, 
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: SizedBox(
                                          width: 150,
                                          height: 150,
                                          child: imageUrl.isNotEmpty
                                              ? Image.network(
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return const Center(child: Icon(Icons.image, size: 100));
                                                  },
                                                )
                                              : const Center(child: Icon(Icons.image, size: 100)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            exchangedItem.itemName,
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          Text('${exchangedItem.itemPrice}฿'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),

                 const SizedBox(height: 18),
                    Text(
                      isOwner
                        ? 'สินค้าที่ ${notificationData['exchanger_username'] ?? 'ผู้ใช้ไม่ทราบ'} นำมาแลกกับคุณ'
                        : 'สินค้าที่คุณนำมาแลกกับ ${notificationData['owner_username'] ?? 'ผู้ใช้ไม่ทราบ'}', 
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedItem != isOwner) 
                      Column(
                        children: [
                          Container(
                            width: double.infinity, 
                            height: 170, 
                            margin: const EdgeInsets.symmetric(vertical: 8), 
                            child: Card(
                              elevation: 4, 
                              child: Row( 
                                children: [
                                  Padding( 
                                    padding: const EdgeInsets.all(8.0), 
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: SizedBox(
                                        width: 150,
                                        height: 150,
                                        child: (_selectedItem?.itemPhoto != isOwner && _selectedItem!.itemPhoto.isNotEmpty)
                                          ? Image.network(
                                              '${myIP.domain}:3000/uploads/items/${json.decode(_selectedItem!.itemPhoto)[0]}',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                print('Error loading image: $error');
                                                return const Center(child: Icon(Icons.image, size: 100));
                                              },
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Center(child: CircularProgressIndicator());
                                              },
                                            )
                                          : const Center(child: Icon(Icons.image, size: 100)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8), // ระยะห่างระหว่างภาพและข้อมูลของสินค้า
                                  Expanded( 
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, 
                                      mainAxisAlignment: MainAxisAlignment.center, 
                                      children: [
                                        Text(
                                          _selectedItem?.itemName ?? 'Unknown Item', 
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text('${_selectedItem?.itemPrice ?? 0}฿'), 
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              isOwner 
                                ? 'กรุณาติดต่อผู้ที่ขอแลกเปลี่ยนเพื่อตกลงกัน\nก่อนกดยอมรับการแลกเปลี่ยนสินค้า' 
                                : 'กรุณาติดต่อเจ้าของสินค้า\nเพื่อตกลงการแลกเปลี่ยนสินค้า', 
                              textAlign: TextAlign.center, 
                              style: const TextStyle(
                                color: Colors.red, 
                                fontWeight: FontWeight.bold, 
                                fontSize: 16, 
                              ),
                            ),
                          ),
                        ],
                      ),

                const SizedBox(height: 15),
                 Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                    children: [
                      SizedBox(
                        height: 45,
                        width: 150,
                        child: CustomButton(
                          title: 'ปฏิเสธ',
                          onPressed: (BuildContext context) async {
                            // ignore: unnecessary_null_comparison
                            if (notificationData == null) {
                              print('Error: notificationData is null');
                              return;
                            }

                            final exchangeId = notificationData['exchanger_id']?.toString() ?? '';
                            final selectedItemId = notificationData['selected_item_id']?.toString() ?? '';
                            final ownerId = widget.userId;

                            if (exchangeId.isEmpty || selectedItemId.isEmpty || ownerId.isEmpty) {
                              print('Error: One or more required IDs are empty.');
                              return;
                            }

                            await rejectExchange(exchangeId, ownerId, selectedItemId);
                          },
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        height: 45,
                        width: 150,
                        child: CustomButton(
                          title: 'ยอมรับ',
                          onPressed: (BuildContext context) async {
                            // ignore: unnecessary_null_comparison
                            if (notificationData == null) {
                              print('Error: notificationData is null');
                              return;
                            }

                            final exchangeId = notificationData['exchanger_id']?.toString() ?? '';
                            final selectedItemId = notificationData['selected_item_id']?.toString() ?? '';
                            final ownerId = widget.userId;

                            if (exchangeId.isEmpty || selectedItemId.isEmpty || ownerId.isEmpty) {
                              print('Error: One or more required IDs are empty.');
                              return;
                            }

                            await saveExchangeId(exchangeId);
                            await acceptExchange(exchangeId, ownerId, selectedItemId);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SwapPage(),
                              ),
                            );
                          },
                          color: Colors.greenAccent[700],
                        ),
                      ),
                    ],
                  )
                ],
              );
            }
          },
        ),
      ),
    );
  }
}


class Item {
  final String itemName;
  final String itemPhoto;
  final double itemPrice;

  Item({required this.itemName, required this.itemPhoto, required this.itemPrice});

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemName: json['item_name'] ?? 'Unknown Item',
      itemPhoto: json['item_photo'] ?? 'default_photo.png',
      itemPrice: (json['item_price'] ?? 1).toDouble(),
    );
  }
}
