import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

class Merchant extends StatefulWidget {
  const Merchant({super.key});

  @override
  State<Merchant> createState() => _MerchantState();
}

class _MerchantState extends State<Merchant> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  File? _image;

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
      String categoryUrl = "$ip/api/view_dress";

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

  Future<void> _deletedress(String dresses_id) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("ip") ?? "";
      String deleteUrl = "$ip/api/delete_dress";

      var response = await http
          .post(Uri.parse(deleteUrl), body: {'dresses_id': dresses_id});
      var jsonData = json.decode(response.body);
      if (jsonData['status'].toString() == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Merchant()),
        );
        setState(() {
          posts.removeWhere(
              (post) => post['dresses_id'].toString() == dresses_id);
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Merchant()),
        );
        print("Failed to delete event.");
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<String> _getIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    return sh.getString("ip") ?? "";
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitDetails() async {
    String title = _titleController.text;
    String price = _priceController.text;
    String size = _sizeController.text;

    if (title.isNotEmpty &&
        price.isNotEmpty &&
        size.isNotEmpty &&
        _image != null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("ip") ?? "";

      if (ip.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server URL not found in preferences')),
        );
        return;
      }

      var request =
          http.MultipartRequest('POST', Uri.parse('$ip/api/add_dress'));
      request.fields['lid'] = lid;
      request.fields['title'] = title;
      request.fields['price'] = price;
      request.fields['size'] = size;

      try {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _image!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await http.Response.fromStream(response);
          var jsonData = json.decode(responseData.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data saved successfully: $jsonData')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending data: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields and select an image!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          backgroundColor: Colors.black,
          title: const Text(
            'Add Dress Details',
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: 'Size',
                  labelStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    _image == null
                        ? const Text('No image selected',
                            style: TextStyle(color: Colors.white))
                        : Image.file(_image!, height: 150),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white),
                      child: const Text('Pick Image',
                          style: TextStyle(color: Colors.black)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitDetails,
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text('Submit',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
                  posts.isEmpty
                      ? const Center(
                    child: Text(
                      'No data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : Expanded(  // Wrap ListView.builder inside Expanded
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          return FutureBuilder<String>(
                            future: _getIpAddress(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
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
                                  "$ipAddress/${posts[index]['image'] ?? ''}";

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(10),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(
                                          Icons.error,
                                          color: Colors.red,
                                          size: 80,
                                        );
                                      },
                                    ),
                                  ),
                                  title: Text(posts[index]['title'] ?? 'No Title'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Price : ${posts[index]['price'] ?? 'N/A'}"),
                                      Text("Size : ${posts[index]['size'] ?? 'N/A'}"),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _deletedress(posts[index]['dresses_id'].toString());
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),

                ])));
  }
}
