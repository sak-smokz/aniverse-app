import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ImageDetailScreen extends StatefulWidget {
  final String imageUrl;
  final String loginId;
  final String title;
  final String post_id;

  ImageDetailScreen({
    required this.imageUrl,
    required this.loginId,
    required this.title,
    required this.post_id,
  });

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  bool _isLiked = false;  // State to keep track of like/unlike status
  int _likeCount = 0;  // Variable to store the like count
  List<Map<String, String>> comments = [];
  String? _selectedReason; // Stores selected report reason
  TextEditingController _customReasonController = TextEditingController(); // Controller for custom reason

  List<String> reportReasons = [
    "Inappropriate Content",
    "Spam",
    "Harassment",
    "False Information",
    "Other"
  ];

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _loadComment();
    _loadLike();
  }
  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a reason')),
      );
      return;
    }

    String reasonToSend = _selectedReason == "Other"
        ? _customReasonController.text
        : _selectedReason!;

    if (reasonToSend.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid reason')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      String lid = prefs.getString("lid") ?? "";
      print("sssssssssssssss"+lid);
      var response = await http.post(
        Uri.parse('$ip/api/report_post'),
        body: {
          'post_id': widget.post_id,
          'lid': lid,
          'reason': reasonToSend,
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Report submitted successfully')),
          );
          Navigator.pop(context); // Close the report dialog
        } else {
          throw Exception('Failed to submit report');
        }
      } else {
        throw Exception('Server error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _openReportDialog() {
    setState(() {
      _selectedReason = null;
      _customReasonController.clear();
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // ✅ Allows full-screen expansion
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // ✅ Prevents keyboard overlap
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) { // ✅ Ensures UI updates inside modal
              return Container(
                padding: EdgeInsets.all(16),
                height: MediaQuery.of(context).size.height * 0.5, // ✅ Adjust height
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Report Post",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 10),

                    // ✅ Radio Button List
                    Expanded(
                      child: ListView(
                        children: reportReasons.map((reason) {
                          return RadioListTile<String>(
                            title: Text(reason),
                            value: reason,
                            groupValue: _selectedReason,
                            onChanged: (String? value) {
                              setModalState(() {
                                _selectedReason = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),

                    // ✅ TextField inside StatefulBuilder
                    if (_selectedReason == "Other")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: TextField(
                          controller: _customReasonController,
                          decoration: InputDecoration(
                            hintText: "Enter your reason",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),

                    // ✅ Submit Button
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitReport,
                        child: Text("Submit Report"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _loadLike() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("ip") ?? "";
      String lid = pref.getString("lid") ?? "";

      var response = await http.post(
        Uri.parse('$ip/api/check_like'),
        body: {'post_id': widget.post_id, 'lid': lid},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == "success") {
          bool isLiked = jsonData['data'][0]['is_liked'] ?? false;
          setState(() {
            _isLiked = true;
          });
        }
      } else {
        print("Failed to fetch like status");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("ip") ?? "";

      var response = await http.post(
        Uri.parse('$ip/api/view_like'),
        body: {'post_id': widget.post_id},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == "success") {
          setState(() {
            _likeCount = jsonData['data'][0]['like_count'] ?? 0;
          });
        }
      } else {
        print("Failed to fetch like count");
      }
    } catch (e) {
      print("Error: $e");
    }
  }
  Future<void> _loadComment() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("ip") ?? "";

      var response = await http.post(
        Uri.parse('$ip/api/view_comment'),
        body: {'post_id': widget.post_id},
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        if (jsonData['status'] == "success") {
          setState(() {
            comments.clear(); // Clear the existing comments before updating
            for (var commentData in jsonData['data']) {
              comments.add({
                'username': commentData['name'] ?? '',
                'comment': commentData['comment'] ?? '',
                'image': ip+'/'+commentData['photo'] ?? '', // Assuming 'image' is the image URL in the comment
              });
            }
          });
        }
      } else {
        print("Failed to fetch comments");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> _addComment(String comment) async {
    if (comment.isNotEmpty) {
      final sh = await SharedPreferences.getInstance();
      String url = sh.getString("ip").toString();
      String lid = sh.getString("lid").toString();

      try {
        var response = await http.post(
          Uri.parse('$url/api/add_comment'),
          body: {
            'comment': comment,
            'lid': lid,
            'post_id': widget.post_id,
          },
        );

        var jsonData = json.decode(response.body);
        String status = jsonData['status'].toString();
        if (status == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Comment added successfully')),
          );
          _loadComment();  // Refresh comments after adding
        } else {
          throw Exception('Failed to add comment');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }


  Future<void> _handleLikeAction(BuildContext context) async {
    try {
      final sh = await SharedPreferences.getInstance();
      String lid = sh.getString("lid") ?? '';
      String url = sh.getString("ip") ?? '';

      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL is not set in SharedPreferences')),
        );
        return;
      }

      var response = await http.post(
        Uri.parse('$url/api/like_post'),
        body: {
          'post_id': widget.post_id,
          'lid': lid,
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          _isLiked = true;  // Update the state to liked
          _likeCount++;  // Increase like count by 1
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to like the post')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _handleUnLikeAction(BuildContext context) async {
    try {
      final sh = await SharedPreferences.getInstance();
      String lid = sh.getString("lid") ?? '';
      String url = sh.getString("ip") ?? '';

      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('URL is not set in SharedPreferences')),
        );
        return;
      }

      var response = await http.post(
        Uri.parse('$url/api/removelike_post'),
        body: {
          'post_id': widget.post_id,
          'lid': lid,
        },
      );

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);
        setState(() {
          _isLiked = false;  // Update the state to unliked
          _likeCount--;  // Decrease like count by 1
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unlike the post')),
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
      appBar: AppBar(
        title: Text('Image Details'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.flag, color: Colors.white), // Report icon
            onPressed: _openReportDialog,
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error, color: Colors.red, size: 100);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.title,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _isLiked
                  ? IconButton(
                icon: const Icon(Icons.thumb_up, color: Colors.white),
                onPressed: () {
                  _handleUnLikeAction(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Unliked', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              )
                  : IconButton(
                icon: const Icon(Icons.thumb_up_alt_outlined, color: Colors.white),
                onPressed: () {
                  _handleLikeAction(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Liked', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              Text(
                'Likes: $_likeCount',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.comment, color: Colors.white),
                onPressed: () {
                  _openCommentDrawer(context);
                },
              ),
            ],
          ),

        ],
      ),
    );
  }


  Future<void> _openCommentDrawer(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: Column(
            children: [
              Text(
                'Comments',
                style: TextStyle(fontSize: 20, color: Colors.black),
              ),
              SizedBox(height: 10),
              Expanded(
                child: comments.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: comments[index]['image']?.isNotEmpty ?? false
                          ? CircleAvatar(
                        backgroundImage: NetworkImage(comments[index]['image']!),
                      )
                          : const Icon(Icons.person, color: Colors.black),
                      title: Text(
                        comments[index]['username']!,
                        style: TextStyle(color: Colors.black),
                      ),
                      subtitle: Text(
                        comments[index]['comment']!,
                        style: TextStyle(color: Colors.black),
                      ),
                    );
                  },
                ),
              ),

              TextField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Write your comment...',
                  hintStyle: TextStyle(color: Colors.black),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String value) {
                  _addComment(value);
                  Navigator.pop(context);  // Close the bottom sheet after adding comment
                },
              ),
            ],
          ),
        );
      },
    );
  }


}
