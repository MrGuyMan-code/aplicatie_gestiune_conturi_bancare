import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const AtmApp());
}

class AtmApp extends StatelessWidget {
  const AtmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ATM BANK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A192F),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF0A192F)),
      ),
      home: const LoginScreen(),
    );
  }
}