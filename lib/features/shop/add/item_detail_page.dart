import 'package:flutter/material.dart';
import 'package:myapp/features/chat/Chat.dart';
import 'package:myapp/features/profile/user_profile_page.dart';
import 'package:myapp/features/shop/add/add_home.dart';
import 'package:myapp/features/shop/add/edit_item_page.dart';
import 'package:myapp/features/shop/home/home_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/features/shop/add/add_item_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  final String currentUserId;
  final MyIP myIP = MyIP();
  final String? ownerUserId;
  
  

  ItemDetailPage({
    Key? key,
    required this.item,
    required this.currentUserId,
    this.ownerUserId,
   
  }) : super(key: key);
  


  @override
  _ItemDetailPageState createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  List<Map<String, dynamic>> _items = [];
  String? userId;
  /*bool _isFavorited = false;*/
  Map<String, dynamic>? selectedItemForSwap, _userProfile;
  Map<String, dynamic>? swapData;
  
  MyIP myIP = MyIP();

  Future<int?> fetchCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    print('userId from SharedPreferences: $userId');

    if (userId != null) {
      return int.tryParse(userId);
    } else {
      _showErrorDialog('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาล็อกอินอีกครั้ง');
      return null;
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('ตกลง', style: TextStyle(color: Colors.pink)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /*void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });
  }*/

 void _sendSwapRequest() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');

  if (userId == null || userId.isEmpty) {
    _showSnackBar('ID ของผู้ใช้หายไป กรุณาลองใหม่อีกครั้ง');
    return;
  }

  final parsedUserId = int.tryParse(userId);
  if (parsedUserId == null) {
    _showSnackBar('ID ของผู้ใช้ไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง');
    return;
  }

  final itemId = widget.item['id'];
  if (itemId == null) {
    _showSnackBar('ID ของสินค้าหายไป กรุณาลองใหม่อีกครั้ง');
    return;
  }

  final swapItemId = selectedItemForSwap?['id'];
  if (swapItemId == null) {
    _showSnackBar('ID ของสินค้าที่จะแลกหายไป กรุณาลองใหม่อีกครั้ง');
    return;
  }

  final url = Uri.parse('${myIP.domain}:3000/exchanges');
  final requestPayload = json.encode({
    'itemId': itemId,
    'userId': parsedUserId,
    'selectedItemId': swapItemId,
  });

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: requestPayload,
    );

    if (response.statusCode == 200) {
      await _showConfirmationDialog(); 
      // ignore: use_build_context_synchronously
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()), 
        (Route<dynamic> route) => false, 
      );
    } else {
      _showSnackBar('ข้อผิดพลาดในการส่งคำขอแลกเปลี่ยน: ${response.body}');
    }
  } catch (e) {
    _showSnackBar('ข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์: $e');
  }
}

Future<void> _showConfirmationDialog() async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          'คำขอแลกสินค้าสำเร็จ',
          style: TextStyle(fontWeight: FontWeight.bold), 
        ),
        content: Text('คำขอแลกสินค้าของคุณถูกส่งเรียบร้อยแล้ว'),
        actions: <Widget>[
          TextButton(
            child: Text('ตกลง', style: TextStyle(color: Colors.pink)),
            onPressed: () {
              Navigator.of(context).pop(); 
            },
          ),
        ],
      );
    },
  );
}



