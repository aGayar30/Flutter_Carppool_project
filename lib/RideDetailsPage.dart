import 'package:flutter/material.dart';
import 'Rides.dart';
import 'package:firebase_database/firebase_database.dart';

class RideDetailsPage extends StatelessWidget {
  final RideData ride;
  final String? currentUserId; // Add this variable

  RideDetailsPage({
    required this.ride,
    required this.currentUserId, // Update the constructor
  });

  final DatabaseReference database = FirebaseDatabase.instance.reference();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        backgroundColor: Color(0xFF495159),
        title: Text('Ride Details', style: TextStyle(color: Color(0xFF73C2BE))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionTitle('Ride Details:'),
            buildRow('Car', ride.car),
            buildRow('Source', ride.source),
            buildRow('Destination', ride.destination),
            buildRow('Period', ride.period),
            buildRow('Price', ride.price),
            buildSectionTitle('Driver Details:'),
            buildRow('Driver Name', ride.driverName),
            buildRow('Driver Grade', ride.driverGrade),
            buildRow('Driver Phone Number', ride.driverPhoneNumber),
            SizedBox(height: 26.0),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement the logic for the "Request Ride" button
                  handleRequestRide(context);
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFF73C2BE),
                ),
                child: Text('Request Ride'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> handleRequestRide(BuildContext context) async {
    // Check if the current user ID is the same as the driver ID
    if (ride.driverID == currentUserId) {
      // Show an alert: "You can't book your own ride"
      showAlert(context, "You can't book your own ride");
      return;
    }

    // Check if there are still free spaces
    String? freeRiderId = await findFreeRiderId();
    if (freeRiderId != null) {
      // Update the corresponding rider ID and rider state
      await updateRideWithRiderInfo(freeRiderId, currentUserId);
      // Show a success message or perform any additional action
      showAlert(context, "Ride requested successfully!");
    } else {
      // Show an alert: "Ride full"
      showAlert(context, "Ride full");
    }
  }

  Future<String?> findFreeRiderId() async {
    // Iterate through rider IDs and find the first "none"
    for (int i = 1; i <= 4; i++) {
      String riderId = 'rider$i' + 'Id';
      String riderState = 'rider$i' + 'State';

      String riderIdValue = await fetchRideData(riderId);

      if (riderIdValue == 'none') {
        // Stop iteration and return the free rider ID
        return riderId;
      }
    }

    // If none of them are "none", return null
    return null;
  }

  Future<void> updateRideWithRiderInfo(String riderId, String? currentUserId) async {
    // Update the corresponding rider ID
    await updateRiderId(riderId, currentUserId);

    // Update the corresponding rider state to "requested"
    String riderState = riderId.replaceFirst('Id', 'State');
    await updateRiderState(riderState, 'requested');
  }

  Future<void> updateRiderId(String riderId, String? currentUserId) async {
    // Update the rider ID in the database
    await database.child('Rides').child(ride.rideID).update({riderId: currentUserId});
  }

  Future<void> updateRiderState(String riderState, String newState) async {
    // Update the rider state in the database
    await database.child('Rides').child(ride.rideID).update({riderState: newState});
  }

  Future<String> fetchRideData(String key) async {
    DatabaseEvent dataSnapshot = await database.child('Rides').child(ride.rideID).child(key).once();
    return dataSnapshot.snapshot.value.toString();
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

  Widget buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title:', style: TextStyle(fontSize: 18, color: Color(0xFF73C2BE))),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 18, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF73C2BE)),
      ),
    );
  }
}
