import 'package:flutter/material.dart';
import 'dart:async';
import 'home_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  OTPScreen({required this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen>
    with SingleTickerProviderStateMixin {
  
  final String correctOtp = "123456";
  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  bool isLoading = false;
  bool otpVerified = false;
  int seconds = 60;
  Timer? timer;

  late AnimationController successController;
  late Animation<double> successScale;

  @override
  void initState() {
    super.initState();
    startTimer();

    successController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    successScale = CurvedAnimation(
      parent: successController,
      curve: Curves.easeOutBack,
    );
  }

  // ---------------------------------------------------------
  // TIMER
  // ---------------------------------------------------------
  void startTimer() {
    timer?.cancel();
    seconds = 60;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        setState(() => seconds--);
      }
    });
  }

  // ---------------------------------------------------------
  // OTP COLLECTOR
  // ---------------------------------------------------------
  String getEnteredOtp() {
    return controllers.map((c) => c.text).join();
  }

  // ---------------------------------------------------------
  // OTP VERIFY + WHATSAPP TRANSITION
  // ---------------------------------------------------------
  void verifyOtp() async {
    setState(() => isLoading = true);

    await Future.delayed(Duration(seconds: 1));

    if (getEnteredOtp() == correctOtp) {
      setState(() {
        otpVerified = true;
        isLoading = false;
      });

      successController.forward();

      await Future.delayed(Duration(milliseconds: 700));

      // WHATSAPP STYLE SLIDE + OPACITY TRANSITION
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 450),
          pageBuilder: (_, animation, __) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                    parent: animation, curve: Curves.easeOut)),
                child: HomeScreen(),
              ),
            );
          },
        ),
      );
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Incorrect OTP")));
    }
  }

  // ---------------------------------------------------------
  // EDIT PHONE NUMBER BOTTOM SHEET
  // ---------------------------------------------------------
  void openPhoneEdit() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        TextEditingController numberController =
            TextEditingController(text: widget.phone);

        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Edit Phone Number",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 15),
              TextField(
                controller: numberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Phone Number",
                  prefixText: "+91 ",
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to Login screen
                },
                child: Text("Update & Go Back"),
              )
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // OTP INPUT BOX BUILDER
  // ---------------------------------------------------------
  Widget buildOtpBox(int index) {
    return Container(
      width: 48,
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.teal, width: 1.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (v.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: InputDecoration(counterText: "", border: InputBorder.none),
        style: TextStyle(fontSize: 22),
      ),
    );
  }

  // ---------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------
  @override
  void dispose() {
    timer?.cancel();
    successController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // UI
  // ---------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify OTP"),
        leading: BackButton(),
      ),
      body: Padding(
        padding: EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("OTP sent to +91 ${widget.phone}",
                style: TextStyle(fontSize: 16)),

            TextButton(
              onPressed: openPhoneEdit,
              child: Text("Edit Number", style: TextStyle(color: Colors.blue)),
            ),

            SizedBox(height: 25),

            // OTP BOXES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => buildOtpBox(index)),
            ),

            SizedBox(height: 25),

            // TIMER
            seconds > 0
                ? Text(
                    "Resend OTP in 00:${seconds.toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 14),
                  )
                : TextButton(
                    onPressed: () {
                      controllers.forEach((c) => c.clear());
                      startTimer();
                    },
                    child: Text("Resend OTP",
                        style: TextStyle(color: Colors.blue)),
                  ),

            SizedBox(height: 40),

            // ✔ SUCCESS TICK
            otpVerified
                ? ScaleTransition(
                    scale: successScale,
                    child: Icon(Icons.check_circle,
                        size: 80, color: Colors.green),
                  )
                : SizedBox(),

            SizedBox(height: 20),

            // VERIFY BUTTON WITH LOADING
            ElevatedButton(
              onPressed: isLoading ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text("Verify OTP", style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
