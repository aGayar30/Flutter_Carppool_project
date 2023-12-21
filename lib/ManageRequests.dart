import 'dart:async';

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

  _ManageRequestsState({required this.ride});

  @override
  void initState() {
    super.initState();
    updateRidersList();
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
                        onTap: () {
                          // Show popup dialog based on rider's status
                          if (riderStatus == 'requested') {
                            // If rider status is 'requested', show accept/reject dialog
                            showAcceptRejectDialog(context, riderInfo, i);
                          } else if (riderStatus == 'confirmed') {
                            // If rider status is 'confirmed', show 'already accepted' dialog
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
                          // Add card details here, e.g., ListTile with riderInfo
                          child: ListTile(
                            title: Text('Rider $i',style: TextStyle( color: Color(0xFF73C2BE))),
                            subtitle: Column (crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.0),
                                Text(riderInfo, style: TextStyle(color: Colors.white)),
                                SizedBox(height: 8.0),
                                Text('State: $riderStatus', style: TextStyle(color: Colors.white)),
                              ],)
                          ),
                        ),
                      )
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

  void updateRidersList() async {
    DatabaseReference rideRef = FirebaseDatabase.instance.reference().child('Rides').child(widget.ride.rideID);

    try {
      DataSnapshot snapshot = (await rideRef.once()) as DataSnapshot;
      if (snapshot.value != null) {
        final rideData = snapshot.value as Map<dynamic, dynamic>;

        // Clear the existing list
        ridersList.clear();

        // Fetch and add the rider information to the list
        for (int i = 1; i <= 4; i++) {
          String riderId = rideData['rider${i}Id'];
          String riderState = rideData['rider${i}State'];

          if (riderState != 'none') {
            String riderInfo = (await fetchRiderInfo(riderId)) as String;
            // Add rider information to the list
            ridersList.add({'rider$i': riderInfo});
          }
        }

        // Call setState to update the UI
        if (mounted) {
          setState(() {});
        }
      }
    } catch (error) {
      // Handle any errors that might occur during the database operation
      print('Error updating riders list: $error');
    }
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
                updateRidersList();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Accept', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                rejectRider(i);
                updateRidersList();
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
      // Call setState to trigger a rebuild of the UI
      if (mounted) {
        setState(() {});
      }
    });
  }

// Method to reject the rider
  void rejectRider(int riderNumber) {
    DatabaseReference riderRef = FirebaseDatabase.instance.reference().child('Rides').child(ride.rideID);
    riderRef.update({
      'rider${riderNumber}Id': 'none',
      'rider${riderNumber}State': 'none',
    }).then((_) {
      // Call setState to trigger a rebuild of the UI
      if (mounted) {
        setState(() {});
      }
    });
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
