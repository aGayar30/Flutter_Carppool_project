import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_project/Profile.dart';
import 'OrderTracking.dart';
import 'package:firebase_database/firebase_database.dart';
import 'auth.dart';
import 'RideDetailsPage.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final database = FirebaseDatabase.instance.reference();
  List<RideData> rides = []; // List to store ride data
  String? selectedPeriod;
  final auth = Auth();

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
        String driverGrade = await fetchDriverGrade(driverId);
        String driverPhoneNumber = await fetchDriverPhoneNumber(driverId);

        // Check if the ride's period matches the selected period
        if (selectedPeriod == null || entry.value['period'] == selectedPeriod) {
          rides.add(RideData.fromMap(
            entry.value,
            driverName,
            driverGrade,
            driverPhoneNumber,
            entry.key,
            driverId,
          ));

        }
      }));

      // Update the widget state to rebuild with the fetched ride data
      setState(() {});
    }
  }



  Future<String> fetchDriverName(String driverId) async {
    DatabaseEvent dataSnapshot = await database.child('Users').child(driverId).child('name').once();
    return dataSnapshot.snapshot.value.toString();
  }

  Future<String> fetchDriverGrade(String driverId) async {
    DatabaseEvent dataSnapshot =
    await database.child('Users').child(driverId).child('grade').once();
    return dataSnapshot.snapshot.value.toString();
  }

  Future<String> fetchDriverPhoneNumber(String driverId) async {
    DatabaseEvent dataSnapshot =
    await database.child('Users').child(driverId).child('phoneNumber').once();
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
              Navigator.push(
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
                // Handle dropdown selection
                setState(() {
                  selectedPeriod = value;
                  fetchRides();
                });
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
                  ride: RideData(
                    car: rides[index].car,
                    destination: rides[index].destination,
                    driverName: rides[index].driverName,
                    period: rides[index].period,
                    price: rides[index].price,
                    source: rides[index].source,
                    driverGrade: rides[index].driverGrade,
                    driverPhoneNumber: rides[index].driverPhoneNumber,
                    rideID: rides[index].rideID,
                    driverID: rides[index].driverID,
                    date: rides[index].date
                  ),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OrderTrackingPage(currentUserId: auth.currentUser?.uid, database: database,)),
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
  final RideData ride;
  final auth = Auth();
  final  DateFormat dateFormat = DateFormat('dd/MM/yyyy');


  RideCard({
    required this.car,
    required this.destination,
    required this.driverName, // Change to driverName
    required this.period,
    required this.price,
    required this.source,
    required this.ride,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to RideDetailsPage and pass the ride details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RideDetailsPage(ride: ride, currentUserId: auth.currentUser?.uid,),
          ),
        );
      },
      child: Container(
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
              'Driver: $driverName',
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
                  'Date: ${dateFormat.format(ride.date)}',
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
      ),
    );
  }
}


class RideData {
  final String rideID;
  final String car;
  final String destination;
  final String driverID;
  final String driverName;
  final String period;
  final String price;
  final String source;
  final String driverGrade;
  final String driverPhoneNumber;
  final DateTime date;

  RideData({
    required this.rideID,
    required this.car,
    required this.destination,
    required this.driverID,
    required this.driverName,
    required this.period,
    required this.price,
    required this.source,
    required this.driverGrade,
    required this.driverPhoneNumber,
    required this.date
  });

  // Factory method to create RideData from a Map
  factory RideData.fromMap(Map<dynamic, dynamic> map, String driverName, String driverGrade, String driverPhoneNumber, String rideID, String driverID) {
    return RideData(
      rideID: rideID,
      car: map['car'] ?? '',
      destination: map['destination'] ?? '',
      driverID: driverID,
      driverName: driverName,
      period: map['period'] ?? '',
      price: map['price'] ?? '',
      source: map['source'] ?? '',
      driverGrade: driverGrade,
      driverPhoneNumber: driverPhoneNumber,
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(), // Parse date from the map
    );
  }
}
