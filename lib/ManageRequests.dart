import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'DriverRides.dart';

class ManageRequests extends StatelessWidget {
  final RideData ride;
  final DatabaseReference database = FirebaseDatabase.instance.reference();

  ManageRequests({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Period: ${ride.period}'),
            Text('From: ${ride.source}'),
            Text('To: ${ride.destination}'),
            Text('Car: ${ride.car}'),
            Text('Price: ${ride.price}'),
            Text('Driver Name: ${ride.driverName}'),
            Text('Driver Grade: ${ride.driverGrade}'),
            Text('Driver Phone Number: ${ride.driverPhoneNumber}'),
            SizedBox(height: 16.0),
            Text(
              'Riders and States:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                      return Text('Rider ${i}: ${snapshot.data!} - State: ${ride.riderStates['rider${i}State']}');
                    } else {
                      return Text('Rider ${i}: Loading... - State: ${ride.riderStates['rider${i}State']}');
                    }
                  },
                ),
          ],
        ),
      ),
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

      print('rideData: $rideData'); // Print rideData for debugging

      for (int i = 1; i <= 4; i++) {
        String riderId = rideData['rider${i}Id'];
        String riderState = rideData['rider${i}State'];

        print('Rider $i - ID: $riderId, State: $riderState');

        if (riderState != 'none') {
          String riderName = await fetchRiderName(riderId);
          String riderPhoneNumber = await fetchRiderPhoneNumber(riderId);

          print('Rider $i - Name: $riderName, Phone: $riderPhoneNumber');

          // Add rider information to the map
          riderInfo['rider$i'] = 'Name: $riderName, Phone: $riderPhoneNumber';
        } else {
          // If riderState is 'none', break the loop since there are no more riders
          break;
        }
      }

    }

    print('Final riderInfo: $riderInfo'); // Print final riderInfo for debugging

    return riderInfo;
  }


}
