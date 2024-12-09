import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/authentication/forgot_password/ResetPassworrd.dart';
import 'package:myapp/features/authentication/forgot_password/email_verify_page.dart';
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/thems/theme.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/custom_button.dart';


class Forgetpassword extends StatefulWidget {
  static const double defaultMargin = 16.0;

  const Forgetpassword({super.key});

  @override
  _ForgetpasswordState createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final TextEditingController email = TextEditingController();
  final TextEditingController _recoverController = TextEditingController();

  bool _isLoading = false;

  String? _message;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    MyIP myIP = MyIP();

    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/forget_password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email.text,
        'recover': _recoverController.text,
      }),
    );

    setState(() {
      _isLoading = false;
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success']) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Resetpassword(email: email.text)),
          );
        } else {
          _showErrorDialog('Error', jsonResponse['error']);
        }
      } else {
        _showErrorDialog('เกิดข้อผิดพลาด', 'กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ');
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()), // Navigate to the login page
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Forgetpassword.defaultMargin,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  Text(
                    'Forget Password',
                    style: blackTextStyle.copyWith(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    title: 'Email',
                    hintText: 'Type your email...',
                    textEditingController: email,
                    prefixIcon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    title: 'Recover Password',
                    hintText: 'Type your Recover password...',
                    textEditingController: _recoverController,
                    prefixIcon: const Icon(Icons.record_voice_over),
                  ),
                  
                  const SizedBox(height: 15),
                  Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmailVerificationPage()),
                      );
                    },
                    child: Text(
                      'ลืม Recover Password?',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  if (_message != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      _message!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                  ]
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            title: 'Check Email',
                            onPressed: (BuildContext context) {
                              _login();
                            },
                          ),
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
