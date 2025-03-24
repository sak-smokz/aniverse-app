import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class UserViewDress extends StatefulWidget {
  const UserViewDress({super.key});

  @override
  State<UserViewDress> createState() => _UserViewDressState();
}

class _UserViewDressState extends State<UserViewDress> {
  List<Map<String, dynamic>> dress = [];
  String ipAddress = "";

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      ipAddress = pref.getString("ip") ?? "";

      String categoryUrl = "$ipAddress/api/user_view_dress";
      var response =
          await http.post(Uri.parse(categoryUrl), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'].toString() == "success") {
        setState(() {
          dress = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      } else {
        print("API returned error status.");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.red),
        ),
        backgroundColor: Colors.black,
        title: const TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.red),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,
      body: dress.isEmpty
          ? const Center(
              child: Text(
                'No dresses available',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: dress.length,
              itemBuilder: (context, index) {
                final dressItem = dress[index];
                String imageUrl = "$ipAddress/${dressItem['image'] ?? ''}";

                return Card(
                  color: Colors.grey[900],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FullScreenImage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 80,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          dressItem['title'] ?? 'No Title',
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        Text(
                          "Price: \$${dressItem['price'] ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.green),
                        ),
                        Text(
                          "Size: ${dressItem['size'] ?? 'N/A'}",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.white54),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BuyScreen(
                                    dressId: dressItem['dresses_id'].toString(),
                                    imageUrl: imageUrl,
                                    title: dressItem['title'] ?? 'No Title',
                                    price: double.tryParse(
                                            dressItem['price'].toString()) ??
                                        0.0,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red),
                            child: const Text("Buy",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class BuyScreen extends StatefulWidget {
  final String dressId;
  final String imageUrl;
  final String title;
  final double price;

  const BuyScreen(
      {super.key,
      required this.dressId,
      required this.imageUrl,
      required this.title,
      required this.price});

  @override
  State<BuyScreen> createState() => _BuyScreenState();
}

class _BuyScreenState extends State<BuyScreen> {
  int quantity = 1;
  late double totalAmount;

  @override
  void initState() {
    super.initState();
    totalAmount = widget.price;
  }

  void _updateTotalAmount(int newQuantity) {
    setState(() {
      quantity = newQuantity;
      totalAmount = widget.price * quantity;
    });
  }

  Future<void> _submitOrder() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("ip") ?? "";
      String apiUrl = "$ip/api/buy_dress";
      String lid = pref.getString("lid") ?? "";
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          "lid": lid,
          "dress_id": widget.dressId,
          "quantity": quantity.toString(),
          "total_amount": totalAmount.toString(),
        },
      );

      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == "success") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order placed successfully!")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Order failed. Please try again.")));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Buy Dress",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red), // Red back button
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(widget.imageUrl,
                    height: 250, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            Text(widget.title,
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text("Price: \$${widget.price}",
                style: const TextStyle(fontSize: 18, color: Colors.green)),
            const SizedBox(height: 20),
            const Text("Quantity:",
                style: TextStyle(fontSize: 18, color: Colors.white)),
            Row(
              children: [
                IconButton(
                    icon: const Icon(Icons.remove, color: Colors.white),
                    onPressed: () =>
                        _updateTotalAmount(quantity > 1 ? quantity - 1 : 1)),
                Text(quantity.toString(),
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    onPressed: () => _updateTotalAmount(quantity + 1)),
              ],
            ),
            Text("Total: \$${totalAmount.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _submitOrder,
                child: const Text(
                  "Submit Order",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
          ],
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 3.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.error,
                color: Colors.red,
                size: 100,
              );
            },
          ),
        ),
      ),
    );
  }
}
