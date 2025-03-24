import 'dart:convert';
import 'view_user_all_post.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Merchant.dart';
import 'message_page.dart';
import 'ticket_booking.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class HomeScreen2 extends StatefulWidget {
  @override
  _HomeScreen2State createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2> {
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
      String categoryUrl = ip + "/api/view_all_post";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text(
          'Aniverse',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(CupertinoIcons.paperplane_fill, color: Colors.white),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => const MessagePage()),
        //       );
        //     },
        //   ),
        // ],
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height / 12,
            width: MediaQuery.of(context).size.width,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TicketBooking()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 17,
                      width: MediaQuery.of(context).size.width / 2.4,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Event Hosting",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Merchant()),
                      );
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 17,
                      width: MediaQuery.of(context).size.width / 2.4,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          "Add Merchant",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          posts.isEmpty
              ? const Center(
            child: Text(
              'No data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          )
              : Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 3 / 4,
              ),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                return FutureBuilder<String>(
                  future: _getIpAddress(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
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
                    String imageUrl = "$ipAddress/${posts[index]['post'] ?? ''}";

                    return InkWell(
                      onTap: () {
                        // Pass image URL and login_id to the new screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ImageDetailScreen(
                              imageUrl: imageUrl,
                              loginId: posts[index]['login_id'].toString(),
                              title: posts[index]['title'].toString(),
                              post_id: posts[index]['post_id'].toString(),

                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 100,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
