import 'package:flutter/material.dart';
import 'package:chamada_ufam/screens/login_screen.dart';

void main() {
  runApp(const UFAMChamadaApp());
}

class UFAMChamadaApp extends StatelessWidget {
  const UFAMChamadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UFAM Chamada',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006633)),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}