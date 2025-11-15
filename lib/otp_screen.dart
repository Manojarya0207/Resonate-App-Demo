import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  OTPScreen({required this.verificationId});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  TextEditingController otpController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("OTP Verification"),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(
                labelText: "Enter OTP",
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () async {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: widget.verificationId,
                      smsCode: otpController.text);

                  try {
                    await auth.signInWithCredential(credential);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => HomeScreen()));
                  } catch (e) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text("Invalid OTP")));
                  }
                },
                child: Text("Verify OTP"))
          ],
        ),
      ),
    );
  }
}
