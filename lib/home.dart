import 'package:flutter/material.dart';
import 'package:my_project/Profile.dart';
import 'OrderTracking.dart';

class HomeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        title: Text('Rides', style: TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: Color(0xFF73C2BE),
    ),
        ),
        backgroundColor: Color(0xFF495159), // Match the login page color
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),color: Color(0xFF73C2BE),
            onPressed: () {
              // Navigate to the user's profile page
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
              children: [
                DropdownButton<String>(
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  items: ['Morning', 'Afternoon']
                      .map((String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ))
                      .toList(),
                  onChanged: (String? value) {
                    // Handle dropdown selection if needed
                  },
                  hint: Text('Select Time', style: TextStyle(color: Colors.white),),
                ),
              ],
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
                ),
                RideCard(
                  from: 'From 2',
                  to: 'To 2',
                  driverName: 'Driver 2',
                  car: 'Car 2',
                  price: 'Price 2',
                ),
                RideCard(
                  from: 'From 3',
                  to: 'To 3',
                  driverName: 'Driver 3',
                  car: 'Car 3',
                  price: 'Price 3',
                ),
                RideCard(
                  from: 'From 4',
                  to: 'To 4',
                  driverName: 'Driver 4',
                  car: 'Car 4',
                  price: 'Price 4',
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Navigate to order tracking page
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => OrderTrackingPage()));
            },
            child: Icon(Icons.history),
            tooltip: 'Order Tracking',
            backgroundColor: Color(0xFF495159), // Match the login page color
          ),
          SizedBox(height: 16.0),
          Text(
            'Order Tracking',
            style: TextStyle(fontSize: 16.0, color: Colors.white), // Match the login page color
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

  RideCard({
    required this.from,
    required this.to,
    required this.driverName,
    required this.car,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(

        color:Color(0xDFE0E2) ,
        border: Border.all(
          color: Colors.white, // Set the border color to white
          width: 2.0, // Set the border width
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Card(
        elevation: 0,
        color: Color(0xDFE0E2),
        child: ListTile(
          title: Text('$from to $to', style: TextStyle(fontSize: 18,color: Color(0xFF73C2BE))),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Driver: $driverName', style: TextStyle(fontSize: 15,color: Colors.white),),
              Text('Car: $car', style: TextStyle(fontSize: 15,color: Colors.white),),
              Text('Price: $price', style: TextStyle(fontSize: 15,color: Colors.white),),
            ],
          ),
        ),
      ),
    );
  }
}
