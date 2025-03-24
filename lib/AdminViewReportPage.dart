import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ViewReportPage extends StatefulWidget {
  final String postId;

  ViewReportPage({required this.postId});

  @override
  _ViewReportPageState createState() => _ViewReportPageState();
}

class _ViewReportPageState extends State<ViewReportPage> {
  List<Map<String, dynamic>> reports = [];
  String ipAddress = "";
  bool isLoading = true;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _fetchReportReasons();
  }

  Future<void> _fetchReportReasons() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String ip = prefs.getString("ip") ?? "";
      ipAddress = ip; // Store the IP address for image URLs
      print("eeeeeeeeeeeeee$ipAddress");



      String apiUrl = "$ip/api/admin_view_report";
      var response = await http.post(Uri.parse(apiUrl), body: {'post_id': widget.postId});
      var jsonData = json.decode(response.body);
      print("eeeeeeeeeeeeeesssssssssss");

      if (jsonData['status'] == "success") {
        setState(() {
          reports = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
          isLoading = false;
          print("eeeeeeeeeeeeee$reports");
        });
      } else {
        setState(() {
          errorMessage = "No reports found.";
          isLoading = false;
        });
      }

    }
    catch (e) {
      print("Error loading posts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Report Details")),
      body: isLoading

          ? Center(child: Text("No reports found.", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          : ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          var report = reports[index];
          String profileImageUrl = "$ipAddress/${report['photo'] ?? ''}";

          return Card(
            margin: EdgeInsets.all(12),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(profileImageUrl),
                      onBackgroundImageError: (_, __) => Icon(Icons.person, color: Colors.black),
                    ),
                    title: Text(report['name'] ?? "Unknown",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("Email: ${report['email'] ?? 'N/A'}"),
                  ),
                  SizedBox(height: 10),
                  Text("📍 Place: ${report['place'] ?? 'N/A'}"),
                  Text("📞 Phone: ${report['phone'] ?? 'N/A'}"),
                  Text("⚠️ Report Reason: ${report['reason'] ?? 'N/A'}",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
