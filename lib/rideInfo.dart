import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'OrderTracking.dart';
import 'package:firebase_database/firebase_database.dart';
import 'paymentPage.dart';

class RideInfo extends StatelessWidget {
  final RideData ride;
  final String? currentUserId;
  final  DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  RideInfo({
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
            buildRow('Status', ride.status),
            buildRow('Car', ride.car),
            buildRow('Source', ride.source),
            buildRow('Destination', ride.destination),
            buildRow('Period', ride.period),
            buildRow('Date', dateFormat.format(ride.date)),
            buildRow('Price', ride.price),
            buildSectionTitle('Driver Details:'),
            buildRow('Driver Name', ride.driverName),
            buildRow('Driver Grade', ride.driverGrade),
            buildRow('Driver Phone Number', ride.driverPhoneNumber),

          SizedBox(height: 26.0),
          Center(
            child: ElevatedButton(
              onPressed: () {
                //check if ride status is confirmed
                if (ride.status == 'confirmed'){
                  // GOTO Payment page
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentPage( price: ride.price)));
                }
                else if (ride.status == 'requested'){
                  //show alert 'ride not yet confirmed' and don't go
                  showAlertDialog(context, "ride not yet confirmed");
                }
                else{
                  //show alert 'already payed'
                  showAlertDialog(context, "already payed");

                }
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF73C2BE),
              ),
              child: Text('Pay'),
            ),
          ),
          ],
        ),
      ),
    );
  }

  void showAlertDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF73C2BE),
          title: Text('Information', style: TextStyle(color: Colors.white)),
          content: Text('${message}',
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

  Future<String> fetchRideData(String key) async {
    DatabaseEvent dataSnapshot = await database.child('Rides').child(ride.rideID).child(key).once();
    return dataSnapshot.snapshot.value.toString();
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
