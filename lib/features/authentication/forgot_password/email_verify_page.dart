import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/features/authentication/forgot_password/ResetPassworrd.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final TextEditingController emailController = TextEditingController();
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController()); // List of controllers for OTP
  bool _isLoading = false;
  bool _otpSent = false;

  Future<void> _sendOtp(BuildContext context) async {
    String email = emailController.text.trim();

    if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      return; 
    }

    setState(() {
      _isLoading = true;
    });

    MyIP myIP = MyIP();

    try {
      final response = await http.post(
        Uri.parse('${myIP.domain}:3000/forgot-password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('JSON Response: $jsonResponse');

        if (jsonResponse['success']) {
          print('OTP sent successfully');
          setState(() {
            _otpSent = true; 
          });
        } else {
          print('Error: ${jsonResponse['message']}');
        }
      } else {
        print('เกิดข้อผิดพลาด: ${response.body}');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดขณะส่ง OTP: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp(BuildContext context) async {
    String otp = otpControllers.map((controller) => controller.text.trim()).join(''); // Join OTP from all controllers
    String email = emailController.text.trim();

    if (otp.isEmpty) {
      return; 
    }

    setState(() {
      _isLoading = true;
    });

    MyIP myIP = MyIP();

    try {
      final response = await http.post(
        Uri.parse('${myIP.domain}:3000/verify-password-otp'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'otp': otp,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        print('JSON Response: $jsonResponse');

        if (jsonResponse['success']) {
          print('OTP verified successfully');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Resetpassword(email: email)), 
          );
        } else {
          print('Error: ${jsonResponse['message']}');
        }
      } else {
        print('เกิดข้อผิดพลาด: ${response.body}');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาดขณะตรวจสอบ OTP: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    for (var controller in otpControllers) {
      controller.dispose(); // Dispose each controller
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recover Password',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFE966A0), 
        iconTheme: IconThemeData(color: Colors.white), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'กรุณากรอกอีเมลของคุณเพื่อรับรหัส OTP',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFFE966A0)), 
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE966A0)),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFE966A0), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center( 
                    child: SizedBox( 
                      width: double.infinity, 
                      child: CustomButton(
                        title: 'ส่ง OTP',
                        onPressed: (context) => _sendOtp(context),
                        color: Color(0xFFE966A0), 
                      ),
                    ),
                  ),
            const SizedBox(height: 80),
            if (_otpSent) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 40,
                    child: TextField(
                      controller: otpControllers[index], 
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      onChanged: (value) {
                        if (value.length == 1 && index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Center( 
                child: SizedBox( 
                  width: double.infinity, 
                  child: CustomButton(
                    title: 'ตรวจสอบ OTP',
                    onPressed: (context) => _verifyOtp(context),
                    color: Colors.purple[800],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
