import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/authentication/forgot_password/forgot_password_page.dart';
import 'package:myapp/features/authentication/signUp/sign_up_page.dart';
import 'package:myapp/features/shop/home/home_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/thems/theme.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/features/admin/admin_home.dart'; 


class LoginScreen extends StatefulWidget {
  static const double defaultMargin = 16.0;

  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isVisible = false;
  String? _message;
   MyIP myIP = MyIP();

  Future<void> _storeUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    print('Stored userId: $userId'); // พิมพ์ userId ที่ถูกเก็บ
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _message = null; // Clear previous message
    });

    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': _emailController.text,
        'password': _passwordController.text,
      }),
    );

    setState(() {
      _isLoading = false;
    });

    // Print the full response body to debug
    print('Response body: ${response.body}');

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (jsonResponse['success']) {
        final user = jsonResponse['user'];
        if (user != null && user['id'] != null && user['role'] != null) {
          final userId = user['id'].toString();
          final userRole = user['role'].toString();
          _storeUserId(userId);

          // ตรวจสอบบทบาทผู้ใช้และนำทางไปยังหน้าที่เหมาะสม
          if (userRole == 'admin') {
            print('Admin logged in with userId: $userId');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AdminHome()), // นำทางไปยังหน้า Admin
            );
          } else {
            print('User logged in with userId: $userId');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage()), // นำทางไปยังหน้า User ปกติ
            );
          }
        } else {
          _showErrorDialog(
              'เกิดข้อผิดพลาด', 'ไม่พบข้อมูลผู้ใช้ในคำตอบจากเซิร์ฟเวอร์');
        }
      } else {
        _showErrorDialog('เกิดข้อผิดพลาด', jsonResponse['message']);
      }
    } else {
      _showErrorDialog('เกิดข้อผิดพลาด',
          jsonResponse['message'] ?? 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ');
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
              style: TextButton.styleFrom(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: LoginScreen.defaultMargin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 90),
                  const SizedBox(height: 15),
                  Text(
                    'Sign In',
                    style: blackTextStyle.copyWith(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    title: 'Email',
                    hintText: 'Type your email...',
                    textEditingController: _emailController,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    title: 'Password',
                    hintText: 'Type your password...',
                    obscureText: !_isVisible,
                    textEditingController: _passwordController,
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isVisible = !_isVisible;
                        });
                      },
                      icon: _isVisible
                          ? const Icon(Icons.visibility, color: Colors.black)
                          : const Icon(Icons.visibility_off,
                              color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Forgetpassword()),
                          );
                        },
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            title: 'Login',
                            onPressed: (BuildContext context) {
                              if (_emailController.text.isEmpty ||
                                  _passwordController.text.isEmpty) {
                                _showErrorDialog('เกิดข้อผิดพลาด',
                                    'กรุณากรอกอีเมลและรหัสผ่าน');
                                return;
                              }
                              _login();
                            },
                          ),
                  ),
                  const SizedBox(height: 15),
                  if (_message != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _message!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an Account?',
                        style:
                            grayTextStyle.copyWith(fontWeight: FontWeight.w400),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUpPage()),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: whiteTextStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE966A0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: LoginScreen(),
  ));
}
