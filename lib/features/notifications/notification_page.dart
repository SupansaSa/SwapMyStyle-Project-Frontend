import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:myapp/features/notifications/noti_detail_page.dart';
import 'package:myapp/features/shop/swap/swap_page.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:myapp/screen/MyIP.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  NotificationsPage({required this.userId});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> notifications = [];
  late IO.Socket socket;
  MyIP myIP = MyIP();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    setupSocket();
  }

   Future<void> fetchNotifications() async {
  final url = Uri.parse('${myIP.domain}:3000/notifications/${widget.userId}');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final Map<String, dynamic> fetchedNotifications = json.decode(response.body);
    if (fetchedNotifications['notifications'] != null) {
      setState(() {
        notifications = (fetchedNotifications['notifications'] as List<dynamic>).map((notification) {
          return {
            'id': notification['id'] ?? '',
            'user_id': notification['user_id'] ?? '',
            'message': notification['message'] ?? 'ไม่มีข้อความ',
            'read': notification['read'] ?? false,
            'created_at': notification['created_at'] ?? 'ไม่มีวันที่',
            'exchanger_id': notification['exchanger_id'] ?? '',
            'exchanger_profile_photo': notification['exchanger_profile_photo'] ?? '',
            'item_photo': notification['item_photo'] ?? '',
          };
        }).toList();

        // กรองเฉพาะข้อความที่ต้องการ
        notifications = notifications.where((notification) {
          return notification['message'].contains('ต้องการแลกเปลี่ยนสินค้ากับคุณ') ||
                 notification['message'].contains('คำขอแลกเปลี่ยนของคุณได้รับการยอมรับเรียบร้อยแล้ว') ||
                 notification['message'].contains('คำขอแลกเปลี่ยนของคุณถูกปฏิเสธ') ||
                 notification['message'].contains('กรุณากดยืนยันรับสินค้า'); 
        }).toList();
      });
    } else {
      print('ไม่พบการแจ้งเตือน');
    }
  } else {
    print('เกิดข้อผิดพลาดในการดึงการแจ้งเตือน');
  }
}

void setupSocket() {
  socket = IO.io('${myIP.domain}:3000', IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

  socket.onConnect((_) {
    print('เชื่อมต่อกับเซิร์ฟเวอร์ Socket.io');
    socket.emit('subscribe', widget.userId);
  });

  socket.on('notification', (data) {
  print('Received notification: $data');
  // ตรวจสอบข้อความและเพิ่มการแจ้งเตือน
  if (data['message'] != null && 
      (data['message'].contains('ต้องการแลกเปลี่ยนสินค้ากับคุณ') ||
       data['message'].contains('คำขอแลกเปลี่ยนของคุณได้รับการยอมรับเรียบร้อยแล้ว') ||
       data['message'].contains('คำขอแลกเปลี่ยนของคุณถูกปฏิเสธ' ) ||
       data['message'].contains('กรุณากดยืนยันรับสินค้า'))) {
    setState(() {
      notifications.insert(0, {
        'id': data['id'] ?? '',
        'user_id': data['user_id'] ?? '',
        'message': data['message'] ?? 'ไม่มีข้อความ',
        'read': data['read'] ?? false,
        'created_at': data['created_at'] ?? 'ไม่มีวันที่',
        'exchanger_profile_photo': data['exchanger_profile_photo'] ?? '',
      });
    });
    print('New Notification Added: ${data['message']}'); // แสดงข้อความใหม่ที่เพิ่ม
  }
});


  socket.onDisconnect((_) => print('ตัดการเชื่อมต่อจากเซิร์ฟเวอร์ Socket.io'));
}

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    final url = Uri.parse('${myIP.domain}:3000/notifications/$notificationId/read');
    final response = await http.put(url);

    if (response.statusCode == 200) {
      print('Notification marked as read');
    } else {
      print('Failed to mark notification as read');
    }
  }

@override
Widget build(BuildContext context) {
  print('Notifications: $notifications');
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFFE966A0),
      title: const Text(
        'Notifications',
        style: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        color: Colors.white,
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      elevation: 0,
    ),
    body: ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        print('Notification ID: ${notification['id']}, Message: ${notification['message']}'); // debug output
        final message = notification['message'] ?? 'ไม่มีข้อความ';
        final createdAt = formatDate(notification['created_at'].toString());

        return GestureDetector(
          onTap: () async {
          await markNotificationAsRead(notification['id'].toString());

          if (message.contains('คำขอแลกเปลี่ยนของคุณถูกปฏิเสธ')) {
            // ไม่ต้องนำไปที่หน้าอื่น แค่ทำเครื่องหมายว่าอ่านแล้ว
            print('Notification only, no navigation needed');
          } else if (message.contains('คำขอแลกเปลี่ยนของคุณได้รับการยอมรับเรียบร้อยแล้ว')) {
            print('Displaying confirmation request notification');
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SwapPage(),
              ),
            );
          } else if (message.contains('กรุณากดยืนยันรับสินค้า')) {
            print('Displaying confirmation request notification');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SwapPage(), // นำทางไปยัง ConfirmReceiptPage
              ),
            );
          } else {
            // ignore: use_build_context_synchronously
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailPage(
                  notificationId: notification['id'].toString(),
                  myIP: myIP.domain,
                  isOwner: notification['user_id'] == widget.userId,
                  userId: widget.userId,
                ),
              ),
            );
          }
            setState(() {
              notification['read'] = true;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notification['read'] ? Colors.grey.shade200 : Colors.white,
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
                  // แสดงรูปสินค้าเฉพาะในกรณีที่มีการแจ้งเตือนเกี่ยวกับการแลกเปลี่ยน
                  if (message.contains('คำขอแลกเปลี่ยนของคุณได้รับการยอมรับเรียบร้อยแล้ว') ||
                      message.contains('คำขอแลกเปลี่ยนของคุณถูกปฏิเสธ')) ...[
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: (() {
                            final itemPhoto = notification['item_photo'];
                            if (itemPhoto != null && itemPhoto.isNotEmpty) {
                              try {
                                final photos = json.decode(itemPhoto);
                                if (photos is List && photos.isNotEmpty) {
                                  return NetworkImage('${myIP.domain}:3000/uploads/items/${photos[0]}');
                                }
                              } catch (e) {
                                print('Error decoding selected item photos: $e');
                              }
                            }
                            return const AssetImage('assets/image/noimage.png') as ImageProvider;
                          })(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(width: 12),
                  ],
                  
                  if (!message.contains('คำขอแลกเปลี่ยนของคุณได้รับการยอมรับเรียบร้อยแล้ว') &&
                      !message.contains('คำขอแลกเปลี่ยนของคุณถูกปฏิเสธ'))
                    CircleAvatar(
                      backgroundImage: (notification['exchanger_profile_photo'] != null && notification['exchanger_profile_photo'].isNotEmpty)
                          ? NetworkImage('${myIP.domain}:3000/uploads/${notification['exchanger_profile_photo']}')
                          : AssetImage('assets/image/user1.png') as ImageProvider,
                      radius: 30,
                    ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          createdAt,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
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
}
