import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_project/Profile.dart';

class DriverDashboard extends StatefulWidget {
  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final database = FirebaseDatabase.instance.reference();
  final TextEditingController periodController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        title: Text(
          'Driver Dashboard',
          style: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF73C2BE),
          ),
        ),
        backgroundColor: Color(0xFF495159),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            color: Color(0xFF73C2BE),
            onPressed: () {
              // Navigate to the user's profile page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: periodController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Period of Day (e.g., Morning)',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: sourceController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Source',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: destinationController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Destination',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: () {
                // Submit ride details to the Firebase Realtime Database
                submitRideDetails();
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF73C2BE),
              ),
              child: Text('Submit Ride'),
            ),
          ],
        ),
      ),
    );
  }

  void submitRideDetails() {
    // Get the text from the text controllers
    String period = periodController.text.trim();
    String source = sourceController.text.trim();
    String destination = destinationController.text.trim();

    // Validate input fields (you may want to add more validation)
    if (period.isEmpty || source.isEmpty || destination.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('PLease enter all details'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return;
    }

    // Save the ride details to Firebase Realtime Database
    database.child('dummyRides/').set({
      'period': period,
      'source': source,
      'destination': destination,
    }).then((_) => print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!"));

    // Clear text fields after submitting
    periodController.clear();
    sourceController.clear();
    destinationController.clear();
  }
}
