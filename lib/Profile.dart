import 'package:flutter/material.dart';
import 'auth.dart';
import 'main.dart';

class ProfilePage extends StatelessWidget {
  final Auth _auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF73C2BE),
          ),
        ),
        backgroundColor: Color(0xFF495159),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 26.0),
            IconButton  (icon: Icon(Icons.account_circle_sharp, size: 70), onPressed: (){
              //nothing
            }
            ),
            SizedBox(height: 26.0),
            Text(
              'Name: Ahmed Amr',
              style: TextStyle(fontSize: 26,color: Colors.white),
            ),
            Text(
              'Age: 25',
              style: TextStyle(fontSize: 20,color: Colors.white),
            ),
            Text(
              'Grade: Senior',
              style: TextStyle(fontSize: 20,color: Colors.white),
            ),
            Text(
              'Address: 123 Main St, City',
              style: TextStyle(fontSize: 20,color: Colors.white),
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
