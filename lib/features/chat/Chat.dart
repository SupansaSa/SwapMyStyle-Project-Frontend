import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class Chat extends StatefulWidget {
  final String userId;
  final String receiverid;
  

  const Chat({
    Key? key,
    required this.userId,
    required this.receiverid, 
    
  }) : super(key: key);

 

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Message> _messages = [];
  final Duration _fetchInterval = const Duration(seconds: 2);
  final ImagePicker _picker = ImagePicker();
  Timer? _messageFetchTimer;
  File? _imageFile;
  bool _hasScrolledToBottom = false;
  late String profileImageUrl = '';
  MyIP myIP = MyIP();
  String? _username;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _startPeriodicFetch();
    print('Receiver ID: ${widget.receiverid}');
    _fetchUsername();
  }

  @override
  void dispose() {
    _stopPeriodicFetch();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && !_hasScrolledToBottom) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        _hasScrolledToBottom = true;
      }
    });
  }

  void _fetchInitialData() {
    _fetchMessages();
  }

  void _startPeriodicFetch() {
    _messageFetchTimer = Timer.periodic(_fetchInterval, (_) {
      _fetchMessages();
    });
  }

  void _stopPeriodicFetch() {
    _messageFetchTimer?.cancel();
  }
Future<void> _fetchMessages() async {
  try {
    final response = await http.get(
      Uri.parse('${myIP.domain}:3000/mes?sender_id=${widget.userId}&receiver_id=${widget.receiverid}'),
    );

    if (response.statusCode == 200) {
      List<Message> fetchedMessages = (jsonDecode(response.body)['messages'] as List)
          .map((data) => Message(
                id: data['id'], 
                senderId: data['sender_id'].toString(), 
                message: data['message'],
                time: DateTime.parse(data['time']),
                imageUrl: data['image_path'],
                profileImageUrl: data['profile_image_url'],
                receiverRealName: data['receiver_real_name'],
                receiverSurname: data['receiver_surname'],
              ))
          .toList();

      setState(() {
        _messages = fetchedMessages;
      });
      _scrollToBottom();
    } else {
      print('Failed to load messages: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching messages: $e');
  }
}


Future<void> sendMessage() async {
  String messageText = _messageController.text.trim();

  if (widget.userId.isEmpty || widget.receiverid.isEmpty) {
    print('Error: Sender or receiver id is empty.');
    return;
  }

  if (messageText.isNotEmpty || _imageFile != null) {
    final url = Uri.parse('${myIP.domain}:3000/send-mes');
    final request = http.MultipartRequest('POST', url)
      ..fields['sender_id'] = widget.userId 
      ..fields['receiver_id'] = widget.receiverid
      ..fields['message'] = messageText.isNotEmpty ? messageText : '' 
      ..fields['time'] = DateTime.now().toIso8601String();

  
    if (_imageFile != null) {
      final fileBytes = await _imageFile!.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        fileBytes,
        filename: _imageFile!.path.split('/').last,
      ));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _messages.add(Message(
            id: responseData['messageId'], 
            senderId: widget.userId,
            message: messageText,
            time: DateTime.now(),
            imageUrl: _imageFile != null ? '/uploads/${_imageFile!.path.split('/').last}' : null,
          ));
          _messageController.clear();
          _imageFile = null;
        });
        _scrollToBottom();
      } else {
        print('Failed to send message: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
}

Future<void> _fetchUsername() async {
  try {
    final response = await http.get(Uri.parse('${myIP.domain}:3000/users/${widget.receiverid}'));
  
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Response data: $data'); 
      setState(() {
        _username = data['username'];  
      });
    } else {
      print('Failed to fetch username: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching username: $e');
  }
}


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteMessage(int messageId) async {
    final url = Uri.parse('${myIP.domain}:3000/delete-mes?id=$messageId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        setState(() {
          _messages.removeWhere((msg) => msg.id == messageId);
        });
      } else {
        print('Failed to delete message: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
           _username ?? 'Loading...', 
          style: const TextStyle(
            color: Colors.white, 
            fontSize: 20,
            fontWeight: FontWeight.bold,
              
          ),
        ),
        backgroundColor: const Color(0xFFE966A0),  
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Stack(
        children: [
           Container(
            decoration: const BoxDecoration(
              color: Colors.white,  
            ),
          ),
          Positioned.fill(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return MessageWidget(
                          message: _messages[index],
                          userid: widget.userId,
                          onDelete: () => _deleteMessage(_messages[index].id),
                        );
                      },
                    ),
                  ),
                ),
                if (_imageFile != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Image.file(
                          _imageFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel),
                          onPressed: () {
                            setState(() {
                              _imageFile = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      FloatingActionButton(
                        onPressed: _pickImage,
                        mini: true,
                        backgroundColor: const Color(0xFFE966A0),
                        child: const Icon(Icons.image, color: Colors.white),
                      ),
                      const SizedBox(width: 8),  
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.pink[50],
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: sendMessage,
                        icon: const Icon(Icons.send_rounded, color: Color(0xFFE966A0)), 
                        iconSize: 35,  
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final int id;
  final String senderId;
  final String message;
  final DateTime time;
  final String? imageUrl;
  final String? profileImageUrl;
  final String? receiverRealName; 
  final String? receiverSurname; 

  Message({
    required this.id,
    required this.senderId,
    required this.message,
    required this.time,
    this.imageUrl,
    this.profileImageUrl,
    this.receiverRealName,
    this.receiverSurname,
  });
}

MyIP myIP = MyIP();

class MessageWidget extends StatelessWidget {
  final Message message;
  final String userid;
  final VoidCallback onDelete;

  const MessageWidget({
    Key? key,
    required this.message,
    required this.userid,
    required this.onDelete,
  }) : super(key: key);

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 300,
              height: 300,
              child: Image.network(
                '${myIP.domain}:3000$imageUrl',
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  void _showProfileImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: SizedBox(
              width: 300,
              height: 300,
              child: message.profileImageUrl != null 
                ? Image.network(
                    '${myIP.domain}:3000${message.profileImageUrl}',
                    fit: BoxFit.cover,
                  )
                : Center(child: Text('No Profile Image')),
            ),
          ),
        );
      },
    );
  }

 @override
  Widget build(BuildContext context) {
    bool isMe = message.senderId == userid;

    // แปลงเวลาเป็นเวลาในท้องถิ่น
    DateTime localTime = message.time.toLocal();
    String formattedTime = '${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            GestureDetector(
              onTap: () => _showProfileImage(context), 
              child: CircleAvatar(
                radius: 20,
                backgroundImage: message.profileImageUrl != null 
                  ? NetworkImage('${myIP.domain}:3000${message.profileImageUrl}') 
                  : null,
                child: message.profileImageUrl == null 
                  ? Text(message.receiverRealName != null ? message.receiverRealName![0] : 'N') 
                  : null,
              ),
            ),
            const SizedBox(width: 8),

            // ข้อความของผู้รับ
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ถ้ามีรูปภาพให้แสดงรูปภาพ โดยไม่ใช้กรอบข้อความ
                if (message.imageUrl != null) ...[
                  GestureDetector(
                    onTap: () {
                      _showImageDialog(context, message.imageUrl!);
                    },
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4), 
                      child: Image.network(
                        '${myIP.domain}:3000${message.imageUrl}',
                        fit: BoxFit.cover,
                        height: 180,
                        width: 180,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return const Center(child: Text('Error loading image'));
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  // ถ้าไม่มีรูปภาพให้แสดงข้อความในกรอบ
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4), // ปรับขนาดที่นี่
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                        bottomLeft: Radius.circular(0.0),
                        bottomRight: Radius.circular(15.0),
                      ),
                    ),
                    child: Text(
                      message.message,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(width: 8),
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],

          if (isMe) ...[
            Text(
              formattedTime,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),

            const SizedBox(width: 8),

            // ข้อความของผู้ส่ง
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                
                if (message.imageUrl != null) ...[
                  GestureDetector(
                    onTap: () {
                      _showImageDialog(context, message.imageUrl!);
                    },
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4), 
                      child: Image.network(
                        '${myIP.domain}:3000${message.imageUrl}',
                        fit: BoxFit.cover,
                        height: 180,
                        width: 180,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                          return const Center(child: Text('Error loading image'));
                        },
                      ),
                    ),
                  ),
                ] else ...[
                  
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4), 
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.purple[100],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0),
                        bottomLeft: Radius.circular(15.0),
                        bottomRight: Radius.circular(0.0),
                      ),
                    ),
                    child: Text(
                      message.message,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}




