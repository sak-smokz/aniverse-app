import 'package:aniverse/Login_page.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // This ensures the screen resizes when the keyboard appears
      body: Stack(
        children: [
          // Background image
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/login_images/login_page.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Back button at the top left
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);  // Go back to the previous screen
              },
              icon: Icon(Icons.arrow_back_ios_rounded),
              color: Colors.white60,
            ),
          ),
          // Main content
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              // This allows the content to scroll and avoid overflow
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      color: Colors.black54,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Text(
                                "ENTER YOUR NAME AND PASSWORD",
                                style: TextStyle(color: Colors.red),
                              )),
                          const SizedBox(height: 30),
                          // Username Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'NAME',
                              labelStyle: TextStyle(color: Colors.black45),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 30),
                          // Password Field
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'PASSWORD',
                              labelStyle: TextStyle(color: Colors.black45),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 30),
                          // Confirm Password Field
                          TextFormField(
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'CONFIRM PASSWORD',
                              labelStyle: TextStyle(color: Colors.black45),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: TextStyle(color: Colors.black),
                          ),
                          const SizedBox(height: 30),
                          // Create Account Button
                          SizedBox(
                            height: 60,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(),));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text(
                                'CREATE ACCOUNT',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
