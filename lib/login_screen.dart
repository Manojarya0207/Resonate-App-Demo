import 'package:flutter/material.dart';
import 'otp_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login with Phone"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Enter Phone Number",
                prefixText: "+91 ",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await auth.verifyPhoneNumber(
                  phoneNumber: "+91${phoneController.text}",
                  verificationCompleted: (_) {},
                  verificationFailed: (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.message.toString())));
                  },
                  codeSent: (verificationId, resendToken) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OTPScreen(
                          verificationId: verificationId,
                        ),
                      ),
                    );
                  },
                  codeAutoRetrievalTimeout: (verificationId) {},
                );
              },
              child: Text("Send OTP"),
            )
          ],
        ),
      ),
    );
  }
}
