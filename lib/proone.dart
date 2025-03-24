
import 'home_page.dart';
import 'message_page.dart';
import 'navigation.dart';
import 'ip_page.dart';
import 'navigation2.dart';
import 'startup_page.dart';
import 'widgets/post_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const proone());
}

class proone extends StatelessWidget {
  const proone({super.key});

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
      home: Navigation2(), // Loads the StartupPage
    );
  }
}
