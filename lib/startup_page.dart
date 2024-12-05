import 'package:flutter/material.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height
    final screenWidth = MediaQuery.of(context).size.width;  // Get screen width

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_images/home_page.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Button at the bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: screenHeight * 0.1, // 10% of the screen height
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Add your action here
                  print("Button pressed!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24, // Button color
                  foregroundColor: Colors.white, // Text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // Curved edges
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.16, // 20% of screen width
                    vertical: screenHeight * 0.02, // 2% of screen height
                  ),
                ),
                child: const Text(
                  'GET STARTED',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
