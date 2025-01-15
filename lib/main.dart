
import 'package:aniverse/navigation.dart';
import 'package:aniverse/ip_page.dart';
import 'package:aniverse/startup_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aniverse', // Sets the app title
      theme: ThemeData(
        // Configures the application's theme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Hides the debug banner
      home:const Navigation(), // Loads the StartupPage
    );
  }
}
