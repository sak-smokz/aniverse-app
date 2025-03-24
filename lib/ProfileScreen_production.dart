import 'production_navigation.dart';
import 'user_navigation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileproductionScreen extends StatefulWidget {
  const ProfileproductionScreen({Key? key}) : super(key: key);

  @override
  _ProfileproductionScreenState createState() => _ProfileproductionScreenState();
}

class _ProfileproductionScreenState extends State<ProfileproductionScreen> {
  List<Map<String, dynamic>> posts = [];
  String ipAddress = "";

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
    _loadMessages();
  }

  Future<void> _loadIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = sh.getString("ip") ?? "";
    });
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = "$ipAddress/api/proview_all_post";

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        setState(() {
          posts = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading posts: $e");
    }
  }

  Future<List<Map<String, dynamic>>> _loadProfileproduction() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = '$ipAddress/api/view_Profileproduction';

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      }
    } catch (e) {
      print("Error loading Profileproduction: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Profile",style: TextStyle(color: Colors.white),),
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => production_navigationscreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadProfileproduction(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading Profileproduction"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Profileproduction data available"));
          }

          var Profileproduction = snapshot.data!.first;
          String ProfileproductionImageUrl = Profileproduction['photo'] != null ? "$ipAddress/${Profileproduction['photo']}" : "";

          return SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Profile Photo
                    Container(
                      padding: const EdgeInsets.all(3), // Border thickness
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.red, width: 3), // Red border
                      ),
                      child: CircleAvatar(
                        radius: 50, // Profile picture size
                        backgroundImage: Profileproduction['photo'] != null
                            ? NetworkImage(ProfileproductionImageUrl)
                            : const AssetImage("assets/default_avatar.png") as ImageProvider,
                      ),
                    ),

                    const SizedBox(height: 12), // Space between photo and name

                    // Username
                    Text(
                      Profileproduction['name'] ?? "No Name",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8), // Space between name and details

                    // Location and Phone Number (aligned to left)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Profileproduction['place'] ?? 'Unknown Location',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Phone: ${Profileproduction['phone'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16), // Space before the next section
                  ],
                ),Padding(
                  padding: const EdgeInsets.all(15),
                  child: Divider(height: 40,color: Colors.red),
                ),

                posts.isEmpty
                    ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No posts available'),
                  ),
                )
                    : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    var post = posts[index];
                    String postImageUrl = post['post'] != null ? "$ipAddress/${post['post']}" : "";

                    return Card(
                      margin: const EdgeInsets.all(8),color: Color(0xff1C2121),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                              child: Image.network(
                                postImageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error, color: Colors.red, size: 100);
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.favorite, color: Colors.red),
                                      const SizedBox(width: 4),
                                      Text("${post['like_count'] ?? 0} ", overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                Flexible(
                                  child: Row(
                                    children: [
                                      const Icon(Icons.comment, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text("${post['comment_count'] ?? 0} ", overflow: TextOverflow.ellipsis,style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
