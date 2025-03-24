import 'user_add_post.dart';

import 'ProfileScreen_production.dart';
import 'home_page.dart';
import 'home_page2.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Navigation2 extends StatefulWidget {
  const Navigation2({super.key});

  @override
  State<Navigation2> createState() => _Navigation2State();
}

class _Navigation2State extends State<Navigation2> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen2(),
    const SearchScreen(),
    const NotificationsScreen(),
    const ProfileproductionScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: _pages[_currentIndex],
      backgroundColor: Colors.black,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        shape: CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FileUploadPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.home_filled,
                color: _currentIndex == 0 ? Colors.red : Colors.white,size: 30,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            // IconButton(
            //   icon: Icon(
            //     Icons.search,
            //     color: _currentIndex == 1 ? Colors.red : Colors.white,size: 30,
            //   ),
            //   onPressed: () {
            //     setState(() {
            //       _currentIndex = 1;
            //     });
            //   },
            // ),
            // const SizedBox(width: 40), // Space for the FAB
            // IconButton(
            //   icon: Icon(
            //     Icons.notifications,
            //     color: _currentIndex == 2 ? Colors.red : Colors.white,size: 30,
            //   ),
            //   onPressed: () {
            //     setState(() {
            //       _currentIndex = 2;
            //     });
            //   },
            // ),
            IconButton(
              icon: Icon(
                Icons.person,
                color: _currentIndex == 3 ? Colors.red : Colors.white,size: 30,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 3;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
