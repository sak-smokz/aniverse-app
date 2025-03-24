import 'payment.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ViewOrderDressScreen extends StatefulWidget {
  const ViewOrderDressScreen({Key? key}) : super(key: key);

  @override
  _ViewOrderDressScreenState createState() => _ViewOrderDressScreenState();
}

class _ViewOrderDressScreenState extends State<ViewOrderDressScreen> {
  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString("lid") ?? "";
      String ip = prefs.getString("ip") ?? "";
      String apiUrl = "$ip/api/user_view_dress_orders";

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': userId});
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

  Future<String> _getIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("ip") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Dress Orders",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red), // Change color here
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
        ),
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
      future: _getIpAddress(),
      builder: (context, snapshot) {
        String ipAddress = snapshot.data ?? "";
        String imageUrl = "$ipAddress/${order['image'] ?? ''}";

        return Card(color: Color(0xff1C2121),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.white),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              "Ordered on: ${order['date'] ?? 'N/A'}",
                              style: const TextStyle(fontSize: 14, color: Colors.white),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "₹ ${order['price'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      Text(
                        " ${order['status'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange),
                      ),

                      // Show "Make Payment" Button if Status is Pending
                      if (order['status'] == "pending") ...[
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                                MaterialPageRoute(
                                  builder: (context) => PaymentScreen(
                                    orderId: order['orders_id'].toString(),
                                    amount: double.tryParse(order['amount'].toString()) ?? 0.0, // Convert String to Double
                                  ),

                            ));
                            // _makePayment(order['id']);  // Call payment function
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, // Button color
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          ),
                          child: const Text(
                            "Make Payment",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
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
