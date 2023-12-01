
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF495159),
        body: Container(
        padding: EdgeInsets.all(16.0),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    SizedBox(height: 80.0),
    Text(
    'wasalna',
    style: TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF73C2BE),
    ),
    )])

    )
    );
  }}