import 'package:flutter/material.dart';
import 'package:my_project/Profile.dart';
import 'OrderTracking.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final database = FirebaseDatabase.instance.reference();
  List<RideData> rides = []; // List to store ride data

  @override
  void initState() {
    super.initState();
    // Fetch ride data from the database when the widget is initialized
    fetchRides();
  }

  void fetchRides() {
    database.child('Rides').once().then((DatabaseEvent event) {
      if (event.snapshot.value != null) {
        // Clear existing rides
        rides.clear();
        // Iterate through the fetched rides and add them to the list
        Map<dynamic, dynamic>? ridesMap = event.snapshot.value as Map?;
        if (ridesMap != null) {
          ridesMap.forEach((key, value) {
            rides.add(RideData.fromMap(value));
          });
        }
        // Update the widget state to rebuild with the fetched ride data
        setState(() {});
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF495159),
      appBar: AppBar(
        title: Text(
          'Rides',
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
                  hint: Text(
                    'Select Time',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rides.length,
              itemBuilder: (context, index) {
                // Build RideCard for each ride in the list
                return RideCard(
                  car: rides[index].car,
                  destination: rides[index].destination,
                  driverId: rides[index].driverId,
                  period: rides[index].period,
                  price: rides[index].price,
                  source: rides[index].source,
                );
              },
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OrderTrackingPage()),
              );
            },
            child: Icon(Icons.history),
            tooltip: 'Order Tracking',
            backgroundColor: Color(0xFF495159),
          ),
          SizedBox(height: 16.0),
          Text(
            'Order Tracking',
            style: TextStyle(fontSize: 16.0, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final String car;
  final String destination;
  final String driverId;
  final String period;
  final String price;
  final String source;

  RideCard({
    required this.car,
    required this.destination,
    required this.driverId,
    required this.period,
    required this.price,
    required this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Color(0xDFE0E2),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Card(
        elevation: 0,
        color: Color(0xDFE0E2),
        child: ListTile(
          title: Text(
            'Driver: $driverId',
            style: TextStyle(fontSize: 18, color: Color(0xFF73C2BE)),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Car: $car',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              Text(
                'Source: $source',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              Text(
                'Destination: $destination',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              Text(
                'Period: $period',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              Text(
                'Price: $price',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RideData {
  final String car;
  final String destination;
  final String driverId;
  final String period;
  final String price;
  final String source;

  RideData({
    required this.car,
    required this.destination,
    required this.driverId,
    required this.period,
    required this.price,
    required this.source,
  });

  // Factory method to create RideData from a Map
  factory RideData.fromMap(Map<dynamic, dynamic> map) {
    return RideData(
      car: map['car'] ?? '',
      destination: map['destination'] ?? '',
      driverId: map['driverId'] ?? '',
      period: map['period'] ?? '',
      price: map['price'] ?? '',
      source: map['source'] ?? '',
    );
  }
}
