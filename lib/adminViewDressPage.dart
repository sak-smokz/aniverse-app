import 'payment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class adminviewDressScreen extends StatefulWidget {
  final String loginId;

  adminviewDressScreen({required this.loginId});

  @override
  _adminviewDressScreenState createState() => _adminviewDressScreenState();
}

class _adminviewDressScreenState extends State<adminviewDressScreen> {
  Future<List<Map<String, dynamic>>> _fetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString("lid") ?? "";
      String ip = prefs.getString("ip") ?? "";
      String apiUrl = "$ip/api/adminview_dress";

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': widget.loginId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      } else {
        throw Exception("API returned error status.");
      }
    } catch (e) {
      print("Error fetching : $e");
      return [];
    }
  }

  Future<String> _getIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("ip") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dress ",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading ", style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No  found", style: TextStyle(color: Colors.white, fontSize: 16)),
            );
          }

          var  orders= snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildOrderTile(orders[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderTile(Map<String, dynamic> order) {
    return FutureBuilder<String>(
      future: _getIpAddress(),
      builder: (context, snapshot) {
        String ipAddress = snapshot.data ?? "";
        String imageUrl = "$ipAddress/${order['image'] ?? ''}";

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Dress Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported, size: 80, color: Colors.grey);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Dress Details & Payment Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['title'] ?? "Unknown Dress",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      // Row(
                      //   children: [
                      //     const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      //     const SizedBox(width: 5),
                      //     Expanded(
                      //       child: Text(
                      //         "Ordered on: ${order['date'] ?? 'N/A'}",
                      //         style: const TextStyle(fontSize: 14, color: Colors.black54),
                      //         overflow: TextOverflow.ellipsis,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 5),
                      Text(
                        "₹ ${order['price'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        " ${order['size'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),





                      // Show "Make Payment" Button if Status is Pending

                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}
