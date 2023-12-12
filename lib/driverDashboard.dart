import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:my_project/Profile.dart';
import 'auth.dart';

class DriverDashboard extends StatefulWidget {
  @override
  _DriverDashboardState createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final database = FirebaseDatabase.instance.reference();
  final TextEditingController periodController = TextEditingController();
  final TextEditingController sourceController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  final TextEditingController carController = TextEditingController();
  final TextEditingController priceController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Fetch default car value from the database
    fetchDefaultCar();
  }

  void fetchDefaultCar() async {
    User? user = Auth().currentUser;

    if (user != null) {
      DatabaseEvent databaseEvent =
      await database.child('Users').child(user.uid).once();
      DataSnapshot dataSnapshot = databaseEvent.snapshot;

      if (dataSnapshot.value != null) {
        Map<dynamic, dynamic>? userData =
        dataSnapshot.value as Map<dynamic, dynamic>?;
        String defaultCar = userData?['carType'] ?? '';
        carController.text = defaultCar;
      }
    }
  }

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
            icon: Icon(Icons.info),
            color: Color(0xFF73C2BE),
            onPressed: () {
              // Show tooltip with information
              showInformationDialog(context);
            },
          ),
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
      body: SingleChildScrollView(
        child:Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButtonFormField<String>(
              value: periodController.text.isNotEmpty ? periodController.text : null,
              items: ['Morning', 'Afternoon']
                  .map((String period) => DropdownMenuItem<String>(
                value: period,
                child: Text(period),
              ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  periodController.text = newValue ?? '';
                  // Reset source and destination when the period changes
                  sourceController.clear();
                  destinationController.clear();
                });
              },
              decoration: InputDecoration(
                labelText: 'Period of Day',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Select Period',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: sourceController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Source',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter Source',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: destinationController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Destination',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter Destination',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: carController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Car',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter Car Type',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: priceController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: Colors.white),
                hintText: 'Enter Price',
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
      )
    );
  }

  void submitRideDetails() {
    // Get the current user ID
    String driverId = Auth().currentUser?.uid ?? '';

    // Get the text from the text controllers
    String car = carController.text.trim();
    String period = periodController.text.trim();
    String source = sourceController.text.trim();
    String destination = destinationController.text.trim();
    String price = priceController.text.trim();

    // Validate input fields (you may want to add more validation)
    if (car.isEmpty || period.isEmpty || source.isEmpty ||
        destination.isEmpty || price.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF73C2BE),
            title: Text('Error',style: TextStyle(color: Colors.white)),
            content: Text('Please enter all details',
                style: TextStyle(color: Color(0xFF495159))),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK',style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      );
      return;
    }

    // Check the conditions based on the selected period
    if ((period == 'Morning' && (destination != 'gate 3' && destination != 'gate 4')) ||
        (period == 'Afternoon' && (source != 'gate 3' && source != 'gate 4'))) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF73C2BE),
            title: Text('Error' ,style: TextStyle(color: Colors.white),),
            content: Text('Invalid source or destination for the selected period',
                style: TextStyle(color: Color(0xFF495159))),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK',style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
      return;
    }

    // Generate a unique key using push
    var newRideRef = database.child('Rides/').push();

    // Save the ride details to Firebase Realtime Database with the unique key
    newRideRef.set({
      'car': car,
      'driverId': driverId,
      'period': period,
      'rider1Id': 'none',
      'rider2Id': 'none',
      'rider3Id': 'none',
      'rider4Id': 'none',
      'rider1State': 'none',
      'rider2State': 'none',
      'rider3State': 'none',
      'rider4State': 'none',
      'source': source,
      'destination': destination,
      'price': price,
    }).then((_) => print("Ride added successfully!"));

    // Clear text fields after submitting
    periodController.clear();
    sourceController.clear();
    destinationController.clear();
    priceController.clear();
  }
  void showInformationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Information', style: TextStyle(color: Colors.white)),
          content: Text('Morning rides are at 7:30 AM, afternoon rides are at 5:30 PM.\n \n'
              'Please note that morning rides can only have a source of gate 3 or gate 4\n \n '
              'and afternoon rides can only have a source of gate 3 or gate 4.\n \n'
              'Please write the gates as follows only: gate "space" 3',
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
}
