import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:myapp/features/chat/Chat.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';

class ChatHistory {
  final String contactId;
  final String username;
  final String profilePhoto;
  final String message;
  final String time;

  ChatHistory({
    required this.contactId,
    required this.username,
    required this.profilePhoto,
    required this.message,
    required this.time,
  });

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      contactId: json['contact_id'].toString(),
      username: json['username'] ?? 'Unknown User',
      profilePhoto: json['profile_photo'] ?? '',
      message: json['last_message'] ?? '',
      time: json['last_time'] ?? '',
    );
  }
}

class ChatHistoryPage extends StatefulWidget {
  final String userId;

  const ChatHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ChatHistoryPageState createState() => _ChatHistoryPageState();
}

class _ChatHistoryPageState extends State<ChatHistoryPage> {
  late Future<List<ChatHistory>> chatHistory;
  MyIP myIP = MyIP();

  @override
  void initState() {
    super.initState();
    chatHistory = fetchChatHistory(widget.userId);
  }

  Future<List<ChatHistory>> fetchChatHistory(String userId) async {
    final response = await http.get(Uri.parse('${myIP.domain}:3000/chat-history/$userId'));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List<dynamic> chatHistoryData = jsonResponse['chatHistory'];
      return chatHistoryData.map((chat) => ChatHistory.fromJson(chat)).toList();
    } else {
      print('Failed to load chat history: ${response.body}');
      throw Exception('Failed to load chat history');
    }
  }

  String formatMessage(String message) {
    return message == 'Send Photo' ? 'Send Photo' : message;
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Chat'),
      backgroundColor: const Color(0xFFE966A0), 
      titleTextStyle: const TextStyle(
        color: Colors.white, 
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(
        color: Colors.white, 
      ),
    ),
    body: FutureBuilder<List<ChatHistory>>(
      future: chatHistory,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error: ${snapshot.error}');
          return Center(child: Text('Error: ${snapshot.error}. Please try again.'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No chat history found.'));
        }

        final chatList = snapshot.data!;
        return ListView.builder(
          itemCount: chatList.length,
          itemBuilder: (context, index) {
            final chat = chatList[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: NetworkImage(
                    '${myIP.domain}:3000/uploads/${chat.profilePhoto.isNotEmpty ? chat.profilePhoto : 'default_profile_photo.png'}',
                  ),
                ),
                title: Text(
                  chat.username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(formatMessage(chat.message)),
                trailing: Text(chat.time),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Chat(
                        userId: widget.userId,
                        receiverid: chat.contactId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    ),
  );
}
}
