import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myapp/features/authentication/TermsAndConditions/privacy_policy_page.dart';
import 'package:myapp/features/authentication/signIn/sign_in_page.dart';
import 'package:myapp/features/authentication/signUp/otp_page.dart';
import 'package:myapp/screen/MyIP.dart';
import 'package:myapp/widgets/custom_text_field.dart';
import 'package:myapp/widgets/custom_button.dart';
import 'package:myapp/features/authentication/TermsAndConditions/terms_and_conditions_page.dart';

class SignUpPage extends StatefulWidget {
  static const double defaultMargin = 16.0;

  const SignUpPage({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isVisible = false;
  bool _acceptedTerms = false;
  bool _consentToProvideInfo = false;
  MyIP myIP = MyIP();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _recoverController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstnameController.dispose();
    _lastnameController.dispose();
    _phoneNumberController.dispose();
    _recoverController.dispose();
    super.dispose();
  }

  Future<void> registerUser(
    String username,
    String email,
    String password,
    String firstname,
    String lastname,
    String phoneNumber,
    String recover,
  ) async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    final url = Uri.parse('${myIP.domain}:3000/register');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'email': email,
      'password': password,
      'username': username,
      'firstname': firstname,
      'lastname': lastname,
      'phoneNumber': phoneNumber,
      'terms_accepted': _acceptedTerms,
      'data_usage_accepted': _consentToProvideInfo,
      'recover': recover,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error registering user'),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Network error'),
        ),
      );
    }
  }

  /*void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(
                  'assets/image/send.png',
                  height: 100,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verify your email',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'ระบบได้ส่งลิงก์สำหรับยืนยันอีเมลไปยังที่อยู่อีเมลที่ท่านได้ระบุไว้  กรุณาทำการยืนยันอีเมลก่อนเข้าสู่ระบบ ขอบคุณค่ะ',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  '(หากไม่พบอีเมลสำหรับการยืนยัน คุณอาจต้องตรวจสอบโฟลเดอร์สแปมของคุณ)',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 45,
                  width: double.infinity,
                  child: CustomButton(
                    title: 'I understand',
                    onPressed: (BuildContext context) {
                      Navigator.of(context).pop();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }*/

  void _showSuccessDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/image/send.png',
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'OTP Verification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'ระบบได้ส่งรหัส OTP ไปยังที่อยู่อีเมลที่ท่านได้ระบุไว้ กรุณาป้อนรหัส OTP เพื่อทำการยืนยัน ขอบคุณค่ะ',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                '(หากไม่พบอีเมล คุณอาจต้องตรวจสอบโฟลเดอร์สแปมของคุณ)',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: CustomButton(
                  title: 'I understand',
                  onPressed: (BuildContext context) {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>  OtpInputScreen(email: _emailController.text)), // เปลี่ยนหน้าไปยังหน้าป้อน OTP
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ข้อผิดพลาด'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'ตกลง',
                style: TextStyle(color: Colors.pink),
              ),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: SignUpPage.defaultMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const SizedBox(height: 15),
              const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 45,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'UserName',
                hintText: 'Type your Username...',
                textEditingController: _usernameController,
                prefixIcon: const Icon(Icons.person),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Email (อีเมลสำหรับการยืนยันอีเมล)',
                hintText: 'Type your email...',
                textEditingController: _emailController,
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Password',
                hintText: 'Type your password...',
                prefixIcon: const Icon(Icons.key),
                obscureText: !_isVisible,
                iconForm: 'assets/image/3.png',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  icon: _isVisible
                      ? const Icon(
                          Icons.visibility,
                          color: Colors.black,
                        )
                      : const Icon(
                          Icons.visibility_off,
                          color: Colors.grey,
                        ),
                ),
                textEditingController: _passwordController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Confirm Password',
                hintText: 'Type your password...',
                prefixIcon: const Icon(Icons.lock),
                obscureText: !_isVisible,
                iconForm: 'assets/image/3.png',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  },
                  icon: _isVisible
                      ? const Icon(
                          Icons.visibility,
                          color: Colors.black,
                        )
                      : const Icon(
                          Icons.visibility_off,
                          color: Colors.grey,
                        ),
                ),
                textEditingController: _confirmPasswordController,
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Recovery Code ',
                hintText: 'Type your Recover code...',
                textEditingController: _recoverController,
                prefixIcon: const Icon(Icons.record_voice_over),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'First name',
                hintText: 'Type your First name...',
                textEditingController: _firstnameController,
                prefixIcon: const Icon(Icons.person_2_outlined),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Last name',
                hintText: 'Type your Last name...',
                textEditingController: _lastnameController,
                prefixIcon: const Icon(Icons.person_2_outlined),
              ),
              const SizedBox(height: 15),
              CustomTextField(
                title: 'Phone Number',
                hintText: 'Type your phone number...',
                textEditingController: _phoneNumberController,
                prefixIcon: const Icon(Icons.phone),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Checkbox(
                    value: _acceptedTerms,
                    onChanged: (value) {
                      setState(() {
                        _acceptedTerms = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndConditionsPage()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'ฉันได้อ่านและยอมรับ ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'ข้อกำหนดและเงื่อนไขการให้บริการ',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _consentToProvideInfo,
                    onChanged: (value) {
                      setState(() {
                        _consentToProvideInfo = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PrivacyPolicyPage()),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: 'ฉันได้อ่านและเข้าใจ ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'นโยบายความเป็นส่วนตัว',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: CustomButton(
                  title: 'Create Account',
                  onPressed: (BuildContext context) {
                    if (_usernameController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _passwordController.text.isEmpty ||
                        _recoverController.text.isEmpty ||
                        _phoneNumberController.text.isEmpty ||
                        !_acceptedTerms ||
                        !_consentToProvideInfo) {
                      _showErrorDialog(
                          'กรุณากรอกข้อมูลให้ครบทุกช่องและกดยอมรับเงื่อนไขการให้บริการและนโยบายความเป็นส่วนตัว');
                      return;
                    }
                    registerUser(
                      _usernameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _firstnameController.text,
                      _lastnameController.text,
                      _phoneNumberController.text,
                      _recoverController.text,
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an Account',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE966A0),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
