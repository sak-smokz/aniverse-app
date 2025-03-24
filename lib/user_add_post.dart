import 'dart:convert';
import 'dart:io';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ip_page.dart';


class FileUploadPage extends StatefulWidget {
  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  File? _selectedImage;
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _viewPosts() {
    // Navigate to a new screen or show a dialog with the products
    Navigator.push(
      this.context,  // Use the widget's context, no need for `as BuildContext`
      MaterialPageRoute(builder: (context) => ViewpostsPage()),
    );

  }

  Future<void> _submitData() async {
    if (_selectedImage == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Please select an image and enter a title')),
      );
      return;
    }

    final SharedPreferences pref = await SharedPreferences.getInstance();
    String lid = pref.getString("lid") ?? "";
    String ip = pref.getString("ip") ?? "";

    if (ip.isEmpty) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Server URL not found in preferences')),
      );
      return;
    }

    String title = _titleController.text;

    var request = http.MultipartRequest('POST', Uri.parse('$ip/api/add_post'));
    request.fields['lid'] = lid;
    request.fields['title'] = title;

    try {
      // Attach the selected image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _selectedImage!.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonData = json.decode(responseData.body);
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Data saved successfully: $jsonData')),
        );
        print("Data saved successfully: $jsonData");
      } else {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error sending data: $e')),
      );
      print("Error sending data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload File'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Enter Title',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16.0),
              _selectedImage != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  _selectedImage!,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
                  : Placeholder(
                fallbackHeight: 200,
                fallbackWidth: double.infinity,
              ),
              SizedBox(height: 16.0),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.upload),
                label: Text('Select Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: _viewPosts,
          child: Icon(Icons.view_list),
          backgroundColor: Colors.red,
        ),
      ),
    );
  }


}
class ViewpostsPage extends StatefulWidget {
  @override
  _ViewpostsPageState createState() => _ViewpostsPageState();
}

class _ViewpostsPageState extends State<ViewpostsPage> {
  List<Map<String, dynamic>> posts = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("ip") ?? "";
      String categoryUrl = ip + "/api/view_post";

      var data = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(data.body);
      String status = jsonData['status'].toString();

      if (status == "success") {
        setState(() {
          posts = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        print("API returned error status.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<String> _getIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    return sh.getString("ip") ?? "";
  }

  Future<void> _deletepost(String postId) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("ip") ?? "";
      String deleteUrl = ip + "/api/delete_post";

      var response = await http.post(Uri.parse(deleteUrl), body: {'post_id': postId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        setState(() {
          posts.removeWhere((post) => post['post_id'] == postId);
        });
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        // Close the dialog after deletion
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(content: Text("post deleted successfully.")),
        );
      } else {
        Navigator.push(
          context as BuildContext,
          MaterialPageRoute(builder: (context) => MyApp()),
        );
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(

          const SnackBar(content: Text("post deleted successfully.")),
        );
      }
    } catch (e) {
      print("Error deleting post: $e");

    }
  }

  void _showPostDetails(Map<String, dynamic> product) {
    showDialog(
      context: this.context , // Explicitly cast to BuildContext
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(product['title'] ?? "Product Details"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<String>(
                  future: _getIpAddress(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return const Text('Error loading image.');
                    }
                    String ipAddress = snapshot.data ?? "";
                    String imageUrl = "$ipAddress/${product['post'] ?? ''}";
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 150,
                        height: 150,
                        fit: BoxFit.fill,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error, size: 100, color: Colors.red);
                        },
                      ),
                    );
                  },
                ),


              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => _deletepost(product['post_id'].toString()),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),

            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("posts"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: posts.isEmpty
          ? const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
          crossAxisSpacing: 12, // Spacing betwe as BuildContexten columns
          mainAxisSpacing: 12, // Spacing between rows
          childAspectRatio: 3 / 4, // Aspect ratio of each grid item
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showPostDetails(posts[index]),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: FutureBuilder<String>(
                      future: _getIpAddress(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (snapshot.hasError) {
                          return const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 100,
                          );
                        }
                        String ipAddress = snapshot.data ?? "";
                        String imageUrl =
                            "$ipAddress/${posts[index]['post'] ?? ''}";
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12),
                          ),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.fill,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.error,
                                color: Colors.red,
                                size: 100,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      posts[index]['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}