import 'package:flutter/material.dart';
import 'Rides.dart';
import 'driverDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class RoleSelectionScreen extends StatelessWidget {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance.reference();

  Future<bool> _checkUserNodeExistence() async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      DatabaseEvent databaseEvent =
      await database.child('Users').child(user.uid).once();
      DataSnapshot snapshot = databaseEvent.snapshot;

      return snapshot.exists;
    }

    return false;
  }

  Future<void> _createUserNode() async {
    User? user = _firebaseAuth.currentUser;

    if (user != null) {
      var email = user?.email;
      // Create a new user node with dummy data
      await database.child('Users').child(user.uid).set({
        'name': 'your name',
        'age': 1,
        'grade': 'your grade',
        'email': email,
        'address': 'your address',
        'profilePictureUrl': 'https://example.com/profile.jpg',
        'phoneNumber': 'your number',
        'major': 'your major',
        'carType': 'your car',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      body: FutureBuilder<bool>(
        future: _checkUserNodeExistence(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // If the Future is still running, show a loading indicator
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            // If there is an error, handle it accordingly
            return Text('Error: ${snapshot.error}');
          } else {
            // If the Future is complete
            bool userNodeExists = snapshot.data ?? false;

            if (!userNodeExists) {
              // If the user node doesn't exist, create it with dummy data
              _createUserNode();

              // Schedule the _showAlertDialog method to be called after the build is complete
              WidgetsBinding.instance?.addPostFrameCallback((_) {
                _showAlertDialog(context);
              });
            }

            // Continue with the rest of the UI
            return Center(
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
                        MaterialPageRoute(
                            builder: (context) => DriverDashboard()),
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
            );
          }
        },
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Welcome!', style: TextStyle(color: Colors.white)),
          content: Text('This is your first time signing in! \n \n'
              'Please head over to the profile page to update your information.',
              style: TextStyle(color: Color(0xFF495159))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.white,)),
            ),
          ],
        );
      },
    );
  }
}
