import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'ip_page.dart';

class Message {
  final int senderId;
  final String messageContent;

  Message({required this.senderId, required this.messageContent});
}

class UserChat extends StatefulWidget {
  final String userIds;

  const UserChat({Key? key, required this.userIds}) : super(key: key);

  @override
  _UserChatState createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  List<Message> messages = [];
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final TextEditingController messageController = TextEditingController();
  String loginId = "";

  @override
  void initState() {
    super.initState();
    loadLoginId();
    loadMessages();
  }

  Future<void> _handleRefresh() async {
    await loadMessages();
  }

  Future<void> loadLoginId() async {
    final pref = await SharedPreferences.getInstance();
    String lid = pref.getString("lid") ?? "";
    setState(() {
      loginId = lid;
    });
    await loadMessages();
  }

  Future<void> loadMessages() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("ip") ?? "";
      String categoryUrl = "$ip/api/view_chat_list";

      var response = await http.post(
        Uri.parse(categoryUrl),
        body: {'lid': lid, 'userIds': widget.userIds},
      );

      var jsonData = json.decode(response.body);
      if (jsonData['status'] == "true") {
        setState(() {
          messages = List<Message>.from(jsonData['data'].map(
                (message) => Message(
              senderId: message['sender_id'],
              messageContent: message['message'],
            ),
          ));
        });
      }
    } catch (e) {
      print("Error loading messages: $e");
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty) return;

    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("ip") ?? "";
      String sendMessageUrl = "$ip/api/chat_with_user";

      var response = await http.post(
        Uri.parse(sendMessageUrl),
        body: {
          'lid': lid,
          'userIds': widget.userIds,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          messages.add(Message(senderId: int.parse(lid), messageContent: message));
        });
        messageController.clear();
      } else {
        print('Error sending message: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text(
            "Messages",
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red), // Change back button color here
            onPressed: () {
              Navigator.pop(context); // Navigate back
            },
          ),
        ),

        body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyApp()),
          );
          return false;
        },
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _handleRefresh,
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final isSender = (messages[index].senderId.toString() == loginId);
                      return Align(
                        alignment: isSender ? Alignment.topRight : Alignment.topLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSender ? Colors.red : Color(0xff1C2121),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(messages[index].messageContent, style: const TextStyle(fontSize: 16,color: Colors.white)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        decoration: InputDecoration(
                          hintText: "Type your message...",hintStyle: TextStyle(color: Colors.white),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.red),
                      onPressed: () {
                        sendMessage(messageController.text.trim());
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
