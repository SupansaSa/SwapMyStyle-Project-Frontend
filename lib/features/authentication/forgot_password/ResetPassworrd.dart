import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/widgets/custom_text_field.dart';

class Resetpassword extends StatefulWidget {
  static const double defaultMargin = 16.0;
  final String email;
  

  const Resetpassword({Key? key, required this.email}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ResetpasswordState createState() => _ResetpasswordState();
}

class _ResetpasswordState extends State<Resetpassword> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;

  Future<void> _resetPassword() async {
    setState(() {
      _isLoading = true;
    });

    MyIP myIP = MyIP();

    final response = await http.post(
      Uri.parse('${myIP.domain}:3000/reset-password'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': widget.email,
        'newPassword': _passwordController.text,
       
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['success']) {
        // Navigate to login screen or home screen after successful password reset
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        _message = jsonResponse['message'];
      }
    } else {
      _message = 'Failed to reset password. Please try again later.';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Resetpassword.defaultMargin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 90),
                  const SizedBox(height: 15),
                  const Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  CustomTextField(
                    title: 'New Password',
                    hintText: 'Type your new password...',
                    textEditingController: _passwordController,
                    prefixIcon: const Icon(Icons.password),
                  ),

                  const SizedBox(height: 25),
                  SizedBox(
                    height: 45,
                    width: double.infinity,
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            title: 'Reset Password',
                            onPressed: (BuildContext context) {
                              _resetPassword();
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

