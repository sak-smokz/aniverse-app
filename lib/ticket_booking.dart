import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';

class TicketBooking extends StatefulWidget {
  const TicketBooking({super.key});

  @override
  _TicketBookingState createState() => _TicketBookingState();
}

class _TicketBookingState extends State<TicketBooking> {
  final TextEditingController _eventNameController = TextEditingController();
  final TextEditingController _eventAmountController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _selectedImage;

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2025),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_eventNameController.text.isNotEmpty && _selectedDate != null && _selectedTime != null && _selectedImage != null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String ip = pref.getString("ip") ?? "";

      if (ip.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server URL not found in preferences')),
        );
        return;
      }

      String event = _eventNameController.text;
      String amount = _eventAmountController.text;

      String selectedDateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      String selectedTimeStr = _selectedTime!.format(context);

      var request = http.MultipartRequest('POST', Uri.parse('$ip/api/add_event'));
      request.fields['lid'] = lid;
      request.fields['event'] = event;
      request.fields['date'] = selectedDateStr;
      request.fields['time'] = selectedTimeStr;
      request.fields['amount'] = amount;


      try {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            _selectedImage!.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

        var response = await request.send();

        if (response.statusCode == 200) {
          var responseData = await http.Response.fromStream(response);
          var jsonData = json.decode(responseData.body);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Data saved successfully: $jsonData')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending data: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields!")),
      );
    }
  }

  void _viewEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ViewEventsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        title: Text("Add Event", style: TextStyle(color: Colors.white)),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _eventNameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Event Name",
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            TextField(
              controller: _eventAmountController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Event Amount",
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickDate,
                    child: Text(_selectedDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _pickTime,
                    child: Text(_selectedTime == null ? "Select Time" : _selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text("Select Image"),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.file(_selectedImage!, height: 100),
              ),
            SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: Text("Submit", style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _viewEvents,
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text("View Events", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class ViewEventsScreen extends StatefulWidget {
  @override
  _ViewEventsScreenState createState() => _ViewEventsScreenState();
}

class _ViewEventsScreenState extends State<ViewEventsScreen> {
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
      String categoryUrl = "$ip/api/view_event";

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

  Future<void> _deleteEvent(String postId) async {
    try {
      final pref = await SharedPreferences.getInstance();
      String ip = pref.getString("ip") ?? "";
      String deleteUrl = "$ip/api/delete_event";

      var response = await http.post(Uri.parse(deleteUrl), body: {'event_id': postId});
      var jsonData = json.decode(response.body);
      if (jsonData['status'].toString() == "success") {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TicketBooking()),
        );
        setState(() {
          posts.removeWhere((post) => post['Events_id'].toString() == postId);
        });
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TicketBooking()),
        );
        print("Failed to delete event.");
      }
    } catch (e) {
      print("Error deleting event: $e");
    }
  }

  Future<String> _getIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    return sh.getString("ip") ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Events")),
      body: posts.isEmpty
          ? const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return FutureBuilder<String>(
              future: _getIpAddress(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Icon(
                    Icons.error,
                    color: Colors.red,
                    size: 100,
                  );
                }
                String ipAddress = snapshot.data ?? "";
                String imageUrl = "$ipAddress/${posts[index]['image'] ?? ''}";

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        width: 80,
                        height: 80,
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
                    title: Text(posts[index]['name'] ?? 'No Title'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Date: ${posts[index]['date'] ?? 'N/A'}"),
                        Text("Time: ${posts[index]['time'] ?? 'N/A'}"),
                        Text("Amount: ${posts[index]['amount'] ?? 'N/A'}"),

                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteEvent(posts[index]['Events_id'].toString());
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageDetailScreen1(
                            imageUrl: imageUrl,
                            loginId: posts[index]['login_id'].toString(),
                            title: posts[index]['title'].toString(),
                            event_id: posts[index]['event_id'].toString(),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class ImageDetailScreen1 extends StatelessWidget {
  final String imageUrl;
  final String loginId;
  final String title;
  final String event_id;

  ImageDetailScreen1({
    required this.imageUrl,
    required this.loginId,
    required this.title,
    required this.event_id,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }
}