void _showSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
  ));
}


  Future<bool> _deleteItem(String item_id, String user_id) async {
  try {
    final response = await http.delete(
      Uri.parse('${myIP.domain}:3000/deleteItem/$item_id?userId=$user_id'), 
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error: ${response.reasonPhrase}');
      return false;
    }
  } catch (e) {
    print('Exception: $e');
    return false;
  }
}



  void _showDeleteDialog(bool isDeleted) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isDeleted ? 'สำเร็จ' : 'ข้อผิดพลาด'),
          content: Text(isDeleted ? 'ลบรายการสำเร็จ' : 'ลบรายการล้มเหลว'),
          actions: <Widget>[
            TextButton(
              child: Text('ตกลง'),
              onPressed: () {
                Navigator.of(context).pop();
                if (isDeleted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AddHomePage()),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }




void _onActionButtonPressed(String action) async {
  if (action == 'swap') {
    _showSelectItemDialog();
  } else if (action == 'edit') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditItemPage(item: widget.item),
      ),
    );
  } else if (action == 'delete') {
    showDialog(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(
      'ยืนยันการลบ',
      style: TextStyle(fontWeight: FontWeight.bold), 
    ),
    content: Text('คุณแน่ใจหรือว่าต้องการลบรายการนี้?'),
    actions: <Widget>[
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          
          String currentUserId = userId.toString(); 
          bool success = await _deleteItem(
            widget.item['id'].toString(),
            currentUserId,
          );
          _showDeleteDialog(success);
        },
        child: Text(
          'ลบ',
          style: TextStyle(color: Colors.pink), 
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text(
          'ยกเลิก',
          style: TextStyle(color: Colors.pink), 
        ),
      ),
    ],
  ),
);

  }
}


Future<void> checkBanStatusAndProceed(Function action) async {
  try {
    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/getUserStatus'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );

    print('Response status: ${response.statusCode}'); 
    print('Response body: ${response.body}'); 

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User status: ${data['status']}'); 
      if (data['status'] == true) {
        _showErrorDialog('บัญชีถูกระงับ',
            'คุณไม่สามารถดำเนินการนี้ได้ เนื่องจากบัญชีของคุณถูกระงับ');
      } else {
        action(); 
      }
    } else {
      print('Failed to get user status: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Error: $e'); 
  }
}

  
 Future<void> _submitReport(String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');
    final itemId =
        widget.item['id']; 
    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/reportItem'),
      body: jsonEncode({'userId': userId, 'itemId': itemId, 'reason': reason}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report submitted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit report')),
      );
    }
  }




  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String selectedReason = '';
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Report Item'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile(
                    title: Text('สินค้านอกเหนือจากเสื้อผ้าและเครื่องประดับ'),
                    value: 'สินค้านอกเหนือจากเสื้อผ้าและเครื่องประดับ',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('สินค้าผิดกฎหมาย'),
                    value: 'สินค้าผิดกฎหมาย',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value.toString();
                      });
                    },
                  ),
                  RadioListTile(
                    title: Text('ชื่อ/ภาพของสินค้ามีความอนาจาร'),
                    value: 'ชื่อ/ภาพของสินค้ามีความอนาจาร',
                    groupValue: selectedReason,
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value.toString();
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('ยกเลิก'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text('ตกลง'),
                  onPressed: () {
                    _submitReport(selectedReason);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }



   @override
  void initState() {
    super.initState();
    fetchCurrentUserId().then((id) {
      setState(() {
        userId = id?.toString();
      });
      _loadUserProfile(); 
      _loadItems(); 
    });
  }


  Future<Map<String, dynamic>?> _fetchUserProfile(int userId) async {
  try {
    final response = await http.get(Uri.parse('${myIP.domain}:3000/getUserProfile?userId=$userId'));

    print('API Response Status: ${response.statusCode}'); 
    print('API Response Body: ${response.body}'); 
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        return {
          'username': data['username'],
          'profile_photo': data['profile_photo']
        };
      } else {
        print('Failed to fetch user profile: ${data['message']}'); 
      }
    } else {
      print('Failed to load user profile: ${response.statusCode}'); 
    }
  } catch (error) {
    print('Error fetching user profile: $error');
  }
  return null; 
}


