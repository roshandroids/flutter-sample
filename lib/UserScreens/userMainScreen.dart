import 'package:flutter/material.dart';
import 'package:flutter_samples/UserScreens/homeScreen.dart';
import 'package:flutter_samples/UserScreens/uploadBook.dart';
import 'package:flutter_samples/UserScreens/userProfileScreen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class UserMainScreen extends StatefulWidget {
  @override
  _UserMainScreenState createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      HomeScreen(),
      UploadBook(),
      UserProfile(),
    ];
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                Color(0xfffff12c2e9),
                Color(0xffffc471ed),
                Color(0xfffff64f59),
              ],
            ),
            borderRadius: BorderRadius.circular(0),
            boxShadow: [
              BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(.9))
            ]),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8),
            child: GNav(
                gap: 5,
                activeColor: Colors.black,
                iconSize: 20,
                textStyle: GoogleFonts.firaCode(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                duration: Duration(milliseconds: 500),
                tabBackgroundColor: Color.fromARGB(0xff, 199, 179, 196),
                tabs: [
                  GButton(
                    icon: FontAwesomeIcons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: FontAwesomeIcons.book,
                    text: 'Upload Books',
                  ),
                  GButton(
                    icon: FontAwesomeIcons.newspaper,
                    text: 'Posts',
                  ),
                ],
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                }),
          ),
        ),
      ),
    );
  }
}
