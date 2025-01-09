import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aniverse',style: TextStyle(color: Colors.white,fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.messenger_outline_rounded),
            onPressed: () {
              // Add your message button logic here
              debugPrint('Message button pressed');
            },
          ),
        ],backgroundColor: Colors.black,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.red,
      ),
    );
  }
}
