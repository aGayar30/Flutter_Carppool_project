import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'main.dart';
import 'EditProfile.dart';
import 'LocalDB.dart';
import 'package:connectivity/connectivity.dart';

class ProfilePage extends StatelessWidget {
  final Auth _auth = Auth();
  final DatabaseReference _userReference = FirebaseDatabase.instance.reference().child('Users');
  User? user = Auth().currentUser;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _updateLocalDatabase(Map<String, dynamic> userData) async {
    await _dbHelper.insertOrUpdateUserProfile(userData);
  }

  Future<Map<String, dynamic>> _fetchUserProfile() async {
    // Check if there is internet connectivity
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // No internet, fetch user profile from local database
      print("got this from local db");
      return _dbHelper.getUserProfile();
    } else {
      // Internet is available, fetch user profile from Firebase
      DataSnapshot dataSnapshot = (await _userReference.child(user?.uid ?? '').once()).snapshot;
      Map<dynamic, dynamic>? userData = dataSnapshot.value as Map<dynamic, dynamic>?;

      if (userData != null) {
        // Convert userData to Map<String, dynamic>
        Map<String, dynamic> userDataMap = Map<String, dynamic>.from(userData);

        // Update local database
        await _updateLocalDatabase(userDataMap);

        return userDataMap;
      }
    }

    // Return an empty map if no data is available
    return {};
  }

  void showOfflineDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Information', style: TextStyle(color: Colors.white)),
          content: Text('You are offline',
            style: TextStyle(color: Color(0xFF495159)),),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK' , style: TextStyle(color: Colors.white,),)
            ),
          ],
        );
      },
    );
  }

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
            icon: Icon(Icons.edit, color: Color(0xFF73C2BE)),
            onPressed: () async {
              var connectivityResult = await Connectivity().checkConnectivity();
              if (connectivityResult == ConnectivityResult.none) {
                showOfflineDialog(context);
              }
              else
              // Navigate to the Edit Profile page
              Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Color(0xFF73C2BE)),
            onPressed: () async {
              var connectivityResult = await Connectivity().checkConnectivity();
              if (connectivityResult == ConnectivityResult.none) {
                showOfflineDialog(context);
              }else {
                await _auth.signOut();
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => MyApp()));
              }
              },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _fetchUserProfile(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Access user data from the snapshot
              Map<String, dynamic> userData = snapshot.data ?? {};

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
              );
            }
          },
        ),
      ),
    );
  }
}
