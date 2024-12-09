import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';
import 'package:myapp/screen/MyIP.dart';

class OtpInputScreen extends StatefulWidget {
  final String email;
  OtpInputScreen({required this.email});

  @override
  _OtpInputScreenState createState() => _OtpInputScreenState();
}

class _OtpInputScreenState extends State<OtpInputScreen> {
  final List<TextEditingController> otpControllers = List.generate(6, (index) => TextEditingController());
  MyIP myIP = MyIP();
  bool _isButtonEnabled = false; 
  Timer? _timer;
  int _start = 60;

  Future<bool> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/verify-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'otp': otp,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> requestNewOtp(String email) async {
    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/resend-otp'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
      }),
    );

    return response.statusCode == 200;
  }

  void startTimer() {
    _isButtonEnabled = false; 
    _start = 60; 
    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel(); 
          _isButtonEnabled = true; 
        });
      } else {
        setState(() {
          _start--; 
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer(); 
  }

  @override
  void dispose() {
    _timer?.cancel(); 
    otpControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Widget customElevatedButton({
    required String title,
    required VoidCallback onPressed,
    Color? color,
    double? width,
  }) {
    return Container(
      width: 200, 
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Color(0xFFE966A0), 
          padding: const EdgeInsets.symmetric(vertical: 12), 
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), 
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String getOtp() {
    return otpControllers.map((controller) => controller.text).join('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'กรุณากรอกรหัส OTP ที่ส่งไปยังอีเมลของคุณ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
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
            SizedBox(height: 40),
            customElevatedButton(
              title: 'ยืนยัน',
              onPressed: () async {
                String otp = getOtp();
                final isValid = await verifyOtp(widget.email, otp);

                if (isValid) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Invalid OTP'),
                        content: Text('The OTP you entered is incorrect or has expired. Please try again.'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
            SizedBox(height: 20),
            if (_start > 0) 
              Text(
                'กรุณารอ $_start วินาทีเพื่อขอรหัส OTP ใหม่',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 20),
            customElevatedButton(
              title: 'ขอรหัส OTP ใหม่อีกครั้ง',
              onPressed: _isButtonEnabled
                  ? () async {
                      bool success = await requestNewOtp(widget.email);
                      if (success) {
                        startTimer(); 
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('New OTP sent to ${widget.email}')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to send new OTP. Please try again.')),
                        );
                      }
                    }
                  : () {}, 
              color: Colors.purple[400], 
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
