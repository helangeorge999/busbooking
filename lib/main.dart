import 'package:flutter/material.dart';
import 'package:sprint_1/Screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bus Booking App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'OpenSans', // set default font
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      home: HomeScreen(),
    );
  }
}
