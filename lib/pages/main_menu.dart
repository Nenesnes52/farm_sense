// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({
    this.initPageIndex,
    super.key,
  });

  final int? initPageIndex;
  @override
  State<MainMenu> createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  final List<Widget> _pages = [
    // Home(),
    // Farm(),
    // Control(),
    Center(
      child: Text('Coming Soon',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
    ),
    Center(
      child: Text('Coming Soon',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
    ),
  ];
  var _pageIndex = 0;
  DateTime? _lastBackPressed;

  @override
  void initState() {
    super.initState();
    _pageIndex = widget.initPageIndex ?? 0;
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (_lastBackPressed == null ||
        now.difference(_lastBackPressed!) > const Duration(seconds: 3)) {
      _lastBackPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Tekan sekali lagi untuk keluar"),
          backgroundColor: Colors.black45.withValues(alpha: 0.7),
          duration: Duration(seconds: 3),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Container(
        color: const Color.fromRGBO(246, 246, 249, 1),
        child: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Scaffold(
                // resizeToAvoidBottomInset: true,
                backgroundColor: const Color.fromRGBO(246, 246, 249, 1),
                body: _pages[_pageIndex],
                // bottomNavigationBar: CustomBottomNavBar(
                //   currentIndex: _pageIndex,
                //   onTap: (value) {
                //     setState(() {
                //       _pageIndex = value;
                //     });
                //   },
                // ),
              ),
              // CameraButton()
            ],
          ),
        ),
      ),
    );
  }
}
