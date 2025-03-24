import 'Login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class forgotpasswordPage extends StatelessWidget {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

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
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                  "ENTER YOUR USERNAME&NEWPASSWORD",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(height: 30),
                            // Name Field
                            TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                labelText: 'USERNAME',
                                labelStyle: TextStyle(color: Colors.black45),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              style: TextStyle(color: Colors.black),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            // Password Field
                            TextFormField(
                              controller: passwordController,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            // Confirm Password Field
                            TextFormField(
                              controller: confirmPasswordController,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your password';
                                } else if (value != passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 30),
                            // Create Account Button
                            SizedBox(
                              height: 60,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState?.validate() ?? false) {
                                    final sh = await SharedPreferences.getInstance();
                                    String pwd = passwordController.text.toString();
                                    String name = nameController.text.toString();


                                    String url = sh.getString("ip").toString();

                                    var response = await http.post(
                                      Uri.parse('$url/api/forgotpassword'),
                                      body: {

                                        'pwd': pwd,
                                        'name': name,
                                      },
                                    );

                                    var jsonData = json.decode(response.body);
                                    String status = jsonData['status'].toString();
                                    if (status == "success") {
                                      // Store user details in SharedPreferences
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password changed successfully.'),
                                        ),
                                      );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
                                        ),
                                      );
                                    } else {
                                      // Show error message if registration fails
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Registration failed. Please try again.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Text(
                                  'CREATE NEW PASSWORD',
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