Future<void> _loadUserProfile() async {
  if (widget.item['user_id'] != null) {
    final profileData = await _fetchUserProfile(widget.item['user_id']);
    setState(() {
    _userProfile = profileData ?? {
    'username': 'Unknown User',
    'profile_photo': null,
  };
});
  }
}



  Future<void> _loadItems() async {
    if (userId == null) return;
    final response = await http
        .get(Uri.parse('${myIP.domain}:3000/getItems?userId=$userId'));

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        print('Received data: $data'); 
        final List<dynamic> items = data['items'];
        setState(() {
          _items = List<Map<String, dynamic>>.from(items);
        });
      } catch (e) {
        print('Failed to parse JSON: $e'); 
      }
    } else {
      print(
          'Failed to load items: ${response.statusCode}');
    }
  }



  Future<void> _fetchUserItems() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    
    if (userId != null) {
      final response = await http.get(Uri.parse('${myIP.domain}:3000/user-items/$userId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> items = json.decode(response.body);
        setState(() {
          _items = items.cast<Map<String, dynamic>>(); 
        });
      } else {
        print('Error fetching items: ${response.body}');
      }
    }
  } catch (e) {
    print('Exception while fetching user items: $e');
  }
}


void _showSelectItemDialog() async {
  await _fetchUserItems();
  
  // กรองรายการสินค้าที่ไม่ได้ถูกล็อก
  final unlockedItems = _items.where((item) => item['is_locked'] == false).toList();

  // ignore: use_build_context_synchronously
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.all(16),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'กรุณาเลือกสินค้าของคุณ \nเพื่อทำแลกเปลี่ยน',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Divider(),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 400,
          child: unlockedItems.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: unlockedItems.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = unlockedItems[index];
                    String imageUrl = '';

                    try {
                      // ตรวจสอบ item['item_photo'] ว่าเป็น JSON ที่ถูกต้อง
                      if (item['item_photo'] != null && item['item_photo'].isNotEmpty) {
                        List<dynamic> photos = json.decode(item['item_photo']);
                        if (photos.isNotEmpty) {
                          imageUrl = '${myIP.domain}:3000/uploads/items/${photos[0]}';
                        }
                      }
                    } catch (e) {
                      print('Error parsing item_photo: $e');
                    }

                    return Card(
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return const Center(child: Icon(Icons.image, size: 100));
                                    },
                                  ),
                                )
                              : const Center(child: Icon(Icons.image, size: 10)),
                        ),
                        title: Text(
                          item['item_name'] ?? 'ชื่อสินค้าไม่ระบุ',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('${item['item_price'] ?? '0'}฿'),
                        onTap: () {
                          setState(() {
                            selectedItemForSwap = item;
                          });
                          Navigator.of(context).pop();
                          _sendSwapRequest();
                        },
                      ),
                    );
                  },
                )
              : const Center(
                  child: Text('ไม่มีสินค้าของคุณในขณะนี้'),
                ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 45,
                  width: 120,
                  child: CustomButton(
                    title: 'ยกเลิก',
                    onPressed: (BuildContext context) {
                      Navigator.of(context).pop();
                    },
                    color: Colors.deepPurple[500],
                  ),
                ),
                SizedBox(
                  height: 45,
                  width: 120,
                  child: CustomButton(
                    title: 'เพิ่มสินค้าอื่น',
                    onPressed: (BuildContext context) {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddItemPage()),
                      );
                    },
                    color: Color(0xFFE966A0),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}


