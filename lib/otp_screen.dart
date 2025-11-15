import 'package:flutter/material.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  OTPScreen({required this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  final String dummyOtp = "1234";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text("OTP sent to +91 ${widget.phone}"),
            SizedBox(height: 20),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter OTP"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                if (otpController.text == dummyOtp) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Incorrect OTP")),
                  );
                }
              },
              child: Text("Verify"),
            )
          ],
        ),
      ),
    );
  }
}
