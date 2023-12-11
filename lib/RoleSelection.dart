import 'package:flutter/material.dart';
import 'home.dart';
import 'driverDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RoleSelectionScreen extends StatelessWidget {


  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  final database = FirebaseDatabase.instance.reference();

  Future<void> _checkAndCreateUserNode() async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      // Check if the user node already exists in the database
      DatabaseEvent databaseEvent  = await database.child('Users').child(user.uid).once();
      DataSnapshot snapshot = databaseEvent.snapshot;

      if (!snapshot.exists) {
        var email = user?.email;
        // If the user node doesn't exist, create it with dummy data
        await database.child('Users').child(user.uid).set({
          'name': 'your name',
          'age': 1,
          'grade': 'your grade',
          'email' : email ,
          'address': 'your address',
          'profilePictureUrl': 'https://example.com/profile.jpg',
          'phoneNumber': 'your number',
          'major': 'your major',
          'carType': 'your car',
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    _checkAndCreateUserNode();
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Rider Side
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text(
                'Rider Side',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF73C2BE),
              ),
            ),
            SizedBox(height: 25.0),
            ElevatedButton(
              onPressed: () {
                // Driver Side
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DriverDashboard()),
                );
              },
              child: Text(
                'Driver Side',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF73C2BE),
              ),
            )
          ],
        ),
      ),
    );
  }
}