@override
Widget build(BuildContext context) {
  final String ownerUserId = widget.item['user_id'].toString();

  
  return FutureBuilder<int?>(
    future: fetchCurrentUserId(),
    builder: (context, snapshot) {
      AppBar appBar = AppBar(
        title: Text(
          'รายละเอียดสินค้า',
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (snapshot.hasData && snapshot.data != null)
            if (widget.item['user_id'] != snapshot.data) 
              IconButton(
                icon: const Icon(
                  Icons.flag,
                  color: Color.fromARGB(255, 236, 14, 14),
                ),
                onPressed: () => _showReportDialog(context),
              ),
        ],
      );

      if (snapshot.connectionState == ConnectionState.waiting) {
        return Scaffold(
          appBar: appBar,
          body: const Center(child: CircularProgressIndicator()),
        );
      } else if (snapshot.hasError || !snapshot.hasData) {
        return Scaffold(
          appBar: appBar,
          body: const Center(child: Text('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ใช้')),
        );
      } else {
        int currentUserId = snapshot.data!;
        bool isOwner = widget.item['user_id'] == currentUserId;

        List<dynamic> itemPhotos = [];
        if (widget.item['item_photo'] != null) {
          try {
            itemPhotos = json.decode(widget.item['item_photo']);
          } catch (e) {
            print('Failed to decode item photos: $e');
          }
        }

        return Scaffold(
          appBar: appBar,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (itemPhotos.isNotEmpty)
                  Container(
                    height: 300,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: itemPhotos.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: Center(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(
                                          '${myIP.domain}:3000/uploads/items/${itemPhotos[index]}',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                '${myIP.domain}:3000/uploads/items/${itemPhotos[index]}',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
               const SizedBox(height: 20),
               
                if (!isOwner) 
                  Row(
                    children: [
                     
                      GestureDetector(
                        onTap: () {
                          
                          if (userId != null) {
                            
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserProfilePage(userId: ownerUserId,item: widget.item)), 
                            );
                          } else {
                           
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
                            );
                          }
                        },
                        child: CircleAvatar(
                          radius: 25,
                          backgroundImage: _userProfile?['profile_photo'] != null
                              ? NetworkImage(_userProfile!['profile_photo']) as ImageProvider 
                              : const AssetImage('assets/image/user1.png'), 
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _userProfile?['username'] ?? 'Unknown User', 
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold, 
                        ),
                      ),
                      const Spacer(), 
                      
                      GestureDetector(
                        onTap: () {
                       
                          if (userId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UserProfilePage(userId: ownerUserId, item: widget.item)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('ไม่พบข้อมูลผู้ใช้')),
                            );
                          }
                        },
                        child: const Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.pink,
                        ),
                      ),
                    
                  

                      IconButton(
                        icon: const ImageIcon(
                          AssetImage('assets/image/speech-bubble.png'),
                          size: 24,
                          color: Colors.pink,
                        ),
                        onPressed: () {
                          
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chat(
                                  userId:userId.toString() , 
                                  receiverid:ownerUserId, 
                                ),
                              ),
                            );
                          
                        }
                      ),
                    ],
                  ),

                  const SizedBox(height: 16.0),
                  Text('${widget.item['item_name']}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: ' Type : ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: '${widget.item['item_type']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: ' Price(baht) : ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: '${widget.item['item_price'].toString()}',
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: ' Description : ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                        TextSpan(
                          text: '${widget.item['item_description']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 18,
                              color: Colors.black),
                        ),
                        
                      ],
                      
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),

                  
                  const SizedBox(height: 30),

                  
                 if (isOwner)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Color(0xFFE966A0)),
                            onPressed: () {
                              checkBanStatusAndProceed(() => _onActionButtonPressed('delete'));
                            },
                          ),
                        ),


                        const SizedBox(width: 20),
                        Expanded(
                          child: SizedBox(
                            height: 45,
                            child: CustomButton(
                              title: 'Edit',
                              onPressed: (BuildContext context) {
                                checkBanStatusAndProceed(
                                  () {
                                  Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) {
      print('Navigating to EditItemPage with item: ${widget.item}');
      return EditItemPage(item: widget.item);
    },
  ),


                                    ).then((updatedItem) {
                                      if (updatedItem != null) {
                                        setState(() {
                                          widget.item.addAll(updatedItem);
                                        });
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [*/
                        /*CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          child: IconButton(
                            icon: Icon(
                              _isFavorited
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _isFavorited
                                  ? Color(0xFFE966A0)
                                  : Color(0xFFE966A0),
                            ),
                            onPressed: _toggleFavorite,
                          ),
                        ),*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 45,
                                width: 80, 
                                child: CustomButton(
                                  title: 'Swap',
                                onPressed: (BuildContext context) {
                                checkBanStatusAndProceed(
                                  () {
                                    _onActionButtonPressed('swap');
                                  },
                                );
                                
                              },
                              
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }
}

