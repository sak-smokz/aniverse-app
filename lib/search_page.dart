import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String ipAddress = "";
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> allProductions = [];
  List<Map<String, dynamic>> filteredUsers = [];
  List<Map<String, dynamic>> filteredProductions = [];

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
  }

  Future<void> _loadIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = sh.getString("ip") ?? "";
      _loadData();
    });
  }

  Future<void> _loadData() async {
    List<Map<String, dynamic>> users = await _loadProfile();
    List<Map<String, dynamic>> productions = await _loadProduction();

    setState(() {
      allUsers = users;
      allProductions = productions;
      filteredUsers = users;
      filteredProductions = productions;
    });
  }

  Future<List<Map<String, dynamic>>> _loadProfile() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = '$ipAddress/api/view_user_list';

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      }
    } catch (e) {
      print("Error loading users: $e");
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> _loadProduction() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = '$ipAddress/api/view_production_list';

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      }
    } catch (e) {
      print("Error loading production: $e");
    }
    return [];
  }

  void _filterData(String query) {
    setState(() {
      filteredUsers = allUsers
          .where((user) =>
          user['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
      filteredProductions = allProductions
          .where((product) =>
          product['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _sendRequest(String userId) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = '$ipAddress/api/user_send_request';

      var response = await http.post(Uri.parse(url), body: {
        'lid': lid,
        'user_id': userId,
      });

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Request Sent Successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to Send Request")),
        );
      }
    } catch (e) {
      print("Error sending request: $e");
    }
  }

  Future<void> _sendFollow(String productionId) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = '$ipAddress/api/user_send_follow';

      var response = await http.post(Uri.parse(url), body: {
        'lid': lid,
        'production_id': productionId,
      });

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Followed Successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to Follow")),
        );
      }
    } catch (e) {
      print("Error following production: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: searchController,
          onChanged: _filterData,
          decoration: const InputDecoration(
            hintText: 'Search by name...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Users',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(
              child: Text('No Users Found', style: TextStyle(color: Colors.white)),
            )
                : ListView.builder(
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var user = filteredUsers[index];
                String profileImageUrl = "$ipAddress/${user['photo'] ?? ''}";

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profileImageUrl),
                    onBackgroundImageError: (_, __) =>
                    const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(user['name'] ?? "Unknown",
                      style: const TextStyle(color: Colors.white)),
                  trailing: ElevatedButton(
                    onPressed: () => _sendRequest(user['login_id'].toString()),
                    child: const Text("Request"),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white54),

          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Production',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Expanded(
            child: filteredProductions.isEmpty
                ? const Center(
              child: Text('No Production Items Found', style: TextStyle(color: Colors.white)),
            )
                : ListView.builder(
              itemCount: filteredProductions.length,
              itemBuilder: (context, index) {
                var product = filteredProductions[index];
                String productImageUrl = "$ipAddress/${product['photo'] ?? ''}";

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(productImageUrl),
                    onBackgroundImageError: (_, __) =>
                    const Icon(Icons.shopping_cart, color: Colors.white),
                  ),
                  title: Text(product['name'] ?? "Unknown",
                      style: const TextStyle(color: Colors.white)),
                  trailing: ElevatedButton(
                    onPressed: () => _sendFollow(product['login_id'].toString()),
                    child: const Text("Follow"),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
