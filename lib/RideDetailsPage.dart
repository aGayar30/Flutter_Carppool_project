import 'package:flutter/material.dart';
import 'Rides.dart';

class RideDetailsPage extends StatelessWidget {
  final RideData ride;

  RideDetailsPage({required this.ride});

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
                  // Navigate back to Rides.dart (you can replace it with your logic)
                  Navigator.pop(context);
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
      padding: const EdgeInsets.only(top: 8.0,bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF73C2BE)),
      ),
    );
  }
}
