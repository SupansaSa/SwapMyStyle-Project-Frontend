import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/features/shop/add/item_detail_page.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> item;
  const UserProfilePage({super.key, required this.userId, required this.item});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? userId;
  String _username = 'Loading...';
  String? _profilePhoto;
  bool _loading = true;
  int _creditPoints = 0;
  int _discreditPoints = 0;
  MyIP myIP = MyIP();
  List<Map<String, dynamic>> _items = []; 

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
      await _fetchUserProfile();
      await _fetchUserItems(); // ดึงสินค้าของผู้ใช้
    }
  }

  Future<void> _fetchUserProfile() async {
    final response = await http.get(Uri.parse('${myIP.domain}:3000/getUserProfile?userId=${widget.userId}'));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _username = data['username'];
            _profilePhoto = data['profile_photo'];
            _creditPoints = data['credit_points'];
            _discreditPoints = data['discredit_points'];
            _loading = false;
          });
        } else {
          setState(() {
            _username = 'Error fetching username';
            _loading = false;
          });
        }
      } catch (e) {
        print('Failed to parse JSON: $e');
        setState(() {
          _username = 'Error fetching username';
          _loading = false;
        });
      }
    } else {
      print('Failed to fetch user profile: ${response.statusCode}');
      setState(() {
        _username = 'Error fetching username';
        _loading = false;
      });
    }
  }

  Future<void> _fetchUserItems() async {
    try {
      final response = await http.get(Uri.parse('${myIP.domain}:3000/user-items/${widget.userId}'));
      if (response.statusCode == 200) {
        final List<dynamic> items = json.decode(response.body);
        setState(() {
          _items = items.cast<Map<String, dynamic>>();
        });
      } else {
        print('Error fetching items: ${response.body}');
      }
    } catch (e) {
      print('Exception while fetching user items: $e');
    }
  }

  void _showDiscreditReason() async {
  
  final response = await http.get(Uri.parse('${myIP.domain}:3000/discredit_points/${widget.userId}'));

  if (response.statusCode == 200) {
    
    final List<dynamic> data = json.decode(response.body);

    
    String reasons = data.map((item) => " - ${item['reason']}").join("\n");

    
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('เหตุผลที่ได้รับ Discredit'),
          content: Text(reasons.isNotEmpty ? reasons : 'ไม่มีเหตุผล'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิด dialog
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  } else {
    
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: const Text('ไม่สามารถดึงข้อมูลคะแนนดิสเครดิตได้'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); 
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE966A0),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchUserProfile();
          await _fetchUserItems();
        },
        child: Container(
         
          color: Colors.white, 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 260,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE966A0), Color(0xFFEDE4FF)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundImage: _profilePhoto != null
                                  ? NetworkImage(_profilePhoto!)
                                  : const AssetImage('assets/image/user1.png') as ImageProvider,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _username,
                              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                            
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '           Credit: $_creditPoints',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 50),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Discredit: $_discreditPoints',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.info_outline),
                                          onPressed: _showDiscreditReason,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'สินค้าของผู้ใช้',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _items.isEmpty
                    ? const Center(child: Text('No items available.'))
                    : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final item = _items[index];

                            
                            List<dynamic> itemPhotos = [];
                            if (item['item_photo'] != null) {
                              print('item_photo: ${item['item_photo']}');
                              try {
                                itemPhotos = json.decode(item['item_photo']);
                              } catch (e) {
                                print('Failed to decode item photos: $e');
                              }
                            }

                            return GestureDetector(
                              onTap: () async {
                                final prefs = await SharedPreferences.getInstance();
                                final currentUserId = prefs.getString('userId') ?? '';

                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ItemDetailPage(
                                      item:widget.item,
                                      currentUserId: currentUserId,
                                      ownerUserId: item['user_id'],
                                      
                                      
                                      
                                    ),
                                  ),
                                );
                              },
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (itemPhotos.isNotEmpty)
                                        Container(
                                          height: 150,
                                          width: double.infinity,
                                          child: Image.network(
                                            '${myIP.domain}:3000/uploads/items/${itemPhotos[0]}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(Icons.image, size: 150);
                                            },
                                          ),
                                        )
                                      else
                                        const Icon(Icons.image, size: 150),
                                      const SizedBox(height: 8.0),
                                      Text(
                                        item['item_name'] ?? 'No Name',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${item['item_price'].toString()}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
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
            ),
          ],
        ),
      ),
    ),
  );
}
}