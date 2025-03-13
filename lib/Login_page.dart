import 'dart:convert';
import 'proone.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'admin_home.dart';
import 'forgotpassword.dart';
import 'home_page.dart';
import 'ip_page.dart';
import 'main.dart';
import 'username_verf_page.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
   LoginPage({Key? key}) : super(key: key);

  TextEditingController uname = TextEditingController();
  TextEditingController pwd = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> loginUser(BuildContext context) async {
    try {
      final sh = await SharedPreferences.getInstance();
      String unames = uname.text.toString();
      String pwds = pwd.text.toString();
      String url = sh.getString("ip") ?? ''; // Ensure it's not null
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL is not set in SharedPreferences')),
        );
        return;
      }

      var response = await http.post(
        Uri.parse('$url/api/login'),
        body: {
          'username': unames,
          'password': pwds,
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        String userType = jsonData['usertype'].toString();

        if (userType == "user") {
          String lid = jsonData['login_id'].toString();
          sh.setString("lid", lid);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
        }
        else if (userType == "production") {
          String lid = jsonData['login_id'].toString();
          sh.setString("lid", lid);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => proone()),
          );
        }
        else if (userType == "admin") {
          String lid = jsonData['login_id'].toString();
          sh.setString("lid", lid);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminHome()),
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed. Please check your credentials.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect to the server')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
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
                      // Username Field
                      TextFormField(
                        controller: uname,
                        decoration: InputDecoration(
                          labelText: 'USERNAME',
                          labelStyle: TextStyle(color: Colors.black45),
                          filled: true,

                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: TextStyle(color: Colors.white60),
                        ),
                        style: TextStyle(color: Colors.black),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        controller: pwd,
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
                          hintStyle: TextStyle(color: Colors.white60),
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
                      Align(
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            // Navigate to Forgot Password page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => forgotpasswordPage()),
                            );
                          },
                          child: Text(
                            'FORGET PASSWORD',
                            style: TextStyle(color: Colors.red, fontSize: 16),
                          ),
                        ),
                      ),

                      // Login Button
                      SizedBox(height: 30),
                      SizedBox(
                        height: 60,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              loginUser(context);  // Pass the context to handle SnackBar
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
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed: () {
                            // _showRegistrationDialog(context);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegistrationPage1(),
                                ));
                          },
                          child: Text(
                            "DON'T HAVE AN ACCOUNT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16, // You can adjust the size as needed
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],

      ),
    );

  }
   // void _showRegistrationDialog(BuildContext context) {
   //   showDialog(
   //     context: context,
   //     builder: (BuildContext context) {
   //       return AlertDialog(
   //         title: Text("Choose Registration Type"),
   //         content: Text("Select the type of account you want to create."),
   //         actions: [
   //           TextButton(
   //             onPressed: () {
   //               Navigator.pop(context); // Close the dialog
   //               Navigator.push(
   //                 context,
   //                 MaterialPageRoute(builder: (context) => RegistrationPage1()),
   //               );
   //             },
   //             child: Text("User Registration"),
   //           ),
   //           TextButton(
   //             onPressed: () {
   //               Navigator.pop(context); // Close the dialog
   //               Navigator.push(
   //                 context,
   //                 MaterialPageRoute(builder: (context) => RegistrationPage1()),
   //               );
   //             },
   //             child: Text("Production Registration"),
   //           ),
   //         ],
   //       );
   //     },
   //   );
   // }
}
