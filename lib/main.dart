import 'package:flutter/material.dart';
import 'package:lung_care_mobile/features/auth/presentation/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lung Care Mobile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A90E2)),
        scaffoldBackgroundColor: const Color(0xFFF2F6FC),
      ),
      home: const RegisterPage(),
    );
  }
}
