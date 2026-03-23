import 'package:f1_app/pages/main_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  runApp(
       ProviderScope(
          child:  MyApp())
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color(0xFFE10600),
            brightness: Brightness.dark,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
            fontStyle: FontStyle.italic,

          ),
          headlineMedium: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB3B3B3),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 14,
            color: Color(0xFFE0E0E0),
          ),
          labelLarge: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      home:  MainShell(),
    );
  }
}


