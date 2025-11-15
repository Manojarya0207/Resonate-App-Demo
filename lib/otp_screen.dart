import 'dart:async';
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

  int secondsRemaining = 60;
  bool enableResend = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    setState(() {
      secondsRemaining = 60;
      enableResend = false;
    });

    timer?.cancel(); // Cancel previous timer

    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        setState(() => enableResend = true);
        timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Verify OTP",
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 15),

            Text(
              "Enter the OTP sent to",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 5),

            Text(
              "+91 ${widget.phone}",
              style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 35),

            // OTP Text Field Box
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal, width: 1.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                style: TextStyle(fontSize: 22, letterSpacing: 10),
                decoration: InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  hintText: "• • • •",
                ),
              ),
            ),

            SizedBox(height: 25),

            Center(
              child: Text(
                enableResend
                    ? "Didn't receive OTP?"
                    : "Waiting for OTP...",
                style: TextStyle(color: Colors.grey[700], fontSize: 15),
              ),
            ),

            SizedBox(height: 10),

            // RESEND OTP BUTTON
            Center(
              child: TextButton(
                onPressed: enableResend
                    ? () {
                        startTimer();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("New OTP sent!")),
                        );
                      }
                    : null,
                child: Text(
                  enableResend
                      ? "Resend OTP"
                      : "Resend in 00:${secondsRemaining.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: enableResend ? Colors.teal : Colors.grey,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(height: 40),

            // VERIFY BUTTON
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

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

                child: Text(
                  "Verify",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
