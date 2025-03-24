import 'payment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'event_payment.dart';

class admin_viewEventScreen extends StatefulWidget {
  final String loginId;

  admin_viewEventScreen({required this.loginId});
  @override
  _admin_viewEventScreenState createState() => _admin_viewEventScreenState();
}

class _admin_viewEventScreenState extends State<admin_viewEventScreen> {
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString("lid") ?? "";
      String ip = prefs.getString("ip") ?? "";
      String apiUrl = "$ip/api/admin_view_event";

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': widget.loginId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      } else {
        throw Exception("API returned error status.");
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return [];
    }
  }

  Future<String> _getIpAdEvent() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("ip") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event ",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Error loading orders", style: TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No orders found", style: TextStyle(color: Colors.white, fontSize: 16)),
            );
          }

          var orders = snapshot.data!;
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
      future: _getIpAdEvent(),
      builder: (context, snapshot) {
        String ipAdEvent = snapshot.data ?? "";
        String imageUrl = "$ipAdEvent/${order['image'] ?? ''}";

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Event Image
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

                // Event Details & Payment Button
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['name'] ?? "Unknown Event",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "Event on: ${order['date'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        " ${order['time'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        " ${order['amount'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        " ${order['status'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
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
  }

}
