import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<Map<String, dynamic>> users = [];
  String ipAddress = "";

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
  }

  Future<void> _loadIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = sh.getString("ip") ?? "";
    });
  }

  Future<List<Map<String, dynamic>>> _loadUsers() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = '$ipAddress/api/user_view_friends';

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      }
    } catch (e) {
      print("Error loading user: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Friends List",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red), // Change back button color here
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No friends found."));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var user = snapshot.data![index];
              String userImageUrl = "$ipAddress/${user['photo'] ?? ''}";
              String userId = user['login_id'].toString(); // Get user ID

              return ListTile(minVerticalPadding: 25,
                leading: Container(
                  width: 80, // Adjust size as needed
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.red, // Border color
                      width: 3, // Border width
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(userImageUrl),
                  ),
                ),

                title: Text(
                  "${user['name']}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserChat(userIds: userId,),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
