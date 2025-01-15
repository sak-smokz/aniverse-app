import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Aniverse",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            backgroundColor: Colors.black),
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            'Notifications Page',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ));
  }
}
