import 'package:flutter/material.dart';
import 'Profile.dart'; // Make sure to import your auth.dart file

class OrderTrackingPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        title: Text(
          'Order Tracking',
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF73C2BE),
          ),
        ),
        backgroundColor: Color(0xFF495159),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: ()  {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfilePage()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,

            ),
          ),
          Expanded(
            child: ListView(
              children: [
                RideCard(
                  from: 'From 1',
                  to: 'To 1',
                  driverName: 'Driver 1',
                  car: 'Car 1',
                  price: 'Price 1',
                  status: 'Completed', // Hardcoded status
                ),
                RideCard(
                  from: 'From 2',
                  to: 'To 2',
                  driverName: 'Driver 2',
                  car: 'Car 2',
                  price: 'Price 2',
                  status: 'Confirmed', // Hardcoded status
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final String from;
  final String to;
  final String driverName;
  final String car;
  final String price;
  final String status;

  RideCard({
    required this.from,
    required this.to,
    required this.driverName,
    required this.car,
    required this.price,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          title: Text(
            '$from to $to',
            style: TextStyle(color: Color(0xFF73C2BE)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Driver: $driverName',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Car: $car',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Price: $price',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                'Status: $status',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
