import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'AdminViewReportPage.dart';
import 'adminViewpro_PostPage.dart';

class AdminViewPostPage extends StatefulWidget {
  final String loginId;

  AdminViewPostPage({required this.loginId});

  @override
  _AdminViewPostPageState createState() => _AdminViewPostPageState();
}

class _AdminViewPostPageState extends State<AdminViewPostPage> {
  List<Map<String, dynamic>> userPosts = [];
  String ipAddress = "";

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
  }

  void _viewReport(String postId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewReportPage(postId: postId),
      ),
    );
  }

  Future<void> _loadIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = sh.getString("ip") ?? "";
      _loadUserPosts();
    });
  }

  Future<void> _loadUserPosts() async {
    try {
      String url = '$ipAddress/api/admin_view_post';
      var response = await http.post(Uri.parse(url), body: {'login_id': widget.loginId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        setState(() {
          userPosts = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading posts: $e");
    }
  }

  Future<void> _deletePost(String postId) async {
    try {
      String url = '$ipAddress/api/admindelete_post';
      var response = await http.post(Uri.parse(url), body: {'post_id': postId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        setState(() {
          userPosts.removeWhere((post) => post['post_id'].toString() == postId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post deleted successfully"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Post deleted successfully"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _confirmDelete(String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Post"),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(postId);
            },
            child: Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Posts")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Future.value(userPosts),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading posts"));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No posts available"));
          }

          var posts = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              String postId = post['post_id'].toString();
              String postImageUrl = post['post'] != null ? "$ipAddress/${post['post']}" : "";

              return GestureDetector(
                onLongPress: () => _confirmDelete(postId), // Trigger delete on long press
                child: Card(
                  margin: const EdgeInsets.all(8),
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
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.red),
                                const SizedBox(width: 4),
                                Text("${post['like_count'] ?? 0}", overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.comment, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text("${post['comment_count'] ?? 0}", overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _viewReport(postId),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.report, color: Colors.red),
                                      const SizedBox(width: 4),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
