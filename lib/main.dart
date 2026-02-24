import 'package:flutter/material.dart';
void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(),
  home: Scaffold(
    backgroundColor: Color(0xFF07080B),
    body: Center(child: Text('Emowall Pro Ready', style: TextStyle(color: Colors.white, fontSize: 24))),
  ),
));
