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
    with TickerProviderStateMixin {
  
  final String correctOtp = "123456";

  List<TextEditingController> controllers =
      List.generate(6, (index) => TextEditingController());

  bool isLoading = false;
  bool otpVerified = false;
  int seconds = 60;
  Timer? timer;

  late AnimationController successController;
  late Animation<double> successScale;

  bool wrongOtp = false;
  late AnimationController shakeController;
  late Animation<double> shakeAnimation;

  @override
  void initState() {
    super.initState();
    startTimer();

    /// Success animation
    successController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
    );

    successScale = CurvedAnimation(
      parent: successController,
      curve: Curves.easeOutBack,
    );

    /// Shake animation
    shakeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    shakeAnimation = Tween<double>(begin: 0, end: 12)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(shakeController);
  }

  void startTimer() {
    timer?.cancel();
    seconds = 60;

    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        if (mounted) {
          setState(() => seconds--);
        }
      }
    });
  }

  String getEnteredOtp() {
    return controllers.map((c) => c.text).join();
  }

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

      if (!mounted) return;

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
      wrongOtp = true;
      isLoading = false;

      shakeController.forward(from: 0);

      controllers.forEach((c) => c.clear());

      Future.delayed(Duration(seconds: 1), () {
        if (mounted) setState(() => wrongOtp = false);
      });

      setState(() {});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Incorrect OTP")));
    }
  }

  Widget buildOtpBox(int index) {
    return AnimatedBuilder(
      animation: shakeController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            wrongOtp ? shakeAnimation.value : 0,
            0,
          ),
          child: child,
        );
      },
      child: Container(
        width: 48,
        height: 60,
        decoration: BoxDecoration(
          border: Border.all(
            color: wrongOtp ? Colors.red : Colors.teal,
            width: 2,
          ),
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
          decoration:
              InputDecoration(counterText: "", border: InputBorder.none),
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    successController.dispose();
    shakeController.dispose();
    controllers.forEach((c) => c.dispose());
    super.dispose();
  }

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
            Text(
              "OTP sent to +91 ${widget.phone}",
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 25),

            AnimatedBuilder(
              animation: shakeController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    wrongOtp ? shakeAnimation.value : 0,
                    0,
                  ),
                  child: child,
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) => buildOtpBox(index)),
              ),
            ),

            SizedBox(height: 25),

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
                    child: Text("Resend OTP"),
                  ),

            SizedBox(height: 40),

            otpVerified
                ? ScaleTransition(
                    scale: successScale,
                    child: Icon(Icons.check_circle,
                        size: 80, color: Colors.green),
                  )
                : SizedBox(),

            SizedBox(height: 20),

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
