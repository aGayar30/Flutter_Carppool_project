import 'dart:async';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'DriverRides.dart';

class ManageRequests extends StatefulWidget {
  final RideData ride;
  final DatabaseReference database = FirebaseDatabase.instance.reference();

  ManageRequests({required this.ride});

  @override
  _ManageRequestsState createState() => _ManageRequestsState(ride: ride);
}
class _ManageRequestsState extends State<ManageRequests> {
  final DatabaseReference database = FirebaseDatabase.instance.reference();
  List<Map<String, String>> ridersList = [];
  final RideData ride;
  final  DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  _ManageRequestsState({required this.ride});

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF495159),
        appBar: AppBar(
            backgroundColor: Color(0xFF495159),
            title: Text('Manage Requests', style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF73C2BE),),)
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${dateFormat.format(ride.date)}',style: TextStyle(color: Colors.white)),
                Text('Period: ${ride.period}',style: TextStyle(color: Colors.white),),
                Text('From: ${ride.source}',style: TextStyle(color: Colors.white)),
                Text('To: ${ride.destination}',style: TextStyle(color: Colors.white)),
                Text('Car: ${ride.car}',style: TextStyle(color: Colors.white)),
                Text('Price: ${ride.price}',style: TextStyle(color: Colors.white)),
                SizedBox(height: 16.0),
                Text(
                  'Riders and States:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF73C2BE)),
                ),
                SizedBox(height: 8.0),
                // Display rider information only if riderId is not 'none'
                for (int i = 1; i <= 4; i++)
                  if (ride.riderStates.containsKey('rider${i}Id') &&
                      ride.riderStates['rider${i}Id'] != 'none')
                    FutureBuilder<Map<String, String>>(
                      future: fetchRiderInfo(ride.rideID),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error loading rider information');
                        } else if (snapshot.hasData) {
                          String riderStatus = ride.riderStates['rider${i}State']!;
                          String riderInfo = snapshot.data!['rider$i']!;

                          return GestureDetector(
                            onTap: () async {
                              if (riderStatus == 'requested') {
                                // Check TimeConstraint from the database
                                int? timeConstraint = await fetchTimeConstraint();
                                if (timeConstraint == 1) {
                                  // Check if the time constraints are met for morning and afternoon rides
                                  if (ride.period == 'Morning') {
                                    if (!checkMorningRideTimeConstraint()) {
                                      showAlert(context,
                                          "Time constraints not met. Cannot accept or reject requests at this time.");
                                      return;
                                    }
                                  }
                                  else if (!checkAfternoonRideTimeConstraint()) {
                                    showAlert(context, "Time constraints not met. Cannot accept or reject requests  at this time.");
                                    return;
                                  }
                                }
                                showAcceptRejectDialog(context, riderInfo, i);
                              } else if (riderStatus == 'confirmed') {
                                showAlreadyAcceptedDialog(context);
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Card(
                                elevation: 0,
                                color: Color(0xC0FDFB),
                                child: ListTile(
                                  title: Text('Rider $i', style: TextStyle(color: Color(0xFF73C2BE))),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 8.0),
                                      Text(riderInfo, style: TextStyle(color: Colors.white)),
                                      SizedBox(height: 8.0),
                                      Text('State: $riderStatus', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Text('Rider $i: Loading...');
                        }
                      },
                    ),

              ],
            ),
          ),
        )
    );
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text("Alert" ,style: TextStyle(color: Colors.white),),
          content: Text(message , style: TextStyle(color: Color(0xFF495159)),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK", style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }

  void showAcceptRejectDialog(BuildContext context, String riderInfo, int i) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Accept or Reject', style: TextStyle(color: Colors.white),),
          content: Text('Do you want to accept or reject this request?\n\n$riderInfo' ,
              style: TextStyle(color: Color(0xFF495159))),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                acceptRider(i);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Accept', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                rejectRider(i);
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  // Method to accept the rider
  void acceptRider(int riderNumber) {
    // Update the rider state to 'confirmed' in the database
    DatabaseReference riderRef = FirebaseDatabase.instance.reference().child('Rides').child(ride.rideID);
    riderRef.update({'rider${riderNumber}State': 'confirmed'}).then((_) {
      fetchRiderInfo(ride.rideID);
      // Reload the page and update the UI
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManageRequests(ride: ride)),
      );
    });
  }

// Method to reject the rider
  void rejectRider(int riderNumber) {
    DatabaseReference riderRef = FirebaseDatabase.instance.reference().child('Rides').child(ride.rideID);
    riderRef.update({
      'rider${riderNumber}Id': 'none',
      'rider${riderNumber}State': 'none',
    }).then((_) {
      fetchRiderInfo(ride.rideID);
      // Reload the page and update the UI
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ManageRequests(ride: ride)),
      );
    });
  }

  bool checkMorningRideTimeConstraint() {
    // Check if the current time is before 11:30 PM the day before the ride
    DateTime now = DateTime.now();
    DateTime rideDate = ride.date.subtract(Duration(days: 1));
    DateTime constraintTime = DateTime(rideDate.year, rideDate.month, rideDate.day, 23, 30);

    return now.isBefore(constraintTime);
  }

  bool checkAfternoonRideTimeConstraint() {
    // Check if the current time is before 4:30 PM on the day of the ride
    DateTime now = DateTime.now();
    DateTime constraintTime = DateTime(ride.date.year, ride.date.month, ride.date.day, 16, 30);

    return now.isBefore(constraintTime);
  }

  Future<int?> fetchTimeConstraint() async {
    // Fetch TimeConstraint value from the database
    DatabaseEvent dataSnapshot = await database.child('TimeConstraint').once();
    return dataSnapshot.snapshot.value as int?;
  }



  void showAlreadyAcceptedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Already Accepted' ,style: TextStyle(color: Colors.white)),
          content: Text('This request has already been accepted.',
              style: TextStyle(color: Color(0xFF495159))),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }


  Future<String> fetchRiderName(String riderId) async {
    // Fetch rider name from the database
    DatabaseEvent dataSnapshot = await database.child('Users').child(riderId).child('name').once();
    return dataSnapshot.snapshot.value.toString();
  }

  Future<String> fetchRiderPhoneNumber(String riderId) async {
    // Fetch rider phone number from the database
    DatabaseEvent dataSnapshot = await database.child('Users').child(riderId).child('phoneNumber').once();
    return dataSnapshot.snapshot.value.toString();
  }

  Future<Map<String, String>> fetchRiderInfo(String rideID) async {
    Map<String, String> riderInfo = {};

    // Fetch rider information from the database
    DatabaseEvent dataSnapshot = await database.child('Rides').child(rideID).once();

    if (dataSnapshot.snapshot.value != null) {
      final rideData = dataSnapshot.snapshot.value as Map<dynamic, dynamic>;

      if (rideData != null) {
        for (int i = 1; i <= 4; i++) {
          String riderId = rideData['rider${i}Id'];
          String riderState = rideData['rider${i}State'];

          if (riderState != null && riderState != 'none' && riderId != null) {
            String riderName = await fetchRiderName(riderId);
            String riderPhoneNumber = await fetchRiderPhoneNumber(riderId);

            // Add rider information to the map
            riderInfo['rider$i'] = 'Name: $riderName, Phone: $riderPhoneNumber';
          } else {
            print('Invalid riderState or riderId for rideID: $rideID, rider$i');
          }
        }
      } else {
        print('Invalid rideData for rideID: $rideID');
      }
    } else {
      print('Snapshot value is null for rideID: $rideID');
    }

    return riderInfo;
  }




}