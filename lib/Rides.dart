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

  void fetchRides() async {
    final event = await database.child('Rides').once();

    if (event.snapshot.value != null) {
      final ridesMap = event.snapshot.value as Map<dynamic, dynamic>;

      // Clear existing rides
      rides.clear();

      // Use Future.wait to wait for all asynchronous calls
      await Future.wait(ridesMap.entries.map((entry) async {
        String driverId = entry.value['driverId'];
        String driverName = await fetchDriverName(driverId);
        rides.add(RideData.fromMap(entry.value, driverName));
      }));

      // Update the widget state to rebuild with the fetched ride data
      setState(() {});
    }
  }


  Future<String> fetchDriverName(String driverId) async {
    DatabaseEvent dataSnapshot = await database.child('Users').child(driverId).child('name').once();
    return dataSnapshot.snapshot.value.toString();
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
                  driverName: rides[index].driverName,
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
  final String driverName; // Change to driverName
  final String period;
  final String price;
  final String source;

  RideCard({
    required this.car,
    required this.destination,
    required this.driverName, // Change to driverName
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
            'Driver: $driverName', // Change to driverName
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
  final String driverName; // Change to driverName
  final String period;
  final String price;
  final String source;

  RideData({
    required this.car,
    required this.destination,
    required this.driverName, // Change to driverName
    required this.period,
    required this.price,
    required this.source,
  });

  // Factory method to create RideData from a Map
  factory RideData.fromMap(Map<dynamic, dynamic> map, String driverName) {
    return RideData(
      car: map['car'] ?? '',
      destination: map['destination'] ?? '',
      driverName: driverName, // Update to use driverName
      period: map['period'] ?? '',
      price: map['price'] ?? '',
      source: map['source'] ?? '',
    );
  }
}

