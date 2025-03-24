import 'dart:io';

import 'Login_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';


class RegistrationPage extends StatefulWidget {
  final dynamic uname;

  RegistrationPage({Key? key, required this.uname}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String userType = "user"; // Default selected value
  File? selectedFile;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensures screen resizes when the keyboard appears
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
          // Back button
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: EdgeInsets.only(top: 50), // Adjust the value to move it down
              child: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios_rounded),
                color: Colors.white,
              ),
            ),
          )
,
          // Main content
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 1.1,
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
                                "ENTER YOUR NAME AND PASSWORD",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(height: 30),

                            // Radio Button for User Type Selection

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select Account Type",
                                  style: TextStyle(color: Colors.white, fontSize: 16),
                                ),
                                ListTile(
                                  leading: Radio(
                                    value: "user",
                                    groupValue: userType,
                                    onChanged: (value) {
                                      setState(() {
                                        userType = value.toString();
                                      });
                                    },
                                    activeColor: Colors.red,
                                  ),
                                  title: Text("User/Animator", style: TextStyle(color: Colors.white)),
                                ),
                                ListTile(
                                  leading: Radio(
                                    value: "production",
                                    groupValue: userType,
                                    onChanged: (value) {
                                      setState(() {
                                        userType = value.toString();
                                      });
                                    },
                                    activeColor: Colors.red,
                                  ),
                                  title: Text("Production/Merchant", style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),

                            if (userType == "production") ...[
                              const Text(
                                "Upload Business License or ID (PDF, JPG, PNG)",
                                style: TextStyle(color: Colors.white),
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton.icon(
                                onPressed: pickFile,
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Upload File"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                              if (selectedFile != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: Text(
                                    "Selected File: ${selectedFile!.path.split('/').last}",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],

                            const SizedBox(height: 20),

                            // Name Field
                            TextFormField(
                              controller: nameController,
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

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

                            const SizedBox(height: 20),

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
                                    if (userType == "production" && selectedFile == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please upload a file for verification'),
                                        ),
                                      );
                                      return;
                                    }

                                    final sh = await SharedPreferences.getInstance();
                                    String pwd = passwordController.text.toString();
                                    String name = nameController.text.toString();
                                    String url = sh.getString("ip").toString();

                                    var uri = Uri.parse('$url/api/user_register');
                                    var request = http.MultipartRequest('POST', uri);

                                    // Add form fields
                                    request.fields['uname'] = widget.uname;
                                    request.fields['pwd'] = pwd;
                                    request.fields['name'] = name;
                                    request.fields['user_type'] = userType;

                                    // Add file if "Production" is selected
                                    if (userType == "production" && selectedFile != null) {
                                      request.files.add(
                                        await http.MultipartFile.fromPath('file', selectedFile!.path),
                                      );
                                    }

                                    // Send request
                                    var response = await request.send();
                                    var responseData = await response.stream.bytesToString();
                                    var jsonData = json.decode(responseData);

                                    if (jsonData['status'] == "success") {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Registration failed. Please try again.')),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
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
