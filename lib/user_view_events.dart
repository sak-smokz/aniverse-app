import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserViewEvent extends StatefulWidget {
  const UserViewEvent({super.key});

  @override
  State<UserViewEvent> createState() => _UserViewEventState();
}

class _UserViewEventState extends State<UserViewEvent> {
  List<Map<String, dynamic>> dress = [];
  String ipAddress = "";

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }
  Future<void> _submitform(String eventId) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      ipAddress = pref.getString("ip") ?? "";

      String categoryUrl = "$ipAddress/api/user_book_event";
      var response = await http.post(
        Uri.parse(categoryUrl),
        body: {'lid': lid, 'event_id': eventId},
      );
      var jsonData = json.decode(response.body);

      if (jsonData['status'].toString() == "success") {
        setState(() {
          dress = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        print("API returned error status.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      ipAddress = pref.getString("ip") ?? "";

      String categoryUrl = "$ipAddress/api/user_view_event";
      var response = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'].toString() == "success") {
        setState(() {
          dress = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        print("API returned error status.");
      }
    } catch (e) {
      print("Error: $e");
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
          icon: const Icon(Icons.arrow_back, color: Colors.red),
        ),
        backgroundColor: Colors.black,
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.red),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: dress.isEmpty
          ? const Center(
        child: Text(
          'No Event available',
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: dress.length,
        itemBuilder: (context, index) {
          final dressItem = dress[index];
          String imageUrl = "$ipAddress/${dressItem['image'] ?? ''}";

          return Card(
            color: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(imageUrl: imageUrl),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 250,
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
                  ),
                  const SizedBox(height: 10),
                  Text(
                    dressItem['name'] ?? 'No name',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    "Date: ${dressItem['date'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16, color: Colors.green),
                  ),
                  Text(
                    "Time: ${dressItem['time'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  Text(
                    "Amount: ${dressItem['amount'] ?? 'N/A'}",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        String eventId = dressItem['Events_id'].toString(); // Ensure event_id is properly extracted
                        _submitform(eventId);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text("Book Ticket",style: TextStyle(color: Colors.white)),
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


class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                color: Colors.red,
                size: 100,
              );
            },
          ),
        ),
      ),
    );
  }
}

