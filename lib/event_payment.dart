import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


class EventPaymentScreen extends StatefulWidget {
  final String orderId;
  final double amount;

  const EventPaymentScreen({Key? key, required this.orderId, required this.amount}) : super(key: key);

  @override
  _EventPaymentScreenState createState() => _EventPaymentScreenState();
}

class _EventPaymentScreenState extends State<EventPaymentScreen> {
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardHolderController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Payment"), backgroundColor: Colors.black),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(  // Added ScrollView
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildCardPreview(),
            const SizedBox(height: 30),
            _buildInputFields(),
            const SizedBox(height: 20),
            _buildAmountSection(),
            const SizedBox(height: 30),
            _buildPayButton(),
            const SizedBox(height: 50), // Extra Space for Keyboard
          ],
        ),
      ),
    );
  }

  // 🔹 ATM Card Preview Section
  Widget _buildCardPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("VISA", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(
            cardNumberController.text.isEmpty ? "XXXX XXXX XXXX XXXX" : cardNumberController.text,
            style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                cardHolderController.text.isEmpty ? "CARDHOLDER NAME" : cardHolderController.text.toUpperCase(),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                expiryDateController.text.isEmpty ? "MM/YY" : expiryDateController.text,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔹 Card Input Fields
  Widget _buildInputFields() {
    return Column(
      children: [
        _buildTextField("Cardholder Name", cardHolderController, false),
        const SizedBox(height: 15),
        _buildTextField("Card Number", cardNumberController, false, format: "xxxx xxxx xxxx xxxx"),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(child: _buildTextField("Expiry Date (MM/YY)", expiryDateController, false, format: "xx/xx")),
            const SizedBox(width: 15),
            Expanded(child: _buildTextField("CVV", cvvController, true)),
          ],
        ),
      ],
    );
  }

  // 🔹 Custom TextField Widget
  Widget _buildTextField(String label, TextEditingController controller, bool isObscure, {String? format}) {
    return TextField(
      controller: controller,
      obscureText: isObscure, // Hides CVV for security
      style: const TextStyle(color: Colors.white),
      inputFormatters: [
        if (format != null) CardNumberFormatter(format), // Custom Formatter
      ],
      onChanged: (_) => setState(() {}), // Updates UI dynamically
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // 🔹 Amount Display Section
  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Total Amount", style: TextStyle(color: Colors.white70, fontSize: 16)),
          Text("₹ ${widget.amount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 🔹 Pay Now Button
  Widget _buildPayButton() {
    return ElevatedButton(
      onPressed: _processPayment,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text("Pay Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  void _processPayment() async {
    if (cardNumberController.text.length < 16 || expiryDateController.text.length < 5 || cvvController.text.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter valid card details!")));
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString("lid") ?? "";
      String ip = prefs.getString("ip") ?? "";

      if (userId.isEmpty || ip.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User details missing!")));
        return;
      }
      String apiUrl = "$ip/api/event_user_payment";

      var response = await http.post(Uri.parse(apiUrl), body: {'lid': userId,'order_id':widget.orderId});


      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        if (jsonData['status'] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Payment Successful for Order ID: ${widget.orderId} 🎉")),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Failed: ${jsonData['message']}")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server Error: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }}


// 🔹 Card Number Formatting Class
class CardNumberFormatter extends TextInputFormatter {
  final String format;
  CardNumberFormatter(this.format);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = "";
    int index = 0;

    for (int i = 0; i < format.length; i++) {
      if (index < digits.length && format[i] == 'x') {
        formatted += digits[index];
        index++;
      } else if (format[i] != 'x') {
        formatted += format[i];
      }
    }
    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
