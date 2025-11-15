import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  // Pages for bottom navigation
  final List<Widget> pages = [
    Center(child: Text("Home", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
    Center(child: Text("Messages", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
    Center(child: Text("Group Call", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
    Center(child: Text("Profile", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ------------------------ APPBAR ------------------------
      appBar: AppBar(
        elevation: 2,
        backgroundColor: Colors.white,
        centerTitle: true,

        // LEFT SIDE (+ icon)
        leading: IconButton(
          icon: Icon(Icons.add, color: Colors.teal, size: 28),
          onPressed: () {},
        ),

        // CENTER (App name)
        title: Text(
          "Resonate",
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        // RIGHT SIDE (message icon)
        actions: [
          IconButton(
            icon: Icon(Icons.message_rounded, color: Colors.teal, size: 26),
            onPressed: () {},
          )
        ],
      ),

      // ------------------------ MAIN BODY ------------------------
      body: pages[currentIndex],

      // ------------------------ BOTTOM NAVIGATION BAR ------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
        },

        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 10,

        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: "Message",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: "Group Call",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
