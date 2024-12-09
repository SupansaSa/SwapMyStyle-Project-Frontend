import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/thems/theme.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  File? _profileImage;
  String _profileImageUrl = '';
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController(); 
  final TextEditingController _lastnameController = TextEditingController(); 

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _firstnameController.dispose(); 
    _lastnameController.dispose(); 
    super.dispose();
  }
  
  MyIP myIP = MyIP();

  Future<void> _fetchUserProfile() async {
  final prefs = await SharedPreferences.getInstance();
  final String? userId = prefs.getString('userId');

  if (userId == null) {
    _showErrorDialog('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาล็อกอินอีกครั้ง');
    return;
  }

  final url = Uri.parse('${myIP.domain}:3000/getUserProfile?userId=$userId');
  final response = await http.get(url);
  final data = jsonDecode(response.body);

  if (response.statusCode == 200 && data['success']) {
    setState(() {
      _usernameController.text = data['username'];
      _firstnameController.text = data['firstname'] ?? '';  
      _lastnameController.text = data['lastname'] ?? '';    
      _profileImageUrl = data['profile_photo'] ?? '';
    });
    print(data);
    print('Firstname: ${data['firstname']}, Lastname: ${data['lastname']}');

  } else {
    _showErrorDialog('ข้อผิดพลาด', 'ไม่สามารถดึงข้อมูลผู้ใช้ได้');
  }
}


  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userId = prefs.getString('userId');

    if (userId == null) {
      _showErrorDialog('ข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ กรุณาล็อกอินอีกครั้ง');
      return;
    }

    final url = Uri.parse('${myIP.domain}:3000/updateProfile');
    final request = http.MultipartRequest('POST', url);

    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_image', _profileImage!.path));
    }
    
    request.fields['userId'] = userId;
    request.fields['username'] = _usernameController.text;
    request.fields['firstname'] = _firstnameController.text; 
    request.fields['lastname'] = _lastnameController.text;   

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Navigator.pop(context, true); 
      } else {
        _showErrorDialog('ข้อผิดพลาด', 'เกิดข้อผิดพลาดขณะอัปเดตข้อมูล: $responseBody');
      }
    } catch (error) {
      _showErrorDialog('ข้อผิดพลาด', 'เกิดข้อผิดพลาดขณะสื่อสารกับเซิร์ฟเวอร์: $error');
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

  Widget _buildProfileImage() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(75),
            border: Border.all(color: Colors.pink, width: 4),
          ),
          child: _profileImage == null
              ? _profileImageUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.camera_alt_outlined, size: 50, color: Colors.pink),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(75),
                      child: Image.network(_profileImageUrl, fit: BoxFit.cover),
                    )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(75),
                  child: Image.file(_profileImage!, fit: BoxFit.cover),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              const SizedBox(height: 15),
              Text(
                'Edit Profile',
                style: blackTextStyle.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              _buildProfileImage(), 
               const SizedBox(height: 15),
              CustomTextField(
                title: 'Username',
                hintText: 'Enter your username...',
                textEditingController: _usernameController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Firstname',
                hintText: 'Enter your firstname...',
                textEditingController: _firstnameController, 
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Lastname',
                hintText: 'Enter your lastname...',
                textEditingController: _lastnameController, 
              ),
             
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: 45,
                    width: 120,
                    child: CustomButton(
                      title: 'Cancel',
                      onPressed: (BuildContext context) {
                        Navigator.pop(context);
                      },
                      color: Colors.deepPurple[500],
                    ),
                  ),
                  SizedBox(
                    height: 45,
                    width: 120,
                    child: CustomButton(
                      title: 'Save',
                      onPressed: (BuildContext context) {
                        _updateProfile();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
