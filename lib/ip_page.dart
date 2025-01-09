import 'package:aniverse/Login_page.dart';
import 'package:flutter/material.dart';


class IpPage extends StatelessWidget {
   IpPage({super.key});
  final _formKey = GlobalKey<FormState>();
  TextEditingController ipcontroller =TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child:Form(key: _formKey,child:
        Column(
          children: [
            SizedBox(height: 100),
            TextFormField(controller: ipcontroller,
              decoration: InputDecoration(
                labelText: 'IP ADDRESS',
                labelStyle: TextStyle(color: Colors.black45),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the IP address';
              }
              return null;
              },
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 30),
            SizedBox(
              width: 150,
              child: ElevatedButton(
                  onPressed: () {
                    // if (_formKey.currentState!.validate()) {
                    //   String ip = ipcontroller.text.trim();
                    //   final prefs = await SharedPreferences.getInstance();
                    //   prefs.setString("ip", "http://$ip");
                    //
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => LoginPage()),
                    //   );
                    // } else {
                    //   print("Form not validated");
                    // }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "SAVE",
                    style: TextStyle(color: Colors.white),
                  )),
            )
          ],)

        ),
      ),
    );
  }
}
