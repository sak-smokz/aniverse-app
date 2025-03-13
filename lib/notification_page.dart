import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];
  String baseUrl = ""; // To store IP Address

  @override
  void initState() {
    super.initState();
    _loadIpAndFetchNotifications();
  }

  // Load IP address from SharedPreferences before fetching notifications
  Future<void> _loadIpAndFetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      baseUrl = prefs.getString("ip") ?? "";
    });
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("lid") ?? "";

    String baseUrl = prefs.getString("ip") ?? "";
    String apiUrl = "$baseUrl/api/notification";

    var response = await http.post(Uri.parse(apiUrl), body: {'lid': userId});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        List<Map<String, dynamic>> combinedList = [];

        // Add Friend Requests
        for (var request in data['data']['friend_requests']) {
          combinedList.add({
            "type": "friend_request",
            "friend_id": request['friend_id'],
            "friends_id": request['friends_id'],

            "name": request['name'],
            "email": request['email'],
            "phone": request['phone'],
            "photo": "$baseUrl/${request['photo'] ?? ''}", // Fixed image URL
            "status": request['status'],
          });
        }

        // Add Events
        for (var event in data['data']['events']) {
          combinedList.add({
            "type": "event",
            "event_name": event['name'],
            "event_date": event['date'],
            "event_time": event['time'],
            "event_image": "$baseUrl/${event['image'] ?? ''}", // Fixed image URL
            "event_amount": event['amount'],
            "status": event['status'],
          });
        }

        setState(() {
          notifications = combinedList;
        });
      }
    }
  }
  Future<void> updateFriendRequest(String friendId, String action) async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("lid") ?? "";
    print('rrrrrrrrrrrrrrrrrrrr'+userId);
    String ip = prefs.getString("ip") ?? "";
    String apiUrl = "$ip/api/update_friend_request";

    var response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'friend_id': friendId,
        'login_id': userId,  // Send logged-in user's ID
        'action': action,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == "success") {
        setState(() {
          notifications.removeWhere((item) =>
          item['type'] == "friend_request" && item['friend_id'] == friendId);
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Aniverse",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: notifications.isEmpty
          ? const Center(
        child: Text(
          'No new notifications',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final item = notifications[index];

          if (item['type'] == "friend_request") {
            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(item['photo']),
                ),
                title: Text(
                  "${item['name']} sent you a friend request",
                  style: const TextStyle(color: Colors.white),
                ),
                // subtitle: Text(
                //   "Phone: ${item['phone']}\nEmail: ${item['email']}",
                //   style: const TextStyle(color: Colors.grey),
                // ),
                trailing: item['status'] == "pending"
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () {
                        updateFriendRequest(item['friends_id'].toString(), "accept");  // Accept request
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        updateFriendRequest(item['friends_id'].toString(), "reject");  // Reject request
                      },
                    ),
                  ],
                )
                    : Text(
                  item['status'] == "accept"
                      ? "Accepted ✅"
                      : "Rejected ❌",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),

              ),
            );
          } else if (item['type'] == "event") {
            return Card(
              color: Colors.grey[850],
              margin: const EdgeInsets.symmetric(vertical: 5),
              child: ListTile(
                leading: Image.network(
                  item['event_image'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(
                  item['event_name'],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Date: ${item['event_date']}\nTime: ${item['event_time']}\nAmount: ${item['event_amount']}",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
