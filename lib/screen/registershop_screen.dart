import 'package:flutter/material.dart';

class Registershop_Screen extends StatefulWidget {
  @override
  _Registershop_ScreenState createState() => _Registershop_ScreenState();
}

class _Registershop_ScreenState extends State<Registershop_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown[400],
        title: Text("REGISTER SHOP"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(),

    );
  }



}
