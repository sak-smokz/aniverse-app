import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profile;

  UpdateProfileScreen({required this.profile});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _placeController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile['name']);
    _lastNameController = TextEditingController(text: widget.profile['gender']);
    _placeController = TextEditingController(text: widget.profile['place']);
    _phoneController = TextEditingController(text: widget.profile['phone']);
    _emailController = TextEditingController(text: widget.profile['email']);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("ip") ?? "";
      String updateUrl = "$ip/api/update_profile";

      var request = http.MultipartRequest('POST', Uri.parse(updateUrl))
        ..fields['lid'] = lid
        ..fields['first_name'] = _firstNameController.text
        ..fields['gender'] = _lastNameController.text
        ..fields['place'] = _placeController.text
        ..fields['phone'] = _phoneController.text
        ..fields['email'] = _emailController.text;

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath('photo', _imageFile!.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);
        String status = jsonData['status'].toString();

        if (status == "profile updated successfully") {
          Navigator.pop(context, true); // Pass true to indicate success
        } else {
          // Show error message if profile not updated successfully
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to update profile")),
          );
        }
      } else {
        print("Failed to update profile. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while updating the profile")),
      );
    }
  }

  Future<String> _getIpAddress() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getString("ip") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Changed background color to black
      appBar: AppBar(
        title: const Text("Update Profile", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.red), // Change the back arrow color to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Picture Section
              FutureBuilder<String>(
                future: _getIpAddress(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return const Icon(Icons.error, size: 100, color: Colors.red);
                  }
                  String ipAddress = snapshot.data ?? "";
                  return GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : NetworkImage("$ipAddress/${widget.profile['photo'] ?? ''}") as ImageProvider,
                      child: _imageFile == null
                          ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Form Fields Section
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: "First Name",labelStyle: TextStyle(color: Colors.white)),style: TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? "First Name cannot be empty" : null,
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: "Gender",labelStyle: TextStyle(color: Colors.white)),style: TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? "Gender cannot be empty" : null,
              ),
              TextFormField(
                controller: _placeController,
                decoration: const InputDecoration(labelText: "Place",labelStyle: TextStyle(color: Colors.white)),style: TextStyle(color: Colors.white),
                validator: (value) => value!.isEmpty ? "Place cannot be empty" : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone",labelStyle: TextStyle(color: Colors.white)),style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Phone cannot be empty" : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email",labelStyle: TextStyle(color: Colors.white)),style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? "Email cannot be empty" : null,
              ),
              const SizedBox(height: 20),

              // Update Button
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red background color
                ),
                child: const Text(
                  "Update",
                  style: TextStyle(color: Colors.white),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
