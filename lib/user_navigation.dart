import 'user_view_event_book.dart';
import 'user_view_order_dress.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Login_page.dart';
import 'update_profile.dart';


class user_navigationscreen extends StatelessWidget {
  const user_navigationscreen({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _loadProfile(BuildContext context) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("ip") ?? "";
      String categoryUrl = '$ip/api/user_view_profile';

      var response = await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);
      String status = jsonData['status'].toString();

      if (status == "success") {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      } else {
        throw Exception("API returned error status.");
      }
    } catch (e) {
      print("Error: $e");
      return [];
    }
  }

  Future<String> _getIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    return sh.getString("ip") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red), // Change back button color here
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadProfile(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading profile'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No profile data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          var profile = snapshot.data!.first;

          return Column(
            children: [
              // Profile Header
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              //   color: Colors.white,
              //   child: Row(
              //     children: [
              //       // Profile Picture
              //       FutureBuilder<String>(
              //         future: _getIpAddress(),
              //         builder: (context, snapshot) {
              //           if (snapshot.connectionState == ConnectionState.waiting) {
              //             return const CircularProgressIndicator();
              //           } else if (snapshot.hasError) {
              //             return const Icon(Icons.error, size: 70, color: Colors.red);
              //           } else {
              //             String ipAddress = snapshot.data ?? "";
              //             String imageUrl = "$ipAddress/${profile['photo'] ?? ''}";
              //             return ClipOval(
              //               child: Image.network(
              //                 imageUrl,
              //                 width: 80,
              //                 height: 80,
              //                 fit: BoxFit.cover,
              //                 errorBuilder: (context, error, stackTrace) {
              //                   return const Icon(Icons.person, size: 80, color: Colors.grey);
              //                 },
              //               ),
              //             );
              //           }
              //         },
              //       ),
              //       const SizedBox(width: 16),
              //
              //       // User Details
              //       Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: [
              //           Text(
              //             "${profile['firstname'] ?? ''} ${profile['lastname'] ?? ''}",
              //             style: const TextStyle(
              //               fontSize: 22,
              //               fontWeight: FontWeight.bold,
              //               color: Colors.black87,
              //             ),
              //           ),
              //           const SizedBox(height: 6),
              //           Row(
              //             children: [
              //               Icon(Icons.location_on, size: 16, color: Colors.black54),
              //               const SizedBox(width: 6),
              //               Text(
              //                 "Place: ${profile['place'] ?? ''}",
              //                 style: const TextStyle(fontSize: 15, color: Colors.black54),
              //               ),
              //             ],
              //           ),
              //           const SizedBox(height: 6),
              //           Row(
              //             children: [
              //               Icon(Icons.phone, size: 16, color: Colors.black54),
              //               const SizedBox(width: 6),
              //               Text(
              //                 "${profile['phone'] ?? ''}",
              //                 style: const TextStyle(fontSize: 15, color: Colors.black54),
              //               ),
              //             ],
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),

              const SizedBox(height: 10),

              // Profile Options (List Style)
              Expanded(
                child: Container(
                  color: Colors.white,
                  child: ListView(
                    children: [
                      _buildListItem(
                        context,
                        icon: Icons.edit,
                        title: "Edit Profile",
                        subtitle: "Update your personal details",
                        onTap: () async {
                          bool? updated = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UpdateProfileScreen(profile: profile)),
                          );
                          if (updated == true) {
                            _loadProfile(context);
                          }
                        },
                      ),
                      _buildListItem(
                        context,
                        icon: Icons.shopping_cart,
                        title: "View Dress Orders",
                        subtitle: "Track your dress orders",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewOrderDressScreen()),
                          );
                        },
                      ),
                      _buildListItem(
                        context,
                        icon: Icons.event,
                        title: "View Event Bookings",
                        subtitle: "Check your event bookings",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ViewOrderEventScreen()),
                          );
                        },
                      ),
                      _buildListItem(
                        context,
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Sign out from your account",
                        iconColor: Colors.red,
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListItem(BuildContext context, {required IconData icon, required String title, required String subtitle, Color iconColor = Colors.black, required VoidCallback onTap}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: iconColor, size: 30),
          title: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          onTap: onTap,
        ),
        const Divider(height: 1, color: Colors.grey),
      ],
    );
  }
}
