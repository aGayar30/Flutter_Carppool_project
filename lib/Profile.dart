import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'main.dart';
import 'EditProfile.dart';

class ProfilePage extends StatelessWidget {
  final Auth _auth = Auth();
  final DatabaseReference _userReference = FirebaseDatabase.instance.reference().child('Users');
  User? user = Auth().currentUser;

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
            icon: Icon(Icons.edit , color: Color(0xFF73C2BE)),
            onPressed: () {
              // Navigate to the Edit Profile page
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app , color: Color(0xFF73C2BE)),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp()));
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<DatabaseEvent>(
          future: _userReference.child(user?.uid ?? '').once(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Access user data from the snapshot
              DataSnapshot dataSnapshot = snapshot.data!.snapshot;
              Map<dynamic, dynamic>? userData = dataSnapshot.value as Map<dynamic, dynamic>?;

              if (user != null && userData != null) {

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 26.0),
                  IconButton(
                    icon: Icon(Icons.account_circle_sharp, size: 70),
                    onPressed: () {
                      // nothing
                    },
                  ),
                  SizedBox(height: 40.0),
                  Text(
                    '${userData['name'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Age: ${userData['age'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Grade: ${userData['grade'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Address: ${userData['address'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Email: ${userData['email'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Phone number: ${userData['phoneNumber'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Major: ${userData['major'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  SizedBox(height: 12.0),
                  Text(
                    'Car: ${userData['carType'] ?? 'N/A'}',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ],
              );} else {
                return Text('Error: User data is null or not a Map. ${user?.uid?? ''}');
              }
            }
          },
        ),
      ),
    );
  }
}
