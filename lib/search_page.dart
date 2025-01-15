import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),backgroundColor: Colors.black,
      body: const Center(
        child: Text(
          'Search Page',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
