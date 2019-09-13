import 'package:flutter/material.dart';
import 'package:ubcfpv3/screen/home_screen.dart';
import 'package:ubcfpv3/screen/login_screen.dart';
import 'package:ubcfpv3/screen/user.dart';



User userInfo;


void main() {
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login app',
      home: LoginScreen (),
      theme: ThemeData(primaryColor: Colors.brown[400]),
//      routes: <String, WidgetBuilder>{
//        '/addpro': (BuildContext context) {},
//        '/home': (BuildContext context) {},
//      },
    );
  }
}