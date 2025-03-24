import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'AdminViewPostPage.dart';
import 'Login_page.dart';
import 'adminViewDressPage.dart';
import 'adminViewEventPage.dart';
import 'adminViewpro_PostPage.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHome()),
          );
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _buildGridButton(
                icon: Icons.people,
                label: "View Users",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewUsersPage()),
                  );
                },
              ),
              _buildGridButton(
                icon: Icons.shopping_bag,
                label: "View Production",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ViewProductionPage()),
                  );
                },
              ),
              // _buildGridButton(
              //   icon: Icons.analytics,
              //   label: "Reports",
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(builder: (context) => ViewReportsPage()),
              //     );
              //   },
              // ),
              _buildGridButton(
                icon: Icons.logout,
                label: "Logout",
                onTap: () => _confirmLogout(context),
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridButton({required IconData icon, required String label, required VoidCallback onTap, Color color = Colors.blue}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        color: color.withOpacity(0.9),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 10),
              Text(label, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );                // Perform logout actions here
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}




class ViewUsersPage extends StatefulWidget {
  @override
  _ViewUsersPageState createState() => _ViewUsersPageState();
}



class _ViewUsersPageState extends State<ViewUsersPage> {
  List<Map<String, dynamic>> allUsers = [];
  String ipAddress = "";

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
  }

  Future<void> _loadIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = sh.getString("ip") ?? "";
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      final pref = await SharedPreferences.getInstance();
      String lid = pref.getString("lid") ?? "";
      String url = '$ipAddress/api/admin_view_user';

      var response = await http.post(Uri.parse(url), body: {'lid': lid});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        setState(() {
          allUsers = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading users: $e");
    }
  }

  void _showOptionsDialog(BuildContext context, String loginId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Options"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("View Post"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminViewPostPage(loginId: loginId),
                    ),
                  );
                },
              ),
              // ListTile(
              //   title: Text("View Report"),
              //   onTap: () {
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => AdminViewReportPage(loginId: loginId),
              //       ),
              //     );
              //   },
              // ),
              ListTile(
                title: Text("Cancel"),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Users")),
      body: allUsers.isEmpty
          ? const Center(
        child: Text('No Users Found', style: TextStyle(color: Colors.black)),
      )
          : ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (context, index) {
          var user = allUsers[index];
          String profileImageUrl = "$ipAddress/${user['photo'] ?? ''}";
          String loginId = user['login_id'].toString();

          return Card(
            margin: EdgeInsets.all(8.0),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl),
                onBackgroundImageError: (_, __) => const Icon(Icons.person, color: Colors.black),
              ),
              title: Text(user['name'] ?? "Unknown", style: TextStyle(color: Colors.black)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phone: ${user['phone'] ?? 'N/A'}"),
                  Text("Email: ${user['email'] ?? 'N/A'}"),
                  Text("Gender: ${user['gender'] ?? 'N/A'}"),
                  Text("Place: ${user['place'] ?? 'N/A'}"),
                ],
              ),
              onTap: () => _showOptionsDialog(context, loginId),
            ),
          );
        },
      ),
    );
  }
}







class ViewProductionPage extends StatefulWidget {
  @override
  _ViewProductionPageState createState() => _ViewProductionPageState();
}

class _ViewProductionPageState extends State<ViewProductionPage> {
  List<Map<String, dynamic>> allProduction = [];
  String ipAddress = "";
  String loginId = ""; // Store login ID

  @override
  void initState() {
    super.initState();
    _loadIpAddress();
  }

  Future<void> _loadIpAddress() async {
    final sh = await SharedPreferences.getInstance();
    setState(() {
      ipAddress = sh.getString("ip") ?? "";
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    try {
      final pref = await SharedPreferences.getInstance();
      loginId = pref.getString("lid") ?? ""; // Store login ID
      String url = '$ipAddress/api/admin_view_production';

      var response = await http.post(Uri.parse(url), body: {'lid': loginId});
      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        setState(() {
          allProduction = List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
        });
      }
    } catch (e) {
      print("Error loading production: $e");
    }
  }
  void _confirmDelete(BuildContext context, String loginId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to delete this production?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteProduction(loginId, index);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduction(String loginId, int index) async {
    try {
      String url = '$ipAddress/api/delete_production';
      var response = await http.post(Uri.parse(url), body: {'login_id': loginId});

      var jsonData = json.decode(response.body);

      if (jsonData['status'] == "success") {
        setState(() {
          allProduction.removeAt(index); // Remove from list
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Production deleted successfully")),
        );
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Production deleted successfully")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminHome()),
        );
      }
    } catch (e) {
      print("Error deleting production: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting production")),
      );
    }
  }

  void _showOptions(BuildContext context, String loginId, int index) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.event),
              title: Text("View Event"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => admin_viewEventScreen(loginId: loginId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.post_add),
              title: Text("View Post"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AdminViewpro_PostPage(loginId: loginId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.checkroom),
              title: Text("View Dress"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => adminviewDressScreen(loginId: loginId)),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, loginId, index);
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text("Cancel"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("View Production")),
      body: allProduction.isEmpty
          ? const Center(
        child: Text('No Production Found', style: TextStyle(color: Colors.black)),
      )
          : ListView.builder(
        itemCount: allProduction.length,
        itemBuilder: (context, index) {
          var production = allProduction[index];
          String profileImageUrl = "$ipAddress/${production['files'] ?? ''}";

          return Card(
            margin: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Certificate image (Tappable for full screen)
                GestureDetector(
                  onTap: () => _showFullScreenImage(context, profileImageUrl),
                  child: Container(
                    width: double.infinity,
                    height: 200, // Adjust height for certificate
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(profileImageUrl),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: profileImageUrl.isEmpty
                        ? Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey))
                        : null,
                  ),
                ),

                // ✅ Name & Info with 3-dot menu button
                ListTile(
                  title: Text(
                    production['name'] ?? "Unknown",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Phone: ${production['phone'] ?? 'N/A'}"),
                      Text("Email: ${production['email'] ?? 'N/A'}"),
                      Text("Place: ${production['place'] ?? 'N/A'}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.black), // 3-dot menu icon
                    onPressed: () => _showOptions(context, production['login_id'].toString(), index),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: imageUrl.isNotEmpty
            ? InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        )
            : const Center(child: Icon(Icons.image_not_supported, size: 100, color: Colors.white)),
      ),
    );
  }
}

