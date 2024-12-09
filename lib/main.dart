import 'package:flutter/material.dart';
import 'package:myapp/features/profile/profile_page.dart';
import 'package:myapp/features/profile/setting_page.dart';
import 'package:myapp/features/shop/home/home_page.dart';
import 'package:myapp/screen/HomeScreen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/profile': (context) => const ProfilePage(),
        '/settings': (context) => const SettingPage(),
        '/home': (context) => HomePage(), 
      },
    );
  }
}
