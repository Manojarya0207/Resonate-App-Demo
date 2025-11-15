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
  List<TextEditingController> otpControllers =
      List.generate(4, (index) => TextEditingController());

  List<FocusNode> focusNodes =
      List.generate(4, (index) => FocusNode());

  final String dummyOtp = "1234";

  int secondsRemaining = 60;
  bool enableResend = false;
  Timer? timer;

  bool isLoading = false;

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

    timer?.cancel();

    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() => secondsRemaining--);
      } else {
        setState(() => enableResend = true);
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    for (var c in otpControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String getOtp() {
    return otpControllers.map((e) => e.text).join();
  }

  Widget otpBox(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        maxLength: 1,
        decoration: InputDecoration(
          counterText: "",
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 3) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          }
          if (index == 3 && value.isNotEmpty) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
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
            SizedBox(height: 10),

            Text(
              "Enter the OTP sent to",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),

            SizedBox(height: 5),

            Text(
              "+91 ${widget.phone}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 35),

            // OTP BOXES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                otpBox(0),
                otpBox(1),
                otpBox(2),
                otpBox(3),
              ],
            ),

            SizedBox(height: 30),

            Center(
              child: Text(
                enableResend ? "Didn't receive OTP?" : "Waiting for OTP...",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),

            SizedBox(height: 10),

            // RESEND OTP BUTTON
            Center(
              child: TextButton(
                onPressed: enableResend
                    ? () {
                        for (var controller in otpControllers) {
                          controller.clear();
                        }
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

            // VERIFY BUTTON WITH LOADING
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        await Future.delayed(Duration(seconds: 2));

                        String otp = getOtp();
                        setState(() => isLoading = false);

                        if (otp == dummyOtp) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => HomeScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Incorrect OTP")),
                          );
                        }
                      },
                child: isLoading
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        "Verify",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
